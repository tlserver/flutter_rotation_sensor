import 'math/axis3.dart';
import 'math/euler_angles.dart';
import 'math/matrix3.dart';
import 'math/quaternion.dart';

/// Represents an orientation event detected by sensors, providing information
/// about the orientation of the device.
///
/// The device's coordinate system is defined relative to the screen in its
/// default orientation. It remains unchanged when the device's screen
/// orientation changes.
/// - X axis: Horizontal and points to the right.
/// - Y axis: Vertical and points up.
/// - Z axis: Points towards the outside of the front face of the screen.
/// Coordinates behind the screen have negative Z values.
///
/// The world coordinate system is defined as a direct orthonormal basis:
/// - x axis: Defined as the vector cross product y⨯z. It is tangential to the
/// ground at the device's current location and roughly points East.
/// - y axis: Tangential to the ground at the device's current location and
/// points towards magnetic north.
/// - z axis: Points towards the sky and is perpendicular to the ground.
///
/// A
/// [right-handed reference frame](https://en.wikipedia.org/wiki/Right-hand_rule)
/// is adopted, with the
/// [right-hand rule](https://en.wikipedia.org/wiki/Right-hand_rule) used to
/// determine the sign of the angles.
class OrientationEvent {
  /// The orientation of the device represented as a quaternion.
  final Quaternion quaternion;

  /// An estimated accuracy of the sensor data (in radians). The actual device
  /// orientation is expected to be within this margin of error. If the accuracy
  /// is unavailable, this value is -1. Accuracy information was introduced in
  /// Android SDK level 18, but not all devices support it. For iOS devices,
  /// this is always -1.
  final double accuracy;

  /// The timestamp at which the event was recorded, in microseconds since
  /// some arbitrary point in time, usually the time of system boot.
  final int timestamp;

  /// The coordinate system in which the orientation is expressed, represented
  /// as a 3x3 matrix.
  final Matrix3 coordinateSystem;

  /// Constructs an [OrientationEvent] with the given [quaternion], [accuracy],
  /// and [timestamp]. The [coordinateSystem] is initialized to the identity
  /// matrix, representing the device's default coordinate system.
  OrientationEvent({
    required this.quaternion,
    required this.accuracy,
    required this.timestamp,
  }) : coordinateSystem = Matrix3.identity();

  /// Constructs an [OrientationEvent] with a specific coordinate system.
  OrientationEvent._(
    this.quaternion,
    this.accuracy,
    this.timestamp,
    this.coordinateSystem,
  );

  @override
  String toString() =>
      'OrientationEvent(\n'
      'quaternion: $quaternion,\n'
      'accuracy: $accuracy,\n'
      'timestamp: $timestamp,\n'
      'coordinateSystem:\n'
      '$coordinateSystem'
      ')';

  /// The orientation of the device represented as a rotation matrix.
  Matrix3 get rotationMatrix => quaternion.toRotationMatrix();

  /// The orientation of the device represented as euler angles (azimuth, pitch,
  /// roll).
  EulerAngles get eulerAngles => rotationMatrix.toEulerAngles();

  /// Remaps the device coordinate system of this [OrientationEvent] to a new
  /// coordinate system defined by the specified 'newX' and 'newY' axes.
  ///
  /// The 'newZ' axis is calculated as the cross product of 'newX' and 'newY'.
  ///
  /// Throws an [UnsupportedError] if 'newX' and 'newY' are not orthogonal or if
  /// they are identical.
  ///
  /// Returns a new [OrientationEvent] instance with the remapped coordinate
  /// system and updated quaternion representing the orientation in the new
  /// system.
  OrientationEvent remapCoordinateSystem(Axis3 newX, Axis3 newY) {
    final newZ = newX.cross(newY);
    if (newZ.length2 != 1) {
      throw UnsupportedError(
        'The specified axes for newX and newY are not orthogonal or are '
        'identical. Please specify two different, non-parallel axes that are '
        'orthogonal to each other.',
      );
    }
    final transformMatrix = Matrix3.columns(newX, newY, newZ);

    return OrientationEvent._(
      quaternion.multiply(transformMatrix.toQuaternion()),
      accuracy,
      timestamp,
      coordinateSystem.multiply(transformMatrix),
    );
  }
}
