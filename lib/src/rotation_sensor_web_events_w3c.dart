import 'dart:js_interop';
import 'dart:math' show pi;

import 'package:web/web.dart';

import 'math/euler_angles.dart';
import 'orientation_event.dart';
import 'rotation_sensor_platform.dart';
import 'rotation_sensor_web_events.dart';

/// A web implementation of the [RotationSensorPlatform].
class RotationSensorWebEventsW3c extends RotationSensorWebEvents {
  late final JSFunction _onDataJS = onData.toJS;

  String? _listeningEvent;

  @override
  void setSamplingPeriod() {
    log('Changing the sampling period is not supported on this browser.');
  }

  @override
  void setReferenceFrame() => _resubscribe();

  @override
  void subscribe({bool ignoreGuard = false}) {
    super.subscribe();
    if (ignoreGuard || _listeningEvent == null) {
      final event = absolute
          ? 'deviceorientationabsolute'
          : 'deviceorientation';
      _listeningEvent = event;
      window.addEventListener(event, _onDataJS);
    }
  }

  @override
  void unsubscribe() {
    super.unsubscribe();
    final listeningEvent = _listeningEvent;
    if (listeningEvent != null) {
      window.removeEventListener(listeningEvent, _onDataJS);
      _listeningEvent = null;
    }
  }

  void _resubscribe() {
    if (_listeningEvent != null) {
      unsubscribe();
      subscribe(ignoreGuard: true);
    }
  }

  @override
  void onData(DeviceOrientationEvent event) {
    super.onData(event);
    final alpha = event.alpha;
    final beta = event.beta;
    final gamma = event.gamma;
    if (alpha != null && beta != null && gamma != null) {
      final timestamp = event.timeStamp;
      _handleData(alpha, beta, gamma, timestamp);
    }
  }

  void _handleData(num alpha, num beta, num gamma, num timestamp) {
    const ratio = pi / 180;
    final azimuth = (360 - alpha) % 360 * ratio;
    final pitch = beta * ratio;
    final roll = gamma * ratio;
    final eulerAngles = EulerAngles(azimuth, pitch, roll);
    streamController.add(
      transform(
        OrientationEvent(
          quaternion: eulerAngles.toQuaternion(),
          accuracy: -1,
          timestamp: (timestamp * 1_000_000).toInt(),
        ),
      ),
    );
  }
}
