import 'dart:math';

import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  test('constructor returns an axis-angle with correct component', () {
    final a = AxisAngle(Vector3(1, 0, 0), 1);
    expect(a.axis.x, equals(1));
    expect(a.axis.y, equals(0));
    expect(a.axis.z, equals(0));
    expect(a.angle, equals(1));
  });

  test('toQuaternion converts this axis-angle to quaternion', () {
    expect(
      AxisAngle(Vector3(0, 0, 1), pi / 2).toQuaternion(),
      closeToQuaternion(Quaternion(0, 0, sin(pi / 4), cos(pi / 4))),
    );
    expect(
      AxisAngle(Vector3(0, 0, 0), 0).toQuaternion(),
      closeToQuaternion(Quaternion(0, 0, 0, 1)),
    );
  });
}
