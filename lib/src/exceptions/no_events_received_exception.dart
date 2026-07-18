/// An exception thrown when no device orientation events are received.
class NoEventsReceivedException implements Exception {
  /// Create a NoEventsReceivedException.
  const NoEventsReceivedException();

  @override
  String toString() =>
      'No device orientation events received. This may be due to a lack of '
      'support or permission.';
}
