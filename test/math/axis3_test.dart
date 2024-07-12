import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('predefined axes returns correct unit vectors', () {
    expect(Axis3.X, equals(Vector3(1, 0, 0)));
    expect(Axis3.Y, equals(Vector3(0, 1, 0)));
    expect(Axis3.Z, equals(Vector3(0, 0, 1)));
    expect(Axis3.invalid, equals(Vector3(0, 0, 0)));
  });

  test('negating axes reverse their direction', () {
    final negX = -Axis3.X;
    final negY = -Axis3.Y;
    final negZ = -Axis3.Z;

    expect(negX, equals(Vector3(-1, 0, 0)));
    expect(negY, equals(Vector3(0, -1, 0)));
    expect(negZ, equals(Vector3(0, 0, -1)));
  });

  test('cross product of axes produce correct orthogonal axis', () {
    final crossXY = Axis3.X.cross(Axis3.Y);
    final crossYZ = Axis3.Y.cross(Axis3.Z);
    final crossZX = Axis3.Z.cross(Axis3.X);

    expect(crossXY, equals(Axis3.Z));
    expect(crossYZ, equals(Axis3.X));
    expect(crossZX, equals(Axis3.Y));
  });

  test('axis instances with the same vector are equal', () {
    final axis1 = Axis3.X;
    final axis2 = Axis3.Y.cross(Axis3.Z);

    expect(axis1 == axis2, isTrue);
    expect(axis1.hashCode, equals(axis2.hashCode));
  });

  test('toString return the correct representation', () {
    expect(Axis3.X.toString(), equals('X'));
    expect(Axis3.Y.toString(), equals('Y'));
    expect(Axis3.Z.toString(), equals('Z'));
    expect((-Axis3.X).toString(), equals('-X'));
    expect((-Axis3.Y).toString(), equals('-Y'));
    expect((-Axis3.Z).toString(), equals('-Z'));
    expect(Axis3.invalid.toString(), equals('Invalid'));
  });
}
