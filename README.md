# flutter_rotation_sensor

[![pub package](https://img.shields.io/pub/v/rotation_sensor)](https://pub.dartlang.org/packages/rotation_sensor)
[![github tag](https://img.shields.io/github/v/tag/tlserver/flutter_rotation_sensor?include_prereleases&sort=semver)](https://github.com/tlserver/flutter_rotation_sensor)
[![license](https://img.shields.io/github/license/tlserver/flutter_rotation_sensor)](https://github.com/tlserver/flutter_rotation_sensor/blob/master/LICENSE)

The RotationSensor plugin provides easy access to the device's physical orientation in three
distinct representations: rotation matrix, quaternion, and Euler angles (azimuth, pitch, roll). This
is ideal for applications that require precise tracking of the device's movement or orientation in
space, such as augmented reality, gaming, navigation, and more.

## Features

- Access to real-time rotation data.
- Supports various formats: rotation matrix, quaternion, and Euler angles (azimuth, pitch, roll).
- Customizable update intervals for sensor data retrieval.
- Supports orientation coordinate system remapping.

## Installation

To add `RotationSensor` to your project, follow these steps:

1. Add `rotation_sensor` as a dependency in your `pubspec.yaml` file:
   ```yaml
   dependencies:
     rotation_sensor: ^latest_version
   ```

2. Install the plugin by running:
   ```sh
   flutter pub get
   ```

3. Import the plugin in your Dart code:
   ```dart
   import 'package:rotation_sensor/rotation_sensor.dart';
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
     RotationSensor.samplingPeriod = SensorInterval.uiInterval;
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

## License

This plugin is licensed under the [MIT License](LICENSE).
