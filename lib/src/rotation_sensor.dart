import 'package:meta/meta.dart';

import 'coordinate_system.dart';
import 'orientation_event.dart';
import 'rotation_sensor_method_channel.dart';
import 'rotation_sensor_platform.dart';
import 'sensor_interval.dart';

/// Provides access to the device's rotation sensor, offering a real-time stream
/// of the device's orientation.
///
/// This class allows applications to retrieve a stream of [OrientationEvent]s
/// which include the device's orientation represented as a rotation matrix,
/// quaternion, and Euler angles (azimuth, pitch, roll).
@sealed
class RotationSensor {
  /// Determines whether the current platform is supported.
  static bool get isPlatformSupported =>
      RotationSensorMethodChannel.isPlatformSupported;

  /// A broadcast [Stream] of [OrientationEvent]s which emits events containing
  /// the orientation of the device from the device's rotation sensor.
  static Stream<OrientationEvent> get orientationStream =>
      RotationSensorPlatform.instance.orientationStream;

  /// The [samplingPeriod] for the device's rotation sensor. The events may
  /// arrive at a rate faster or slower than the [samplingPeriod], which is only
  /// a hint to the system. The actual rate depends on the system's event queue
  /// and sensor hardware capabilities.
  ///
  /// Defaults to [SensorInterval.normalInterval]. It can be set to other
  /// predefined [SensorInterval] values or any [Duration] as needed to suit
  /// different use cases such as gaming or UI responsiveness. When changing
  /// this value, all existing listeners will be affected.
  static Duration get samplingPeriod =>
      RotationSensorPlatform.instance.samplingPeriod;

  static set samplingPeriod(Duration value) =>
      RotationSensorPlatform.instance.samplingPeriod = value;

  /// The [coordinateSystem] used for upcoming [OrientationEvent].
  ///
  /// Defaults to [DisplayCoordinateSystem]. When changing this value, all
  /// existing listeners will receive [OrientationEvent] in the new coordinate
  /// system.
  static CoordinateSystem coordinateSystem = DisplayCoordinateSystem();
}
