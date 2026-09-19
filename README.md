# flutter_rotation_sensor

[![pub package](https://img.shields.io/pub/v/flutter_rotation_sensor)](https://pub.dev/packages/flutter_rotation_sensor)
[![github tag](https://img.shields.io/github/v/tag/tlserver/flutter_rotation_sensor?include_prereleases&sort=semver)](https://github.com/tlserver/flutter_rotation_sensor)
[![license](https://img.shields.io/github/license/tlserver/flutter_rotation_sensor)](https://github.com/tlserver/flutter_rotation_sensor/blob/master/LICENSE)

The `flutter_rotation_sensor` plugin provides easy access to the device's physical orientation on
Android, iOS, and supported web browsers in three distinct representations: rotation matrix,
quaternion, and Euler angles (azimuth, pitch, roll). This is ideal for applications requiring
precise tracking of the device's movement or orientation in space, such as augmented reality,
gaming, navigation, and more.

## Features

- **Real-time Rotation Data**: Access to real-time rotation data.
- **Multiple Formats Supported**: Provides rotation matrix, quaternion, and Euler angles (azimuth,
  pitch, roll).
- **Customizable Update Intervals**: Set custom intervals for sensor data retrieval.
- **Coordinate System Remapping**: Supports orientation coordinate system remapping.
- **Web Support**: Works in browsers with the Sensors API or `DeviceOrientationEvent` support.

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

To start receiving orientation data from the sensors on supported platforms, simply use the stream
in a `StreamBuilder`:

```dart
@override
Widget build(BuildContext context) {
  if (RotationSensor.isPlatformSupported) {
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
  } else {
    return const Text('Rotation sensor is not supported on this platform.');
  }
}
```

Use `RotationSensor.isPlatformSupported` to guard unsupported browsers or devices before starting a
subscription.

For more control, you can subscribe to the stream directly:

1. Initialize the sensor and specify the desired update interval during `initState`:
   ```dart
   late final StreamSubscription<OrientationEvent> orientationSubscription;

   @override
   void initState() {
     super.initState();
     orientationSubscription = RotationSensor.orientationStream.listen((event) {
       final azimuth = event.eulerAngles.azimuth;
       // Print azimuth: 0 for North, π/2 for East, π for South, 3π/2 for West
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

  // Set the reference frame from which the azimuth is measured
  RotationSensor.referenceFrame = ReferenceFrame.trueNorth;

  // Set the coordinate system for the rotation sensor
  RotationSensor.coordinateSystem = CoordinateSystem.transformed(Axis3.X, Axis3.Z);
}
```

## Platform Support

- **Android**: Uses the native rotation sensor implementation.
- **iOS**: Uses the native rotation sensor implementation.
- **Web**: Uses the browser Sensors API when available, otherwise falls back to
  `DeviceOrientationEvent`.

### Permissions

For web platform, permission is handled at runtime. The plugin provides the following methods to
manage permissions:

- `RotationSensor.shouldRequestPermission` tells you whether the current browser exposes an explicit
  permission flow. It always returns false for Android and iOS, which do not require explicit
  permission for sensor access.
- `RotationSensor.requestPermission()` returns `SensorPermission.granted` or
  `SensorPermission.denied`. It must be called from a transient user activation, such as a button
  tap. This matches the behavior described in MDN's
  [DeviceOrientationEvent.requestPermission()](https://developer.mozilla.org/en-US/docs/Web/API/DeviceOrientationEvent/requestPermission_static)
  docs.

```dart
bool showPermissionButton = RotationSensor.shouldRequestPermission;

@override
Widget build() {
  if (!RotationSensor.isPlatformSupported) {
    return Text('Rotation sensor is not supported on this platform.');
  } else if (showPermissionButton) {
    return ElevatedButton(
      onPressed: () async {
        final result = await RotationSensor.requestPermission();
        if (result == .granted) {
          setState(() => showPermissionButton = false);
        }
      },
      child: const Text('Start'),
    );
  } else {
    // ...
  }
}
```

If permission is denied or the browser blocks sensor access, check the following:

- The page is served over HTTPS or `localhost`.
- The browser allows motion/orientation sensors.
- The site is not blocked by a Permissions Policy / feature policy.
- The device actually has the required sensors enabled.

### Sampling Period

The [RotationSensor.samplingPeriod](https://pub.dev/documentation/flutter_rotation_sensor/latest/flutter_rotation_sensor/RotationSensor/samplingPeriod.html)
determines how frequently the sensor data is updated. Here are the predefined values you can use:

- `SensorInterval.normalInterval` (200ms): Default rate, suitable for general use.
- `SensorInterval.uiInterval` (66ms): Suitable for UI updates, balancing update rate and power
  consumption.
- `SensorInterval.gameInterval` (20ms): Suitable for games, updating at a rate to ensure smooth
  motion.
- `SensorInterval.fastestInterval` (0ms): Updates as fast as possible.

You can also set a custom [Duration](https://api.dart.dev/stable/dart-core/Duration-class.html), for
example:

```dart
void config() {
  RotationSensor.samplingPeriod = Duration(seconds: 1);
}
```

Events may arrive at a rate faster or slower than the sampling period, which is only a hint to the
system. The actual rate depends on the system's event queue and sensor hardware capabilities.

### Reference Frame

The [RotationSensor.referenceFrame](https://pub.dev/documentation/flutter_rotation_sensor/latest/flutter_rotation_sensor/RotationSensor/referenceFrame.html)
property controls the world reference from which the angles are measured. Here are the values you
can use:

- `ReferenceFrame.arbitrary`: Uses the initial device orientation as the frame of reference.
- `ReferenceFrame.arbitraryCorrected`: Uses the magnetometer to improve long-term accuracy.
- `ReferenceFrame.magneticNorth`: *(default value)* Points to the magnetic north pole.
- `ReferenceFrame.trueNorth`: Points to the geographic north pole.

```dart
void config() {
  RotationSensor.referenceFrame = ReferenceFrame.trueNorth;
}
```

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

## FAQ

### Why doesn't the plugin request permission automatically when the event stream is subscribed?

Some browsers require an explicit user gesture before they allow access to motion or orientation
sensors. In those cases, call `RotationSensor.requestPermission()` from a button tap or similar
interaction.

### What should I do if `RotationSensor.shouldRequestPermission` is false?

You can usually start listening directly. The browser either does not require a prompt or does not
support the permission API.

### Why do I get no events after granting permission?

Check browser support, HTTPS, Permissions Policy settings, and whether the device exposes the needed
sensors.

### Why should I guard with `RotationSensor.isPlatformSupported`?

It lets you avoid starting a stream on unsupported browsers or devices and show a fallback UI
instead.

## License

This plugin is licensed under the [MIT License](LICENSE).
