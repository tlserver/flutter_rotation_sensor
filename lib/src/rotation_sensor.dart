import 'package:meta/meta.dart';

import 'coordinate_system.dart';
import 'orientation_event.dart';
import 'rotation_sensor_platform_interface.dart';
import 'sensor_interval.dart';

/// Provides access to the device's rotation sensor, offering a real-time stream
/// of the device's orientation.
///
/// This class allows applications to retrieve a stream of [OrientationEvent]s
/// which include the device's orientation represented as a rotation matrix,
/// quaternion, and Euler angles (azimuth, pitch, roll).
@sealed
class RotationSensor {
  @visibleForTesting
  static RotationSensorPlatform platform = RotationSensorPlatform.instance;

  /// Returns a broadcast [Stream] of [OrientationEvent]s which emits events
  /// containing the orientation of the device from the device's rotation
  /// sensor.
  ///
  /// The [samplingPeriod] defaults to [SensorInterval.normalInterval] if not
  /// specified. It can be set to other predefined [SensorInterval] values or
  /// any [Duration] as needed to suit different use cases such as gaming or UI
  /// responsiveness.
  ///
  /// The events may arrive at a rate faster or slower than the
  /// [samplingPeriod], which is only a hint to the system. The actual rate
  /// depends on the system's event queue and sensor hardware capabilities.
  ///
  /// If multiple calls are made to this method, the same stream is returned
  /// each time, allowing only one stream per application. To adjust the
  /// [samplingPeriod], simply call this method again with the new desired
  /// value. All existing listeners will then receive events at the updated
  /// sampling rate.
  static Stream<OrientationEvent> get orientationStream =>
      RotationSensorPlatform.instance.orientationStream;

  static Duration get samplingPeriod =>
      RotationSensorPlatform.instance.samplingPeriod;

  static set samplingPeriod(Duration value) =>
      RotationSensorPlatform.instance.samplingPeriod = value;

  static CoordinateSystem get coordinateSystem =>
      RotationSensorPlatform.instance.coordinateSystem;

  static set coordinateSystem(CoordinateSystem value) =>
      RotationSensorPlatform.instance.coordinateSystem = value;
}
