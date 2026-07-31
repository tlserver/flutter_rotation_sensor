import 'dart:typed_data';

Float32List numList(List<num> list) =>
    Float32List.fromList(list.map((e) => e.toDouble()).toList());
