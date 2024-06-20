// TODO: replace magic numbers with constants

import 'dart:typed_data';
import '_bytes.dart';
import '_search.dart';

/// The maximum repeat size allowed for the LZ11 algorithm.
const maxRepeatSize = 65809;

abstract class LZException implements Exception {
  @override
  String toString() => 'LZException';
}

class ByteReadException implements LZException {
  /// Message describing cause of the exception.
  final String message;

  const ByteReadException(this.message);

  @override
  String toString() {
    return 'ByteReadException: $message';
  }
}

class UnknownVersionException implements LZException {
  /// Message describing cause of the exception.
  final String message;

  const UnknownVersionException(this.message);

  @override
  String toString() {
    return 'UnknownVersionException: $message';
  }
}

class InputDataTooLargeException implements LZException {
  /// Message describing cause of the exception.
  final String message;

  const InputDataTooLargeException(this.message);

  @override
  String toString() {
    return 'InputDataTooLargeException: $message';
  }
}

sealed class Algorithm {
  /// Maximum repeat size in bytes.
  int get maximumRepeatSize;

  /// The magic version number.
  _Version get _version;
}

class LZ10Algorithm extends Algorithm {
  LZ10Algorithm();

  @override
  int get maximumRepeatSize => 18;

  @override
  _Version get _version => _Version.lz10;
}

class LZ11Algorithm extends Algorithm {
  final int _maximumRepeatSize;

  LZ11Algorithm(this._maximumRepeatSize) {
    assert(0 <= _maximumRepeatSize && _maximumRepeatSize <= maxRepeatSize);
  }

  @override
  int get maximumRepeatSize => _maximumRepeatSize;

  @override
  _Version get _version => _Version.lz11;
}

enum _Version { lz10, lz11 }

(int, int)? _findLongestMatch(List<int> data, int off, int max) {
  if (off < 4 || data.length - off < 4) {
    return null;
  }

  var longestPos = 0;
  var longestLen = 0;
  var start = 0;

  if (off > 0x1000) {
    start = off - 0x1000;
  }

  for (final pos
      in search(data.sublist(start, off + 2), data.sublist(off, off + 3))) {
    var length = 0;
    for (final (index, position)
        in List.generate(off + data.length, (i) => off + i).indexed) {
      if (length == max) {
        return (start + pos, length);
      }
      if (data[position] != data[start + pos + index]) {
        break;
      }
      length += 1;
    }
    if (length > longestLen) {
      longestPos = pos;
      longestLen = length;
    }
  }
  if (longestLen < 3) {
    return null;
  }
  return (start + longestPos, longestLen);
}

/// Decompresses LZ10/LZ11 compressed data.
///
/// ```dart
/// import 'dart:io';
/// import 'dart:typed_data';
/// import 'package:nzlss/nzlss.dart' as nzlss;
///
/// void main() {
///   final file = File('compressed.bin');
///   final data = Uint8List.fromList(file.readAsBytesSync());
///   final decompressed = nzlss.decompress(ByteData.sublistView(data));
///   print(decompressed);
/// }
/// ```
Uint8List decompress(ByteData data) {
  final bytes = ReadBytes(data);

  var length = bytes.readUint32(Endian.little);
  if (length == null) {
    throw ByteReadException('Expected a 32-bit unsigned integer');
  }
  final version = length & 0xFF;
  final compressionLevel = switch (version) {
    0x10 => _Version.lz10,
    0x11 => _Version.lz11,
    _ => throw UnknownVersionException('Unknown compression version $version'),
  };

  length >>= 8;
  if (length == 0 && compressionLevel == _Version.lz11) {
    length = bytes.readUint32(Endian.little);
    if (length == null) {
      throw ByteReadException('Expected a 32-bit unsigned integer');
    }
  }

  final List<int> output = [];
  while (output.length < length) {
    final byte = bytes.readUint8();
    if (byte == null) {
      throw ByteReadException('Expected a 8-bit unsigned integer');
    }
    for (final bit in Iterable.generate(8, (i) => 7 - i)) {
      if (output.length >= length) {
        break;
      }

      if (((byte >> bit) & 1) == 0) {
        final b = bytes.readUint8();
        if (b == null) {
          throw ByteReadException('Expected a 8-bit unsigned integer');
        }
        output.add(b);
        continue;
      }

      final lenmsb = bytes.readUint8();
      if (lenmsb == null) {
        throw ByteReadException('Expected a 8-bit unsigned integer (lenmsb)');
      }
      final lsb = bytes.readUint8();
      if (lsb == null) {
        throw ByteReadException('Expected a 8-bit unsigned integer (lsb)');
      }
      var length2 = lenmsb >> 4;
      assert(length2 >= 0);
      var disp = ((lenmsb & 15) << 8) + lsb;
      assert(disp >= 0);

      if (compressionLevel == _Version.lz10) {
        length2 += 3;
      } else if (length2 > 1) {
        length2 += 1;
      } else if (length2 == 0) {
        length2 = (lenmsb & 15) << 4;
        length2 += lsb >> 4;
        length2 += 0x11;
        final msb = bytes.readUint8();
        if (msb == null) {
          throw ByteReadException('Expected a 8-bit unsigned integer (msb)');
        }
        disp = ((lsb & 15) << 8) + msb;
      } else {
        length2 = (lenmsb & 15) << 12;
        length2 += lsb << 4;
        final byte1 = bytes.readUint8();
        if (byte1 == null) {
          throw ByteReadException('Expected a 8-bit unsigned integer');
        }
        final byte2 = bytes.readUint8();
        if (byte2 == null) {
          throw ByteReadException('Expected a 8-bit unsigned integer');
        }
        length2 += byte1 >> 4;
        length2 += 0x111;
        disp = ((byte1 & 15) << 8) + byte2;
      }

      final start = output.length - disp - 1;
      assert(start >= 0);

      for (var i = 0; i < length2; i++) {
        final value = output[start + i];
        output.add(value);
      }
    }
  }

  return Uint8List.fromList(output);
}

