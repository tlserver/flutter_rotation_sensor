# flutter_rotation_sensor

[![pub package](https://img.shields.io/pub/v/rotation_sensor)](https://pub.dartlang.org/packages/rotation_sensor)
[![github tag](https://img.shields.io/github/v/tag/tlserver/flutter_rotation_sensor?include_prereleases&sort=semver)](https://github.com/tlserver/flutter_rotation_sensor)
[![license](https://img.shields.io/github/license/tlserver/flutter_rotation_sensor)](https://github.com/tlserver/flutter_rotation_sensor/blob/master/LICENSE)

The `flutter_rotation_sensor` plugin provides easy access to the device's physical orientation in
three distinct representations: rotation matrix, quaternion, and Euler angles (azimuth, pitch,
roll). This is ideal for applications requiring precise tracking of the device's movement or
orientation in space, such as augmented reality, gaming, navigation, and more.

## Features

- **Real-time Rotation Data**: Access to real-time rotation data.
- **Multiple Formats Supported**: Provides rotation matrix, quaternion, and Euler angles (azimuth,
  pitch, roll).
- **Customizable Update Intervals**: Set custom intervals for sensor data retrieval.
- **Coordinate System Remapping**: Supports orientation coordinate system remapping.

## Installation

To add `flutter_rotation_sensor` to your project, follow these steps:

1. Add `flutter_rotation_sensor` as a dependency in your `pubspec.yaml` file:
   ```yaml
   dependencies:
     flutter_rotation_sensor: ^latest_version
   ```

2. Install the plugin by running:
   ```sh
   flutter pub get
   ```

3. Import the plugin in your Dart code:
   ```dart
   import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
   ```

## Usage

To start receiving orientation data from the sensors, simply use the stream in a `StreamBuilder`:

```dart
@override
Widget build(BuildContext context) {
  return StreamBuilder(
    stream: RotationSensor.orientationStream,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final data = snapshot.data!;
        print(data.quaternion);
        print(data.rotationMatrix);
        print(data.eulerAngles);
        // ...
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        return const CircularProgressIndicator();
      }
    },
  );
}
```

For more control, you can subscribe to the stream directly:

1. Initialize the sensor and specify the desired update interval during `initState`:
   ```dart
   late final StreamSubscription<OrientationData> orientationSubscription;

   @override
   void initState() {
     super.initState();
     orientationSubscription = RotationSensor.orientationStream.listen((event) {
       final azimuth = event.eulerAngles.azimuth;
       // Print azimuth: 0 for North, π/2 for East, π for South, -π/2 for West
       print(azimuth);
     });
   }
   ```

2. Remember to cancel the subscription in the `dispose` method to prevent memory leaks:
   ```dart
   @override
   void dispose() {
     orientationSubscription.cancel();
     super.dispose();
   }
   ```

## Configuration

To configure the `flutter_rotation_sensor` plugin, you can set various properties at any time, such
as in your `initState` method. Below is an example demonstrating how to configure these settings:

```dart
@override
void initState() {
  super.initState();
  // Set the sampling period for the rotation sensor
  RotationSensor.samplingPeriod = SensorInterval.uiInterval;

  // Set the coordinate system for the rotation sensor
  RotationSensor.coordinateSystem = CoordinateSystem.transformed(Axis3.X, Axis3.Z);
}
```

### Sampling Period

The [RotationSensor.samplingPeriod](https://pub.dev/documentation/flutter_rotation_sensor/latest/flutter_rotation_sensor/RotationSensor/samplingPeriod.html)
determines how frequently the sensor data is updated. Here are the predefined values you can use:

- `SensorInterval.normal` (200ms): Default rate, suitable for general use.
- `SensorInterval.ui` (66ms): Suitable for UI updates, balancing update rate and power consumption.
- `SensorInterval.game` (20ms): Suitable for games, updating at a rate to ensure smooth motion.
- `SensorInterval.fastest` (0ms): Updates as fast as possible.

You can also set a custom [Duration](https://api.dart.dev/stable/dart-core/Duration-class.html), for
example:

```dart
void config() {
  RotationSensor.samplingPeriod = Duration(seconds: 1);
}
```

Events may arrive at a rate faster or slower than the sampling period, which is only a hint to the
system. The actual rate depends on the system's event queue and sensor hardware capabilities.

### Coordinate System

The [RotationSensor.coordinateSystem](https://pub.dev/documentation/flutter_rotation_sensor/latest/flutter_rotation_sensor/RotationSensor/coordinateSystem.html)
property allows you to remap the coordinate system used by the sensor data. By default, the
coordinate system follows the display's orientation. You can transform the coordinate system to
match your application's needs. Here are the predefined coordinate systems you can use:

- `CoordinateSystem.device()`: Defined relative to the device's screen in its default orientation.
- `CoordinateSystem.display()`: *(default value)* Adapts to the device's current orientation.
- `CoordinateSystem.transformed()`: Applies a transformation on top of a base coordinate system.

For example, a driving navigation application may want a transformed coordinate system where the
y-axis points to the back of the device. This ensures that the plugin can return the azimuth
correctly when the device is mounted in front of the driver.

```dart
void config() {
  // The new x-axis is same as old x-axis and the new y-axis is the old negative-z-axis which points
  // to the back of the device.
  RotationSensor.coordinateSystem = CoordinateSystem.transformed(Axis3.X, -Axis3.Z);
}
```

## License

This plugin is licensed under the [MIT License](LICENSE).
