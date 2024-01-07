import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:rotation_sensor/src/orientation_event.dart';
import 'package:rotation_sensor/src/rotation_sensor.dart';
import 'package:rotation_sensor/src/rotation_sensor_method_channel.dart';
import 'package:rotation_sensor/src/rotation_sensor_platform_interface.dart';
import 'package:vector_math/vector_math.dart';

class MockRotationSensorPlatform
    with MockPlatformInterfaceMixin
    implements RotationSensorPlatform {
  @override
  Stream<OrientationEvent> getOrientationStream({Duration? samplingPeriod}) =>
      Stream<OrientationEvent>.fromIterable([
        OrientationEvent(
          quaternion: Quaternion.identity(),
          accuracy: -1,
          timestamp: 0,
        ),
      ]);
}

void main() {
  final initialPlatform = RotationSensorPlatform.instance;

  test('$MethodChannelRotationSensor is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRotationSensor>());
  });

  test('getOrientationStream', () async {
    var fakePlatform = MockRotationSensorPlatform();
    RotationSensorPlatform.instance = fakePlatform;

    expect(
      await RotationSensor.getOrientationStream().first,
      isA<OrientationEvent>(),
    );
  });
}
