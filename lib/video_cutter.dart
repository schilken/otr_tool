import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'cutlist_parser.dart';

class VideoCutter {
  cutVideo(String videoFilename, StreamController<String> streamController,
      {bool dryRun = true}) async {
    streamController.add('Starting video cut... $videoFilename');
    streamController.add('loadScriptTemplate()...');
    List<String> lines = await loadScriptTemplate();
    streamController.add('getSegmentsFromFile()...');
    List<String> segmentLines = await getSegmentsFromFile(videoFilename);
    if (segmentLines.isEmpty) {
      print('No segments found in input file');
      exit(2);
    }
    lines.addAll(segmentLines);
    streamController.add('${segmentLines.length} segment(s) found');
    await saveScript(lines, 'custom_cut_script.py');
    final basenameWithoutExtension = p.basenameWithoutExtension(videoFilename);
    String outputFilename =
        videoFilename.replaceFirst('_TVOON_DE', '_TVOON_DE-cut');
    if (dryRun) {
      streamController.add(
          'Dry run, not cutting inputfile, but custom_cut_script.py is generated');
    } else {
      runCutCommand(videoFilename, outputFilename, streamController);
    }
  }

  Future<List<String>> getSegmentsFromFile(String inputFilename) async {
    final extension = p.extension(inputFilename);
    final cutlistFilename =
        inputFilename.replaceFirst(extension, '$extension.cutlist');
    final cutlist = await File(cutlistFilename).readAsLines();
    final cutlistParser = CutlistParser(inputFilename, cutlist);
    if (cutlistParser.isValid()) {
      return cutlistParser.segmentLines;
    } else {
      print('Invalid cutlist');
      return [];
    }
  }

  List<String> parseSegmentLines(List<String> cutlist) {
    List<String> segmentLines = [];
    segmentLines.add('adm.addSegment(0, 542180000, 8160020000');
    return segmentLines;
  }

  Future<Directory> get currentDirectory async {
    return Directory.current;
  }

  Future<List<String>> loadScriptTemplate() async {
    final dir = await currentDirectory;
    final filePath = p.join(dir.path, 'cut_script_template.py');
    final File infoFile = File(filePath);
    final lines = await infoFile.readAsLines();
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
          streamController.add('stdout >>>>>Yes or No found!, entered yes');
          proc.stdin.writeln('y');
        }
        if (line.contains('%')) {
          print(line);
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
