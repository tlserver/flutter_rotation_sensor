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

## Platform Support

- **Android**: Uses the native rotation sensor implementation.
- **iOS**: Uses the native rotation sensor implementation.
- **Web**: Uses the browser Sensors API when available, otherwise falls back to
  `DeviceOrientationEvent`.

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

### Reference Frame (World Frame) & Coordinate System (Device Frame)

In this package, **orientation** means the device's rotational pose: how its device frame is rotated
relative to a world frame.

The [RotationSensor.referenceFrame](https://pub.dev/documentation/flutter_rotation_sensor/latest/flutter_rotation_sensor/RotationSensor/referenceFrame.html)
property controls the world frame from which the angles are measured. Here are the values you can
use:

- `ReferenceFrame.arbitrary`: Uses the initial device orientation as the frame of reference.
- `ReferenceFrame.arbitraryCorrected`: Uses the magnetometer to improve long-term accuracy.
- `ReferenceFrame.magneticNorth`: *(default value)* Points to the magnetic North Pole.
- `ReferenceFrame.trueNorth`: Points to the geographic North Pole.

```dart
void config() {
  RotationSensor.referenceFrame = ReferenceFrame.trueNorth;
}
```

The [RotationSensor.coordinateSystem](https://pub.dev/documentation/flutter_rotation_sensor/latest/flutter_rotation_sensor/RotationSensor/coordinateSystem.html)
property selects the device frame in which orientation data is expressed. By default, the coordinate
system follows the display's orientation. You can create a new device frame by transforming the
coordinate system to match your application's needs. Here are the coordinate systems you can use:

- `CoordinateSystem.device()`: Defined relative to the device's screen in its default orientation:
  X points right, Y points toward the top of the screen, and Z points out through the screen.
- `CoordinateSystem.display()`: *(default value)* Adapts to the display's current orientation:
  X points right and Y toward the top of the currently oriented screen; Z points out through it.
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

## Concepts

### Orientation

An orientation describes rotation only, not the device's position or movement through space, and is
distinct from the display's portrait or landscape orientation.

Each event represents this orientation internally as a quaternion and also provides derived
rotation-matrix and Euler-angle representations.

### Euler-angle convention

Euler angles are not a single universal representation: their meaning depends on the rotation axes,
the order of rotations, and whether those axes are fixed or move with the object. This plugin uses
intrinsic Tait–Bryan angles in the order azimuth, pitch, roll (the Z-X-Y axis sequence, with azimuth
measured about -Z). In an intrinsic sequence, each subsequent rotation is about the coordinate frame
as it has already been rotated.

More precisely, using active, right-handed rotations on column vectors, the orientation matrix is

```text
R = Rz(-azimuth) · Rx(pitch) · Ry(roll)
```

Here `Rx`, `Ry`, and `Rz` are rotations about the corresponding positive axes, and the rightmost
matrix acts first. The same orientation can therefore be described as extrinsic rotations about
fixed axes in the reverse order: first roll about Y, then pitch about X, then azimuth about -Z.
See [Euler angles](https://en.wikipedia.org/wiki/Euler_angles) for a broader overview.

## Platform Compatibility

| Features                          | Android         | iOS      | web (SensorAPI)        | web (W3cDOE #1)        | web (WebKitDOE #1)     | windows | Mac | linux |
|-----------------------------------|-----------------|----------|------------------------|------------------------|------------------------|---------|-----|-------|
| Support                           | ✅              | ✅       | ✅ (in Secure context) | ✅ (in Secure context) | ✅ (in Secure context) | ❌      | ❌  | ❌    |
| Runtime Permissions Request       | ⚪ No-op        | ⚪ No-op | ⚪ No-op               | ✅                     | ✅                     | ❌      | ❌  | ❌    |
| SensorInterval                    | ✅              | ✅       | ✅                     | ❌                     | ❌                     | ❌      | ❌  | ❌    |
| ReferenceFrame.arbitrary          | ✅              | ✅       | ✅                     | ✅ (#2)                | ✅                     | ❌      | ❌  | ❌    |
| ReferenceFrame.arbitraryCorrected | ↪️ arbitrary     | ✅       | ↪️ arbitrary            | ↪️ arbitrary (#2)       | ↪️ arbitrary            | ❌      | ❌  | ❌    |
| ReferenceFrame.magneticNorth      | ✅              | ✅       | ✅                     | ✅                     | ✅                     | ❌      | ❌  | ❌    |
| ReferenceFrame.trueNorth          | ↪️ magneticNorth | ✅       | ↪️ magneticNorth        | ↪️ magneticNorth        | ↪️ magneticNorth        | ❌      | ❌  | ❌    |
| CoordinateSystem.device()         | ✅              | ✅       | ✅                     | ✅                     | ✅                     | ❌      | ❌  | ❌    |
| CoordinateSystem.display()        | ✅              | ✅       | ❌                     | ❌                     | ❌                     | ❌      | ❌  | ❌    |
| CoordinateSystem.transformed()    | ✅              | ✅       | ✅                     | ✅                     | ✅                     | ❌      | ❌  | ❌    |

#1 W3cDOE and WebKitDOE refer to the plugin's W3C and WebKit implementations of
`DeviceOrientationEvent`, respectively.

#2 A browser may provide absolute orientation data in a `deviceorientation` event rather than
relative orientation data. In that case, selecting `ReferenceFrame.arbitrary` (or
`arbitraryCorrected`, which falls back to it) can produce magnetic-north-referenced readings instead
of an arbitrary reference frame. The plugin does not check the event's `absolute` flag or rebase
these readings. See
the [W3C specification](https://www.w3.org/TR/orientation-event/#deviceorientation).

### Web Browser Compatibility

A browser needs to expose the corresponding Sensor API or DeviceOrientationEvent; otherwise the web
implementation falls back to unsupported. If multiple implementations are available, the Sensor API
takes precedence.

| Features                                                                                                                                 | Chrome            | Edge              | Firefox            | Opera             | Safari           | Chrome Android    | Firefox for Android | Opera Android     | Safari on iOS      | Samsung Browser | WebView Android   | WebView on iOS     |
|------------------------------------------------------------------------------------------------------------------------------------------|-------------------|-------------------|--------------------|-------------------|------------------|-------------------|---------------------|-------------------|--------------------|-----------------|-------------------|--------------------|
| [SensorAPI](https://developer.mozilla.org/en-US/docs/Web/API/OrientationSensor)                                                          | 67+ (2018-05-29)  | 79+ (2020-01-15)  | ❌                 | 54+ (2018-06-28)  | ❌               | 67+ (2018-05-31)  | ❌                  | 48+ (2018-11-08)  | ❌                 | 9+ (2018-09-15) | 67+ (2018-05-31)  | ❌                 |
| [W3cDOE](https://developer.mozilla.org/en-US/docs/Web/API/Window/deviceorientationabsolute_event)                                        | 50+ (2016-04-13)  | 79+ (2020-01-15)  | 110+ (2023-02-14)) | 37+ (2016-05-04)  | ❌               | 50+ (2016-04-13)  | 110+ (2023-02-14)   | 37+ (2016-06-16)  | ❌                 | 5+ (2016-12-15) | 50+ (2016-04-13)  | ❌                 |
| [WebKitDOE](https://developer.mozilla.org/en-US/docs/Web/API/DeviceOrientationEvent)                                                     | ❌                | ❌                | ❌                 | ❌                | 17+ (2023-09-18) | ❌                | ❌                  | ❌                | 4.2+ (2010-11-22)  | ❌              | ❌                | 4.2+ (2010-11-22)  |
| [DOE Permission](https://developer.mozilla.org/en-US/docs/Web/API/DeviceOrientationEvent/requestPermission_static#browser_compatibility) | 152+ (2026-08-25) | 152+ (2026-08-28) | ❌                 | 136+ (2026-09-17) | ❌               | 152+ (2026-08-25) | ❌                  | 102+ (2026-09-23) | 14.5+ (2021-04-26) | ❌              | 152+ (2026-08-25) | 14.5+ (2021-04-26) |

In browsers that older than the table above, the plugin's behavior is unpredictable: it may fall
back to an unsupported state or produce incorrect data without exception.

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
