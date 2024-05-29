// ignore_for_file: prefer_int_literals

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rotation_sensor/rotation_sensor.dart';
import 'package:vector_math/vector_math.dart';

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
          () => event1.remapCoordinateSystem(Axis3D.X, Axis3D.X),
      throwsUnsupportedError,
    );
    expect(
          () => event1.remapCoordinateSystem(Axis3D.X, -Axis3D.X),
      throwsUnsupportedError,
    );
  });

  test(
    'remapCoordinateSystem returns a new OrientationEvent with transformed '
        'coordinate system',
        () {
      final event1xy = event1.remapCoordinateSystem(Axis3D.X, Axis3D.Y);
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

      final event1xz = event1.remapCoordinateSystem(Axis3D.X, Axis3D.Z);
      expect(
        event1xz.rotationMatrix,
        closeToMatrix3(
          matrix(
            [01.0000000, 00.0000000, 00.0000000],
            [00.0000000, 00.0000000, 01.0000000],
            [00.0000000, -1.0000000, 00.0000000],
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

      final event1yZ = event1.remapCoordinateSystem(Axis3D.Y, -Axis3D.Z);
      expect(
        event1yZ.rotationMatrix,
        closeToMatrix3(
          matrix(
            [00.0000000, 01.0000000, 00.0000000],
            [00.0000000, 00.0000000, -1.0000000],
            [-1.0000000, 00.0000000, 00.0000000],
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

      final event1YX = event1.remapCoordinateSystem(-Axis3D.Y, -Axis3D.X);
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
        event2.remapCoordinateSystem(Axis3D.X, Axis3D.Z).rotationMatrix,
        closeToMatrix3(
          matrix(
            [-0.0524597, 00.9982457, -0.0274485],
            [-0.9678703, -0.0440563, 00.2475602],
            [00.2459166, 00.0395535, 00.9684836],
          ),
        ),
      );

      expect(
        event2.remapCoordinateSystem(Axis3D.Y, -Axis3D.Z).rotationMatrix,
        closeToMatrix3(
          matrix(
            [-0.2459166, -0.0395535, -0.9684836],
            [00.9678703, 00.0440563, -0.2475602],
            [00.0524597, -0.9982457, 00.0274485],
          ),
        ),
      );

      expect(
        event2.remapCoordinateSystem(-Axis3D.Y, -Axis3D.X).rotationMatrix,
        closeToMatrix3(
          matrix(
            [00.2459171, 00.0395531, 00.9684835],
            [00.0524596, -0.9982458, 00.0274480],
            [00.9678702, 00.0440564, -0.2475607],
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
            .remapCoordinateSystem(-Axis3D.Y, Axis3D.Z)
            .remapCoordinateSystem(-Axis3D.Y, Axis3D.Z),
        closeToOrientationEvent(
          event2.remapCoordinateSystem(-Axis3D.Z, -Axis3D.X),
        ),
      );
    },
  );

  test(
    'should result in a matrix close to the original rotation matrix '
        'transposed after remapping and multiplying by coordinate system',
        () {
      final remapped = event2.remapCoordinateSystem(-Axis3D.Y, Axis3D.Z);
      expect(
        remapped.coordinateSystem * remapped.rotationMatrix,
        closeToMatrix3(
          event2.rotationMatrix,
        ),
      );
    },
  );

  test('toString should return the correct representation', () {
    expect(event1.toString(), '''
OrientationEvent(
quaternion: 0.0, 0.0, 0.0 @ 1.0,
accuracy: -1.0,
timestamp: 0,
coordinateSystem:
[0] [1.0,0.0,0.0]
[1] [0.0,1.0,0.0]
[2] [0.0,0.0,1.0]
)''');
    expect(event2.remapCoordinateSystem(-Axis3D.Y, -Axis3D.X).toString(), '''
OrientationEvent(
quaternion: 0.7892594933509827, 0.02914547175168991, 0.6133451461791992 @ 0.005260601174086332,
accuracy: -1.0,
timestamp: 0,
coordinateSystem:
[0] [0.0,-1.0,0.0]
[1] [-1.0,0.0,0.0]
[2] [-0.0,-0.0,-1.0]
)''');
  });
}

OrientationEvent eventOf(double x, double y, double z, double w) =>
    OrientationEvent(
      quaternion: Quaternion(x, y, z, w).normalized(),
      accuracy: -1,
      timestamp: 0,
    );

Matrix3 matrix(List<double> row0, List<double> row1, List<double> row2) =>
    Matrix3.fromList([...row0, ...row1, ...row2])..transpose();

Matcher closeToMatrix3(Matrix3 expected) {
  var mc = isA<Matrix3>();
  for (var t = 0; t < 9; t++) {
    mc = mc.having((mt) => mt[t], '[$t]', closeTo(expected[t], threshold));
  }
  return mc;
}

Matcher closeToEulerAngles(EulerAngles expected) => isA<EulerAngles>()
    .having(
      (ea) => ea.azimuth,
      'azimuth',
      closeTo(expected.azimuth, threshold),
    )
    .having((ea) => ea.pitch, 'pitch', closeTo(expected.pitch, threshold))
    .having((ea) => ea.roll, 'roll', closeTo(expected.roll, threshold));

Matcher closeToOrientationEvent(OrientationEvent expected) =>
    isA<OrientationEvent>().having(
      (ea) => ea.rotationMatrix,
      'rotationMatrix',
      closeToMatrix3(expected.rotationMatrix),
    );
