import 'package:flutter/foundation.dart';
import 'package:flutter_rotation_sensor/src/environment.dart';
import 'package:flutter_rotation_sensor/src/rotation_sensor_method_channel.dart';
import 'package:flutter_rotation_sensor/src/rotation_sensor_platform.dart';
import 'package:flutter_rotation_sensor/src/rotation_sensor_unsupported.dart';
import 'package:flutter_test/flutter_test.dart';

const webImplementation = RotationSensorUnsupported;

const implementations = {
  TargetPlatform.android: RotationSensorMethodChannel,
  TargetPlatform.iOS: RotationSensorMethodChannel,
  TargetPlatform.fuchsia: RotationSensorUnsupported,
  TargetPlatform.linux: RotationSensorUnsupported,
  TargetPlatform.macOS: RotationSensorUnsupported,
  TargetPlatform.windows: RotationSensorUnsupported,
};

void main() {
  test('instance returns the implementation for current platform', () {
    expect(
      RotationSensorPlatform.instance.runtimeType,
      equals(implementations[defaultTargetPlatform]),
    );
  });

  test('$webImplementation is used on web platform', () {
    isWeb = true;
    expect(
      RotationSensorPlatform.createPlatformInstance().runtimeType,
      equals(webImplementation),
    );
  });

  implementations.forEach((platform, implementation) {
    test('$implementation is used on ${platform.name} platform', () {
      isWeb = false;
      debugDefaultTargetPlatformOverride = platform;
      expect(
        RotationSensorPlatform.createPlatformInstance().runtimeType,
        equals(implementation),
      );
    });
  });
}
