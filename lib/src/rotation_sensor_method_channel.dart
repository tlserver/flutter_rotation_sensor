import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:vector_math/vector_math.dart';

import 'coordinate_system.dart';
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

  /// A broadcast [Stream] of [OrientationEvent]s which emits events containing
  /// the orientation of the device from the device's rotation sensor.
  Stream<OrientationEvent> get orientationStream {
    if (_orientationStream != null) {
      return _orientationStream!;
    }
    methodChannel.invokeMethod('getOrientationStream', {
      'samplingPeriod': _samplingPeriod,
    });
    return _orientationStream =
        eventChannel.receiveBroadcastStream().map((event) {
      final data = event as List<dynamic>;
      return OrientationEvent(
        quaternion: Quaternion(data[0], data[1], data[2], data[3]),
        accuracy: data[4],
        timestamp: data[5],
      );
    });
  }

  int _samplingPeriod = SensorInterval.normalInterval.inMicroseconds;
  /// The [samplingPeriod] for the device's rotation sensor. The events may
  /// arrive at a rate faster or slower than the [samplingPeriod], which is only
  /// a hint to the system. The actual rate depends on the system's event queue
  /// and sensor hardware capabilities.
  ///
  /// Defaults to [SensorInterval.normalInterval]. It can be set to other
  /// predefined [SensorInterval] values or any [Duration] as needed to suit
  /// different use cases such as gaming or UI responsiveness. When changing
  /// this value, all existing listeners will be affected.
  @override
  Duration get samplingPeriod => Duration(microseconds: _samplingPeriod);
  @override
  set samplingPeriod(Duration value) {
    _samplingPeriod = value.inMicroseconds;
    if (_samplingPeriod >= 1 && _samplingPeriod <= 3) {
      logger.warning(
        'The sampling period is currently set to $_samplingPeriodμs, which is '
        'a reserved value in Android. Please consider changing it to either 0 '
        // ignore: missing_whitespace_between_adjacent_strings
        'or 4μs. See https://developer.android.com/reference/android/hardware/'
        'SensorManager#registerListener(android.hardware.SensorEventListener,'
        '%20android.hardware.Sensor,%20int) for more information.',
      );
      _samplingPeriod = 0;
    }
    methodChannel.invokeMethod('getOrientationStream', {
      'samplingPeriod': _samplingPeriod,
    });
  }

  /// The [coordinateSystem] used for upcoming [OrientationEvent].
  ///
  /// Defaults to [DisplayCoordinateSystem]. When changing this value, all
  /// existing listeners will receive [OrientationEvent] in the new coordinate
  /// system.
  @override
  CoordinateSystem coordinateSystem = CoordinateSystem.display();
}
