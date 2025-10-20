import 'package:flutter_rotation_sensor/src/rotation_sensor_unsupported.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = RotationSensorUnsupported();

  test('orientationStream', () async {
    expect(() => platform.orientationStream.first, throwsUnsupportedError);
  });
}
