import 'dart:typed_data';

abstract interface class Readable {
  int? readUint8();
  int? readUint32([Endian endian = Endian.big]);
}
