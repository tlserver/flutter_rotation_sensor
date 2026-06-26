import Flutter
import UIKit
import CoreMotion

public class FlutterRotationSensorPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  private var eventChannel: FlutterEventChannel
  private let motionManager: CMMotionManager
  private var eventSink: FlutterEventSink?
  private var referenceFrame: CMAttitudeReferenceFrame = .xMagneticNorthZVertical

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "rotation_sensor/method", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "rotation_sensor/orientation", binaryMessenger: registrar.messenger())
    let motionManager = CMMotionManager()
    motionManager.deviceMotionUpdateInterval = 0.2
    let instance = FlutterRotationSensorPlugin(eventChannel: eventChannel, motionManager: motionManager)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
  }

  public init(eventChannel: FlutterEventChannel, motionManager: CMMotionManager) {
    self.eventChannel = eventChannel
    self.motionManager = motionManager
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    eventChannel.setStreamHandler(nil)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setSamplingPeriod":
      guard let samplingPeriod = call.arguments as? Int32 else {
        result(FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "Int32 samplingPeriod is required",
          details: nil
        ))
        return
      }
      setSamplingPeriod(samplingPeriod)
      result(nil)
    case "setReferenceFrame":
      guard let referenceFrame = call.arguments as? String else {
        result(FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "String referenceFrame is required",
          details: nil
        ))
        return
      }
      setReferenceFrame(referenceFrame)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setSamplingPeriod(_ samplingPeriod: Int32) {
    guard samplingPeriod != Int32((motionManager.deviceMotionUpdateInterval * 1000000).rounded()) else { return }
    motionManager.deviceMotionUpdateInterval = Double(samplingPeriod) * 0.000001
  }

  private func setReferenceFrame(_ referenceFrame: String) {
    let referenceFrame: CMAttitudeReferenceFrame = switch referenceFrame {
    case "arbitrary": .xArbitraryZVertical
    case "arbitraryCorrected": .xArbitraryCorrectedZVertical
    case "magneticNorth": .xMagneticNorthZVertical
    case "trueNorth": .xTrueNorthZVertical
    default: .xMagneticNorthZVertical
    }
    guard referenceFrame != self.referenceFrame else { return }
    self.referenceFrame = referenceFrame
    resubscribe()
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    subscribe()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    unsubscribe()
    return nil
  }

  private func noListeners() -> Bool { eventSink == nil }

  private func handleDeviceMotion(motion: CMDeviceMotion?, error: Error?) {
    guard let motion else {
      if let error {
        eventSink?(FlutterError(code: "UNKNOWN", message: error.localizedDescription, details: nil))
      }
      return
    }
    let quaternion = motion.attitude.quaternion
    let rotationVector: [Any] = [
      quaternion.x,
      quaternion.y,
      quaternion.z,
      quaternion.w,
      -1.0,
      Int64((motion.timestamp * 1000000000).rounded())
    ]
    DispatchQueue.main.async {
      self.eventSink?(rotationVector)
    }
  }

  private func subscribe() {
    guard motionManager.isDeviceMotionAvailable else {
      eventSink?(FlutterError(code: "UNAVAILABLE", message: "Device motion unavailable", details: nil))
      return
    }
    motionManager.startDeviceMotionUpdates(using: referenceFrame, to: OperationQueue(), withHandler: handleDeviceMotion)
  }

  private func unsubscribe() {
    motionManager.stopDeviceMotionUpdates()
  }

  private func resubscribe() {
    if noListeners() { return }
    unsubscribe()
    subscribe()
  }
}
