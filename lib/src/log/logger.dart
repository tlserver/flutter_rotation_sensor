import 'dart:developer' as developer;

import 'level.dart';

/// A function type that defines a log handler for logging messages with
/// different severity levels.
typedef LogHandler =
    void Function(
      String message, {
      LogLevel level,
      Object? error,
      StackTrace? stackTrace,
    });

/// The default log handler that logs messages using the `developer.log`
/// function.
void defaultLogHandler(
  String message, {
  LogLevel level = .info,
  Object? error,
  StackTrace? stackTrace,
}) {
  developer.log(
    message,
    level: level.value,
    name: 'FlutterRotationSensor',
    error: error,
    stackTrace: stackTrace,
  );
}
