import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'orientation_event.dart';
import 'rotation_sensor_method_channel.dart';
import 'rotation_sensor_unsupported.dart';
import 'sensor_interval.dart';

/// The interface that implementations of rotation_sensor must implement.
abstract class RotationSensorPlatform extends PlatformInterface {
  /// Constructs a RotationSensorPlatform.
  RotationSensorPlatform() : super(token: _token) {
    logger = Logger(runtimeType.toString());
  }

  static final Object _token = Object();

  /// The [RotationSensorPlatform] for current platform.
  static RotationSensorPlatform? _instance;

  static RotationSensorPlatform get instance {
    if (_instance != null) return _instance!;
    return createPlatformInstance();
  }

  static set instance(RotationSensorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  @visibleForTesting
  static RotationSensorPlatform createPlatformInstance() {
    if (RotationSensorMethodChannel.isPlatformSupported) {
      return instance = RotationSensorMethodChannel();
    }
    return instance = RotationSensorUnsupported();
  }

  @protected
  late final Logger logger;

  /// A broadcast [Stream] of [OrientationEvent]s which emits events containing
  /// the orientation of the device from the device's rotation sensor.
  Stream<OrientationEvent> get orientationStream;

  @protected
  int samplingMicroseconds = SensorInterval.normalInterval.inMicroseconds;

  /// The [samplingPeriod] for the device's rotation sensor. The events may
  /// arrive at a rate faster or slower than the [samplingPeriod], which is only
  /// a hint to the system. The actual rate depends on the system's event queue
  /// and sensor hardware capabilities.
  ///
  /// Defaults to [SensorInterval.normalInterval]. It can be set to other
  /// predefined [SensorInterval] values or any [Duration] as needed to suit
  /// different use cases such as gaming or UI responsiveness. When changing
  /// this value, all existing listeners will be affected.
  Duration get samplingPeriod => Duration(microseconds: samplingMicroseconds);

  set samplingPeriod(Duration value) {
    samplingMicroseconds = value.inMicroseconds;
    if (samplingMicroseconds >= 1 && samplingMicroseconds <= 3) {
      logger.warning(
        'The sampling period is currently set to $samplingMicrosecondsμs, '
        'which is a reserved value in Android. Please consider changing it to '
        // ignore: missing_whitespace_between_adjacent_strings
        'either 0 or 4μs. See https://developer.android.com/reference/android/'
        'hardware/SensorManager#registerListener(android.hardware.'
        'SensorEventListener,%20android.hardware.Sensor,%20int) for more '
        'information.',
      );
      samplingMicroseconds = 0;
    }
    updateSamplingPeriod(samplingMicroseconds);
  }

  @protected
  void updateSamplingPeriod(int value) {
    // no-op
  }
}
