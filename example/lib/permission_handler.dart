import 'package:flutter/material.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';

class PermissionHandler extends StatefulWidget {
  final Widget child;

  const PermissionHandler({super.key, required this.child});

  @override
  State<PermissionHandler> createState() => _PermissionHandlerState();
}

class _PermissionHandlerState extends State<PermissionHandler> {
  bool showPermissionButton = RotationSensor.shouldRequestPermission;

  @override
  Widget build(BuildContext context) {
    return showPermissionButton ? buildPermissionButton() : widget.child;
  }

  Widget buildPermissionButton() => ElevatedButton(
    onPressed: () async {
      final result = await RotationSensor.requestPermission();
      if (result == .granted) {
        setState(() {
          showPermissionButton = false;
        });
      }
    },
    child: const Text('Start'),
  );
}
