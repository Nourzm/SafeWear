import Foundation
import HealthKit
import CoreMotion
import WatchConnectivity

// Reads heart rate and motion data from the Apple Watch.
// Sends emergency signals to the Flutter iOS app via WatchConnectivity.
class SensorManager: NSObject, ObservableObject {

    private let healthStore = HKHealthStore()
    private let motionManager = CMMotionManager()
    private let session = WCSession.default

    @Published var currentHeartRate: Double = 0
    @Published var fallDetected = false
    @Published var inGreyZone = false

    private let greyZoneLow = 110.0
    private let greyZoneHigh = 130.0
    private let fallImpactThreshold = 3.0  // g-force
    private let fallInactivitySeconds = 10.0

    private var lastImpactTime: Date?
    private var impactCheckTimer: Timer?

    func start() {
        requestHealthKitPermission()
        setupWatchConnectivity()
        startMotionTracking()
    }

    private func requestHealthKitPermission() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: [], read: [hrType]) { [weak self] granted, _ in
            if granted { self?.startHeartRateMonitoring() }
        }
    }

    private func startHeartRateMonitoring() {
        let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKObserverQuery(sampleType: hrType, predicate: nil) { [weak self] _, _, error in
            if error != nil { return }
            self?.fetchLatestHeartRate()
        }
        healthStore.execute(query)

        // Also poll every 5 seconds for real-time HR during an alert
        let anchor = HKQueryAnchor.init(fromValue: 0)
        let anchoredQuery = HKAnchoredObjectQuery(
            type: hrType,
            predicate: nil,
            anchor: anchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            self?.processSamples(samples)
        }
        anchoredQuery.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.processSamples(samples)
        }
        healthStore.execute(anchoredQuery)
    }

    private func fetchLatestHeartRate() {
        let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: hrType, predicate: nil, limit: 1, sortDescriptors: [sort]) {
            [weak self] _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async { self?.processHeartRate(bpm) }
        }
        healthStore.execute(query)
    }

    private func processSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample], let latest = samples.last else { return }
        let bpm = latest.quantity.doubleValue(for: HKUnit(from: "count/min"))
        DispatchQueue.main.async { self.processHeartRate(bpm) }
    }

    private func processHeartRate(_ bpm: Double) {
        currentHeartRate = bpm
        inGreyZone = bpm >= greyZoneLow && bpm <= greyZoneHigh

        let payload: [String: Any] = [
            "heartRate": bpm,
            "inGreyZone": inGreyZone,
            "fallDetected": false,
            "timestamp": Date().timeIntervalSince1970,
        ]
        sendToPhone(payload)
    }

    private func startMotionTracking() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 0.1

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data, error == nil else { return }
            self?.processAccelerometer(data)
        }
    }

    private func processAccelerometer(_ data: CMAccelerometerData) {
        let magnitude = sqrt(
            pow(data.acceleration.x, 2) +
            pow(data.acceleration.y, 2) +
            pow(data.acceleration.z, 2)
        )

        if magnitude > fallImpactThreshold {
            lastImpactTime = Date()
            scheduleFallCheck()
        }
    }

    private func scheduleFallCheck() {
        impactCheckTimer?.invalidate()
        impactCheckTimer = Timer.scheduledTimer(
            withTimeInterval: fallInactivitySeconds,
            repeats: false
        ) { [weak self] _ in
            self?.checkForFall()
        }
    }

    private func checkForFall() {
        // If the watch has been still since the impact — fall confirmed
        guard let _ = lastImpactTime else { return }
        lastImpactTime = nil
        fallDetected = true

        let payload: [String: Any] = [
            "heartRate": currentHeartRate,
            "inGreyZone": false,
            "fallDetected": true,
            "timestamp": Date().timeIntervalSince1970,
        ]
        sendToPhone(payload)
    }

    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
    }

    private func sendToPhone(_ payload: [String: Any]) {
        guard session.isReachable else {
            // Phone not reachable — transfer when it becomes available
            session.transferUserInfo(payload)
            return
        }
        session.sendMessage(payload, replyHandler: nil)
    }
}

extension SensorManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // Phone can send commands to watch — e.g., vibrate during active alert
        if let command = message["command"] as? String {
            if command == "vibrate_alert" {
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }
}
