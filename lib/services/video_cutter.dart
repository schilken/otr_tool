import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../logging_stream.dart';
import 'cutlist_parser.dart';

class VideoCutter {

  Future<void> cutVideo(
    String otrFolder,
    String videoFilename,
    String cutlistFilename,
      StreamController<String> loggingStreamController,
      {
    bool dryRun = true,
  }) async {
    loggingStreamController.add('Starting video cut... $videoFilename');
    final videoFilePath = p.join(otrFolder, videoFilename);
    await patchScript(
        videoFilePath,
        p.join(
          otrFolder,
          cutlistFilename,
      ),
    );
    final outputFilePath =
        videoFilePath.replaceFirst('_TVOON_DE', '_TVOON_DE-cut');
    if (dryRun) {
      loggingStreamController.add(
        'Dry run, not cutting inputfile, but custom_cut_script.py is generated',
      );
    } else {
      await runCutCommand(
        videoFilePath,
        outputFilePath,
        loggingStreamController,
      );
    }
  }

  Future<bool> patchScript(String videoFilePath, String cutlistFilePath) async {
    loggingStreamController.add('loadScriptTemplate()...');
    final scriptLines = await loadScriptTemplate();
    loggingStreamController.add('getSegmentsFromFile()...');
    final segmentLines =
        await getSegmentsFromFile(videoFilePath, cutlistFilePath);
    if (segmentLines.isEmpty) {
      loggingStreamController.add('No segments found in input file');
      return false;
    }
    loggingStreamController.add('${segmentLines.length} segment(s) found');
    scriptLines.addAll(segmentLines);
    await saveScript(scriptLines, customScriptPath);
    return true;
  }

  String get customScriptPath => p.join('/tmp', 'custom_cut_script.py');

  Future<List<String>> getSegmentsFromFile(
    String videoFilename,
    String cutlistFilename,
  ) async {
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
    const textasset = 'assets/files/cut_script_template.py';
    final text = await rootBundle.loadString(textasset);
    final lines = text.split('\n');
    return lines;
  }

  Future<void> saveScript(List<String> lines, String filePath) async {
    final infoFile = File(filePath);
    await infoFile.writeAsString(lines.join('\n'));
  }

//  /Applications/Avidemux_2.8.0.app/Contents/MacOS/avidemux_cli --load input.mpg.avi --run "cut-script-2.py" --save "output2.avi" --quit
  Future<void> runCutCommand(String inputFilename, String outputFilename,
    StreamController<String> loggingStreamController,
  ) async {
    final completer = Completer<void>();
    loggingStreamController.add('Running avidemux_cli ...');
    final process = await Process.start(
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
