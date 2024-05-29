import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotation_sensor/rotation_sensor.dart';
import 'package:rotation_sensor/src/rotation_sensor_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelRotationSensor();
  const methodChannel = MethodChannel('rotation_sensor/method');
  const orientationChannel = EventChannel('rotation_sensor/orientation');
  late int expectedSamplingPeriod;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      methodChannel,
      (methodCall) async {
        switch (methodCall.method) {
          case 'getOrientationStream':
            final arguments = methodCall.arguments as Map;
            final samplingPeriod = arguments['samplingPeriod'] as int;
            expect(samplingPeriod, expectedSamplingPeriod);
            return null;
          default:
            throw UnsupportedError(methodCall.method);
        }
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
      orientationChannel,
      MockStreamHandler.inline(
        onListen: (args, sink) {
          sink.success([
            // Quaternion
            0.0, 0.0, 0.0, 1.0,
            // accuracy
            -1.0,
            // timestamp
            123456789,
          ]);
        },
      ),
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test(
    'getOrientationStream emits OrientationEvent with default sampling period',
    () async {
      expectedSamplingPeriod = SensorInterval.normalInterval.inMicroseconds;
      expect(
        await platform.orientationStream.first,
        isA<OrientationEvent>(),
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(orientationChannel, null);
    },
  );

  test(
    'getOrientationStream emits OrientationEvent with a replaced sampling '
    'period when a reserved value is provided',
    () async {
      // samplingPeriod is should be replaced with 0 since 1-3 is a
      // reserved value for Android.
      expectedSamplingPeriod = 0;
      platform.samplingPeriod = const Duration(microseconds: 1);
      await Future.microtask(() => null);
      expect(
        await platform.orientationStream.first,
        isA<OrientationEvent>(),
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(orientationChannel, null);
    },
  );
}
