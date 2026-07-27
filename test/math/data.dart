import 'dart:math';

import 'package:flutter_rotation_sensor/src/math/axis3.dart';
import 'package:flutter_rotation_sensor/src/math/axis_angle.dart';
import 'package:flutter_rotation_sensor/src/math/euler_angles.dart';
import 'package:flutter_rotation_sensor/src/math/matrix3.dart';
import 'package:flutter_rotation_sensor/src/math/quaternion.dart';
import 'package:flutter_rotation_sensor/src/math/vector3.dart';

final ra = pi / 2;

final xrEa = EulerAngles(0, ra, 0);
final xrMt = Matrix3(
  // @formatter:off
   1,  0,  0,
   0,  0, -1,
   0,  1,  0,
  // @formatter:on
);
final xrQt = Quaternion(sqrt1_2, 0, 0, sqrt1_2);
final xrAa = AxisAngle(Axis3.X, ra);

final yrEa = EulerAngles(0, 0, ra);
final yrMt = Matrix3(
  // @formatter:off
   0,  0,  1,
   0,  1,  0,
  -1,  0,  0,
  // @formatter:on
);
final yrQt = Quaternion(0, sqrt1_2, 0, sqrt1_2);
final yrAa = AxisAngle(Axis3.Y, ra);

final zrEa = EulerAngles(-ra, 0, 0);
final zrMt = Matrix3(
  // @formatter:off
   0, -1,  0,
   1,  0,  0,
   0,  0,  1,
  // @formatter:on
);
final zrQt = Quaternion(0, 0, sqrt1_2, sqrt1_2);
final zrAa = AxisAngle(Axis3.Z, ra);

final ab1Ea = EulerAngles(0.1, 0.2, 0.3);
final ab1Mt = Matrix3(
  // @formatter:off
   0.9564251,  0.0978434,  0.2750959,
  -0.0369570,  0.9751703, -0.2183507,
  -0.2896295,  0.1986693,  0.9362934,
  // @formatter:on
);
final ab1Qt = Quaternion(0.1060205, 0.1435722, -0.0342708, 0.9833474);
final ab1Aa = AxisAngle(Vector3(0.5833780, 0.7900061, -0.1885751), 0.3655022);
final ab1Mt2 = ab1Mt * 2;
final ab1Qt2 = ab1Qt * sqrt2;
final ab1Aa2 = ab1Aa * 2;

final v1 = Vector3(1, 2, 3);
