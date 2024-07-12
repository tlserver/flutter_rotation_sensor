import 'package:meta/meta.dart';

import 'vector3.dart';

/// Represents an axis of a 3D coordinate system, internally storing a unit
/// vector that indicates the direction of the axis.
@immutable
class Axis3 extends Vector3 {
  /// Represents an invalid axis, often used as a placeholder or error state.
  static final invalid = Axis3._(0, 0, 0);

  /// Represents the X-axis of a 3D coordinate system.
  static final X = Axis3._(1, 0, 0);

  /// Represents the Y-axis of a 3D coordinate system.
  static final Y = Axis3._(0, 1, 0);

  /// Represents the Z-axis of a 3D coordinate system.
  static final Z = Axis3._(0, 0, 1);

  Axis3._(super.x, super.y, super.z);

  /// Negates the axis vector, effectively representing the axis in the opposite
  /// direction.
  @override
  Axis3 operator -() => Axis3._(-x, -y, -z);

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
