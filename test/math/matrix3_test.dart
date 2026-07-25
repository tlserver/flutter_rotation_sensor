// ignore_for_file: prefer_int_literals

import 'dart:math';

import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  test('constructor returns an matrix with correct elements', () {
    final m = Matrix3(
      // @formatter:off
      1, 2, 3,
      4, 5, 6,
      7, 8, 9,
      // @formatter:on
    );
    expect(m.a, equals(1));
    expect(m.b, equals(2));
    expect(m.c, equals(3));
    expect(m.d, equals(4));
    expect(m.e, equals(5));
    expect(m.f, equals(6));
    expect(m.g, equals(7));
    expect(m.h, equals(8));
    expect(m.i, equals(9));
  });

  test('identity constructor returns an identity matrix', () {
    expect(
      Matrix3.identity(),
      closeToMatrix3(Matrix3(
        // @formatter:off
        1, 0, 0,
        0, 1, 0,
        0, 0, 1,
        // @formatter:on
      )),
    );
  });

  test('rows constructor returns an matrix with given row vectors', () {
    final v = Vector3(1, 2, 3);
    expect(
      Matrix3.rows(v, v, v),
      closeToMatrix3(Matrix3(
        // @formatter:off
        1, 2, 3,
        1, 2, 3,
        1, 2, 3,
        // @formatter:on
      )),
    );
  });

  test('columns constructor returns an matrix with given columns vectors', () {
    final v = Vector3(1, 2, 3);
    expect(
      Matrix3.columns(v, v, v),
      closeToMatrix3(Matrix3(
        // @formatter:off
        1, 1, 1,
        2, 2, 2,
        3, 3, 3,
        // @formatter:on
      )),
    );
  });

  test('zero constructor returns a zero matrix', () {
    expect(Matrix3.zero(), closeToMatrix3(Matrix3(
      // @formatter:off
      0, 0, 0,
      0, 0, 0,
      0, 0, 0,
      // @formatter:on
    )));
  });

  test('rotateX constructor returns a zero matrix', () {
    expect(
      Matrix3.rotateX(1),
      closeToMatrix3(
        Matrix3(
          // @formatter:off
           1.0000000,  0.0000000,  0.0000000,
           0.0000000,  0.5403023, -0.8414710,
           0.0000000,  0.8414710,  0.5403023,
          // @formatter:on
        ),
      ),
    );
  });

  test('rotateY constructor returns a zero matrix', () {
    expect(
      Matrix3.rotateY(2),
      closeToMatrix3(
        Matrix3(
          // @formatter:off
          -0.4161468,  0.0000000,  0.9092974,
           0.0000000,  1.0000000,  0.0000000,
          -0.9092974,  0.0000000, -0.4161468,
          // @formatter:on
        ),
      ),
    );
  });

  test('rotateZ constructor returns a zero matrix', () {
    expect(
      Matrix3.rotateZ(3),
      closeToMatrix3(
        Matrix3(
          // @formatter:off
          -0.9899925, -0.1411200,  0.0000000,
           0.1411200, -0.9899925,  0.0000000,
           0.0000000,  0.0000000,  1.0000000,
          // @formatter:on
        ),
      ),
    );
  });

  test('equality and hashCode', () {
    final m1 = Matrix3(
      // @formatter:off
      1, 2, 3,
      4, 5, 6,
      7, 8, 9,
      // @formatter:on
    );
    final m2 = Matrix3(
      // @formatter:off
      1, 2, 3,
      4, 5, 6,
      7, 8, 9,
      // @formatter:on
    );
    final m3 = Matrix3(
      // @formatter:off
      9, 8, 7,
      6, 5, 4,
      3, 2, 1,
      // @formatter:on
    );
    expect(m1 == m2, isTrue);
    expect(m1 == m3, isFalse);
    expect(m1.hashCode == m2.hashCode, isTrue);
    expect(m1.hashCode == m3.hashCode, isFalse);
  });

  test('toString returns the correct representation', () {
    expect(
      Matrix3(
        // @formatter:off
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        // @formatter:on
      ).toString(),
      equals('⌈1.0,2.0,3.0⌉\n|4.0,5.0,6.0|\n⌊7.0,8.0,9.0⌋\n'),
    );
  });

  test('row returns the corresponding elements at index', () {
    expect(
      Matrix3(
        // @formatter:off
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        // @formatter:on
      ).row(1),
      closeToVector3(Vector3(4, 5, 6)),
    );
  });

  test('column returns the corresponding elements at index', () {
    expect(
      Matrix3(
        // @formatter:off
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        // @formatter:on
      ).column(1),
      closeToVector3(Vector3(2, 5, 8)),
    );
  });

  test('negation changes sign of each element', () {
    expect(
      -Matrix3(
        // @formatter:off
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        // @formatter:on
      ),
      closeToMatrix3(Matrix3(
        // @formatter:off
        -1, -2, -3,
        -4, -5, -6,
        -7, -8, -9,
        // @formatter:off
      )),
    );
  });

  test('addition sums corresponding elements', () {
    expect(
      Matrix3(
        // @formatter:off
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        // @formatter:on
      ) + Matrix3(
        // @formatter:off
        9, 8, 7,
        6, 5, 4,
        3, 2, 1,
        // @formatter:on
      ),
      closeToMatrix3(Matrix3(
        // @formatter:off
        10, 10, 10,
        10, 10, 10,
        10, 10, 10,
        // @formatter:on
      )),
    );
  });

  test('subtraction subtracts corresponding elements', () {
    expect(
      Matrix3(
        // @formatter:off
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        // @formatter:off
      ) - Matrix3(
        // @formatter:off
        9, 8, 7,
        6, 5, 4,
        3, 2, 1,
        // @formatter:off
      ),
      closeToMatrix3(Matrix3(
        // @formatter:off
        -8, -6, -4,
        -2,  0,  2,
         4,  6,  8,
        // @formatter:off
      )),
    );
  });

  test('multiplication scales each element by a scalar', () {
    expect(
      Matrix3(
        // @formatter:off
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        // @formatter:on
      ) * 2,
      closeToMatrix3(Matrix3(
        // @formatter:off
         2,  4,  6,
         8, 10, 12,
        14, 16, 18,
        // @formatter:on
      )),
    );
  });

  test('division scales each element by a scalar', () {
    expect(
      Matrix3(
        // @formatter:off
         2,  4,  6,
         8, 10, 12,
        14, 16, 18,
        // @formatter:on
      ) / 2,
      closeToMatrix3(Matrix3(
        // @formatter:off
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        // @formatter:on
      )),
    );
  });

  test('multiplication matrix calculates product of two matrices', () {
    expect(
      Matrix3(
        // @formatter:off
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        // @formatter:on
      ).multiply(Matrix3(
        // @formatter:off
        9, 8, 7,
        6, 5, 4,
        3, 2, 1,
        // @formatter:on
      )),
      closeToMatrix3(Matrix3(
        // @formatter:off
         30,  24,  18,
         84,  69,  54,
        138, 114,  90,
        // @formatter:on
      )),
    );
  });

  test('trace calculates the sum of main diagonal', () {
    expect(Matrix3(
      // @formatter:off
      1, 2, 3,
      0, 1, 4,
      5, 6, 0,
      // @formatter:on
    ).trace, closeToNum(2));
  });

  test('determinant calculates the determinant value', () {
    expect(Matrix3(
      // @formatter:off
      1, 2, 3,
      0, 1, 4,
      5, 6, 0,
      // @formatter:on
    ).determinant, closeToNum(1));
  });

  test('transpose swaps rows and columns', () {
    expect(
      Matrix3(
        // @formatter:off
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        // @formatter:on
      ).transpose(),
      closeToMatrix3(Matrix3(
        // @formatter:off
        1, 4, 7,
        2, 5, 8,
        3, 6, 9,
        // @formatter:on
      )),
    );
  });

  test('adjoint calculates the adjugate matrix', () {
    expect(
      Matrix3(
        // @formatter:off
        1, 2, 3,
        0, 1, 4,
        5, 6, 0,
        // @formatter:on
      ).adjoint(),
      closeToMatrix3(Matrix3(
        // @formatter:off
        -24,  18,   5,
         20, -15, - 4,
        - 5,   4,   1,
        // @formatter:on
      )),
    );
  });

  test('invert calculates the inverse matrix', () {
    expect(
      Matrix3(
        // @formatter:off
        1, 2, 3,
        0, 1, 4,
        5, 6, 0,
        // @formatter:on
      ).invert(),
      closeToMatrix3(Matrix3(
        // @formatter:off
        -24,  18,   5,
         20, -15, - 4,
        - 5,   4,   1,
        // @formatter:on
      )),
    );
  });

  test('apply function applies function to each element', () {
    expect(
      Matrix3(
        // @formatter:off
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
        // @formatter:on
      ).apply((x) => min(x * 2, 9)),
      closeToMatrix3(Matrix3(
        // @formatter:off
        2, 4, 6,
        8, 9, 9,
        9, 9, 9,
        // @formatter:on
      )),
    );
  });

  test('toEulerAngles converts this rotation matrix to Euler-angles', () {
    expect(
      Matrix3(
        // @formatter:off
         1,  0,  0,
         0, -1,  0,
         0,  0, -1,
        // @formatter:on
      ).toEulerAngles(),
      closeToEulerAngles(EulerAngles(pi, 0, pi)),
    );
    expect(
      Matrix3(
        // @formatter:off
         0.5403023,  0.0000000,  0.8414710,
         0.8414710,  0.0000000, -0.5403023,
         0.0000000,  1.0000000,  0.0000000,
        // @formatter:on
      ).toEulerAngles(),
      closeToEulerAngles(EulerAngles(pi * 2 - 1, pi / 2, 0)),
    );
  });

  test('toQuaternion converts this rotation matrix to quaternion', () {
    expect(
      Matrix3(
        // @formatter:off
        1,  0,  0,
        0, -1,  0,
        0,  0, -1,
        // @formatter:on
      ).toQuaternion(),
      closeToQuaternion(Quaternion(1, 0, 0, 0)),
    );
  });
}
