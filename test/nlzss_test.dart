import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:nlzss/nlzss.dart' as nlzss;
import 'package:test/test.dart';

void main() {
  test('LZ11 small decompression', () {
    final compressed = Uint8List.fromList(
      [
        0x11,
        0x07,
        0x00,
        0x00,
        0x00,
        0x41,
        0x42,
        0x43,
        0x44,
        0x45,
        0x46,
        0x47,
        0xff,
        0x00
      ],
    );
    final decompressed = nlzss.decompress(ByteData.sublistView(compressed));
    expect(decompressed, equals(utf8.encode('ABCDEFG')));
  });

  test('LZ11 large decompression', () {
    final compressed = Uint8List.fromList(
      [
        0x11,
        0x39,
        0x00,
        0x00,
        0x00,
        0x49,
        0x7e,
        0x02,
        0xd0,
        0xcb,
        0x28,
        0xa4,
        0x47,
        0x00,
        0xb7,
        0xa0,
        0x4e,
        0xa9,
        0x3a,
        0x46,
        0x67,
        0xd4,
        0x00,
        0x20,
        0xad,
        0x5a,
        0xde,
        0xfd,
        0xf0,
        0x34,
        0xaf,
        0x00,
        0xb9,
        0x91,
        0xde,
        0xed,
        0x86,
        0x97,
        0x9d,
        0xc1,
        0x00,
        0x5d,
        0x2c,
        0xda,
        0xd3,
        0xea,
        0x88,
        0xc1,
        0xee,
        0x00,
        0xbc,
        0x8f,
        0xd7,
        0xf7,
        0x08,
        0x8f,
        0x46,
        0x3e,
        0x00,
        0xe2,
        0x1d,
        0x3a,
        0x02,
        0x27,
        0x8d,
        0x15,
        0x37,
        0x00,
        0x93,
        0xff
      ],
    );
    final decompressed = nlzss.decompress(ByteData.sublistView(compressed));
    expect(
      decompressed,
      equals(
        [
          0x49,
          0x7e,
          0x02,
          0xd0,
          0xcb,
          0x28,
          0xa4,
          0x47,
          0xb7,
          0xa0,
          0x4e,
          0xa9,
          0x3a,
          0x46,
          0x67,
          0xd4,
          0x20,
          0xad,
          0x5a,
          0xde,
          0xfd,
          0xf0,
          0x34,
          0xaf,
          0xb9,
          0x91,
          0xde,
          0xed,
          0x86,
          0x97,
          0x9d,
          0xc1,
          0x5d,
          0x2c,
          0xda,
          0xd3,
          0xea,
          0x88,
          0xc1,
          0xee,
          0xbc,
          0x8f,
          0xd7,
          0xf7,
          0x08,
          0x8f,
          0x46,
          0x3e,
          0xe2,
          0x1d,
          0x3a,
          0x02,
          0x27,
          0x8d,
          0x15,
          0x37,
          0x93,
        ],
      ),
    );
  });

  test('LZ11 small compression', () {
    final decompressed = utf8.encode('ABCDEFG');
    final compressed =
        nlzss.compress(decompressed, nlzss.LZ11Algorithm(nlzss.maxRepeatSize));
    expect(
      compressed,
      equals(
        Uint8List.fromList(
          [
            0x11,
            0x07,
            0x00,
            0x00,
            0x00,
            0x41,
            0x42,
            0x43,
            0x44,
            0x45,
            0x46,
            0x47,
            0xff,
          ],
        ),
      ),
    );
  });

  test('LZ11 large compression', () {
    final decompressed = Uint8List.fromList([
      0x49,
      0x7e,
      0x02,
      0xd0,
      0xcb,
      0x28,
      0xa4,
      0x47,
      0xb7,
      0xa0,
      0x4e,
      0xa9,
      0x3a,
      0x46,
      0x67,
      0xd4,
      0x20,
      0xad,
      0x5a,
      0xde,
      0xfd,
      0xf0,
      0x34,
      0xaf,
      0xb9,
      0x91,
      0xde,
      0xed,
      0x86,
      0x97,
      0x9d,
      0xc1,
      0x5d,
      0x2c,
      0xda,
      0xd3,
      0xea,
      0x88,
      0xc1,
      0xee,
      0xbc,
      0x8f,
      0xd7,
      0xf7,
      0x08,
      0x8f,
      0x46,
      0x3e,
      0xe2,
      0x1d,
      0x3a,
      0x02,
      0x27,
      0x8d,
      0x15,
      0x37,
      0x93,
    ]);
    final compressed =
        nlzss.compress(decompressed, nlzss.LZ11Algorithm(nlzss.maxRepeatSize));
    expect(
      compressed,
      equals(
        Uint8List.fromList(
          [
            0x11,
            0x39,
            0x00,
            0x00,
            0x00,
            0x49,
            0x7e,
            0x02,
            0xd0,
            0xcb,
            0x28,
            0xa4,
            0x47,
            0x00,
            0xb7,
            0xa0,
            0x4e,
            0xa9,
            0x3a,
            0x46,
            0x67,
            0xd4,
            0x00,
            0x20,
            0xad,
            0x5a,
            0xde,
            0xfd,
            0xf0,
            0x34,
            0xaf,
            0x00,
            0xb9,
            0x91,
            0xde,
            0xed,
            0x86,
            0x97,
            0x9d,
            0xc1,
            0x00,
            0x5d,
            0x2c,
            0xda,
            0xd3,
            0xea,
            0x88,
            0xc1,
            0xee,
            0x00,
            0xbc,
            0x8f,
            0xd7,
            0xf7,
            0x08,
            0x8f,
            0x46,
            0x3e,
            0x00,
            0xe2,
            0x1d,
            0x3a,
            0x02,
            0x27,
            0x8d,
            0x15,
            0x37,
            0x00,
            0x93,
            0xff
          ],
        ),
      ),
    );
  });

  final rng = Random();
  final maxSize = 50;
  final minSize = 1;
  for (int i = 0; i < 10; i++) {
    final List<int> data = [];
    final size = rng.nextInt(maxSize - minSize);
    for (int j = 0; j < size; j++) {
      final byte = rng.nextInt(0xFF);
      data.add(byte);
    }

    final maxRepeatSize = rng.nextInt(nlzss.maxRepeatSize);

    final List<int> compressed = nlzss.compress(
        Uint8List.fromList(data), nlzss.LZ11Algorithm(maxRepeatSize));
    final List<int> decompressed =
        nlzss.decompress(ByteData.sublistView(Uint8List.fromList(compressed)));

    test('LZ11 with random bytes ($i)', () {
      expect(data, equals(decompressed));
    });
  }
}
