import 'package:flutter/foundation.dart';

import 'environment.dart';
import 'orientation_event.dart';
import 'rotation_sensor_platform.dart';

/// A placeholder implementation of [RotationSensorPlatform] for unsupported
/// platforms. Used as a fallback to indicate that device rotation sensing is
/// not available.
class RotationSensorUnsupported extends RotationSensorPlatform {
  /// Throws an [UnsupportedError] indicating that the rotation sensor is not
  /// supported on the current platform. This getter does not return a
  /// functional stream.
  @override
  Stream<OrientationEvent> get orientationStream {
    final platform = isWeb ? 'web' : defaultTargetPlatform.name;
    throw UnsupportedError(
      'FlutterRotationSensor does not support the $platform platform.',
    );
  }
}
