import 'dart:async';

import 'package:meta/meta.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'math/axis3.dart';
import 'orientation_event.dart';

/// An abstract class representing a standard 3-axis right-handed Cartesian
/// coordinate system to express orientation data values.
// ignore: one_member_abstracts
abstract class CoordinateSystem {
  const CoordinateSystem();

  factory CoordinateSystem.device() = DeviceCoordinateSystem;

  factory CoordinateSystem.display() = DisplayCoordinateSystem;

  factory CoordinateSystem.transformed(
    Axis3 newX,
    Axis3 newY, [
    CoordinateSystem? base,
  ]) = TransformedCoordinateSystem;

  /// Applies the coordinate system transformation to the given orientation
  /// event.
  OrientationEvent apply(OrientationEvent event);
}

/// A coordinate system defined relative to the device's screen when the device
/// is held in its default orientation, which is the orientation that the system
/// first uses for its boot logo, or the orientation in which the hardware logos
/// or markings are upright, or the orientation in which the cameras are at the
/// top.
///
/// - X axis: Horizontal, points to the right of the screen in its default
///           orientation.
/// - Y axis: Vertical, points up in device's default orientation.
/// - Z axis: Points toward the outside of the screen. Coordinates behind the
///           screen have negative Z values.
class DeviceCoordinateSystem extends CoordinateSystem {
  static const DeviceCoordinateSystem instance = DeviceCoordinateSystem._();

  factory DeviceCoordinateSystem() => instance;

  const DeviceCoordinateSystem._();

  @override
  OrientationEvent apply(OrientationEvent event) => event;
}

/// A coordinate system that adapts to the device's current orientation. It
/// adjusts based on the device's rotation.
///
/// - X axis: Horizontal, points to the right of the current UI orientation.
/// - Y axis: Vertical, points up in current UI orientation.
/// - Z axis: Points toward the outside of the screen. Coordinates behind the
///           screen have negative Z values.
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

/// A coordinate system that applies a transformation on top of an optional base
/// coordinate system. If no base is provided, it defaults to the display
/// coordinate system.
///
/// This transformation allows you to remap the coordinate axes according to
/// your application's specific requirements. The new coordinate system is
/// defined as:
///
/// - X axis: Corresponds to the `newX` axis in the `base` coordinate system.
/// - Y axis: Corresponds to the `newY` axis in the `base` coordinate system.
/// - Z axis: Defined by the cross product of `newX` and `newY` axes in the
///           `base` coordinate system, ensuring a right-handed coordinate
///           system.
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
