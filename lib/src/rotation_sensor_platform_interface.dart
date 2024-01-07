import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'orientation_event.dart';
import 'rotation_sensor_method_channel.dart';
import 'sensor_interval.dart';

/// The interface that implementations of rotation_sensor must implement.
abstract class RotationSensorPlatform extends PlatformInterface {
  /// Constructs a RotationSensorPlatform.
  RotationSensorPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The default instance of [RotationSensorPlatform] to use.
  static RotationSensorPlatform _instance = MethodChannelRotationSensor();

  static RotationSensorPlatform get instance => _instance;

  static set instance(RotationSensorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

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
  Stream<OrientationEvent> getOrientationStream({Duration? samplingPeriod}) {
    throw UnimplementedError(
      'getOrientationStream() has not been implemented.',
    );
  }
}
