import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:vector_math/vector_math.dart';

import 'orientation_event.dart';
import 'rotation_sensor_platform_interface.dart';
import 'sensor_interval.dart';

/// An implementation of [RotationSensorPlatform] that uses method channels.
class MethodChannelRotationSensor extends RotationSensorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('rotation_sensor/method');

  /// The event channel used to receive orientation events from the native
  /// platform.
  @visibleForTesting
  final eventChannel = const EventChannel('rotation_sensor/orientation');

  final logger = Logger('MethodChannelSensors');

  Stream<OrientationEvent>? _orientationStream;

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
  @override
  Stream<OrientationEvent> getOrientationStream({
    Duration? samplingPeriod,
  }) {
    if (samplingPeriod != null || _orientationStream == null) {
      samplingPeriod ??= SensorInterval.normalInterval;
      var microseconds = samplingPeriod.inMicroseconds;
      if (microseconds >= 1 && microseconds <= 3) {
        logger.warning(
          'The SamplingPeriod is currently set to $microsecondsμs, which is a '
          'reserved value in Android. Please consider changing it to either 0 '
          // ignore: missing_whitespace_between_adjacent_strings
          'or 4μs. See https://developer.android.com/reference/android/hardware'
          '/SensorManager#registerListener(android.hardware.'
          'SensorEventListener,%20android.hardware.Sensor,%20int) for more '
          'information.',
        );
        microseconds = 0;
      }
      methodChannel.invokeMethod('getOrientationStream', {
        'samplingPeriod': microseconds,
      });
    }
    _orientationStream ??= eventChannel.receiveBroadcastStream().map((event) {
      final data = event as List<dynamic>;
      return OrientationEvent(
        quaternion: Quaternion(data[0], data[1], data[2], data[3]),
        accuracy: data[4],
        timestamp: data[5],
      );
    });
    return _orientationStream!;
  }
}
