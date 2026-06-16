import Flutter
import UIKit
import CoreMotion

public class FlutterRotationSensorPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  private var eventChannel: FlutterEventChannel
  private let motionManager: CMMotionManager
  private var referenceFrame: CMAttitudeReferenceFrame = .xArbitraryZVertical
  private var eventSink: FlutterEventSink?

  // CoreMotion expresses a north reference frame as (north, west, up), while
  // this plugin's world convention is (east, north, up) like Android. The two
  // differ by a fixed 90° rotation about the vertical axis, applied to the
  // attitude quaternion so the azimuth stays 0 = north on every platform.
  private let northToEastNorthUp = 0.7071067811865476 // sin(45°) = cos(45°)

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
      let args = call.arguments as? [String: Any]
      if let samplingPeriod = args?["samplingPeriod"] as? Double {
        motionManager.deviceMotionUpdateInterval = samplingPeriod * 0.000001
      }
      updateReferenceFrame(args?["referenceFrame"] as? String)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func updateReferenceFrame(_ name: String?) {
    let newFrame = attitudeReferenceFrame(from: name)
    guard newFrame != referenceFrame else { return }
    referenceFrame = newFrame
    if motionManager.isDeviceMotionActive, let sink = eventSink {
      motionManager.stopDeviceMotionUpdates()
      startUpdates(sink)
    }
  }

  private func attitudeReferenceFrame(from name: String?) -> CMAttitudeReferenceFrame {
    switch name {
    case "magneticNorth": return .xMagneticNorthZVertical
    case "trueNorth": return .xTrueNorthZVertical
    default: return .xArbitraryZVertical
    }
  }

  private func isNorthReferenced(_ frame: CMAttitudeReferenceFrame) -> Bool {
    return frame == .xMagneticNorthZVertical || frame == .xTrueNorthZVertical
  }

  private func startUpdates(_ events: @escaping FlutterEventSink) {
    let correctToEastNorthUp = isNorthReferenced(referenceFrame)
    motionManager.startDeviceMotionUpdates(using: referenceFrame, to: OperationQueue()) { (motion, error) in
      guard let motion = motion, error == nil else {
        events(FlutterError(code: "UNAVAILABLE", message: "Device motion updates unavailable", details: nil))
        return
      }

      let q = motion.attitude.quaternion
      let k = self.northToEastNorthUp
      let qx = correctToEastNorthUp ? k * (q.x - q.y) : q.x
      let qy = correctToEastNorthUp ? k * (q.x + q.y) : q.y
      let qz = correctToEastNorthUp ? k * (q.z + q.w) : q.z
      let qw = correctToEastNorthUp ? k * (q.w - q.z) : q.w

      let rotationVector = [qx, qy, qz, qw, -1.0, Int64((motion.timestamp * 1000000000).rounded())] as [Any]
      DispatchQueue.main.async {
        events(rotationVector)
      }
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    guard motionManager.isDeviceMotionAvailable else {
      return FlutterError(code: "NO_SENSOR", message: "Rotation vector sensor unavailable", details: nil)
    }
    eventSink = events
    startUpdates(events)
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    motionManager.stopDeviceMotionUpdates()
    eventSink = nil
    return nil
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    eventChannel.setStreamHandler(nil)
  }
}
