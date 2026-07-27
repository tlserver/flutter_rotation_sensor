import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'axis_angle.dart';
import 'float32_list.dart';
import 'matrix3.dart';
import 'vector3.dart';

/// A class representing a quaternion.
///
/// The quaternion number system extends the complex numbers. Quaternions have
/// practical uses in applied mathematics, particularly for calculations
/// involving three-dimensional rotations, such as in three-dimensional computer
/// graphics, computer vision, magnetic resonance imaging and crystallographic
/// texture analysis. They can be used alongside other methods of rotation, such
/// as Euler angles and rotation matrices, or as an alternative to them,
/// depending on the application.
@immutable
class Quaternion {
  final Float32List _qStorage;

  /// Constructs a Quaternion with given x, y, z, w components
  Quaternion(num x, num y, num z, num w) : _qStorage = numList([x, y, z, w]);

  /// constructs an identity Quaternion (0, 0, 0, 1)
  factory Quaternion.identity() => Quaternion(0, 0, 0, 1);

  /// Determines whether this quaternion is equal to another object. Returns
  /// true if the other object is an Quaternion with the same components.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quaternion &&
          x == other.x &&
          y == other.y &&
          z == other.z &&
          w == other.w;

  @override
  int get hashCode => Object.hash(x, y, z, w);

  @override
  String toString() => '$x, $y, $z @ $w';

  /// The x component of the quaternion.
  double get x => _qStorage[0];

  /// The y component of the quaternion.
  double get y => _qStorage[1];

  /// The z component of the quaternion.
  double get z => _qStorage[2];

  /// The w component of the quaternion.
  double get w => _qStorage[3];

  /// Negates this quaternion.
  Quaternion operator -() => Quaternion(-x, -y, -z, -w);

  /// Adds this quaternion with another [Quaternion].
  Quaternion operator +(Quaternion o) =>
      Quaternion(x + o.x, y + o.y, z + o.z, w + o.w);

  /// Subtracts another [Quaternion] from this quaternion.
  Quaternion operator -(Quaternion o) =>
      Quaternion(x - o.x, y - o.y, z - o.z, w - o.w);

  /// Multiplies this quaternion.
  Quaternion operator *(dynamic o) {
    switch (o) {
      case num n:
        return Quaternion(x * n, y * n, z * n, w * n);
      case Vector3 v:
        return this * Quaternion(v.x, v.y, v.z, 0);
      case Matrix3 m:
        return this * m.toQuaternion();
      // Computes the Hamilton product of this quaternion with another
      // [Quaternion].
      case Quaternion q:
        return Quaternion(
          w * q.x + x * q.w + y * q.z - z * q.y,
          w * q.y + y * q.w + z * q.x - x * q.z,
          w * q.z + z * q.w + x * q.y - y * q.x,
          w * q.w - x * q.x - y * q.y - z * q.z,
        );
      default:
        throw UnsupportedError(
          'Unsupported operand type for *: ${o.runtimeType}',
        );
    }
  }

  /// Divides this quaternion by a scalar.
  Quaternion operator /(num s) => Quaternion(x / s, y / s, z / s, w / s);

  /// The squared length of this quaternion.
  double get length2 => x * x + y * y + z * z + w * w;

  /// The length (magnitude) of this quaternion.
  double get length => sqrt(length2);

  /// Normalizes this quaternion.
  Quaternion normalize() {
    final l = length;
    if (l == 0) {
      return this;
    } else {
      return this / l;
    }
  }

  /// Returns the conjugate of this quaternion.
  Quaternion conjugate() => Quaternion(-x, -y, -z, w);

  /// Inverts the quaternion.
  Quaternion invert() {
    final l = length2;
    return Quaternion(-x / l, -y / l, -z / l, w / l);
  }

  /// Applies a function [f] to each component of this quaternion and returns a
  /// new [Quaternion].
  Quaternion apply(num Function(num) f) => Quaternion(f(x), f(y), f(z), f(w));

  /// Converts quaternion to axis-angle representation.
  AxisAngle toAxisAngle() {
    final l = length;
    if (l == 0) {
      throw StateError(
        'Cannot convert a zero quaternion to an axis-angle representation.',
      );
    } else if ((l - 1).abs() > 0.000001) {
      final a = normalize().toAxisAngle();
      return AxisAngle(a.axis * length2, a.angle);
    } else {
      final d = 1 - (w * w);
      if (d < 0.000001) {
        return AxisAngle(Vector3(1, 0, 0), 0);
      } else {
        final s = sqrt(d);
        return AxisAngle(Vector3(x / s, y / s, z / s).normalize(), 2 * acos(w));
      }
    }
  }

  /// Converts quaternion to rotation matrix.
  Matrix3 toRotationMatrix() {
    final l = length2;

    final x2 = x * 2;
    final y2 = y * 2;
    final z2 = z * 2;

    final wx = w * x2;
    final wy = w * y2;
    final wz = w * z2;
    final xx = x * x2;
    final xy = x * y2;
    final xz = x * z2;
    final yy = y * y2;
    final yz = y * z2;
    final zz = z * z2;

    return Matrix3(
      // @formatter:off
      // dart format off
      l - yy - zz,     xy - wz,     xz + wy,
          xy + wz, l - xx - zz,     yz - wx,
          xz - wy,     yz + wx, l - xx - yy,
      // dart format on
      // @formatter:on
    );
  }

  /// Converts quaternion to a point vector if w is 0.
  Vector3 toVector3() {
    if (w.abs() > 0.000001) {
      throw UnsupportedError(
        'Cannot convert a quaternion with w != 0 to a vector.',
      );
    }
    return Vector3(x, y, z);
  }
}
