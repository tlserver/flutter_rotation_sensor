/// Numeric severity keys used by the Flutter DevTool. Higher values indicate
/// more severe events.
enum LogLevel {
  /// Key for highly detailed tracing.
  finest(300),

  /// Key for fairly detailed tracing.
  finer(400),

  /// Key for tracing information.
  fine(500),

  /// Key for configuration messages.
  config(700),

  /// Key for informational messages.
  info(800),

  /// Key for potential problems.
  warning(900),

  /// Key for serious failures.
  severe(1000),

  /// Key for extra debugging loudness.
  shout(1200);

  /// The severity level, which is a value between 0 and 2000. See the `Level`
  /// class in `package:logging` for an overview of the possible values.
  final int value;

  const LogLevel(this.value);
}
