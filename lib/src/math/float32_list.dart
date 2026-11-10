import 'dart:typed_data';

Float32List numList(List<num> list) =>
    .fromList(list.map((e) => e.toDouble()).toList());
