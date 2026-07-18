import 'dart:js_interop';
import 'dart:math' show pi;

import 'package:web/web.dart';

import 'math/euler_angles.dart';
import 'orientation_event.dart';
import 'rotation_sensor_platform.dart';
import 'rotation_sensor_web_events.dart';

/// A web implementation of the [RotationSensorPlatform].
class RotationSensorWebEventsWebkit extends RotationSensorWebEvents {
  late final JSFunction _onDataJS = onData.toJS;

  @override
  void setSamplingPeriod() {
    log(
      'Changing the sampling period is not supported on this browser.',
      level: .warning,
    );
  }

  @override
  void subscribe() {
    super.subscribe();
    window.addEventListener('deviceorientation', _onDataJS);
  }

  @override
  void unsubscribe() {
    super.unsubscribe();
    window.removeEventListener('deviceorientation', _onDataJS);
  }

  @override
  void onData(DeviceOrientationEvent event) {
    event = event as WebkitDeviceOrientationEvent;
    super.onData(event);
    late final num? accuracy;
    late final num? alpha;
    if (absolute) {
      alpha = event.webkitCompassHeading;
      accuracy = event.webkitCompassAccuracy;
    } else {
      final a = event.alpha;
      alpha = a != null ? (360 - a) % 360 : null;
      accuracy = null;
    }
    final beta = event.beta;
    final gamma = event.gamma;
    if (alpha != null && beta != null && gamma != null) {
      final timestamp = event.timeStamp;
      _handleData(alpha, beta, gamma, accuracy, timestamp);
    }
  }

  void _handleData(
    num alpha,
    num beta,
    num gamma,
    num? accuracy,
    num timestamp,
  ) {
    const ratio = pi / 180;
    final azimuth = alpha * ratio;
    final pitch = beta * ratio;
    final roll = gamma * ratio;
    final eulerAngles = EulerAngles(azimuth, pitch, roll);
    streamController.add(
      transform(
        OrientationEvent(
          quaternion: eulerAngles.toQuaternion(),
          accuracy: accuracy != null ? accuracy * ratio : -1,
          timestamp: (timestamp * 1_000_000).toInt(),
        ),
      ),
    );
  }
}

extension type WebkitDeviceOrientationEvent._(DeviceOrientationEvent _)
    implements DeviceOrientationEvent {
  WebkitDeviceOrientationEvent(DeviceOrientationEvent event) : _ = event;

  /// A direction that is measured in degrees relative to magnetic north.
  ///
  /// Direction values are measured in degrees starting at due north and
  /// continuing clockwise around the compass. Thus, north is 0 degrees, east is
  /// 90 degrees, south is 180 degrees, and so on. A negative value indicates an
  /// invalid direction.
  external num? get webkitCompassHeading;

  /// The accuracy of the compass data in degrees.
  ///
  /// For example, if this property value is 10, the heading is off by plus or
  /// minus 10 degrees. A value of -1 means that the compass is not calibrated
  /// and not giving usable readings.
  external num? get webkitCompassAccuracy;
}
