import 'environment.dart';
import 'rotation_sensor_platform.dart';

/// A web implementation of the [RotationSensorPlatform].
abstract class RotationSensorWeb extends RotationSensorPlatform {
  /// Determines whether the current platform is supported.
  static bool get isPlatformSupported => isWeb;
}
