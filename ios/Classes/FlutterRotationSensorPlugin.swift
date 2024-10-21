import Flutter
import UIKit
import CoreMotion

public class FlutterRotationSensorPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  private var eventChannel: FlutterEventChannel
  private let motionManager: CMMotionManager

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

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getOrientationStream":
      if let args = call.arguments as? [String: Any],
         let samplingPeriod = args["samplingPeriod"] as? Double {
          motionManager.deviceMotionUpdateInterval = samplingPeriod * 0.000001
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      if motionManager.isDeviceMotionAvailable {
        motionManager.startDeviceMotionUpdates(to: OperationQueue()) { (motion, error) in
          guard let motion = motion, error == nil else {
            events(FlutterError(code: "UNAVAILABLE", message: "Device motion updates unavailable", details: nil))
            return
          }

          let quaternion = motion.attitude.quaternion
          let rotationVector = [quaternion.x, quaternion.y, quaternion.z, quaternion.w, -1.0, Int64((motion.timestamp * 1000000000).rounded())]
          DispatchQueue.main.async {
            events(rotationVector)
          }
        }
        return nil
      } else {
        return FlutterError(code: "NO_SENSOR", message: "Rotation vector sensor unavailable", details: nil)
      }
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    motionManager.stopDeviceMotionUpdates()
    return nil
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    eventChannel.setStreamHandler(nil)
  }
}
