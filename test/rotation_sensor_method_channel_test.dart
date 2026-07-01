import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_rotation_sensor/src/rotation_sensor_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = RotationSensorMethodChannel();
  const methodChannel = RotationSensorMethodChannel.methodChannel;
  const orientationChannel = RotationSensorMethodChannel.eventChannel;
  late int expectedSamplingPeriod;
  late String expectedReferenceFrame;
  late List<dynamic> orientationPayload;

  setUp(() {
    debugDefaultTargetPlatformOverride = null;
    expectedSamplingPeriod = platform.samplingPeriod.inMicroseconds;
    expectedReferenceFrame = platform.referenceFrame.name;
    RotationSensor.coordinateSystem = CoordinateSystem.device();
    orientationPayload = _payloadOfQuaternion(Quaternion.identity());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (methodCall) async {
          switch (methodCall.method) {
            case 'setSamplingPeriod':
              final samplingPeriod = methodCall.arguments as int;
              expect(samplingPeriod, expectedSamplingPeriod);
              return null;
            case 'setReferenceFrame':
              final referenceFrame = methodCall.arguments as String;
              expect(referenceFrame, expectedReferenceFrame);
              return null;
            default:
              throw UnsupportedError(methodCall.method);
          }
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
          orientationChannel,
          MockStreamHandler.inline(
            onListen: (args, sink) {
              sink.success(orientationPayload);
            },
          ),
        );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(orientationChannel, null);
  });

  test(
    'orientationStream emits OrientationEvent with default sampling period',
    () async {
      expect(await platform.orientationStream.first, isA<OrientationEvent>());
    },
  );

  test(
    'orientationStream emits OrientationEvent with a replaced sampling period '
    'when a reserved value is provided',
    () async {
      // samplingPeriod should be replaced with 0 since 1-3 is a reserved value
      // for Android.
      expectedSamplingPeriod = 0;
      platform.samplingPeriod = const Duration(microseconds: 1);
      expect(platform.samplingPeriod, equals(Duration.zero));
      await Future.microtask(() => null);
      expect(await platform.orientationStream.first, isA<OrientationEvent>());
    },
  );

  test('arbitraryCorrected frame are unconverted on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expectedReferenceFrame = 'arbitraryCorrected';
    platform.referenceFrame = .arbitraryCorrected;
    final event = await platform.orientationStream.first;
    expect(event.coordinateSystem, closeToMatrix3(Matrix3.identity()));
  });

  test(
    'north-referenced frames are converted from X-north to Y-north on iOS',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expectedReferenceFrame = 'trueNorth';
      platform.referenceFrame = .trueNorth;
      final event = await platform.orientationStream.first;
      expect(event.coordinateSystem, closeToMatrix3(Matrix3.rotateZ(pi / 2)));
    },
  );

  test(
    'north-referenced frames apply X-north to Y-north azimuth remap on iOS',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expectedReferenceFrame = 'magneticNorth';
      platform.referenceFrame = .magneticNorth;

      for (var n = 0; n < 4; n++) {
        final payloadAzimuth = n * pi / 2;
        final expectedAzimuth = ((n + 3) % 4) * pi / 2;
        orientationPayload = _payloadOfAzimuth(payloadAzimuth);
        final event = await platform.orientationStream.first;
        expect(event.eulerAngles.azimuth, closeTo(expectedAzimuth, delta));
      }
    },
  );

  test(
    'north-referenced frame preserves cardinal headings on Android',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expectedReferenceFrame = 'magneticNorth';
      platform.referenceFrame = .magneticNorth;

      for (var n = 0; n < 4; n++) {
        final payloadAzimuth = n * pi / 2;
        final expectedAzimuth = payloadAzimuth;
        orientationPayload = _payloadOfAzimuth(payloadAzimuth);
        final event = await platform.orientationStream.first;
        expect(event.eulerAngles.azimuth, closeTo(expectedAzimuth, delta));
      }
    },
  );
}

List<dynamic> _payloadOfQuaternion(
  Quaternion quaternion, {
  double accuracy = -1,
  int timestamp = 123456789,
}) => [
  quaternion.x,
  quaternion.y,
  quaternion.z,
  quaternion.w,
  accuracy,
  timestamp,
];

List<dynamic> _payloadOfAzimuth(double azimuth) => _payloadOfQuaternion(
  EulerAngles(azimuth, 0, 0).toRotationMatrix().toQuaternion().normalize(),
);
