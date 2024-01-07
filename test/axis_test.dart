import 'package:flutter_test/flutter_test.dart';
import 'package:rotation_sensor/rotation_sensor.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  test('Predefined axes should have correct unit vectors', () {
    expect(Axis.X.vector, Vector3(1, 0, 0));
    expect(Axis.Y.vector, Vector3(0, 1, 0));
    expect(Axis.Z.vector, Vector3(0, 0, 1));
    expect(Axis.invalid.vector, Vector3(0, 0, 0));
  });

  test('Negating an axis should reverse its direction', () {
    final negX = -Axis.X;
    final negY = -Axis.Y;
    final negZ = -Axis.Z;

    expect(negX.vector, Vector3(-1, 0, 0));
    expect(negY.vector, Vector3(0, -1, 0));
    expect(negZ.vector, Vector3(0, 0, -1));
  });

  test('Cross product of axes should produce correct orthogonal axis', () {
    final crossXY = Axis.X * Axis.Y;
    final crossYZ = Axis.Y * Axis.Z;
    final crossZX = Axis.Z * Axis.X;

    expect(crossXY.vector, Axis.Z.vector);
    expect(crossYZ.vector, Axis.X.vector);
    expect(crossZX.vector, Axis.Y.vector);
  });

  test('Axis instances with the same vector should be equal', () {
    final axis1 = Axis.X;
    final axis2 = Axis.Y * Axis.Z;

    expect(axis1 == axis2, isTrue);
    expect(axis1.hashCode, axis2.hashCode);
  });

  test('toString should return the correct representation', () {
    expect(Axis.X.toString(), 'X');
    expect(Axis.Y.toString(), 'Y');
    expect(Axis.Z.toString(), 'Z');
    expect((-Axis.X).toString(), '-X');
    expect((-Axis.Y).toString(), '-Y');
    expect((-Axis.Z).toString(), '-Z');
    expect(Axis.invalid.toString(), 'Invalid');
  });
}
