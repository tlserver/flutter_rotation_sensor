import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'matrix3.dart';
import 'vector3.dart';

const twoPi = pi * 2;
const halfPi = pi / 2;

/// Represents the orientation as
/// [Euler angles](https://en.wikipedia.org/wiki/Euler_angles), which are angles
/// of rotation about each of the three principal axes. The sequence of
/// rotations follows the order of azimuth (yaw), pitch, and roll. All angles
/// are in radians. This plugin utilizes
/// [intrinsic](https://en.wikipedia.org/wiki/Euler_angles#Intrinsic_rotations)
/// [Tait-Bryan angles](https://en.wikipedia.org/wiki/Euler_angles#Tait%E2%80%93Bryan_angles),
/// indicating that rotations are performed relative to the rotating reference
/// frame of the device's coordinate system (XYZ axes).
@immutable
class EulerAngles {
  final Float32List _v3Storage;

  /// Constructs an EulerAngles.
  factory EulerAngles(double azimuth, double pitch, double roll) {
    azimuth %= twoPi;
    if (pitch.abs() > halfPi) {
      throw UnsupportedError(
        'The value $pitch is not a valid pitch angle. A valid pitch angle must '
        'be in the range -π/2 (inclusive) to π/2 (inclusive).',
      );
    }
    roll = -(-(roll + pi) % twoPi) + pi;
    return EulerAngles._(pitch, roll, -azimuth);
  }

  EulerAngles._(double x, double y, double z)
    : _v3Storage = Float32List.fromList([x, y, z]);

  /// Constructs an [EulerAngles] initialized to zero (0, 0, 0).
  EulerAngles.zero() : _v3Storage = Float32List(3);

  /// Determines whether this EulerAngles is equal to another object. Returns
  /// true if the other object is an EulerAngles with the same components.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vector3 && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => '[$x,$y,$z]';

  /// The x component of the Euler angles.
  double get x => _v3Storage[0];

  /// The y component of the Euler angles.
  double get y => _v3Storage[1];

  /// The z component of the Euler angles.
  double get z => _v3Storage[2];

  /// Angle of rotation about the -Z axis. This value represents the angle
  /// between the device's Y axis and the magnetic north pole (y-axis). When
  /// facing north, this angle is 0, when facing south, this angle is π.
  /// Likewise, when facing east, this angle is π/2, and when facing west, this
  /// angle is 3π/2. The range of values is 0(inclusive) to 2π(exclusive).
  ///
  /// This value is also known as [yaw].
  double get azimuth => -z;

  /// Angle of rotation about the -Z axis. This value represents the angle
  /// between the device's Y axis and the magnetic north pole (y-axis). When
  /// facing north, this angle is 0, when facing south, this angle is π.
  /// Likewise, when facing east, this angle is π/2, and when facing west, this
  /// angle is 3π/2. The range of values is 0(inclusive) to 2π(exclusive).
  ///
  /// This value is also known as [azimuth].
  double get yaw => -z;

  /// Angle of rotation about the X axis. This value represents the angle
  /// between a plane parallel to the device's screen and a plane parallel to
  /// the ground. Assuming that the bottom edge of the device faces the user and
  /// that the screen is face-up, tilting the top edge of the device toward the
  /// sky creates a positive pitch angle. The range of values is -π/2(inclusive)
  /// to π/2(inclusive).
  double get pitch => x;

  /// Angle of rotation about the Y axis. This value represents the angle
  /// between a plane perpendicular to the device's screen and a plane
  /// perpendicular to the ground. Assuming that the bottom edge of the device
  /// faces the user and that the screen is face-up, tilting the left edge of
  /// the device toward the sky creates a positive roll angle. The range of
  /// values is -π(exclusive) to π(inclusive).
  double get roll => y;

  /// Applies a function [f] to each component of this euler angles and returns
  /// a new [EulerAngles].
  EulerAngles apply(double Function(double) f) => EulerAngles(f(x), f(y), f(z));

  /// Converts this Euler angles to a rotation matrix.
  Matrix3 toRotationMatrix() {
    final cx = cos(x);
    final cy = cos(y);
    final cz = cos(z);
    final sx = sin(x);
    final sy = sin(y);
    final sz = sin(z);
    return Matrix3(
      cz * cy - sz * sx * sy,
      -cx * sz,
      cz * sy + cy * sz * sx,
      cy * sz + cz * sx * sy,
      cz * cx,
      sz * sy - cz * cy * sx,
      -cx * sy,
      sx,
      cx * cy,
    );
  }
}
