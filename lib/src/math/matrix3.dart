import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:meta/meta.dart';

import 'euler_angles.dart';
import 'float32_list.dart';
import 'quaternion.dart';
import 'vector3.dart';

/// A class representing a 3x3 matrix.
@immutable
class Matrix3 {
  static const dimension = 3;

  final Float32List _m3Storage;

  /// Constructs a Matrix3 with the specified elements.
  // @formatter:off
  // dart format off
  Matrix3(
    num a, num b, num c,
    num d, num e, num f,
    num g, num h, num i,
  ) : _m3Storage = numList([
    a, b, c,
    d, e, f,
    g, h, i,
  ]);
  // dart format on
  // @formatter:on

  /// Constructs a Matrix3 from the given row vectors.
  Matrix3.rows(Vector3 r0, Vector3 r1, Vector3 r2)
    : _m3Storage = numList([
        // skip formatting
        r0.x, r0.y, r0.z,
        r1.x, r1.y, r1.z,
        r2.x, r2.y, r2.z,
      ]);

  /// Constructs a Matrix3 from the given column vectors.
  Matrix3.columns(Vector3 c0, Vector3 c1, Vector3 c2)
    : _m3Storage = numList([
        // skip formatting
        c0.x, c1.x, c2.x,
        c0.y, c1.y, c2.y,
        c0.z, c1.z, c2.z,
      ]);

  /// Constructs a Matrix3 with all elements initialized to zero.
  Matrix3.zero() : _m3Storage = Float32List(9);

  /// Constructs an identity Matrix3.
  Matrix3.identity()
    : _m3Storage = Float32List.fromList([
        // skip formatting
        1, 0, 0,
        0, 1, 0,
        0, 0, 1,
      ]);

  /// Constructs a rotation matrix around the X-axis.
  factory Matrix3.rotateX(num r) {
    final cr = cos(r);
    final sr = sin(r);
    return Matrix3(
      // @formatter:off
      // dart format off
      1,  0,   0,
      0, cr, -sr,
      0, sr,  cr,
      // dart format on
      // @formatter:on
    );
  }

  /// Constructs a rotation matrix around the Y-axis.
  factory Matrix3.rotateY(num r) {
    final cr = cos(r);
    final sr = sin(r);
    return Matrix3(
      // @formatter:off
      // dart format off
       cr, 0, sr,
        0, 1,  0,
      -sr, 0, cr,
      // dart format on
      // @formatter:on
    );
  }

  /// Constructs a rotation matrix around the Z-axis.
  factory Matrix3.rotateZ(num r) {
    final cr = cos(r);
    final sr = sin(r);
    return Matrix3(
      // @formatter:off
      // dart format off
      cr, -sr,  0,
      sr,  cr,  0,
       0,   0,  1,
      // dart format on
      // @formatter:on
    );
  }

  /// Determines whether this matrix is equal to another object. Returns true
  /// if the other object is an Matrix3 with the same elements.
  // @formatter:off
  // dart format off
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Matrix3 &&
          a == other.a && b == other.b && c == other.c &&
          d == other.d && e == other.e && f == other.f &&
          g == other.g && h == other.h && i == other.i;
  // dart format on
  // @formatter:on

  // @formatter:off
  // dart format off
  @override
  int get hashCode => Object.hash(
    a, b, c,
    d, e, f,
    g, h, i,
  );
  // dart format on
  // @formatter:on

  @override
  String toString() =>
      '⌈$a,$b,$c⌉\n'
      '|$d,$e,$f|\n'
      '⌊$g,$h,$i⌋\n';

  /// Returns the element at the first row and first column.
  double get a => _m3Storage[0];

  /// Returns the element at the first row and second column.
  double get b => _m3Storage[1];

  /// Returns the element at the first row and third column.
  double get c => _m3Storage[2];

  /// Returns the element at the second row and first column.
  double get d => _m3Storage[3];

  /// Returns the element at the second row and second column.
  double get e => _m3Storage[4];

  /// Returns the element at the second row and third column.
  double get f => _m3Storage[5];

  /// Returns the element at the third row and first column.
  double get g => _m3Storage[6];

  /// Returns the element at the third row and second column.
  double get h => _m3Storage[7];

  /// Returns the element at the third row and third column.
  double get i => _m3Storage[8];

  /// Returns the element at the given index in row major order.
  double operator [](int i) => _m3Storage[i];

  /// Returns the row at the given index.
  Vector3 row(int r) {
    final i = r * 3;
    return Vector3(this[i + 0], this[i + 1], this[i + 2]);
  }

  /// Returns the column at the given index.
  Vector3 column(int c) => Vector3(this[0 + c], this[3 + c], this[6 + c]);

  // @formatter:off
  // dart format off
  /// Returns the negation of this matrix.
  Matrix3 operator -() => Matrix3(
    -a, -b, -c,
    -d, -e, -f,
    -g, -h, -i,
  );
  // dart format on
  // @formatter:on

  // @formatter:off
  // dart format off
  /// Adds the given matrix to this matrix.
  Matrix3 operator +(Matrix3 o) => Matrix3(
    a + o.a,
    b + o.b,
    c + o.c,
    d + o.d,
    e + o.e,
    f + o.f,
    g + o.g,
    h + o.h,
    i + o.i,
  );
  // dart format on
  // @formatter:on

