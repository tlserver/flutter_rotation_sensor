import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Sp3dWorld world;

  @override
  void initState() {
    super.initState();
    const black = Color(0xFF000000);
    final obj = UtilSp3dGeometry.cube(60, 200, 40, 1, 1, 1)
      ..move(Sp3dV3D(0, 0, -20))
      ..materials = [
        Sp3dMaterial(black, true, 0, black, imageIndex: 0),
        Sp3dMaterial(black, true, 0, black, imageIndex: 1),
        FSp3dMaterial.red,
        FSp3dMaterial.blue,
      ]
      ..fragments[0].faces[0].materialIndex = 1
      ..fragments[0].faces[2].materialIndex = 2
      ..fragments[0].faces[4].materialIndex = 3;

    world = Sp3dWorld([obj]);

    loadImages(world);

    RotationSensor.samplingPeriod = SensorInterval.uiInterval;
    RotationSensor.coordinateSystem =
        CoordinateSystem.transformed(Axis3.X, Axis3.Z);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Rotation Sensor Example'),
          ),
          body: OrientationBuilder(
            builder: (context, orientation) => StreamBuilder(
              stream: RotationSensor.orientationStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  final axisAngle = data.quaternion.invert().toAxisAngle();
                  final axis = axisAngle.axis;
                  return Center(
                    child: Flex(
                      direction: orientation == Orientation.portrait
                          ? Axis.vertical
                          : Axis.horizontal,
                      children: [
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: Sp3dRenderer(
                            const Size(240, 240),
                            const Sp3dV2D(120, 120),
                            world,
                            Sp3dCamera(
                              Sp3dV3D(0, 0, 3000),
                              3000,
                              rotateAxis: Sp3dV3D(axis.x, axis.y, axis.z),
                              radian: axisAngle.angle,
                            ),
                            Sp3dLight(Sp3dV3D(0, 0, 1)),
                            useUserGesture: false,
                          ),
                        ),
                        Expanded(
                          child: Column(
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
                              Text(
                                'Timestamp:\n'
                                '${data.timestamp}',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ),
      );

  Future<void> loadImages(Sp3dWorld world) async {
    world.objs[0].images = await Future.wait([
      readImageFile('./assets/images/other.png'),
      readImageFile('./assets/images/top.png'),
    ]);
    await world.initImages();
  }

  Future<Uint8List> readImageFile(String filePath) async {
    final byteData = await rootBundle.load(filePath);
    return byteData.buffer.asUint8List();
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Sp3dWorld>('world', world));
  }
}
