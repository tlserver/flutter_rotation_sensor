import 'dart:math';

import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('constructor returns a vector with correct components', () {
    final v = Vector3(1, 2, 3);
    expect(v.x, 1);
    expect(v.y, 2);
    expect(v.z, 3);
  });

  test('zero constructor returns a zero vector', () {
    expect(Vector3.zero(), equals(Vector3(0, 0, 0)));
  });

  test('equality and hashCode', () {
    final v1 = Vector3(1, 2, 3);
    final v2 = Vector3(1, 2, 3);
    final v3 = Vector3(4, 5, 6);
    expect(v1 == v2, isTrue);
    expect(v1 == v3, isFalse);
    expect(v1.hashCode == v2.hashCode, isTrue);
    expect(v1.hashCode == v3.hashCode, isFalse);
  });

  test('toString returns the correct representation', () {
    expect(Vector3(1, 2, 3).toString(), equals('[1.0,2.0,3.0]'));
  });

  test('negation changes sign of each component', () {
    expect(-Vector3(1, 2, 3), equals(Vector3(-1, -2, -3)));
  });

  test('addition sums corresponding components', () {
    expect(Vector3(1, 2, 3) + Vector3(4, 5, 6), equals(Vector3(5, 7, 9)));
  });

  test('subtraction subtracts corresponding components', () {
    expect(Vector3(4, 5, 6) - Vector3(1, 2, 3), equals(Vector3(3, 3, 3)));
  });

  test('multiplication scales each component by a scalar', () {
    expect(Vector3(1, 2, 3) * 2, equals(Vector3(2, 4, 6)));
  });

  test('division scales each component by a scalar', () {
    expect(Vector3(4, 6, 8) / 2, equals(Vector3(2, 3, 4)));
  });

  test('dot product calculates scalar product of two vectors', () {
    expect(Vector3(1, 2, 3).dot(Vector3(4, 5, 6)), equals(32));
  });

  test('cross product calculates perpendicular vector', () {
    expect(Vector3(1, 0, 0).cross(Vector3(0, 1, 0)), equals(Vector3(0, 0, 1)));
  });

  test('length and length2 calculate vector magnitude and its square', () {
    final v = Vector3(3, 4, 0);
    expect(v.length2, equals(25));
    expect(v.length, equals(5));
  });

  test('normalize scales vector to unit length', () {
    expect(
      Vector3(3, 4, 0).normalize(),
      equals(
        // ignore: prefer_int_literals
        Vector3(0.6, 0.8, 0.0),
      ),
    );
    expect(Vector3(0, 0, 0).normalize(), equals(Vector3(0, 0, 0)));
  });

  test('apply function applies function to each component', () {
    expect(Vector3(1, 2, 3).apply((x) => min(x * 2, 5)), Vector3(2, 4, 5));
  });
}
