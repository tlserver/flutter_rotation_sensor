// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'rotation_sensor_platform.dart';

/// A web implementation of the RotationSensorPlatform of the FlutterRotationSensor plugin.
class RotationSensorWeb extends RotationSensorPlatform {
  /// Constructs a FlutterRotationSensorWeb
  RotationSensorWeb();

  static void registerWith(Registrar registrar) {
    FlutterRotationSensorPlatform.instance = RotationSensorWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }
}