  // @formatter:off
  // dart format off
  /// Subtracts the given matrix from this matrix.
  Matrix3 operator -(Matrix3 o) => Matrix3(
    a - o.a, b - o.b, c - o.c,
    d - o.d, e - o.e, f - o.f,
    g - o.g, h - o.h, i - o.i,
  );
  // dart format on
  // @formatter:on

  /// Multiplies this matrix.
  Matrix3 operator *(dynamic o) {
    switch (o) {
      case num n:
        return Matrix3(
          // @formatter:off
          // dart format off
          a * n, b * n, c * n,
          d * n, e * n, f * n,
          g * n, h * n, i * n,
          // dart format on
          // @formatter:on
        );
      case Matrix3 m:
        return Matrix3(
          a * m.a + b * m.d + c * m.g,
          a * m.b + b * m.e + c * m.h,
          a * m.c + b * m.f + c * m.i,

          d * m.a + e * m.d + f * m.g,
          d * m.b + e * m.e + f * m.h,
          d * m.c + e * m.f + f * m.i,

          g * m.a + h * m.d + i * m.g,
          g * m.b + h * m.e + i * m.h,
          g * m.c + h * m.f + i * m.i,
        );
      case Quaternion q:
        return this * q.toRotationMatrix();
      default:
        throw UnsupportedError(
          'Unsupported operand type for *: ${o.runtimeType}',
        );
    }
  }

  // @formatter:off
  // dart format off
  /// Divides this matrix by the given scalar.
  Matrix3 operator /(num s) => Matrix3(
    a / s, b / s, c / s,
    d / s, e / s, f / s,
    g / s, h / s, i / s,
  );
  // dart format on
  // @formatter:on

  /// Multiplies with a vector.
  Vector3 multiplyVector(Vector3 v) => Vector3(
    a * v.x + b * v.y + c * v.z,
    d * v.x + e * v.y + f * v.z,
    g * v.x + h * v.y + i * v.z,
  );

  /// Returns the trace of this matrix.
  double get trace => a + e + i;

  /// Returns the determinant of this matrix.
  double get determinant =>
      a * e * i + b * f * g + c * d * h - a * f * h - b * d * i - c * e * g;

  // @formatter:off
  // dart format off
  /// Returns the transpose of this matrix.
  Matrix3 transpose() => Matrix3(
    a, d, g,
    b, e, h,
    c, f, i,
  );
  // dart format on
  // @formatter:on

  // @formatter:off
  // dart format off
  /// Returns the adjoint of this matrix.
  Matrix3 adjoint() => Matrix3(
    e * i - f * h, c * h - b * i, b * f - c * e,
    f * g - d * i, a * i - c * g, c * d - a * f,
    d * h - e * g, b * g - a * h, a * e - b * d,
  );
  // dart format on
  // @formatter:on

  // @formatter:off
  // dart format off
  /// Returns the inverse of this matrix.
  /// If the determinant is zero, returns this matrix.
  Matrix3 invert() {
    final t = determinant;
    if (t == 0) {
      return this;
    } else {
      return Matrix3(
        // @formatter:off
        // dart format off
        (e * i - f * h) / t, (c * h - b * i) / t, (b * f - c * e) / t,
        (f * g - d * i) / t, (a * i - c * g) / t, (c * d - a * f) / t,
        (d * h - e * g) / t, (b * g - a * h) / t, (a * e - b * d) / t,
        // dart format on
        // @formatter:on
      );
    }
  }

  // @formatter:off
  // dart format off
  /// Applies the given function to each element of the matrix.
  Matrix3 apply(num Function(num) t) => Matrix3(
    t(a), t(b), t(c),
    t(d), t(e), t(f),
    t(g), t(h), t(i),
  );
  // dart format on
  // @formatter:on

  /// Converts this matrix to Euler angles.
  EulerAngles toEulerAngles() {
    final x = asin(clampDouble(h, -1, 1));
    final double y;
    final double z;
    if (h.abs() < 0.9999999) {
      y = atan2(-g, i);
      z = atan2(-b, e);
    } else {
      y = 0;
      z = atan2(d, a);
    }
    return EulerAngles(-z, x, y);
  }

  /// Converts this matrix to a quaternion.
  Quaternion toQuaternion() {
    final t = trace;
    if (t > 0) {
      final s = sqrt(t + 1);
      final r = 0.5 / s;
      return Quaternion((h - f) * r, (c - g) * r, (d - b) * r, s * 0.5);
    } else {
      final u = a < e ? (e < i ? 2 : 1) : (a < i ? 2 : 0);
      final v = (u + 1) % 3;
      final w = (u + 2) % 3;
      final s = sqrt(this[u * 4] - this[v * 4] - this[w * 4] + 1);
      final q = Float32List(4);
      final r = 0.5 / s;
      q[u] = s * 0.5;
      q[v] = (this[v * 3 + u] + this[u * 3 + v]) * r;
      q[w] = (this[w * 3 + u] + this[u * 3 + w]) * r;
      q[3] = (this[w * 3 + v] - this[v * 3 + w]) * r;
      return Quaternion(q[0], q[1], q[2], q[3]);
    }
  }
}
