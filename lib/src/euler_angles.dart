import 'dart:math';

import 'package:vector_math/vector_math.dart';

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
class EulerAngles extends Vector3 {
  /// Angle of rotation about the -Z axis. This value represents the angle
  /// between the device's Y axis and the magnetic north pole (y-axis). When
  /// facing north, this angle is 0, when facing south, this angle is π.
  /// Likewise, when facing east, this angle is π/2, and when facing west, this
  /// angle is 3π/2. The range of values is 0(inclusive) to 2π(exclusive).
  double get azimuth => -z;

  /// Angle of rotation about the -Z axis. This value represents the angle
  /// between the device's Y axis and the magnetic north pole (y-axis). When
  /// facing north, this angle is 0, when facing south, this angle is π.
  /// Likewise, when facing east, this angle is π/2, and when facing west, this
  /// angle is 3π/2. The range of values is 0(inclusive) to 2π(exclusive).
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

  /// Constructs an EulerAngles.
  EulerAngles(double azimuth, double pitch, double roll) : super.zero() {
    azimuth %= twoPi;
    if (pitch.abs() > halfPi) {
      throw UnsupportedError(
        'The value $pitch is not a valid pitch angle. A valid pitch angle must '
        'be in the range -π/2 (inclusive) to π/2 (inclusive).',
      );
    }
    roll = -(-(roll + pi) % twoPi) + pi;
    setValues(pitch, roll, -azimuth);
  }
}
