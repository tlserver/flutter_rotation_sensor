import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rotation_sensor/rotation_sensor.dart';

const threshold = 0.000001;

void main() {
  test('Constructor should set azimuth, pitch, and roll correctly', () {
    const azimuth = pi / 2; // 90 degrees
    const pitch = pi / 4; // 45 degrees
    const roll = -pi / 6; // -30 degrees

    final eulerAngles = EulerAngles(azimuth, pitch, roll);

    expect(eulerAngles.azimuth, closeTo(azimuth, threshold));
    expect(eulerAngles.pitch, closeTo(pitch, threshold));
    expect(eulerAngles.roll, closeTo(roll, threshold));
  });

  test('Azimuth getter should return the correct value', () {
    const azimuth = pi / 3; // 60 degrees
    final eulerAngles = EulerAngles(azimuth, 0, 0);

    expect(eulerAngles.azimuth, closeTo(azimuth, threshold));
  });

  test('Pitch getter should return the correct value', () {
    const pitch = -pi / 4; // -45 degrees
    final eulerAngles = EulerAngles(0, pitch, 0);

    expect(eulerAngles.pitch, closeTo(pitch, threshold));
  });

  test('Roll getter should return the correct value', () {
    const roll = pi; // 180 degrees
    final eulerAngles = EulerAngles(0, 0, roll);

    expect(eulerAngles.roll, closeTo(roll, threshold));
  });

  test('Yaw should be equivalent to azimuth', () {
    const azimuth = pi / 2; // 90 degrees
    final eulerAngles = EulerAngles(azimuth, 0, 0);

    expect(eulerAngles.yaw, closeTo(eulerAngles.azimuth, threshold));
  });

  test('Azimuth angles should be within the range of 0 to 2π', () {
    final eulerAngles = EulerAngles(-2 * pi, 0, 0);

    expect(eulerAngles.azimuth, closeTo(0, threshold));
  });

  test('Pitch angle should be within the range of -π/2 to π/2', () {
    const pitchAngles = [
      -pi / 2, // -90 degrees
      pi / 4, // 45 degrees
      pi / 2, // 90 degrees
    ];
    for (final pitchAngle in pitchAngles) {
      final eulerAngles1 = EulerAngles(0, pitchAngle, 0);
      expect(eulerAngles1.pitch, closeTo(pitchAngle, threshold));
    }
  });

  test(
    'Pitch angle out of the range of -π/2 to π/2 throws '
    'InvalidPitchException',
    () {
      expect(
        () => EulerAngles(0, pi, 0),
        throwsA(isA<UnsupportedError>()),
      );
    },
  );

  test('Azimuth and roll angles should be within the range of -π to π', () {
    final eulerAngles = EulerAngles(0, 0, -3 * pi);

    expect(eulerAngles.roll, closeTo(pi, threshold));
  });
}
