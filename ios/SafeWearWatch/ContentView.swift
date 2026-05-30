import SwiftUI
import WatchKit

// Main watch UI: status indicator + SOS button + active alert countdown
struct ContentView: View {
    @StateObject private var sensorManager = SensorManager()
    @State private var showingAlert = false
    @State private var countdownSeconds = 20
    @State private var alertActive = false
    @State private var countdownTimer: Timer?

    var body: some View {
        ZStack {
            if alertActive {
                ActiveAlertView(onResolve: resolveAlert)
            } else if showingAlert {
                CountdownView(
                    secondsLeft: countdownSeconds,
                    onCancel: cancelAlert
                )
            } else {
                StatusView(
                    heartRate: sensorManager.currentHeartRate,
                    inGreyZone: sensorManager.inGreyZone,
                    onSOSTap: startSOSCountdown
                )
            }
        }
        .onReceive(sensorManager.$fallDetected) { detected in
            if detected && !showingAlert {
                startSOSCountdown()
            }
        }
    }

    private func startSOSCountdown() {
        WKInterfaceDevice.current().play(.notification)
        showingAlert = true
        countdownSeconds = 20

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdownSeconds > 0 {
                countdownSeconds -= 1
            } else {
                timer.invalidate()
                showingAlert = false
                alertActive = true
                sendAlertToPhone()
            }
        }
    }

    private func cancelAlert() {
        countdownTimer?.invalidate()
        showingAlert = false
        countdownSeconds = 20
        WKInterfaceDevice.current().play(.success)
    }

    private func resolveAlert() {
        alertActive = false
        WKInterfaceDevice.current().play(.success)
    }

    private func sendAlertToPhone() {
        // WCSession sends emergency trigger to Flutter iOS app via platform channel
        WKInterfaceDevice.current().play(.failure)
    }
}

struct StatusView: View {
    let heartRate: Double
    let inGreyZone: Bool
    let onSOSTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                Text("\(Int(heartRate)) bpm")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if inGreyZone {
                Text("CAUTION")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
            }

            Spacer()

            Button(action: onSOSTap) {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 80, height: 80)
                    Text("SOS")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)

            Text("SafeWear")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct CountdownView: View {
    let secondsLeft: Int
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            VStack(spacing: 8) {
                Text("ALERT IN")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Text("\(secondsLeft)")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundColor(.white)
                Button("Cancel", action: onCancel)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
            }
        }
    }
}

struct ActiveAlertView: View {
    let onResolve: () -> Void

    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                Text("ALERT SENT")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Contacts notified")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Button("I'm Safe", action: onResolve)
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
            }
        }
    }
}
