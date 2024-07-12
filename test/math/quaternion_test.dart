import 'dart:math';

import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  test('constructor returns a quaternion with correct components', () {
    final q = Quaternion(1, 2, 3, 4);
    expect(q.x, equals(1));
    expect(q.y, equals(2));
    expect(q.z, equals(3));
    expect(q.w, equals(4));
  });

  test('identity constructor returns a identity quaternion', () {
    expect(Quaternion.identity(), equals(Quaternion(0, 0, 0, 1)));
  });

  test('equality and hashCode', () {
    final q1 = Quaternion(1, 2, 3, 4);
    final q2 = Quaternion(1, 2, 3, 4);
    final q3 = Quaternion(2, 3, 4, 5);
    expect(q1 == q2, isTrue);
    expect(q1 == q3, isFalse);
    expect(q1.hashCode == q2.hashCode, isTrue);
    expect(q1.hashCode == q3.hashCode, isFalse);
  });

  test('toString returns the correct representation', () {
    expect(Quaternion(1, 2, 3, 4).toString(), equals('1.0, 2.0, 3.0 @ 4.0'));
  });

  test('negation changes sign of each component', () {
    expect(-Quaternion(1, 2, 3, 4), equals(Quaternion(-1, -2, -3, -4)));
  });

  test('addition sums corresponding components', () {
    expect(
      Quaternion(1, 2, 3, 4) + Quaternion(5, 6, 7, 8),
      equals(Quaternion(6, 8, 10, 12)),
    );
  });

  test('subtraction subtracts corresponding components', () {
    expect(
      Quaternion(5, 6, 7, 8) - Quaternion(1, 2, 3, 4),
      equals(Quaternion(4, 4, 4, 4)),
    );
  });

  test('multiplication scales each component by a scalar', () {
    expect(
      Quaternion(1, 2, 3, 4) * 2,
      equals(Quaternion(2, 4, 6, 8)),
    );
  });

  test('division scales each component by a scalar', () {
    expect(
      Quaternion(2, 4, 6, 8) / 2,
      equals(Quaternion(1, 2, 3, 4)),
    );
  });

  test('multiplication quaternion calculates product of two quaternions', () {
    expect(
      Quaternion(1, 2, 3, 4).multiply(Quaternion(5, 6, 7, 8)),
      equals(Quaternion(24, 48, 48, -6)),
    );
  });

  test('length and length2 calculate quaternion magnitude and its square', () {
    final q = Quaternion(1, 2, 3, 4);
    expect(q.length2, closeTo(30, delta));
    expect(q.length, closeTo(5.4772256, delta));
  });

  test('normalize scales quaternion to unit length', () {
    expect(
      Quaternion(1, 2, 3, 4).normalize(),
      closeToQuaternion(Quaternion(0.1825742, 0.3651484, 0.5477226, 0.7302967)),
    );
  });

  test('conjugate', () {
    expect(
      Quaternion(1, 2, 3, 4).conjugate(),
      equals(Quaternion(-1, -2, -3, 4)),
    );
  });

  test('invert calculates the inverse quaternion', () {
    expect(
      Quaternion(1, 2, 3, 4).invert(),
      closeToQuaternion(
        Quaternion(-0.0333333, -0.0666667, -0.1000000, 0.1333333),
      ),
    );
  });

  test('apply function applies function to each component', () {
    expect(
      Quaternion(1, 2, 3, 4).apply((x) => min(x * 2, 5)),
      equals(Quaternion(2, 4, 5, 5)),
    );
  });

  test('toAxisAngle converts quaternion to axis angle representation', () {
    expect(
      Quaternion(0, 0, sin(pi / 4), cos(pi / 4)).toAxisAngle(),
      closeToAxisAngle(AxisAngle(Vector3(0, 0, 1), pi / 2)),
    );
    expect(
      Quaternion(0, 0, 0, 1).toAxisAngle(),
      closeToAxisAngle(AxisAngle(Vector3(0, 0, 0), 0)),
    );
  });

  test('toRotationMatrix converts quaternion to rotation matrix', () {
    expect(
      Quaternion(1, 0, 0, 0).toRotationMatrix(),
      equals(Matrix3(1, 0, 0, 0, -1, 0, 0, 0, -1)),
    );
  });
}
