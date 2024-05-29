import 'package:native_device_orientation/native_device_orientation.dart';

import 'axis3d.dart';
import 'orientation_event.dart';

/// A standard 3-axis right-handed Cartesian coordinate system to express
/// orientation data value.
abstract class CoordinateSystem {
  const CoordinateSystem();

  factory CoordinateSystem.device() => DeviceCoordinateSystem.instance;

  factory CoordinateSystem.display() => DisplayCoordinateSystem.instance;

  factory CoordinateSystem.transformed(
    Axis3D newX,
    Axis3D newY,
    CoordinateSystem base,
  ) = TransformedCoordinateSystem;

  void apply(OrientationEvent event);
}

/// The device coordinate system is defined relative to the device's screen when
/// the device is held in its default orientation. The X axis is horizontal and
/// points to the right, the Y axis is vertical and points up, and the Z axis
/// points toward the outside of the screen face. In this system, coordinates
/// behind the screen have negative Z values.
class DeviceCoordinateSystem extends CoordinateSystem {
  static const DeviceCoordinateSystem instance = DeviceCoordinateSystem._();

  const DeviceCoordinateSystem._();

  @override
  void apply(OrientationEvent event) {
    // no-op
  }
}

class DisplayCoordinateSystem extends CoordinateSystem {
  static final DisplayCoordinateSystem instance = DisplayCoordinateSystem._();

  final NativeDeviceOrientationCommunicator _communicator =
      NativeDeviceOrientationCommunicator();
  NativeDeviceOrientation _orientation = NativeDeviceOrientation.portraitUp;

  DisplayCoordinateSystem._() {
    _communicator.onOrientationChanged().listen((orientation) {
      _orientation = orientation;
    });
  }

  @override
  void apply(OrientationEvent event) {
    switch (_orientation) {
      case NativeDeviceOrientation.portraitUp:
        break;
      case NativeDeviceOrientation.portraitDown:
        event.remapCoordinateSystem(-Axis3D.X, -Axis3D.Y);
      case NativeDeviceOrientation.landscapeLeft:
        event.remapCoordinateSystem(Axis3D.Y, -Axis3D.X);
      case NativeDeviceOrientation.landscapeRight:
        event.remapCoordinateSystem(-Axis3D.Y, Axis3D.X);
      case NativeDeviceOrientation.unknown:
        throw StateError('Cannot get display orientation.');
    }
  }
}

class TransformedCoordinateSystem extends CoordinateSystem {
  final CoordinateSystem base;
  final Axis3D newX;
  final Axis3D newY;

  TransformedCoordinateSystem(this.newX, this.newY, [CoordinateSystem? base])
      : base = base ?? DisplayCoordinateSystem.instance;

  @override
  void apply(OrientationEvent event) {
    base.apply(event);
    event.remapCoordinateSystem(newX, newY);
  }
}
