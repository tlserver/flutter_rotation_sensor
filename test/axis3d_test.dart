import 'package:flutter_test/flutter_test.dart';
import 'package:rotation_sensor/rotation_sensor.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  test('Predefined axes should have correct unit vectors', () {
    expect(Axis3D.X.vector, Vector3(1, 0, 0));
    expect(Axis3D.Y.vector, Vector3(0, 1, 0));
    expect(Axis3D.Z.vector, Vector3(0, 0, 1));
    expect(Axis3D.invalid.vector, Vector3(0, 0, 0));
  });

  test('Negating an axis should reverse its direction', () {
    final negX = -Axis3D.X;
    final negY = -Axis3D.Y;
    final negZ = -Axis3D.Z;

    expect(negX.vector, Vector3(-1, 0, 0));
    expect(negY.vector, Vector3(0, -1, 0));
    expect(negZ.vector, Vector3(0, 0, -1));
  });

  test('Cross product of axes should produce correct orthogonal axis', () {
    final crossXY = Axis3D.X * Axis3D.Y;
    final crossYZ = Axis3D.Y * Axis3D.Z;
    final crossZX = Axis3D.Z * Axis3D.X;

    expect(crossXY.vector, Axis3D.Z.vector);
    expect(crossYZ.vector, Axis3D.X.vector);
    expect(crossZX.vector, Axis3D.Y.vector);
  });

  test('Axis instances with the same vector should be equal', () {
    final axis1 = Axis3D.X;
    final axis2 = Axis3D.Y * Axis3D.Z;

    expect(axis1 == axis2, isTrue);
    expect(axis1.hashCode, axis2.hashCode);
  });

  test('toString should return the correct representation', () {
    expect(Axis3D.X.toString(), 'X');
    expect(Axis3D.Y.toString(), 'Y');
    expect(Axis3D.Z.toString(), 'Z');
    expect((-Axis3D.X).toString(), '-X');
    expect((-Axis3D.Y).toString(), '-Y');
    expect((-Axis3D.Z).toString(), '-Z');
    expect(Axis3D.invalid.toString(), 'Invalid');
  });
}
