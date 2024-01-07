import 'package:meta/meta.dart';
import 'package:vector_math/vector_math.dart';

/// Represents an axis of a 3D coordinate system, internally storing a unit
/// vector that indicates the direction of the axis.
@immutable
class Axis {
  /// Represents an invalid axis, often used as a placeholder or error state.
  static final invalid = Axis._(Vector3(0, 0, 0));

  /// Represents the X-axis of a 3D coordinate system.
  static final X = Axis._(Vector3(1, 0, 0));

  /// Represents the Y-axis of a 3D coordinate system.
  static final Y = Axis._(Vector3(0, 1, 0));

  /// Represents the Z-axis of a 3D coordinate system.
  static final Z = Axis._(Vector3(0, 0, 1));

  /// The vector representation of the axis.
  final Vector3 _vector;

  /// Constructs a Axis.
  const Axis._(this._vector);

  /// Negates the axis vector, effectively representing the axis in the opposite
  /// direction.
  Axis operator -() => Axis._(-_vector);

  /// Computes the cross product of this axis with another [Axis], resulting in
  /// a new Axis that is orthogonal to both.
  Axis operator *(Axis other) => Axis._(_vector.cross(other._vector));

  /// The vector representation of the axis.
  Vector3 get vector => Vector3.copy(_vector);

  /// Determines whether the current Axis is equal to another object. Returns
  /// true if the other object is an Axis with the same vector direction.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Axis &&
          runtimeType == other.runtimeType &&
          _vector == other._vector;

  @override
  int get hashCode => _vector.hashCode;

  /// Converts the Axis to a human-readable string, identifying the Axis by its
  /// standard Cartesian coordinate name.
  @override
  String toString() {
    if (this == X) return 'X';
    if (this == Y) return 'Y';
    if (this == Z) return 'Z';
    if (this == -X) return '-X';
    if (this == -Y) return '-Y';
    if (this == -Z) return '-Z';
    return 'Invalid';
  }
}
