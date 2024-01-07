import 'package:flutter_test/flutter_test.dart';
import 'package:rotation_sensor/rotation_sensor.dart';
import 'package:rotation_sensor/src/rotation_sensor_platform_interface.dart';

class MockRotationSensorPlatform extends RotationSensorPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    RotationSensorPlatform.instance = MockRotationSensorPlatform();
  });

  test('getOrientationStream should throw UnimplementedError by default', () {
    expect(
      RotationSensor.getOrientationStream,
      throwsA(isA<UnimplementedError>()),
    );
  });
}
