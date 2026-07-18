import 'package:flutter/foundation.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_rotation_sensor/src/environment.dart';
import 'package:flutter_rotation_sensor/src/rotation_sensor_platform.dart';
import 'package:flutter_rotation_sensor/src/sensor_permission.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRotationSensorPlatform extends RotationSensorPlatform
    with MockPlatformInterfaceMixin {
  @override
  Stream<OrientationEvent> get orientationStream =>
      Stream<OrientationEvent>.fromIterable([
        OrientationEvent(
          quaternion: Quaternion.identity(),
          accuracy: -1,
          timestamp: 0,
        ),
      ]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('diagnosticMode can be set and retrieved correctly', () {
    RotationSensor.diagnosticMode = true;
    expect(RotationSensor.diagnosticMode, isTrue);
  });

  test('isPlatformSupported returns true only for Android and iOS '
      'platforms', () {
    isWeb = false;
    for (final platform in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = platform;
      expect(
        RotationSensor.isPlatformSupported,
        equals([TargetPlatform.android, TargetPlatform.iOS].contains(platform)),
      );
    }
  });

  test('shouldRequestPermission returns false for android', () {
    expect(RotationSensor.shouldRequestPermission, isFalse);
  });

  test('requestPermission returns granted for android', () {
    expectLater(
      RotationSensor.requestPermission(),
      completion(equals(SensorPermission.granted)),
    );
  });

  test('isPlatformSupported returns true for web platform', () {
    isWeb = true;
    expect(RotationSensor.isPlatformSupported, isTrue);
  });

  test('orientationStream returns a stream of orientation events', () async {
    var fakePlatform = MockRotationSensorPlatform();
    RotationSensorPlatform.instance = fakePlatform;

    expect(
      await RotationSensor.orientationStream.first,
      isA<OrientationEvent>(),
    );
  });

  test('samplingPeriod return zero duration for reserved value', () {
    for (var t = 0; t < 4; t++) {
      RotationSensor.samplingPeriod = Duration(microseconds: t);
      expect(RotationSensor.samplingPeriod, equals(Duration.zero));
    }
    RotationSensor.samplingPeriod = SensorInterval.uiInterval;
    expect(RotationSensor.samplingPeriod, equals(SensorInterval.uiInterval));
  });

  test('referenceFrame can be set and retrieved correctly', () {
    RotationSensor.referenceFrame = ReferenceFrame.trueNorth;
    expect(RotationSensor.referenceFrame, equals(ReferenceFrame.trueNorth));
  });

  test('coordinateSystem can be set and retrieved correctly', () {
    RotationSensor.coordinateSystem = CoordinateSystem.display();
    expect(RotationSensor.coordinateSystem, same(CoordinateSystem.display()));
  });
}
