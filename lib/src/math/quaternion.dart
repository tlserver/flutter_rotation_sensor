import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'axis_angle.dart';
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
  Quaternion(double x, double y, double z, double w)
      : _qStorage = Float32List.fromList([x, y, z, w]);

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

  /// Multiplies this quaternion by a scalar.
  Quaternion operator *(double s) => Quaternion(x * s, y * s, z * s, w * s);

  /// Divides this quaternion by a scalar.
  Quaternion operator /(double s) => Quaternion(x / s, y / s, z / s, w / s);

  /// Computes the Hamilton product of this quaternion with another
  /// [Quaternion].
  Quaternion multiply(Quaternion o) => Quaternion(
        w * o.x + x * o.w + y * o.z - z * o.y,
        w * o.y + y * o.w + z * o.x - x * o.z,
        w * o.z + z * o.w + x * o.y - y * o.x,
        w * o.w - x * o.x - y * o.y - z * o.z,
      );

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
  Quaternion apply(double Function(double) f) =>
      Quaternion(f(x), f(y), f(z), f(w));

  /// Converts quaternion to axis-angle representation.
  AxisAngle toAxisAngle() {
    final d = 1 - (w * w);
    if (d < 0.00001) {
      return AxisAngle(Vector3.zero(), 0);
    } else {
      final s = sqrt(d);
      return AxisAngle(Vector3(x / s, y / s, z / s), 2 * acos(w));
    }
  }

  /// Converts quaternion to rotation matrix.
  Matrix3 toRotationMatrix() {
    final l = length2;
    assert(l != 0.0, 'Cannot convert a zero quaternion to rotation matrix.');
    final s = 2.0 / l;

    final xs = x * s;
    final ys = y * s;
    final zs = z * s;

    final wx = w * xs;
    final wy = w * ys;
    final wz = w * zs;
    final xx = x * xs;
    final xy = x * ys;
    final xz = x * zs;
    final yy = y * ys;
    final yz = y * zs;
    final zz = z * zs;

    return Matrix3(
      1 - yy - zz,
      xy - wz,
      xz + wy,
      xy + wz,
      1 - xx - zz,
      yz - wx,
      xz - wy,
      yz + wx,
      1 - xx - yy,
    );
  }
}
