import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'math/quaternion.dart';
import 'orientation_event.dart';
import 'rotation_sensor_platform_interface.dart';

/// An implementation of [RotationSensorPlatform] that uses method channels.
class MethodChannelRotationSensor extends RotationSensorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  static const methodChannel = MethodChannel('rotation_sensor/method');

  /// The event channel used to receive orientation events from the native
  /// platform.
  @visibleForTesting
  static const eventChannel = EventChannel('rotation_sensor/orientation');

  Stream<OrientationEvent>? _orientationStream;

  /// A broadcast [Stream] of [OrientationEvent]s which emits events containing
  /// the orientation of the device from the device's rotation sensor.
  @override
  Stream<OrientationEvent> get orientationStream {
    if (_orientationStream != null) {
      return _orientationStream!;
    }
    methodChannel.invokeMethod('getOrientationStream', {
      'samplingPeriod': samplingMicroseconds,
    });
    final broadcastStream = eventChannel.receiveBroadcastStream();
    return _orientationStream = broadcastStream.map((event) {
      final data = event as List<dynamic>;
      final orientationEvent = OrientationEvent(
        quaternion: Quaternion(data[0], data[1], data[2], data[3]),
        accuracy: data[4],
        timestamp: data[5],
      );
      return coordinateSystem.apply(orientationEvent);
    });
  }

  @override
  @protected
  void updateSamplingPeriod(int value) {
    methodChannel.invokeMethod('getOrientationStream', {
      'samplingPeriod': value,
    });
  }
}
