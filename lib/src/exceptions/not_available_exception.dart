/// An exception thrown when the sensor is not available on the device.
class NotAvailableException implements Exception {
  /// Create a NotAvailableException.
  const NotAvailableException();

  @override
  String toString() => 'Cannot connect to the sensor.';
}
