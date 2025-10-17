import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A 3D vector class for representing and manipulating vectors in
/// three-dimensional space.
@immutable
class Vector3 {
  final Float32List _v3Storage;

  /// Constructs a [Vector3] with the given [x], [y], and [z] components.
  Vector3(double x, double y, double z)
    : _v3Storage = Float32List.fromList([x, y, z]);

  /// Constructs a [Vector3] initialized to zero (0, 0, 0).
  Vector3.zero() : _v3Storage = Float32List(3);

  /// Determines whether this vector is equal to another object. Returns true if
  /// the other object is an Vector3 with the same components.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vector3 && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => '[$x,$y,$z]';

  /// The x component of the vector.
  double get x => _v3Storage[0];

  /// The y component of the vector.
  double get y => _v3Storage[1];

  /// The z component of the vector.
  double get z => _v3Storage[2];

  /// Negates this vector.
  Vector3 operator -() => Vector3(-x, -y, -z);

  /// Adds this vector with another [Vector3].
  Vector3 operator +(Vector3 o) => Vector3(x + o.x, y + o.y, z + o.z);

  /// Subtracts another [Vector3] from this vector.
  Vector3 operator -(Vector3 o) => Vector3(x - o.x, y - o.y, z - o.z);

  /// Multiplies this vector by a scalar.
  Vector3 operator *(double s) => Vector3(x * s, y * s, z * s);

  /// Divides this vector by a scalar.
  Vector3 operator /(double s) => Vector3(x / s, y / s, z / s);

  /// Computes the dot product of this vector with another [Vector3].
  double dot(Vector3 o) => x * o.x + y * o.y + z * o.z;

  /// Computes the cross product of this vector with another [Vector3].
  Vector3 cross(Vector3 o) =>
      Vector3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);

  /// The squared length of this vector.
  double get length2 => x * x + y * y + z * z;

  /// The length (magnitude) of this vector.
  double get length => sqrt(length2);

  /// Normalizes this vector.
  Vector3 normalize() {
    final l = length;
    if (l == 0) {
      return this;
    } else {
      return this / l;
    }
  }

  /// Applies a function [f] to each component of this vector and returns a new
  /// [Vector3].
  Vector3 apply(double Function(double) f) => Vector3(f(x), f(y), f(z));
}
