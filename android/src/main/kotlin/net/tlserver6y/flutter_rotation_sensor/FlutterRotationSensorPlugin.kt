package net.tlserver6y.flutter_rotation_sensor

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterRotationSensorPlugin : FlutterPlugin, MethodCallHandler, StreamHandler {
  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var sensorManager: SensorManager
  private var sensor: Sensor? = null
  private var sensorEventListener: SensorEventListener? = null
  private var samplingPeriod = 200000

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val context = flutterPluginBinding.applicationContext
    sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
    setupMethodChannel(flutterPluginBinding.binaryMessenger)
    setupEventChannel(flutterPluginBinding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    teardownMethodChannel()
    teardownEventChannels()
  }

  private fun setupMethodChannel(messenger: BinaryMessenger) {
    methodChannel = MethodChannel(messenger, "rotation_sensor/method")
    methodChannel.setMethodCallHandler(this)
  }

  private fun teardownMethodChannel() {
    methodChannel.setMethodCallHandler(null);
  }

  private fun setupEventChannel(messenger: BinaryMessenger) {
    eventChannel = EventChannel(messenger, "rotation_sensor/orientation")
    eventChannel.setStreamHandler(this)
  }

  private fun teardownEventChannels() {
    eventChannel.setStreamHandler(null)
    onCancel(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getOrientationStream" -> {
        if (call.hasArgument("samplingPeriod")) {
          val samplingPeriod = call.argument<Int?>("samplingPeriod")
          if (
            samplingPeriod != null &&
            samplingPeriod != this.samplingPeriod &&
            sensorEventListener != null
          ) {
            this.samplingPeriod = samplingPeriod
            sensorManager.unregisterListener(sensorEventListener)
            sensorManager.registerListener(sensorEventListener, sensor, samplingPeriod)
          }
        }
        result.success(null);
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onListen(arguments: Any?, events: EventSink) {
    if (sensor != null) {
      sensorEventListener = createSensorEventListener(events)
      sensorManager.registerListener(sensorEventListener, sensor, samplingPeriod)
    } else {
      events.error(
        "NO_SENSOR",
        "Sensor not found",
        "It seems that your device has no rotation vector sensor"
      )
    }
  }

  override fun onCancel(arguments: Any?) {
    if (sensor != null) {
      sensorEventListener?.let {
        sensorManager.unregisterListener(it)
        sensorEventListener = null
      }
    }
  }

  private fun createSensorEventListener(events: EventSink): SensorEventListener {
    return object : SensorEventListener {
      override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}

      override fun onSensorChanged(event: SensorEvent) {

        val rotationMatrix = FloatArray(9)
        SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)

        val orientation = FloatArray(3)
        SensorManager.getOrientation(rotationMatrix, orientation)

        val sensorValues = arrayListOf(
          event.values[0].toDouble(),
          event.values[1].toDouble(),
          event.values[2].toDouble(),
          event.values[3].toDouble(),
          event.values[4].toDouble(),
          event.timestamp,
        )
        events.success(sensorValues)
      }
    }
  }
}
