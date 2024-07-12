import 'dart:math';

import 'package:meta/meta.dart';

import 'quaternion.dart';
import 'vector3.dart';

@immutable
class AxisAngle {
  final Vector3 axis;
  final double angle;

  /// Constructs an AxisAngle.
  const AxisAngle(this.axis, this.angle);

  /// Converts this axis-angle representation to a quaternion.
  Quaternion toQuaternion() {
    final a = angle * 0.5;
    final s = sin(a);
    return Quaternion(s * axis.x, s * axis.y, s * axis.z, cos(a));
  }
}
