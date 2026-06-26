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

class FlutterRotationSensorPlugin : FlutterPlugin, MethodCallHandler, SensorEventListener,
  StreamHandler {
  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var sensorManager: SensorManager
  private var eventSink: EventSink? = null
  private var sensor: Sensor? = null
  private var samplingPeriod = 200000
  private var sensorType = Sensor.TYPE_ROTATION_VECTOR

  // === FlutterPlugin ===

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val context = flutterPluginBinding.applicationContext
    sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
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

  // === MethodCallHandler ===

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "setSamplingPeriod" -> {
        val samplingPeriod = call.arguments as? Int ?: run {
          return result.error(
            "INVALID_ARGUMENTS",
            "Int samplingPeriod is required",
            null
          )
        }
        setSamplingPeriod(samplingPeriod)
        return result.success(null)
      }
      "setReferenceFrame" -> {
        val referenceFrame = call.arguments as? String ?: run {
          return result.error(
            "INVALID_ARGUMENTS",
            "String referenceFrame is required",
            null
          )
        }
        setReferenceFrame(referenceFrame)
        result.success(null);
      }
      else -> result.notImplemented()
    }
  }

  private fun setSamplingPeriod(samplingPeriod: Int) {
    if (samplingPeriod == this.samplingPeriod) return
    this.samplingPeriod = samplingPeriod
    resubscribe()
  }

  private fun setReferenceFrame(referenceFrame: String) {
    val sensorType = when (referenceFrame) {
      "arbitrary", "arbitraryCorrected" -> Sensor.TYPE_GAME_ROTATION_VECTOR
      "magneticNorth", "trueNorth" -> Sensor.TYPE_ROTATION_VECTOR
      else -> Sensor.TYPE_ROTATION_VECTOR
    }
    if (sensorType == this.sensorType) return
    this.sensorType = sensorType
    resubscribe()
  }

  // === SensorEventListener ===

  override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}

  override fun onSensorChanged(event: SensorEvent) {
    eventSink?.success(
      arrayListOf(
        event.values[0].toDouble(),
        event.values[1].toDouble(),
        event.values[2].toDouble(),
        event.values[3].toDouble(),
        // Estimated heading accuracy may not exist.
        event.values.getOrElse(4, { -1.0f }).toDouble(),
        event.timestamp,
      )
    )
  }

  // === StreamHandler ===

  override fun onListen(arguments: Any?, events: EventSink) {
    eventSink = events
    subscribe()
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
    unsubscribe()
  }

  private fun noListeners(): Boolean = eventSink == null

  private fun defaultSensor(): Sensor? {
    val sensor = this.sensor
    val sensorType = this.sensorType
    if (sensor?.type == sensorType) return sensor
    return sensorManager.getDefaultSensor(sensorType)?.also {
      this.sensor = it
    } ?: run {
      eventSink?.error(
        "UNAVAILABLE",
        "Sensor not found",
        "It seems that your device has no ${
          when (sensorType) {
            Sensor.TYPE_ROTATION_VECTOR -> "rotation vector sensor"
            Sensor.TYPE_GAME_ROTATION_VECTOR -> "game rotation vector sensor"
            else -> "needed sensor"
          }
        }."
      )
      null
    }
  }

  private fun subscribe() {
    defaultSensor()?.let {
      sensorManager.registerListener(this, it, samplingPeriod)
    }
  }

  private fun unsubscribe() {
    sensorManager.unregisterListener(this)
  }

  private fun resubscribe() {
    if (noListeners()) return
    unsubscribe()
    subscribe()
  }
}
