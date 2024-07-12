import 'package:meta/meta.dart';

/// Defines some common intervals for sensor data updates.
@sealed
class SensorInterval {
  /// Default update interval suitable for tracking screen orientation changes.
  /// This is a balanced rate that does not demand high processing power and is
  /// sufficient for most applications that react to orientation changes.
  static const normalInterval = Duration(milliseconds: 200);

  /// Update interval optimised for user interface responsiveness. This faster
  /// rate is appropriate when the UI needs to update smoothly in response to
  /// sensor data, such as in animations or transitions.
  static const uiInterval = Duration(milliseconds: 66, microseconds: 667);

  /// High-frequency update interval suitable for gaming applications. Provides
  /// more frequent updates to ensure game mechanics based on sensor data are
  /// responsive and provide a fluid experience.
  static const gameInterval = Duration(milliseconds: 20);

  /// The fastest possible update interval for sensor data. This setting is for
  /// applications that require real-time updates from the sensor, such as those
  /// needed for precise scientific measurements or advanced simulation.
  static const fastestInterval = Duration.zero;
}
