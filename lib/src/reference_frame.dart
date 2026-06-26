/// The world reference frame the device orientation is expressed against.
///
/// This controls what the azimuth is measured from.
enum ReferenceFrame {
  /// A reference frame where the Z axis is vertical (points towards the sky and
  /// is perpendicular to the ground) and the X axis points in an arbitrary
  /// direction in the horizontal plane (based on device’s initial orientation).
  ///
  /// On Android, a sensor of type
  /// [`Sensor.TYPE_GAME_ROTATION_VECTOR`](https://developer.android.com/reference/android/hardware/SensorEvent#sensor.type_game_rotation_vector:)
  /// is used internally.
  ///
  /// On iOS,
  /// [xArbitraryZVertical](https://developer.apple.com/documentation/coremotion/cmattitudereferenceframe/xarbitraryzvertical)
  /// is used internally.
  arbitrary,

  /// Improved version of [arbitrary] that provides better long-term accuracy
  /// for the Z axis (azimuth). The device must have a magnetometer and that
  /// sensor must be available and calibrated. This option requires more CPU
  /// usage than the [arbitrary] option.
  ///
  /// On Android, falls back to [arbitrary] because it is not supported.
  ///
  /// On iOS,
  /// [xArbitraryCorrectedZVertical](https://developer.apple.com/documentation/coremotion/cmattitudereferenceframe/xarbitrarycorrectedzvertical)
  /// is used internally.
  arbitraryCorrected,

  /// The azimuth is referenced to magnetic north. No dependency on location
  /// services.
  ///
  /// On Android, a sensor of type
  /// [`Sensor.TYPE_ROTATION_VECTOR`](https://developer.android.com/reference/android/hardware/SensorEvent#sensor.type_rotation_vector:)
  /// is used internally.
  ///
  /// On iOS,
  /// [xMagneticNorthZVertical](https://developer.apple.com/documentation/coremotion/cmattitudereferenceframe/xmagneticnorthzvertical)
  /// is used internally.
  magneticNorth,

  /// The azimuth is referenced to true (geographic) north. Requires location
  /// services to be available.
  ///
  /// On Android, falls back to [magneticNorth] because it is not supported.
  ///
  /// On iOS,
  /// [xTrueNorthZVertical](https://developer.apple.com/documentation/coremotion/cmattitudereferenceframe/xtruenorthzvertical)
  /// is used internally.
  trueNorth,
}
