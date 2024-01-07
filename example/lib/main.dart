import 'package:flutter/material.dart';
import 'package:rotation_sensor/rotation_sensor.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Rotation Sensor Example'),
          ),
          body: Center(
            child: StreamBuilder(
              stream: RotationSensor.getOrientationStream(
                  SensorInterval.uiInterval),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Euler:\n${formatEulerAngles(data.eulerAngles)}'),
                      Text('Quaternion:\n${formatQuaternion(data.quaternion)}'),
                      Text('Matrix:\n${formatMatrix(data.rotationMatrix)}'),
                      Text('Accuracy:\n${formatDouble(data.accuracy)}'),
                      Text('Timestamp:\n${data.timestamp}'),
                    ],
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

  String formatQuaternion(Quaternion q) {
    final f = formatDouble;
    return '(${f(q.x)}, ${f(q.y)}, ${f(q.z)} @ ${f(q.w)})';
  }

  String formatMatrix(Matrix3 m) {
    final f = formatDouble;
    return ''
        '/${f(m[0])}, ${f(m[3])}, ${f(m[6])}\\\n'
        '|${f(m[1])}, ${f(m[4])}, ${f(m[7])}|\n'
        '\\${f(m[2])}, ${f(m[5])}, ${f(m[8])}/';
  }

  String formatEulerAngles(EulerAngles e) {
    final f = formatDouble;
    return '(${f(e.azimuth)}, ${f(e.pitch)}, ${f(e.roll)})';
  }

  String formatDouble(double d) => d.toStringAsFixed(2).padLeft(5);
}
