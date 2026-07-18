/// An exception thrown when access to the sensor is blocked by a security
/// policy.
class SecurityException implements Exception {
  /// Create a SecurityException.
  const SecurityException();

  @override
  String toString() =>
      'Sensor construction was blocked by a feature policy. Please check your '
      "server's Permissions Policy settings.";
}
