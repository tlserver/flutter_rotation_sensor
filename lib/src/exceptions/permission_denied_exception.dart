/// An exception thrown when trying to access the device's orientation while
/// access is denied.
class PermissionDeniedException implements Exception {
  /// Create a NotAllowException.
  const PermissionDeniedException();

  @override
  String toString() => 'Permission to access the sensor was denied.';
}
