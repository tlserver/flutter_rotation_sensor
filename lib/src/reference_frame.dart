/// The world reference frame the device orientation is expressed against.
///
/// This controls what the azimuth is measured from. Whatever the value, the
/// orientation is always returned in the package's east-north-up world
/// convention, so an azimuth of 0 means the device points north.
enum ReferenceFrame {
  /// The platform default, with no guarantee of a north reference.
  ///
  /// On iOS the horizontal reference is arbitrary (the direction the device
  /// happened to point when the sensor started, no compass). On Android the
  /// rotation vector sensor is already referenced to magnetic north.
  device,

  /// The azimuth is referenced to magnetic north on both platforms. No
  /// dependency on location services.
  magneticNorth,

  /// The azimuth is referenced to true (geographic) north. Requires location
  /// services to be available. On Android, where the rotation vector is only
  /// magnetic, this currently behaves like [magneticNorth].
  trueNorth;
}
