import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

class Compass extends StatefulWidget {
  final OrientationEvent orientation;

  const Compass({super.key, required this.orientation});

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  late Sp3dWorld world;

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
  }

  @override
  Widget build(BuildContext context) {
    final axisAngle = widget.orientation.quaternion.conjugate().toAxisAngle();
    final axis = axisAngle.axis;
    return SizedBox(
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
    );
  }

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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Sp3dWorld>('world', world));
  }
}
