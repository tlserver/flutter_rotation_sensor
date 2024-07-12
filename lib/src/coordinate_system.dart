import 'dart:async';

import 'package:meta/meta.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'math/axis3.dart';
import 'orientation_event.dart';

/// A standard 3-axis right-handed Cartesian coordinate system to express
/// orientation data value.
abstract class CoordinateSystem {
  const CoordinateSystem();

  factory CoordinateSystem.device() = DeviceCoordinateSystem;

  factory CoordinateSystem.display() = DisplayCoordinateSystem;

  factory CoordinateSystem.transformed(
    Axis3 newX,
    Axis3 newY, [
    CoordinateSystem? base,
  ]) = TransformedCoordinateSystem;

  OrientationEvent apply(OrientationEvent event);
}

/// The device coordinate system is defined relative to the device's screen when
/// the device is held in its default orientation. The X axis is horizontal and
/// points to the right, the Y axis is vertical and points up, and the Z axis
/// points toward the outside of the screen face. In this system, coordinates
/// behind the screen have negative Z values.
class DeviceCoordinateSystem extends CoordinateSystem {
  static const DeviceCoordinateSystem instance = DeviceCoordinateSystem._();

  factory DeviceCoordinateSystem() => instance;

  const DeviceCoordinateSystem._();

  @override
  OrientationEvent apply(OrientationEvent event) => event;
}

class DisplayCoordinateSystem extends CoordinateSystem {
  static final DisplayCoordinateSystem instance = DisplayCoordinateSystem._();

  late NativeDeviceOrientationCommunicator _communicator;

  @visibleForTesting
  NativeDeviceOrientationCommunicator get communicator => _communicator;

  @visibleForTesting
  set communicator(NativeDeviceOrientationCommunicator value) {
    _communicator = value;
    _orientationStreamSubscription?.cancel();
    _orientationStreamSubscription = value.onOrientationChanged().listen(
          (o) => orientation = o,
        );
  }

  StreamSubscription<NativeDeviceOrientation>? _orientationStreamSubscription;

  @visibleForTesting
  NativeDeviceOrientation orientation = NativeDeviceOrientation.portraitUp;

  factory DisplayCoordinateSystem() => instance;

  DisplayCoordinateSystem._() {
    communicator = NativeDeviceOrientationCommunicator();
  }

  @override
  OrientationEvent apply(OrientationEvent event) {
    switch (orientation) {
      case NativeDeviceOrientation.portraitUp:
        return event;
      case NativeDeviceOrientation.portraitDown:
        return event.remapCoordinateSystem(-Axis3.X, -Axis3.Y);
      case NativeDeviceOrientation.landscapeLeft:
        return event.remapCoordinateSystem(-Axis3.Y, Axis3.X);
      case NativeDeviceOrientation.landscapeRight:
        return event.remapCoordinateSystem(Axis3.Y, -Axis3.X);
      case NativeDeviceOrientation.unknown:
        throw StateError('Cannot get display orientation.');
    }
  }
}

class TransformedCoordinateSystem extends CoordinateSystem {
  final CoordinateSystem base;
  final Axis3 newX;
  final Axis3 newY;

  TransformedCoordinateSystem(this.newX, this.newY, [CoordinateSystem? base])
      : base = base ?? CoordinateSystem.display();

  @override
  OrientationEvent apply(OrientationEvent event) {
    event = base.apply(event);
    return event.remapCoordinateSystem(newX, newY);
  }
}
