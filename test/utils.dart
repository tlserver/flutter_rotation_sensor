import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

const delta = 1e-6;

Matcher closeToNum(num o, [num delta = delta]) => closeTo(o, delta);

Matcher closeToVector3(Vector3 o, [num delta = delta]) => isA<Vector3>()
    .having((v) => v.x, 'x', closeToNum(o.x))
    .having((v) => v.y, 'y', closeToNum(o.y))
    .having((v) => v.z, 'z', closeToNum(o.z));

Matcher closeToMatrix3(Matrix3 o, [num delta = delta]) => isA<Matrix3>()
    .having((m) => m.a, 'a', closeToNum(o.a))
    .having((m) => m.b, 'b', closeToNum(o.b))
    .having((m) => m.c, 'c', closeToNum(o.c))
    .having((m) => m.d, 'd', closeToNum(o.d))
    .having((m) => m.e, 'e', closeToNum(o.e))
    .having((m) => m.f, 'f', closeToNum(o.f))
    .having((m) => m.g, 'g', closeToNum(o.g))
    .having((m) => m.h, 'h', closeToNum(o.h))
    .having((m) => m.i, 'i', closeToNum(o.i));

Matcher closeToQuaternion(Quaternion o, [num delta = delta]) =>
    isA<Quaternion>()
        .having((q) => q.x, 'x', closeToNum(o.x))
        .having((q) => q.y, 'y', closeToNum(o.y))
        .having((q) => q.z, 'z', closeToNum(o.z))
        .having((q) => q.w, 'w', closeToNum(o.w));

Matcher closeToAxisAngle(AxisAngle o, [num delta = delta]) => isA<AxisAngle>()
    .having((a) => a.axis, 'axis', closeToVector3(o.axis, delta))
    .having((a) => a.angle, 'angle', closeToNum(o.angle));

Matcher closeToEulerAngles(EulerAngles expected, [num delta = delta]) =>
    isA<EulerAngles>()
        .having((ea) => ea.azimuth, 'azimuth', closeToNum(expected.azimuth))
        .having((ea) => ea.pitch, 'pitch', closeToNum(expected.pitch))
        .having((ea) => ea.roll, 'roll', closeToNum(expected.roll));

Matcher closeToOrientationEvent(
  OrientationEvent expected, [
  num delta = delta,
]) => isA<OrientationEvent>()
    .having(
      (e) => e.quaternion,
      'quaternion',
      closeToQuaternion(expected.quaternion, delta),
    )
    .having((e) => e.accuracy, 'accuracy', closeToNum(expected.accuracy))
    .having(
      (e) => e.coordinateSystem,
      'coordinateSystem',
      closeToMatrix3(expected.coordinateSystem),
    )
    .having((e) => e.timestamp, 'timestamp', equals(expected.timestamp));
