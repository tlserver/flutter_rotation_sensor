import 'dart:async';

import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:flutter_rotation_sensor/src/rotation_sensor_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

@GenerateNiceMocks([MockSpec<NativeDeviceOrientationCommunicator>()])
import 'coordinate_system_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelRotationSensor();
  final binaryMessenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const methodChannel = MethodChannelRotationSensor.methodChannel;
  const orientationChannel = MethodChannelRotationSensor.eventChannel;
  // ignore: close_sinks
  late StreamController<void> oeStreamController;
  late int expectedSamplingPeriod;

  setUp(() {
    oeStreamController = StreamController<void>();
    expectedSamplingPeriod = platform.samplingPeriod.inMicroseconds;
    binaryMessenger
      ..setMockMethodCallHandler(
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
      )
      ..setMockStreamHandler(
        orientationChannel,
        MockStreamHandler.inline(
          onListen: (args, sink) => oeStreamController.stream.listen(
            (_) => sink.success([
              // Quaternion
              0.0, 0.0, 0.0, 1.0,
              // Accuracy
              -1.0,
              // Timestamp
              123456789,
            ]),
            onDone: () => sink.endOfStream(),
          ),
        ),
      );
  });

  tearDown(() async {
    await oeStreamController.sink.close();
    binaryMessenger
      ..setMockMethodCallHandler(methodChannel, null)
      ..setMockStreamHandler(orientationChannel, null);
  });

  test(
    'orientationStream emit OrientationEvent in device coordinate system',
    () async {
      platform.coordinateSystem = CoordinateSystem.device();
      oeStreamController.sink.add(null);
      final orientationEvent = await platform.orientationStream.first;
      expect(
        orientationEvent.coordinateSystem,
        equals(Matrix3.identity()),
      );
    },
  );

  test(
    'orientationStream emit OrientationEvent in display coordinate system',
    () async {
      final displayCoordinateSystem = DisplayCoordinateSystem();
      platform.coordinateSystem = displayCoordinateSystem;
      final ndoStreamController =
          StreamController<NativeDeviceOrientation>.broadcast();
      final mockCommunicator = MockNativeDeviceOrientationCommunicator();
      when(mockCommunicator.onOrientationChanged()).thenAnswer(
        (_) => ndoStreamController.stream,
      );
      displayCoordinateSystem.communicator = mockCommunicator;
      expect(displayCoordinateSystem.communicator, equals(mockCommunicator));

      final orientations = [
        NativeDeviceOrientation.portraitUp,
        NativeDeviceOrientation.landscapeRight,
        NativeDeviceOrientation.portraitDown,
        NativeDeviceOrientation.landscapeLeft,
      ];

      final orientationEventsFuture =
          platform.orientationStream.take(orientations.length).toList();
      for (final orientation in orientations) {
        ndoStreamController.sink.add(orientation);
        await Future.delayed(const Duration(microseconds: 1), () {});
        oeStreamController.sink.add(null);
        await Future.delayed(const Duration(microseconds: 1), () {});
      }
      final orientationEvents = await orientationEventsFuture;

      for (var t = 0, e = Matrix3.identity();
          t < orientationEvents.length;
          t++, e = e.multiply(Matrix3(0, -1, 0, 1, 0, 0, 0, 0, 1))) {
        final orientationEvent = orientationEvents[t];
        expect(
          orientationEvent.coordinateSystem,
          equals(e),
          reason: 'orientationEvents[$t]',
        );
      }

      ndoStreamController.sink.add(NativeDeviceOrientation.portraitUp);
      await ndoStreamController.close();
    },
  );

  test(
    'orientationStream emit error in display coordinate system',
    () async {
      final displayCoordinateSystem = DisplayCoordinateSystem();
      platform.coordinateSystem = displayCoordinateSystem;
      final ndoStreamController =
          StreamController<NativeDeviceOrientation>.broadcast();
      final mockCommunicator = MockNativeDeviceOrientationCommunicator();
      when(mockCommunicator.onOrientationChanged()).thenAnswer(
        (_) => ndoStreamController.stream,
      );
      displayCoordinateSystem.communicator = mockCommunicator;
      expect(displayCoordinateSystem.communicator, equals(mockCommunicator));

      ndoStreamController.sink.add(NativeDeviceOrientation.unknown);
      await Future.delayed(const Duration(microseconds: 1), () {});
      oeStreamController.sink.add(null);
      await Future.delayed(const Duration(microseconds: 1), () {});
      await expectLater(
        () => platform.orientationStream.first,
        throwsStateError,
      );

      ndoStreamController.sink.add(NativeDeviceOrientation.portraitUp);
      await ndoStreamController.close();
    },
  );

  test(
    'orientationStream emit OrientationEvent in transformed coordinate system',
    () async {
      platform.coordinateSystem = CoordinateSystem.transformed(
        Axis3.X,
        Axis3.Z,
        CoordinateSystem.transformed(
          Axis3.X,
          Axis3.Y,
        ),
      );
      oeStreamController.sink.add(null);
      final orientationEvent = await platform.orientationStream.first;
      expect(
        orientationEvent.coordinateSystem,
        equals(Matrix3(1, 0, 0, 0, 0, -1, 0, 1, 0)),
      );
    },
  );
}
