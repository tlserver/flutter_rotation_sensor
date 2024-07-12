// ignore_for_file: prefer_int_literals

import 'dart:math';

import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils.dart';

const threshold = 0.000001;

void main() {
  final event1 = eventOf(00.0000000, 00.0000000, 00.0000000, 01.0000000);
  final event2 = eventOf(00.4299807, 00.4374203, -0.5786997, 00.5374818);

  test(
    'rotationMatrix returns correct matrix for some known quaternions',
    () {
      expect(
        event1.rotationMatrix,
        closeToMatrix3(
          matrix(
            [01.0000000, 00.0000000, 00.0000000],
            [00.0000000, 01.0000000, 00.0000000],
            [00.0000000, 00.0000000, 01.0000000],
          ),
        ),
      );
      expect(
        event2.rotationMatrix,
        closeToMatrix3(
          matrix(
            [-0.0524597, 00.9982457, -0.0274485],
            [-0.2459166, -0.0395536, -0.9684836],
            [-0.9678704, -0.0440563, 00.2475601],
          ),
        ),
      );
    },
  );

  test('eulerAngles returns correct angles for some known quaternions', () {
    expect(
      event1.eulerAngles,
      closeToEulerAngles(EulerAngles(00.0000000, 00.0000000, 00.0000000)),
    );
    expect(
      event2.eulerAngles,
      closeToEulerAngles(EulerAngles(01.6103987, -0.0440705, 01.3203868)),
    );
    final event = eventOf(00.7071068, 00.0000000, 00.0000000, 00.7071068);
    final eulerAngles = event.eulerAngles;
    expect(eulerAngles.pitch, closeTo(pi / 2, threshold));
    expect(eulerAngles.azimuth, closeTo(eulerAngles.roll, threshold));
  });

  test('remapCoordinateSystem throws error with invalid axes', () {
    expect(
      () => event1.remapCoordinateSystem(Axis3.X, Axis3.X),
      throwsUnsupportedError,
    );
    expect(
      () => event1.remapCoordinateSystem(Axis3.X, -Axis3.X),
      throwsUnsupportedError,
    );
  });

  test(
    'remapCoordinateSystem returns a new OrientationEvent with transformed '
    'coordinate system',
    () {
      final event1xy = event1.remapCoordinateSystem(Axis3.X, Axis3.Y);
      expect(
        event1xy.rotationMatrix,
        closeToMatrix3(
          matrix(
            [01.0000000, 00.0000000, 00.0000000],
            [00.0000000, 01.0000000, 00.0000000],
            [00.0000000, 00.0000000, 01.0000000],
          ),
        ),
      );
      expect(
        event1xy.coordinateSystem,
        closeToMatrix3(
          matrix(
            [01.0000000, 00.0000000, 00.0000000],
            [00.0000000, 01.0000000, 00.0000000],
            [00.0000000, 00.0000000, 01.0000000],
          ),
        ),
      );

      final event1xz = event1.remapCoordinateSystem(Axis3.X, Axis3.Z);
      expect(
        event1xz.rotationMatrix,
        closeToMatrix3(
          matrix(
            [01.0000000, 00.0000000, 00.0000000],
            [00.0000000, 00.0000000, -1.0000000],
            [00.0000000, 01.0000000, 00.0000000],
          ),
        ),
      );
      expect(
        event1xz.coordinateSystem,
        closeToMatrix3(
          matrix(
            [01.0000000, 00.0000000, 00.0000000],
            [00.0000000, 00.0000000, -1.0000000],
            [00.0000000, 01.0000000, 00.0000000],
          ),
        ),
      );

      final event1yZ = event1.remapCoordinateSystem(Axis3.Y, -Axis3.Z);
      expect(
        event1yZ.rotationMatrix,
        closeToMatrix3(
          matrix(
            [00.0000000, 00.0000000, -1.0000000],
            [01.0000000, 00.0000000, 00.0000000],
            [00.0000000, -1.0000000, 00.0000000],
          ),
        ),
      );
      expect(
        event1yZ.coordinateSystem,
        closeToMatrix3(
          matrix(
            [00.0000000, 00.0000000, -1.0000000],
            [01.0000000, 00.0000000, 00.0000000],
            [00.0000000, -1.0000000, 00.0000000],
          ),
        ),
      );

      final event1YX = event1.remapCoordinateSystem(-Axis3.Y, -Axis3.X);
      expect(
        event1YX.rotationMatrix,
        closeToMatrix3(
          matrix(
            [00.0000000, -1.0000000, 00.0000000],
            [-1.0000000, 00.0000000, 00.0000000],
            [00.0000000, 00.0000000, -1.0000000],
          ),
        ),
      );
      expect(
        event1YX.coordinateSystem,
        closeToMatrix3(
          matrix(
            [00.0000000, -1.0000000, 00.0000000],
            [-1.0000000, 00.0000000, 00.0000000],
            [00.0000000, 00.0000000, -1.0000000],
          ),
        ),
      );

      expect(
        event2.remapCoordinateSystem(Axis3.X, Axis3.Z).rotationMatrix,
        closeToMatrix3(
          matrix(
            [-0.0524597, -0.0274485, -0.9982457],
            [-0.2459166, -0.9684836, 00.0395536],
            [-0.9678704, 00.2475601, 00.0440563],
          ),
        ),
      );

      expect(
        event2.remapCoordinateSystem(Axis3.Y, -Axis3.Z).rotationMatrix,
        closeToMatrix3(
          matrix(
            [00.9982457, 00.0274485, 00.0524597],
            [-0.0395536, 00.9684836, 00.2459166],
            [-0.0440563, -0.2475601, 00.9678704],
          ),
        ),
      );

      expect(
        event2.remapCoordinateSystem(-Axis3.Y, -Axis3.X).rotationMatrix,
        closeToMatrix3(
          matrix(
            [-0.9982457, 00.0524597, 00.0274485],
            [00.0395536, 00.2459166, 00.9684836],
            [00.0440563, 00.9678704, -0.2475601],
          ),
        ),
      );
    },
  );

  test(
    'should be equivalent to single remapping with different axes when '
    'remapped twice consecutively',
    () {
      expect(
        event2
            .remapCoordinateSystem(-Axis3.Y, Axis3.Z)
            .remapCoordinateSystem(-Axis3.Y, Axis3.Z),
        closeToOrientationEvent(
          event2.remapCoordinateSystem(-Axis3.Z, -Axis3.X),
        ),
      );
    },
  );

  test(
    'should result in a matrix close to the original rotation matrix '
    'transposed after remapping and multiplying by inverted coordinate system',
    () {
      final remapped = event2.remapCoordinateSystem(-Axis3.Y, Axis3.Z);
      expect(
        remapped.rotationMatrix.multiply(remapped.coordinateSystem.invert()),
        closeToMatrix3(
          event2.rotationMatrix,
        ),
      );
    },
  );

  test('toString return the correct representation', () {
    expect(
      event1.toString(),
      equals('''
OrientationEvent(
quaternion: 0.0, 0.0, 0.0 @ 1.0,
accuracy: -1.0,
timestamp: 0,
coordinateSystem:
⌈1.0,0.0,0.0⌉
|0.0,1.0,0.0|
⌊0.0,0.0,1.0⌋
)'''),
    );
    expect(
      event2.remapCoordinateSystem(-Axis3.Y, -Axis3.X).toString(),
      equals('''
OrientationEvent(
quaternion: -0.02914547175168991, -0.7892594933509827, -0.6133451461791992 @ 0.005260601174086332,
accuracy: -1.0,
timestamp: 0,
coordinateSystem:
⌈-0.0,-1.0,0.0⌉
|-1.0,-0.0,0.0|
⌊-0.0,-0.0,-1.0⌋
)'''),
    );
  });
}

OrientationEvent eventOf(double x, double y, double z, double w) =>
    OrientationEvent(
      quaternion: Quaternion(x, y, z, w).normalize(),
      accuracy: -1,
      timestamp: 0,
    );

Matrix3 matrix(List<double> row0, List<double> row1, List<double> row2) =>
    Matrix3(
      row0[0],
      row0[1],
      row0[2],
      row1[0],
      row1[1],
      row1[2],
      row2[0],
      row2[1],
      row2[2],
    );
