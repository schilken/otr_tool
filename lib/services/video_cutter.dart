import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../logging_stream.dart';
import 'cutlist_parser.dart';

class VideoCutter {

  Future<void> cutVideo(String otrFolder, String videoFilename, cutlistFilename,
      StreamController<String> loggingStreamController,
      {bool dryRun = true}) async {
    loggingStreamController.add('Starting video cut... $videoFilename');
    loggingStreamController.add('loadScriptTemplate()...');
    List<String> scrtiptLines = await loadScriptTemplate();
    loggingStreamController.add('getSegmentsFromFile()...');
    final videoFilePath = p.join(otrFolder, videoFilename);
    final cutlistFilePath = p.join(otrFolder, cutlistFilename);
    List<String> segmentLines =
        await getSegmentsFromFile(videoFilePath, cutlistFilePath);
    if (segmentLines.isEmpty) {
      loggingStreamController.add('No segments found in input file');
      return;
    }
    scrtiptLines.addAll(segmentLines);
    loggingStreamController.add('${segmentLines.length} segment(s) found');
    await saveScript(scrtiptLines, customScriptPath);
    String outputFilePath =
        videoFilePath.replaceFirst('_TVOON_DE', '_TVOON_DE-cut');
    if (dryRun) {
      loggingStreamController.add(
          'Dry run, not cutting inputfile, but custom_cut_script.py is generated');
    } else {
      await runCutCommand(
          videoFilePath, outputFilePath, loggingStreamController);
    }
  }

  String get customScriptPath => p.join('/tmp', 'custom_cut_script.py');

  // Future<bool> temporaryFileExists(String filename) async {
  //   final dir = Directory.systemTemp;
  //   final filePath = p.join(dir.path, filename);
  //   return await File(filePath).exists();
  // }

  Future<List<String>> getSegmentsFromFile(
      String videoFilename, String cutlistFilename) async {
    final cutlistLines = await File(cutlistFilename).readAsLines();
    final cutlistParser = CutlistParser(videoFilename, cutlistLines);
    if (cutlistParser.isValid()) {
      return cutlistParser.segmentLines;
    } else {
      loggingStreamController.add('Invalid cutlist');
      return [];
    }
  }

  Future<List<String>> loadScriptTemplate() async {
    String textasset = "assets/files/cut_script_template.py";
    String text = await rootBundle.loadString(textasset);
    final lines = text.split('\n');
    // final dir = await currentDirectory;
    // final filePath = p.join(dir.path, 'cut_script_template.py');
    // final File infoFile = File(filePath);
    // final lines = await infoFile.readAsLines();
    return lines;
  }

  Future<void> saveScript(List<String> lines, String filePath) async {
    final File infoFile = File(filePath);
    await infoFile.writeAsString(lines.join('\n'));
  }

//  /Applications/Avidemux_2.8.0.app/Contents/MacOS/avidemux_cli --load input.mpg.avi --run "cut-script-2.py" --save "output2.avi" --quit
  Future<void> runCutCommand(String inputFilename, String outputFilename,
      StreamController<String> loggingStreamController) async {
    var completer = Completer();
    loggingStreamController.add('Running avidemux_cli ...');
    var process = await Process.start(
      '/usr/bin/script',
      [
        '/tmp/cutter.log',
        '/Applications/Avidemux_2.8.0.app/Contents/MacOS/avidemux_cli',
        '--load',
        inputFilename,
        '--run',
        customScriptPath,
        '--save',
        outputFilename,
        '--quit',
      ],
      runInShell: true,
    );
    final stdOutSubscription = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        if (line.contains('reconstruct')) {
          loggingStreamController.add(line);
        }
        if (line.contains('Yes')) {
          loggingStreamController
              .add('stdout >>>>> Yes or No asked!, answered yes');
          process.stdin.writeln('y');
        }
        if (line.contains('%')) {
          loggingStreamController.add(line);
        }
      },
    );
    stdOutSubscription.onDone(() {
      loggingStreamController.add('runCutCommand: onDone');
      loggingStreamController.add('-------------');
      completer.complete();
    });
    stdOutSubscription.onError(
      (error, stackTrace) {
        loggingStreamController.add('runCutCommand: Error ${error.toString()}');
        loggingStreamController.add('-------------');
        completer.complete();
        return;
      },
    );
    return completer.future;
  }
}
