import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_rotation_sensor/src/rotation_sensor_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = RotationSensorMethodChannel();
  const methodChannel = RotationSensorMethodChannel.methodChannel;
  const orientationChannel = RotationSensorMethodChannel.eventChannel;
  late int expectedSamplingPeriod;
  late ReferenceFrame expectedReferenceFrame;

  setUp(() {
    expectedSamplingPeriod = platform.samplingPeriod.inMicroseconds;
    expectedReferenceFrame = platform.referenceFrame;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (methodCall) async {
          switch (methodCall.method) {
            case 'getOrientationStream':
              final arguments = methodCall.arguments as Map;
              final samplingPeriod = arguments['samplingPeriod'] as int;
              expect(samplingPeriod, expectedSamplingPeriod);
              final referenceFrame = arguments['referenceFrame'] as String;
              expect(referenceFrame, expectedReferenceFrame.name);
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
              sink.success([
                // Quaternion
                0.0, 0.0, 0.0, 1.0,
                // Accuracy
                -1.0,
                // Timestamp
                123456789,
              ]);
            },
          ),
        );
  });

  tearDown(() {
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

  test(
    'orientationStream forwards the configured reference frame to the platform',
    () async {
      expectedReferenceFrame = ReferenceFrame.magneticNorth;
      platform.referenceFrame = ReferenceFrame.magneticNorth;
      expect(platform.referenceFrame, equals(ReferenceFrame.magneticNorth));
      await Future.microtask(() => null);
      expect(await platform.orientationStream.first, isA<OrientationEvent>());
    },
  );
}
