import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

const delta = 1e-6;

Matcher closeToVector3(Vector3 o, [num delta = delta]) => isA<Vector3>()
    .having((v) => v.x, 'x', closeTo(o.x, delta))
    .having((v) => v.y, 'y', closeTo(o.y, delta))
    .having((v) => v.z, 'z', closeTo(o.z, delta));

Matcher closeToMatrix3(Matrix3 o, [num delta = delta]) => isA<Matrix3>()
    .having((m) => m.a, 'a', closeTo(o.a, delta))
    .having((m) => m.b, 'b', closeTo(o.b, delta))
    .having((m) => m.c, 'c', closeTo(o.c, delta))
    .having((m) => m.d, 'd', closeTo(o.d, delta))
    .having((m) => m.e, 'e', closeTo(o.e, delta))
    .having((m) => m.f, 'f', closeTo(o.f, delta))
    .having((m) => m.g, 'g', closeTo(o.g, delta))
    .having((m) => m.h, 'h', closeTo(o.h, delta))
    .having((m) => m.i, 'i', closeTo(o.i, delta));

Matcher closeToQuaternion(Quaternion o, [num delta = delta]) =>
    isA<Quaternion>()
        .having((q) => q.x, 'x', closeTo(o.x, delta))
        .having((q) => q.y, 'y', closeTo(o.y, delta))
        .having((q) => q.z, 'z', closeTo(o.z, delta))
        .having((q) => q.w, 'w', closeTo(o.w, delta));

Matcher closeToAxisAngle(AxisAngle o, [num delta = delta]) => isA<AxisAngle>()
    .having((a) => a.axis, 'axis', closeToVector3(o.axis, delta))
    .having((a) => a.angle, 'angle', closeTo(o.angle, delta));

Matcher closeToEulerAngles(EulerAngles expected, [num delta = delta]) =>
    isA<EulerAngles>()
        .having((ea) => ea.azimuth, 'azimuth', closeTo(expected.azimuth, delta))
        .having((ea) => ea.pitch, 'pitch', closeTo(expected.pitch, delta))
        .having((ea) => ea.roll, 'roll', closeTo(expected.roll, delta));

Matcher closeToOrientationEvent(
  OrientationEvent expected, [
  num delta = delta,
]) =>
    isA<OrientationEvent>()
        .having(
          (e) => e.quaternion,
          'quaternion',
          closeToQuaternion(expected.quaternion, delta),
        )
        .having(
          (e) => e.accuracy,
          'accuracy',
          closeTo(expected.accuracy, delta),
        )
        .having(
          (e) => e.coordinateSystem,
          'coordinateSystem',
          equals(expected.coordinateSystem),
        )
        .having((e) => e.timestamp, 'timestamp', equals(expected.timestamp));
