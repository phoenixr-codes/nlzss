import 'dart:typed_data';

abstract interface class Writable {
  Uint8List get data;

  void write(List<int> bytes);
  void writeUint8(int x);
  void writeUint32(int x, [Endian endian = Endian.big]);
}
