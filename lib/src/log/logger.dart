import 'dart:developer' as developer;

import 'level.dart';

typedef LogHandler =
    void Function(
      String message, {
      LogLevel level,
      Object? error,
      StackTrace? stackTrace,
    });

void defaultLogHandler(
  String message, {
  LogLevel level = LogLevel.info,
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
