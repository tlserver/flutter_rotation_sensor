import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'float32_list.dart';
import 'matrix3.dart';
import 'quaternion.dart';

/// A 3D vector class for representing and manipulating vectors in
/// three-dimensional space.
@immutable
class Vector3 {
  final Float32List _v3Storage;

  /// Constructs a [Vector3] with the given [x], [y], and [z] components.
  Vector3(num x, num y, num z) : _v3Storage = numList([x, y, z]);

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

  /// Multiplies this vector.
  Vector3 operator *(dynamic o) {
    switch (o) {
      case num n:
        return Vector3(x * n, y * n, z * n);
      case Vector3 v:
        return cross(v);
      case Matrix3 m:
        return Vector3(
          m.a * x + m.d * y + m.g * z,
          m.b * x + m.e * y + m.h * z,
          m.c * x + m.f * y + m.i * z,
        );
      default:
        throw UnsupportedError(
          'Unsupported operand type for *: ${o.runtimeType}',
        );
    }
  }

  /// Divides this vector by a scalar.
  Vector3 operator /(num s) => Vector3(x / s, y / s, z / s);

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
  Vector3 apply(num Function(num) f) => Vector3(f(x), f(y), f(z));

  /// Converts this vector to a quaternion with w = 0.
  Quaternion toQuaternion() => Quaternion(x, y, z, 0);
}
