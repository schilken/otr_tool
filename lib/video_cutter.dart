import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'cutlist_parser.dart';

class VideoCutter {

  cutVideo(String otrFolder, String videoFilename, cutlistFilename,
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
    await saveScript(scrtiptLines, 'custom_cut_script.py');
    String outputFilePath =
        videoFilePath.replaceFirst('_TVOON_DE', '_TVOON_DE-cut');
    if (dryRun) {
      loggingStreamController.add(
          'Dry run, not cutting inputfile, but custom_cut_script.py is generated');
    } else {
      runCutCommand(videoFilePath, outputFilePath, loggingStreamController);
    }
  }

Future<bool> fileExists(String filename) async {
    final dir = await currentDirectory;
    final filePath = p.join(dir.path, filename);
    return await File(filePath).exists();
  }

  Future<List<String>> getSegmentsFromFile(
      String videoFilename, String cutlistFilename) async {
    final cutlistLines = await File(cutlistFilename).readAsLines();
    final cutlistParser = CutlistParser(videoFilename, cutlistLines);
    if (cutlistParser.isValid()) {
      return cutlistParser.segmentLines;
    } else {
      print('Invalid cutlist');
      return [];
    }
  }

  Future<Directory> get currentDirectory async {
    return Directory.current;
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

  Future<void> saveScript(List<String> lines, String filename) async {
    final dir = await currentDirectory;
    final filePath = p.join(dir.path, filename);
    final File infoFile = File(filePath);
    await infoFile.writeAsString(lines.join('\n'));
  }

//  /Applications/Avidemux_2.8.0.app/Contents/MacOS/avidemux_cli --load input.mpg.avi --run "cut-script-2.py" --save "output2.avi" --quit
  void runCutCommand(String inputFilename, String outputFilename,
      StreamController<String> streamController) {
    streamController.add('Running avidemux_cli ...');
    var process = Process.start(
      'script',
      [
        'cutter.log',
        '/Applications/Avidemux_2.8.0.app/Contents/MacOS/avidemux_cli',
        '--load',
        inputFilename,
        '--run',
        'custom_cut_script.py',
        '--save',
        outputFilename,
        '--quit',
      ],
      runInShell: true,
    ).then(
      (proc) => proc.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .forEach((line) {
        if (line.contains('Yes')) {
          streamController.add('stdout >>>>>Yes or No asked!, answered yes');
          proc.stdin.writeln('y');
        }
        if (line.contains('%')) {
//          print(line);
          streamController.add(line);
        }
      }).whenComplete(() {
        streamController.add('Stream closed in whenComplete');
        return streamController.close();
      }).onError((error, stackTrace) {
        streamController.add('Stream closed onError');
        return streamController.close();
      }),
    );
  }
}
