import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sourceEvent = OrientationEvent(
    quaternion: Quaternion(0, 0, 0, 1),
    accuracy: -1,
    timestamp: 123456789,
  );

  test('DeviceCoordinateSystem remap OrientationEvent to itself', () async {
    final deviceCoordinateSystem = DeviceCoordinateSystem();
    final result = deviceCoordinateSystem.apply(sourceEvent);
    expect(result.coordinateSystem, closeToMatrix3(Matrix3.identity()));
  });

  test('DisplayCoordinateSystem remap OrientationEvent to display coordinate '
      'system', () async {
    final displayCoordinateSystem = DisplayCoordinateSystem();

    final orientations = [
      NativeDeviceOrientation.portraitUp,
      NativeDeviceOrientation.landscapeRight,
      NativeDeviceOrientation.portraitDown,
      NativeDeviceOrientation.landscapeLeft,
    ];

    final pyNx = Matrix3(
      // @formatter:off
       0, -1,  0,
       1,  0,  0,
       0,  0,  1,
      // @formatter:on
    );
    for (
      var t = 0, e = Matrix3.identity();
      t < orientations.length;
      t++, e = e * pyNx
    ) {
      displayCoordinateSystem.orientation = orientations[t];
      final orientationEvent = displayCoordinateSystem.apply(sourceEvent);
      expect(
        orientationEvent.coordinateSystem,
        closeToMatrix3(e),
        reason: 'orientationEvents[$t]',
      );
    }
  });

  test('DisplayCoordinateSystem.apply emit error for unknown '
      'orientation', () async {
    final displayCoordinateSystem = DisplayCoordinateSystem()
      ..orientation = .unknown;
    expect(() => displayCoordinateSystem.apply(sourceEvent), throwsStateError);
  });

  test('TransformedCoordinateSystem remap OrientationEvent to custom '
      'coordinate system', () async {
    final deviceCoordinateSystem = DeviceCoordinateSystem();
    final transformedCoordinateSystem1 = TransformedCoordinateSystem(
      -Axis3.X,
      -Axis3.Y,
      deviceCoordinateSystem,
    );
    final transformedCoordinateSystem2 = TransformedCoordinateSystem(
      Axis3.X,
      Axis3.Z,
      transformedCoordinateSystem1,
    );
    final result = transformedCoordinateSystem2.apply(sourceEvent);
    expect(
      result.coordinateSystem,
      closeToMatrix3(Matrix3.columns(-Axis3.X, Axis3.Z, Axis3.Y)),
    );
  });
}
