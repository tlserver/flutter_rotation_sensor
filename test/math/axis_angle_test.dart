import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';
import 'data.dart';

void main() {
  test('constructor returns an axis-angle with correct component', () {
    final a = AxisAngle(Vector3(1, 0, 0), 1);
    expect(a.axis.x, equals(1));
    expect(a.axis.y, equals(0));
    expect(a.axis.z, equals(0));
    expect(a.angle, equals(1));
  });

  test('multiplication scales the axis', () {
    expect(
      AxisAngle(Vector3(1, 2, 3), 1) * 2,
      closeToAxisAngle(AxisAngle(Vector3(2, 4, 6), 1)),
    );
  });

  test('division scales the axis', () {
    expect(
      AxisAngle(Vector3(2, 4, 6), 1) / 2,
      closeToAxisAngle(AxisAngle(Vector3(1, 2, 3), 1)),
    );
  });

  test('normalize scales axis to unit length', () {
    expect(
      AxisAngle(Vector3(1, 2, 3), 4).normalize(),
      closeToAxisAngle(AxisAngle(Vector3(0.2672612, 0.5345225, 0.8017837), 4)),
    );
  });

  test('toQuaternion converts this axis-angle to quaternion', () {
    expect(xrAa.toQuaternion(), closeToQuaternion(xrQt));
    expect(yrAa.toQuaternion(), closeToQuaternion(yrQt));
    expect(zrAa.toQuaternion(), closeToQuaternion(zrQt));
    expect(ab1Aa.toQuaternion(), closeToQuaternion(ab1Qt));
    expect(ab1Aa2.toQuaternion(), closeToQuaternion(ab1Qt2));
  });
}
