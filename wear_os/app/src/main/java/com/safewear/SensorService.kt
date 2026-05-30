package com.safewear

import android.app.Service
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.IBinder
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import kotlin.math.sqrt

// Runs continuously on the watch, reading HR + motion sensors.
// Sends data to the phone Flutter app via Wear OS Data Layer API.
class SensorService : Service(), SensorEventListener {

    private lateinit var sensorManager: SensorManager
    private lateinit var dataClient: DataClient

    private var lastHeartRate = 0f
    private val accelBuffer = FloatArray(3)
    private var lastImpactTime = 0L
    private var inactiveAfterImpact = false

    // Thresholds
    private val FALL_IMPACT_G = 3.0f       // impact > 3g triggers fall check
    private val FALL_INACTIVITY_MS = 10_000L  // 10 seconds inactivity after impact
    private val GREY_ZONE_HR_LOW = 110f
    private val GREY_ZONE_HR_HIGH = 130f

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        dataClient = Wearable.getDataClient(this)

        val hrSensor = sensorManager.getDefaultSensor(Sensor.TYPE_HEART_RATE)
        val accelSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        val gyroSensor = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)

        hrSensor?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
        accelSensor?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
        }
        gyroSensor?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
        }

        return START_STICKY
    }

    override fun onSensorChanged(event: SensorEvent) {
        when (event.sensor.type) {
            Sensor.TYPE_HEART_RATE -> handleHeartRate(event.values[0])
            Sensor.TYPE_ACCELEROMETER -> handleAccelerometer(event.values)
        }
    }

    private fun handleHeartRate(bpm: Float) {
        lastHeartRate = bpm
        val now = System.currentTimeMillis()

        // Check grey zone: sustained elevated HR without intense motion
        val inGreyZone = bpm in GREY_ZONE_HR_LOW..GREY_ZONE_HR_HIGH
        sendDataToPhone(
            path = "/sensor_data",
            heartRate = bpm,
            inGreyZone = inGreyZone,
            fallDetected = false,
        )
    }

    private fun handleAccelerometer(values: FloatArray) {
        values.copyInto(accelBuffer)
        val magnitude = sqrt(
            values[0] * values[0] + values[1] * values[1] + values[2] * values[2]
        ) / SensorManager.GRAVITY_EARTH

        if (magnitude > FALL_IMPACT_G) {
            lastImpactTime = System.currentTimeMillis()
            inactiveAfterImpact = true
        }

        // If still inactive 10+ seconds after impact → fall detected
        if (inactiveAfterImpact) {
            val timeSinceImpact = System.currentTimeMillis() - lastImpactTime
            val currentlyMoving = magnitude > 1.2f

            if (currentlyMoving) {
                inactiveAfterImpact = false
            } else if (timeSinceImpact >= FALL_INACTIVITY_MS) {
                inactiveAfterImpact = false
                triggerFallAlert()
            }
        }
    }

    private fun triggerFallAlert() {
        sendDataToPhone(
            path = "/emergency_trigger",
            heartRate = lastHeartRate,
            inGreyZone = false,
            fallDetected = true,
        )
    }

    private fun sendDataToPhone(
        path: String,
        heartRate: Float,
        inGreyZone: Boolean,
        fallDetected: Boolean,
    ) {
        val request = PutDataMapRequest.create(path).apply {
            dataMap.putFloat("heartRate", heartRate)
            dataMap.putBoolean("inGreyZone", inGreyZone)
            dataMap.putBoolean("fallDetected", fallDetected)
            dataMap.putLong("timestamp", System.currentTimeMillis())
        }.asPutDataRequest().setUrgent()

        dataClient.putDataItem(request)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        sensorManager.unregisterListener(this)
        super.onDestroy()
    }
}
