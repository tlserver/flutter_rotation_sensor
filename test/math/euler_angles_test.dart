import 'dart:math';

import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  test('constructor sets azimuth, pitch, and roll correctly', () {
    const azimuth = pi / 2; // 90 degrees
    const pitch = pi / 4; // 45 degrees
    const roll = -pi / 6; // -30 degrees
    final eulerAngles = EulerAngles(azimuth, pitch, roll);

    expect(eulerAngles.azimuth, closeToNum(azimuth));
    expect(eulerAngles.pitch, closeToNum(pitch));
    expect(eulerAngles.roll, closeToNum(roll));
  });

  test('azimuth returns the correct value', () {
    const azimuth = pi / 3; // 60 degrees
    final eulerAngles = EulerAngles(azimuth, 0, 0);

    expect(eulerAngles.azimuth, closeToNum(azimuth));
  });

  test('pitch returns the correct value', () {
    const pitch = -pi / 4; // -45 degrees
    final eulerAngles = EulerAngles(0, pitch, 0);

    expect(eulerAngles.pitch, closeToNum(pitch));
  });

  test('roll returns the correct value', () {
    const roll = pi; // 180 degrees
    final eulerAngles = EulerAngles(0, 0, roll);

    expect(eulerAngles.roll, closeToNum(roll));
  });

  test('yaw is equivalent to azimuth', () {
    const azimuth = pi / 2; // 90 degrees
    final eulerAngles = EulerAngles(azimuth, 0, 0);

    expect(eulerAngles.yaw, closeToNum(eulerAngles.azimuth));
  });

  test('azimuth is normalized to the range 0 to 2π', () {
    final eulerAngles = EulerAngles(-2 * pi, 0, 0);

    expect(eulerAngles.azimuth, closeToNum(0));
  });

  test('pitch is within the range -π/2 to π/2', () {
    const pitchAngles = [
      -pi / 2, // -90 degrees
      pi / 4, // 45 degrees
      pi / 2, // 90 degrees
    ];
    for (final pitchAngle in pitchAngles) {
      final eulerAngles1 = EulerAngles(0, pitchAngle, 0);
      expect(eulerAngles1.pitch, closeToNum(pitchAngle));
    }
  });

  test('pitch outside -π/2 to π/2 throws InvalidPitchException', () {
    expect(
          () => EulerAngles(0, pi, 0),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('roll is normalized to the range -π to π', () {
    final eulerAngles = EulerAngles(0, 0, -3 * pi);

    expect(eulerAngles.roll, closeToNum(pi));
  });

  test('toRotationMatrix converts to matrix', () {
    expect(
      EulerAngles(0.1, 0.2, 0.3).toRotationMatrix(),
      closeToMatrix3(
        Matrix3(
          //@formatter:off
           0.9564251,  0.0978434,  0.2750959,
          -0.0369570,  0.9751703, -0.2183507,
          -0.2896295,  0.1986693,  0.9362934,
          //@formatter:on
        ),
      ),
    );
  });
}
