// ignore_for_file: prefer_int_literals

import 'dart:math';

import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  test('constructor returns an matrix with correct elements', () {
    final m = Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9);
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
      equals(Matrix3(1, 0, 0, 0, 1, 0, 0, 0, 1)),
    );
  });

  test('rows constructor returns an matrix with given row vectors', () {
    final v = Vector3(1, 2, 3);
    expect(
      Matrix3.rows(v, v, v),
      equals(Matrix3(1, 2, 3, 1, 2, 3, 1, 2, 3)),
    );
  });

  test('columns constructor returns an matrix with given columns vectors', () {
    final v = Vector3(1, 2, 3);
    expect(
      Matrix3.columns(v, v, v),
      equals(Matrix3(1, 1, 1, 2, 2, 2, 3, 3, 3)),
    );
  });

  test('zero constructor returns a zero matrix', () {
    expect(
      Matrix3.zero(),
      equals(Matrix3(0, 0, 0, 0, 0, 0, 0, 0, 0)),
    );
  });

  test('rotateX constructor returns a zero matrix', () {
    expect(
      Matrix3.rotateX(1),
      closeToMatrix3(
        Matrix3(
          01.0000000,
          00.0000000,
          00.0000000,
          00.0000000,
          00.5403023,
          -0.8414710,
          00.0000000,
          00.8414710,
          00.5403023,
        ),
      ),
    );
  });

  test('rotateY constructor returns a zero matrix', () {
    expect(
      Matrix3.rotateY(2),
      closeToMatrix3(
        Matrix3(
          -0.4161468,
          00.0000000,
          00.9092974,
          00.0000000,
          01.0000000,
          00.0000000,
          -0.9092974,
          00.0000000,
          -0.4161468,
        ),
      ),
    );
  });

  test('rotateZ constructor returns a zero matrix', () {
    expect(
      Matrix3.rotateZ(3),
      closeToMatrix3(
        Matrix3(
          -0.9899925,
          -0.1411200,
          00.0000000,
          00.1411200,
          -0.9899925,
          00.0000000,
          00.0000000,
          00.0000000,
          01.0000000,
        ),
      ),
    );
  });

  test('equality and hashCode', () {
    final m1 = Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    final m2 = Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9);
    final m3 = Matrix3(9, 8, 7, 6, 5, 4, 3, 2, 1);
    expect(m1 == m2, isTrue);
    expect(m1 == m3, isFalse);
    expect(m1.hashCode == m2.hashCode, isTrue);
    expect(m1.hashCode == m3.hashCode, isFalse);
  });

  test('toString returns the correct representation', () {
    expect(
      Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9).toString(),
      equals('⌈1.0,2.0,3.0⌉\n|4.0,5.0,6.0|\n⌊7.0,8.0,9.0⌋\n'),
    );
  });

  test('row returns the corresponding elements at index', () {
    expect(
      Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9).row(1),
      equals(Vector3(4, 5, 6)),
    );
  });

  test('column returns the corresponding elements at index', () {
    expect(
      Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9).column(1),
      equals(Vector3(2, 5, 8)),
    );
  });

  test('negation changes sign of each element', () {
    expect(
      -Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9),
      equals(Matrix3(-1, -2, -3, -4, -5, -6, -7, -8, -9)),
    );
  });

  test('addition sums corresponding elements', () {
    expect(
      Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9) + Matrix3(9, 8, 7, 6, 5, 4, 3, 2, 1),
      equals(Matrix3(10, 10, 10, 10, 10, 10, 10, 10, 10)),
    );
  });

  test('subtraction subtracts corresponding elements', () {
    expect(
      Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9) - Matrix3(9, 8, 7, 6, 5, 4, 3, 2, 1),
      equals(Matrix3(-8, -6, -4, -2, 0, 2, 4, 6, 8)),
    );
  });

  test('multiplication scales each element by a scalar', () {
    expect(
      Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9) * 2,
      equals(Matrix3(2, 4, 6, 8, 10, 12, 14, 16, 18)),
    );
  });

  test('division scales each element by a scalar', () {
    expect(
      Matrix3(2, 4, 6, 8, 10, 12, 14, 16, 18) / 2,
      equals(Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9)),
    );
  });

  test('multiplication matrix calculates product of two matrices', () {
    expect(
      Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9)
          .multiply(Matrix3(9, 8, 7, 6, 5, 4, 3, 2, 1)),
      equals(Matrix3(30, 24, 18, 84, 69, 54, 138, 114, 90)),
    );
  });

  test('trace calculates the sum of main diagonal', () {
    expect(Matrix3(1, 2, 3, 0, 1, 4, 5, 6, 0).trace, equals(2));
  });

  test('determinant calculates the determinant value', () {
    expect(Matrix3(1, 2, 3, 0, 1, 4, 5, 6, 0).determinant, equals(1));
  });

  test('transpose swaps rows and columns', () {
    expect(
      Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9).transpose(),
      equals(Matrix3(1, 4, 7, 2, 5, 8, 3, 6, 9)),
    );
  });

  test('adjoint calculates the adjugate matrix', () {
    expect(
      Matrix3(1, 2, 3, 0, 1, 4, 5, 6, 0).adjoint(),
      equals(Matrix3(-24, 18, 5, 20, -15, -4, -5, 4, 1)),
    );
  });

  test('invert calculates the inverse matrix', () {
    expect(
      Matrix3(1, 2, 3, 0, 1, 4, 5, 6, 0).invert(),
      equals(Matrix3(-24, 18, 5, 20, -15, -4, -5, 4, 1)),
    );
  });

  test('apply function applies function to each element', () {
    expect(
      Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9).apply((x) => min(x * 2, 9)),
      equals(Matrix3(2, 4, 6, 8, 9, 9, 9, 9, 9)),
    );
  });

  test('toQuaternion converts this rotation matrix to quaternion', () {
    expect(
      Matrix3(1, 0, 0, 0, -1, 0, 0, 0, -1).toQuaternion(),
      equals(Quaternion(1, 0, 0, 0)),
    );
  });

  test('toEulerAngles converts this rotation matrix to Euler-angles', () {
    expect(
      Matrix3(1, 0, 0, 0, -1, 0, 0, 0, -1).toEulerAngles(),
      closeToEulerAngles(EulerAngles(pi, 0, pi)),
    );
    expect(
      Matrix3(
        00.5403023,
        00.0000000,
        00.8414710,
        00.8414710,
        00.0000000,
        -0.5403023,
        00.0000000,
        01.0000000,
        00.0000000,
      ).toEulerAngles(),
      closeToEulerAngles(EulerAngles(pi * 2 - 1, pi / 2, 0)),
    );
  });
}
