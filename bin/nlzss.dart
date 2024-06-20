import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:args/command_runner.dart';
import 'package:nlzss/nlzss.dart' as nlzss;

class CompressCommand extends Command {
  @override
  final name = 'compress';

  @override
  final description = 'Compresses data';

  @override
  final aliases = ['c'];

  CompressCommand() {
    argParser.addOption('level',
        abbr: 'L',
        help: 'Whether to use LZ10 or LZ11 compression algorithm.',
        defaultsTo: '11');
  }

  @override
  void run() async {
    final level = argResults!.option('level');
    nlzss.Algorithm algorithm;
    switch (level) {
      case '10':
        algorithm = nlzss.LZ10Algorithm();
      case '11':
        algorithm = nlzss.LZ11Algorithm(nlzss.maxRepeatSize);
      default:
        throw 'Invalid level $level';
    }
    final compressed = nlzss.compress(
      Uint8List.fromList((await stdin.toList()).expand((x) => x).toList()),
      algorithm,
    );
    stdout.add(compressed);
  }
}

class DecompressCommand extends Command {
  @override
  final name = 'decompress';

  @override
  final description = 'Decompresses data';

  @override
  final aliases = ['d'];

  DecompressCommand() {
    argParser.addOption('path', mandatory: false);
  }

  @override
  Future<void> run() async {
    final path = argResults!.option('path');
    final List<int> compressed = [];
    if (path == null) {
      compressed.addAll((await stdin.toList()).expand((x) => x));
    } else {
      compressed.addAll(await File(path).readAsBytes());
    }

    final decompressed =
        nlzss.decompress(ByteData.sublistView(Uint8List.fromList(compressed)));
    stdout.add(decompressed);
  }
}

void main(List<String> arguments) {
  CommandRunner('nlzss', '(De)compression with Nintendo\'s LZSS format')
    ..addCommand(CompressCommand())
    ..addCommand(DecompressCommand())
    ..run(arguments);
}
