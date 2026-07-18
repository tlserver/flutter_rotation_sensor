import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:meta/meta.dart';
import 'package:web/web.dart';

import 'exceptions/no_events_received_exception.dart';
import 'rotation_sensor_platform.dart';
import 'rotation_sensor_web.dart';
import 'sensor_permission.dart';

@JS('DeviceOrientationEvent')
external DeviceOrientationEventClass? get _deviceOrientationEvent;

/// A web implementation of the [RotationSensorPlatform].
abstract class RotationSensorWebEvents extends RotationSensorWeb {
  Timer? _noEventsTimer;

  @override
  bool get shouldRequestPermission =>
      _deviceOrientationEvent?.has('requestPermission') ?? false;

  @override
  Future<SensorPermission> requestPermission() async {
    if (shouldRequestPermission) {
      final result = await _deviceOrientationEvent!
          .requestPermission(absolute.toJS)
          .toDart;
      return switch (result.toDart) {
        'granted' => .granted,
        'denied' => .denied,
        _ => .denied,
      };
    } else {
      return .granted;
    }
  }

  @override
  void subscribe() {
    _noEventsTimer = Timer(
      const Duration(seconds: 2),
      () => streamController.addError(NoEventsReceivedException()),
    );
  }

  @override
  void unsubscribe() {
    _noEventsTimer?.cancel();
    _noEventsTimer = null;
  }

  @protected
  void onData(DeviceOrientationEvent event) {
    _noEventsTimer?.cancel();
    _noEventsTimer = null;
  }
}

extension type DeviceOrientationEventClass._(JSObject _) implements JSObject {
  external JSPromise<JSString> requestPermission(JSBoolean absolute);
}
