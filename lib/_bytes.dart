import 'dart:typed_data';
import '_write.dart';
import '_read.dart';

class ReadBytes implements Readable {
  final ByteData _data;
  int _ptr = 0;

  ReadBytes(this._data);

  @override
  int? readUint8() {
    try {
      final res = _data.getUint8(_ptr);
      _ptr += 1;
      return res;
    } on ArgumentError {
      return null;
    }
  }

  @override
  int? readUint32([Endian endian = Endian.big]) {
    try {
      final res = _data.getUint32(_ptr, endian);
      _ptr += 4;
      return res;
    } on ArgumentError {
      return null;
    }
  }
}

class WriteBytes implements Writable {
  final BytesBuilder _data = BytesBuilder();

  WriteBytes();

  @override
  Uint8List get data => _data.toBytes(); // FIXME: change to takeBytes

  @override
  void write(List<int> bytes) {
    _data.add(bytes);
  }

  @override
  void writeUint8(int x) {
    _data.addByte(x);
  }

  @override
  void writeUint32(int x, [Endian endian = Endian.big]) {
    if (endian == Endian.little) {
      _data.addByte(x);
      _data.addByte(x >> 8);
      _data.addByte(x >> 16);
      _data.addByte(x >> 24);
    } else if (endian == Endian.big) {
      _data.addByte(x >> 24);
      _data.addByte(x >> 16);
      _data.addByte(x >> 8);
      _data.addByte(x);
    } else {
      assert(false);
    }
  }
}
