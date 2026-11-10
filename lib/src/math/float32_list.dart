import 'dart:typed_data';

/// A utility function that converts a list of numbers to a [Float32List].
Float32List numList(List<num> list) =>
    .fromList(list.map((e) => e.toDouble()).toList());
