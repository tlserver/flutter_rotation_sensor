import 'dart:js_interop';

import 'package:web/web.dart';

import 'exceptions/not_available_exception.dart';
import 'exceptions/permission_denied_exception.dart';
import 'exceptions/security_exception.dart';
import 'math/quaternion.dart';
import 'orientation_event.dart';
import 'rotation_sensor_platform.dart';
import 'rotation_sensor_web.dart';

/// A web implementation of the [RotationSensorPlatform].
class RotationSensorWebSensorApi extends RotationSensorWeb {
  late final JSFunction _onDataJS = _onData.toJS;

  late final JSFunction _onErrorJS = _onError.toJS;

  late OrientationSensor _sensor;

  RotationSensorWebSensorApi() : super() {
    _createSensor();
  }

  OrientationSensor _createSensor() {
    var frequency = Duration(seconds: 1).inMicroseconds / samplingMicroseconds;
    final options = OrientationSensorOptions(
      frequency: frequency.isFinite ? frequency : double.maxFinite,
    );
    return _sensor = switch (referenceFrame) {
      .arbitrary || .arbitraryCorrected => RelativeOrientationSensor(options),
      .magneticNorth || .trueNorth => AbsoluteOrientationSensor(options),
    };
  }

  @override
  void setSamplingPeriod() => _resubscribe();

  @override
  void setReferenceFrame() => _resubscribe();

  @override
  void subscribe() {
    _sensor
      ..addEventListener('error', _onErrorJS)
      ..addEventListener('reading', _onDataJS)
      ..start();
  }

  @override
  void unsubscribe() {
    _sensor
      ..removeEventListener('reading', _onDataJS)
      ..removeEventListener('error', _onErrorJS)
      ..stop();
  }

  void _resubscribe() {
    if (_sensor.activated) {
      unsubscribe();
      _createSensor();
      subscribe();
    } else {
      _createSensor();
    }
  }

  void _onData() {
    final quaternion = _sensor.quaternion;
    final timestamp = _sensor.timestamp;
    if (quaternion != null && quaternion.length >= 4 && timestamp != null) {
      _handleData(quaternion, timestamp);
    }
  }

  void _handleData(JSArray<JSNumber> quaternion, num timestamp) {
    final x = quaternion[0].toDartDouble;
    final y = quaternion[1].toDartDouble;
    final z = quaternion[2].toDartDouble;
    final w = quaternion[3].toDartDouble;
    streamController.add(
      transform(
        OrientationEvent(
          quaternion: Quaternion(x, y, z, w),
          accuracy: -1,
          timestamp: (timestamp * 1_000_000).toInt(),
        ),
      ),
    );
  }

  void _onError(SensorErrorEvent event) {
    final errorType = event.error.name;
    streamController.addError(switch (errorType) {
      'SecurityError' => SecurityException(),
      'NotAllowedError' => PermissionDeniedException(),
      'NotReadableError' => NotAvailableException(),
      _ => Exception('$errorType: ${event.error.message}'),
    });
  }
}
