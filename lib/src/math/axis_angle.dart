import 'dart:math';

import 'package:meta/meta.dart';

import 'quaternion.dart';
import 'vector3.dart';

/// A class representing an axis-angle rotation. The rotation is defined by an
/// axis and an angle of rotation around that axis.
@immutable
class AxisAngle {
  /// The axis represented by a [Vector3].
  final Vector3 axis;

  /// The angle in radians.
  final double angle;

  /// Constructs an AxisAngle.
  const AxisAngle(this.axis, this.angle);

  /// Multiplies the axis by the given scalar.
  AxisAngle operator *(num s) => AxisAngle(axis * s, angle);

  /// Divides the axis by the given scalar.
  AxisAngle operator /(num s) => AxisAngle(axis / s, angle);

  /// Normalizes the axis.
  AxisAngle normalize() => AxisAngle(axis.normalize(), angle);

  /// Converts this axis-angle representation to a quaternion.
  Quaternion toQuaternion() {
    final rl = sqrt(axis.length);
    final a = angle * 0.5;
    final s = sin(a) / rl;
    final c = cos(a) * rl;
    return Quaternion(s * axis.x, s * axis.y, s * axis.z, c);
  }
}
