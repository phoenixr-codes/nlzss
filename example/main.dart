import 'dart:io';
import 'dart:typed_data';
import 'package:nlzss/nlzss.dart' as nzlss;

void main() {
  final file = File('compressed.bin');
  final data = Uint8List.fromList(file.readAsBytesSync());
  final decompressed = nzlss.decompress(ByteData.sublistView(data));
  print(decompressed);
}
