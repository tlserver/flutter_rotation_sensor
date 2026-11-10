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
  // ignore: public_member_api_docs
  void onData(DeviceOrientationEvent event) {
    _noEventsTimer?.cancel();
    _noEventsTimer = null;
  }
}

/// The [DeviceOrientationEvent] interface of the Device Orientation Events
/// provides web developers with information from the physical orientation of
/// the device running the web page.
///
/// See also
/// https://developer.mozilla.org/en-US/docs/Web/API/DeviceOrientationEvent.
extension type DeviceOrientationEventClass._(JSObject _) implements JSObject {
  /// Requests the user's permission to access device orientation data. Returns
  /// a Promise that resolves with a string of "granted" or "denied".
  external JSPromise<JSString> requestPermission(JSBoolean absolute);
}
