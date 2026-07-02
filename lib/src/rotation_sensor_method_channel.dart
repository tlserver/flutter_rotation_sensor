import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'environment.dart';
import 'math/quaternion.dart';
import 'orientation_event.dart';
import 'rotation_sensor_platform.dart';

/// An implementation of [RotationSensorPlatform] that uses method channels.
class RotationSensorMethodChannel extends RotationSensorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  static const methodChannel = MethodChannel('rotation_sensor/method');

  /// The event channel used to receive orientation events from the native
  /// platform.
  @visibleForTesting
  static const eventChannel = EventChannel('rotation_sensor/orientation');

  /// Determines whether the current platform is supported.
  static bool get isPlatformSupported =>
      !isWeb &&
      [
        TargetPlatform.android,
        TargetPlatform.iOS,
      ].contains(defaultTargetPlatform);

  Stream<OrientationEvent>? _orientationStream;

  /// A broadcast [Stream] of [OrientationEvent]s which emits events containing
  /// the orientation of the device from the device's rotation sensor.
  @override
  Stream<OrientationEvent> get orientationStream {
    if (_orientationStream != null) {
      return _orientationStream!;
    }
    setSamplingPeriod();
    setReferenceFrame();
    final broadcastStream = eventChannel.receiveBroadcastStream();
    return _orientationStream = broadcastStream.map(_onData);
  }

  OrientationEvent _onData(dynamic event) {
    final data = event as List<dynamic>;
    return transform(
      OrientationEvent(
        quaternion: Quaternion(data[0], data[1], data[2], data[3]),
        accuracy: data[4],
        timestamp: data[5],
      ),
      // Core Motion uses a world frame with X = north and Z = up.
      isXConvention:
          defaultTargetPlatform == TargetPlatform.iOS &&
          (referenceFrame == .magneticNorth || referenceFrame == .trueNorth),
    );
  }

  @override
  @protected
  void setSamplingPeriod() {
    methodChannel.invokeMethod('setSamplingPeriod', samplingMicroseconds);
  }

  @override
  @protected
  void setReferenceFrame() {
    methodChannel.invokeMethod('setReferenceFrame', referenceFrame.name);
  }
}
