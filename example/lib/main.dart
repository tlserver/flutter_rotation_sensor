import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'compass.dart';
import 'permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  int? lastTimestamp;

  @override
  void initState() {
    super.initState();
    RotationSensor.samplingPeriod = SensorInterval.uiInterval;
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Rotation Sensor Example')),
      body: Center(
        child: RotationSensor.isPlatformSupported
            ? buildPage()
            : const Text('Rotation sensor is not supported on this platform.'),
      ),
    ),
  );

  Widget buildPage() => PermissionHandler(
    child: OrientationBuilder(
      builder: (context, orientation) => StreamBuilder(
        stream: RotationSensor.orientationStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final previousTimestamp = lastTimestamp ?? data.timestamp;
            lastTimestamp = data.timestamp;
            return Flex(
              direction: orientation == Orientation.portrait
                  ? Axis.vertical
                  : Axis.horizontal,
              children: [
                Compass(orientation: data),
                buildDashboard(data, previousTimestamp),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    ),
  );

  Widget buildDashboard(OrientationEvent data, int previousTimestamp) =>
      Expanded(
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Values'),
                  Tab(text: 'Interval'),
                  Tab(text: 'Ref. Frame'),
                  Tab(text: 'Coor. Sys.'),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: TabBarView(
                    children: [
                      buildValuesTab(data),
                      buildIntervalTab(data, previousTimestamp),
                      buildReferenceFrameTab(),
                      buildCoordinateSystemTab(data),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildValuesTab(OrientationEvent data) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Euler:\n'
                '${formatEulerAngles(data.eulerAngles)}',
                textAlign: TextAlign.center,
              ),
              Text(
                'Quaternion:\n'
                '${formatQuaternion(data.quaternion)}',
                textAlign: TextAlign.center,
              ),
              Text(
                'Matrix:\n'
                '${formatMatrix(data.rotationMatrix)}',
                textAlign: TextAlign.center,
              ),
              Text(
                'Accuracy:\n'
                '${formatDouble(data.accuracy)}',
                textAlign: TextAlign.center,
              ),
              NativeDeviceOrientationReader(
                builder: (context) {
                  final orientation = NativeDeviceOrientationReader.orientation(
                    context,
                  );
                  return Text(
                    'Display Orientation:\n'
                    '${orientation.name}',
                    textAlign: TextAlign.center,
                  );
                },
              ),
              Text(
                'Current Platform:\n'
                '${defaultTargetPlatform.name}',
                textAlign: TextAlign.center,
              ),
              Text(
                'Implementation:\n'
                '${RotationSensor.implementation}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget buildIntervalTab(OrientationEvent data, int previousTimestamp) =>
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 8,
                children: [
                  Text(
                    'Timestamp:\n'
                    '${data.timestamp}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Timestamp delta:\n'
                    '${data.timestamp - previousTimestamp}',
                    textAlign: TextAlign.center,
                  ),
                  buildSamplingPeriodSelector(),
                ],
              ),
            ),
          );
        },
      );

  Widget buildReferenceFrameTab() => Align(
    alignment: Alignment.bottomCenter,
    child: buildReferenceFrameSelector(),
  );

  Widget buildCoordinateSystemTab(OrientationEvent data) => LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Coordinate System:\n'
                '${formatCoordinateSystem(data.coordinateSystem)}',
                textAlign: TextAlign.center,
              ),
              Text(
                'Transformed Count:\n'
                '${countTransformed()}',
                textAlign: TextAlign.center,
              ),
              buildCoordinateSystemController(),
            ],
          ),
        ),
      );
    },
  );

  Widget buildSamplingPeriodSelector() => Padding(
    padding: const EdgeInsets.all(8),
    child: RadioGroup<Duration>(
      groupValue: RotationSensor.samplingPeriod,
      onChanged: (value) {
        setState(() {
          RotationSensor.samplingPeriod = value!;
        });
      },
      child: Column(
        children: [
          buildDurationRadioTile(
            value: SensorInterval.fastestInterval,
            title: 'Fastest',
          ),
          buildDurationRadioTile(
            value: SensorInterval.gameInterval,
            title: 'Game',
          ),
          buildDurationRadioTile(value: SensorInterval.uiInterval, title: 'UI'),
          buildDurationRadioTile(
            value: SensorInterval.normalInterval,
            title: 'Normal',
          ),
        ],
      ),
    ),
  );

  Widget buildReferenceFrameSelector() => Padding(
    padding: const EdgeInsets.all(8),
    child: RadioGroup<ReferenceFrame>(
      groupValue: RotationSensor.referenceFrame,
      onChanged: (value) {
        setState(() {
          RotationSensor.referenceFrame = value!;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildReferenceFrameRadioTile(
            value: ReferenceFrame.magneticNorth,
            title: 'Magnetic North',
          ),
          buildReferenceFrameRadioTile(
            value: ReferenceFrame.trueNorth,
            title: 'True North',
          ),
          buildReferenceFrameRadioTile(
            value: ReferenceFrame.arbitrary,
            title: 'Arbitrary',
          ),
          buildReferenceFrameRadioTile(
            value: ReferenceFrame.arbitraryCorrected,
            title: 'Arbitrary Corrected',
          ),
        ],
      ),
    ),
  );

  Widget buildDurationRadioTile({
    required Duration value,
    required String title,
  }) => RadioListTile<Duration>(
    title: Text(title),
    value: value,
    selected: RotationSensor.samplingPeriod == value,
  );

  Widget buildReferenceFrameRadioTile({
    required ReferenceFrame value,
    required String title,
  }) => RadioListTile<ReferenceFrame>(
    title: Text(title),
    value: value,
    selected: RotationSensor.referenceFrame == value,
  );

  Widget buildCoordinateSystemController() => Table(
    defaultColumnWidth: FixedColumnWidth(80),
    children: [
      TableRow(
        children: [
          IconButton(
            onPressed: () => transform(-Axis3.Y, Axis3.X),
            icon: Transform.rotate(
              angle: -pi / 2,
              child: Icon(Icons.rotate_left, size: 40),
            ),
          ),
          IconButton(
            onPressed: () => transform(Axis3.X, Axis3.Z),
            icon: Icon(Icons.arrow_upward, size: 40),
          ),
          IconButton(
            onPressed: () => transform(Axis3.Y, -Axis3.X),
            icon: Transform.rotate(
              angle: pi / 2,
              child: Icon(Icons.rotate_right, size: 40),
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          IconButton(
            onPressed: () => transform(-Axis3.Z, Axis3.Y),
            icon: Transform.rotate(
              angle: pi / 2,
              child: Icon(Icons.arrow_downward, size: 40),
            ),
          ),
          IconButton(
            onPressed: untransform,
            icon: Icon(Icons.backspace_outlined, size: 40),
          ),
          IconButton(
            onPressed: () => transform(Axis3.Z, Axis3.Y),
            icon: Transform.rotate(
              angle: pi / 2,
              child: Icon(Icons.arrow_upward, size: 40),
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          SizedBox.shrink(),
          IconButton(
            onPressed: () => transform(Axis3.X, -Axis3.Z),
            icon: Icon(Icons.arrow_downward, size: 40),
          ),
          SizedBox.shrink(),
        ],
      ),
    ],
  );

  void transform(Axis3 x, Axis3 y) {
    RotationSensor.coordinateSystem = CoordinateSystem.transformed(
      x,
      y,
      RotationSensor.coordinateSystem,
    );
  }

  void untransform() {
    final coordinateSystem = RotationSensor.coordinateSystem;
    if (coordinateSystem is TransformedCoordinateSystem) {
      RotationSensor.coordinateSystem = coordinateSystem.base;
    }
  }

  String formatQuaternion(Quaternion q) {
    final f = formatDouble;
    return '(${f(q.x)}, ${f(q.y)}, ${f(q.z)} @ ${f(q.w)})';
  }

  String formatMatrix(Matrix3 m) {
    final f = formatDouble;
    return '/${f(m[0])}, ${f(m[3])}, ${f(m[6])}\\\n'
        '| ${f(m[1])}, ${f(m[4])}, ${f(m[7])} |\n'
        '\\${f(m[2])}, ${f(m[5])}, ${f(m[8])}/';
  }

  String formatEulerAngles(EulerAngles e) {
    final f = formatDouble;
    return '(${f(e.azimuth)}, ${f(e.pitch)}, ${f(e.roll)})';
  }

  String formatDouble(double d) => d.toStringAsFixed(2).padLeft(5);

  String formatCoordinateSystem(Matrix3 coordinateSystem) {
    final x = formatAxis3(coordinateSystem, 0);
    final y = formatAxis3(coordinateSystem, 1);
    final z = formatAxis3(coordinateSystem, 2);

    return 'X: $x Y: $y Z: $z';
  }

  int countTransformed() {
    var coordinateSystem = RotationSensor.coordinateSystem;
    var result = 0;
    while (coordinateSystem is TransformedCoordinateSystem) {
      coordinateSystem = coordinateSystem.base;
      result += 1;
    }
    return result;
  }

  String formatAxis3(Matrix3 coordinateSystem, int columnIndex) {
    final axis = coordinateSystem.column(columnIndex);
    if (axis == -Axis3.X) {
      return '⬅';
    } else if (axis == Axis3.X) {
      return '⮕';
    } else if (axis == -Axis3.Y) {
      return '⬇';
    } else if (axis == Axis3.Y) {
      return '⬆';
    } else if (axis == -Axis3.Z) {
      return '⊗';
    } else if (axis == Axis3.Z) {
      return '⊙';
    } else {
      throw UnsupportedError('Invalid axis: $axis');
    }
  }
}
