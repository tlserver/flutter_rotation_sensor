import 'dart:math';

import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';
import 'data.dart';

void main() {
  test('constructor returns a quaternion with correct components', () {
    final q = Quaternion(1, 2, 3, 4);
    expect(q.x, equals(1));
    expect(q.y, equals(2));
    expect(q.z, equals(3));
    expect(q.w, equals(4));
  });

  test('identity constructor returns a identity quaternion', () {
    expect(Quaternion.identity(), closeToQuaternion(Quaternion(0, 0, 0, 1)));
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
    expect(
      -Quaternion(1, 2, 3, 4),
      closeToQuaternion(Quaternion(-1, -2, -3, -4)),
    );
  });

  test('addition sums corresponding components', () {
    expect(
      Quaternion(1, 2, 3, 4) + Quaternion(5, 6, 7, 8),
      closeToQuaternion(Quaternion(6, 8, 10, 12)),
    );
  });

  test('subtraction subtracts corresponding components', () {
    expect(
      Quaternion(5, 6, 7, 8) - Quaternion(1, 2, 3, 4),
      closeToQuaternion(Quaternion(4, 4, 4, 4)),
    );
  });

  test('multiplies a scalar', () {
    expect(
      Quaternion(1, 2, 3, 4) * 2,
      closeToQuaternion(Quaternion(2, 4, 6, 8)),
    );
  });

  test('multiplies a vector', () {
    expect(
      Quaternion(1, 2, 3, 4) * Vector3(5, 6, 7),
      closeToQuaternion(Quaternion(16, 32, 24, -38)),
    );
  });

  test('multiplies a matrix', () {
    final q = Quaternion(1, 2, 3, 4);
    final m = Matrix3(
      // @formatter:off
       0.8571429, -0.2857143, -0.4285714,
       0.1714286,  0.9428571, -0.2857143,
       0.4857143,  0.1714286,  0.8571429,
      // @formatter:on
    );
    expect(q.length, closeToNum(5.4772255));
    expect(m.determinant, closeToNum(1));
    expect(m.toQuaternion().length, closeToNum(1));
    expect((q * m).length, closeToNum(5.4772255));
    expect(
      q * m,
      closeToQuaternion(Quaternion(2.3904574, 1.1952288, 2.8685488, 3.8247314)),
    );
  });

  test('multiplies a quaternion', () {
    expect(
      Quaternion(1, 2, 3, 4) * Quaternion(5, 6, 7, 8),
      closeToQuaternion(Quaternion(24, 48, 48, -6)),
    );
  });

  test('division scales each component by a scalar', () {
    expect(
      Quaternion(2, 4, 6, 8) / 2,
      closeToQuaternion(Quaternion(1, 2, 3, 4)),
    );
  });

  test('length and length2 calculate quaternion magnitude and its square', () {
    final q = Quaternion(1, 2, 3, 4);
    expect(q.length2, closeToNum(30));
    expect(q.length, closeToNum(5.4772256));
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
      closeToQuaternion(Quaternion(-1, -2, -3, 4)),
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
      closeToQuaternion(Quaternion(2, 4, 5, 5)),
    );
  });

  test('toAxisAngle converts quaternion to axis angle representation', () {
    expect(xrQt.toAxisAngle(), closeToAxisAngle(xrAa));
    expect(yrQt.toAxisAngle(), closeToAxisAngle(yrAa));
    expect(zrQt.toAxisAngle(), closeToAxisAngle(zrAa));
    expect(ab1Qt.toAxisAngle(), closeToAxisAngle(ab1Aa));
    expect(ab1Qt2.toAxisAngle(), closeToAxisAngle(ab1Aa2));
  });

  test('toRotationMatrix converts quaternion to rotation matrix', () {
    expect(xrQt.toRotationMatrix(), closeToMatrix3(xrMt));
    expect(yrQt.toRotationMatrix(), closeToMatrix3(yrMt));
    expect(zrQt.toRotationMatrix(), closeToMatrix3(zrMt));
    expect(ab1Qt.toRotationMatrix(), closeToMatrix3(ab1Mt));
    expect(ab1Qt2.toRotationMatrix(), closeToMatrix3(ab1Mt2));
  });

  test('rotates vectors', () {
    expect(
      (xrQt * v1 * xrQt.conjugate()).toVector3(),
      closeToVector3(Vector3(1, -3, 2)),
    );
    expect(
      (yrQt * v1 * yrQt.conjugate()).toVector3(),
      closeToVector3(Vector3(3, 2, -1)),
    );
    expect(
      (zrQt * v1 * zrQt.conjugate()).toVector3(),
      closeToVector3(Vector3(-2, 1, 3)),
    );
    expect(
      (ab1Qt * v1 * ab1Qt.conjugate()).toVector3(),
      closeToVector3(Vector3(1.9773995, 1.2583316, 2.9165893)),
    );
    expect(
      (ab1Qt2 * v1 * ab1Qt2.conjugate()).toVector3(),
      closeToVector3(Vector3(3.9547989, 2.5166633, 5.8331786)),
    );
  });
}