/// Compresses arbitrary data.
List<int> compress(Uint8List data, Algorithm algorithm) {
  final output = WriteBytes();

  final size = data.length;

  if (algorithm._version == _Version.lz10 && size > 16777216) {
    throw InputDataTooLargeException(
        'Input data too large for LZ10 ($size > 16777216)');
  }

  if (algorithm._version == _Version.lz11 && size > 0xFFFFFFFF) {
    throw InputDataTooLargeException(
        'Input data too large for LZ11 ($size) > ${0xFFFFFFFF}');
  }

  if (size < 16777216 && (size != 0 || algorithm._version == _Version.lz10)) {
    final header = switch (algorithm) {
          LZ10Algorithm() => 0x10,
          LZ11Algorithm() => 0x11,
        } +
        (size << 8);
    output.writeUint32(header, Endian.little);
  } else {
    output.writeUint32(0x11, Endian.little);
    output.writeUint32(size, Endian.little);
  }

  var off = 0;
  var byte = 0;
  var index = 7;
  final List<int> cmpbuf = [];

  while (off < size) {
    final longestMatch =
        _findLongestMatch(data, off, algorithm.maximumRepeatSize);
    if (longestMatch == null) {
      index -= 1;
      cmpbuf.add(data[off]);
      off += 1;
    } else {
      final pos = longestMatch.$1;
      final len = longestMatch.$2;

      final lzOff = off - pos - 1;
      byte |= 1 << index;
      index -= 1;

      if (algorithm._version == _Version.lz10) {
        final l = len - 3;
        cmpbuf.add((lzOff >> 8) + (l << 4));
        cmpbuf.add(lzOff);
      } else if (len < 0x11) {
        final l = len - 1;
        cmpbuf.add((lzOff >> 8) + (l << 4));
        cmpbuf.add(lzOff);
      } else if (len < 0x111) {
        final l = len - 0x11;
        cmpbuf.add(l >> 4);
        cmpbuf.add((lzOff >> 8) + (l << 4));
        cmpbuf.add(lzOff);
      } else {
        final l = len - 0x111;
        cmpbuf.add((l >> 12) + 0x10);
        cmpbuf.add(l >> 4);
        cmpbuf.add((lzOff >> 8) + (l << 4));
        cmpbuf.add(lzOff);
      }

      off += len;
    }

    if (index < 0) {
      output.writeUint8(byte);
      output.write(cmpbuf);
      byte = 0;
      index = 7;
      cmpbuf.clear();
    }
  }

  if (cmpbuf.isNotEmpty) {
    output.writeUint8(byte);
    output.write(cmpbuf);
  }
  output.writeUint8(0xFF);

  return output.data;
}
