import 'package:flutter/widgets.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_rotation_sensor/src/rotation_sensor_method_channel.dart';
import 'package:flutter_rotation_sensor/src/rotation_sensor_platform_interface.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  final initialPlatform = RotationSensorPlatform.instance;

  test('MethodChannelRotationSensor is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRotationSensor>());
  });

  test('platform is default MethodChannelRotationSensor', () {
    expect(RotationSensor.platform, same(initialPlatform));
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

  test('coordinateSystem can be set and retrieved correctly', () {
    RotationSensor.coordinateSystem = CoordinateSystem.display();
    expect(RotationSensor.coordinateSystem, same(CoordinateSystem.display()));
  });
}
