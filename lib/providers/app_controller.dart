import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import '../logging_stream.dart';
import '../model/otr_data.dart';
import '../services/video_cutter.dart';
import 'providers.dart';

class AppController extends Notifier<AppState> {
  late SettingsState _settingsState;
  late FilesRepository _filesRepository;

  List<OtrData> _fullOtrDataList = [];

  @override
  AppState build() {
    debugPrint('AppController.build');
    _filesRepository = ref.watch(filesRepositoryProvider);
    _settingsState = ref.watch(settingsControllerProvider);
    return (AppState(
      currentPathname: _settingsState.otrFolder,
      details: [],
      fileCount: 0,
      isLoading: false,
    ));
  }

  Future<void> scanFolder() async {
    debugPrint('scanFolder: ${_settingsState.otrFolder}');
    state = state.copyWith(
      isLoading: true,
    );

    await Future.delayed(const Duration(seconds: 1));
    _filesRepository.currentFolderPath = _settingsState.otrFolder;
    final allFilePaths =
        await _filesRepository.findOtrFiles(_settingsState.otrFolder);
    allFilePaths.sort((a, b) => a.compareTo(b));
    _fullOtrDataList = _filesRepository.consolidateOtrFiles(allFilePaths);
    state = state.copyWith(
      fileCount: _fullOtrDataList.length,
      details: _fullOtrDataList,
    );
  }

  Future<void> reScanFolder() async {
    final allFilePaths =
        await _filesRepository.findOtrFiles(_settingsState.otrFolder);
    allFilePaths.sort((a, b) => a.compareTo(b));
    _fullOtrDataList = _filesRepository.consolidateOtrFiles(allFilePaths);
  }

  void openEditor(String? filename) {
    final filePath = p.join(_settingsState.otrFolder, filename);
    debugPrint('openEditor: $filePath');
    Process.run('/usr/local/bin/code', [filePath]);
  }

  showInFinder(String filename) {
    final filePath = p.join(_settingsState.otrFolder, filename);
    Process.run('open', ['-R', filePath]);
  }

  openTrash() {
    debugPrint('openTrash');
    Process.run('open', ['/Users/aschilken/.Trash']);
  }

  copyToClipboard(String path) {
    Clipboard.setData(ClipboardData(text: path));
  }

  Future<void> decodeCutAndCopyVideo(
      String otrkeyBasename, String cutlistBasename, String name) async {
    await decodeAndCutVideo(otrkeyBasename, cutlistBasename);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await reScanFolder();
    await moveToTrashOrToMovies(name);
  }

  Future<void> decodeAndCutVideo(
      String otrkeyBasename, String cutlistBasename) async {
    await decodeVideo(otrkeyBasename);
    final decodedBasename = otrkeyBasename.replaceFirst('.otrkey', '');
    debugPrint('decodeAndCutVideo#decodedBasename: $decodedBasename');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await cutVideo(decodedBasename, cutlistBasename);
  }

  Future<void> decodeVideo(String filename) async {
    debugPrint('decodeVideo: $filename');
    ref.read(pageIndexProvider.notifier).setPageIndex(1);
    await _runDecodeCommand(filename, loggingStreamController);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await reScanFolder();
  }

  Future<void> _runDecodeCommand(
    String filename,
    StreamController<String> loggingStreamController,
  ) async {
    loggingStreamController
        .add('_runDecodeCommand: ${_settingsState.otrdecoderBinary} started');
    var completer = Completer();
    final workingDirectory = _settingsState.otrFolder;
    final otrEmail = _settingsState.otrEmail;
    // this is the raw password without ***** handling
    final otrPassword =
        ref.read(settingsControllerProvider.notifier).otrPassword;
    final process = await Process.start(
      _settingsState.otrdecoderBinary,
      ['-i', filename, '-e', otrEmail, '-p', otrPassword],
      workingDirectory: workingDirectory,
    );
    final stdOutSubscription = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        loggingStreamController.add(line);
      },
    );
    stdOutSubscription.onDone(() {
      loggingStreamController.add('_runDecodeCommand: onDone');
      loggingStreamController.add('-------------');
      completer.complete();
    });
    stdOutSubscription.onError(
      (error, stackTrace) {
        loggingStreamController
            .add('_runDecodeCommand: Error ${error.toString()}');
        loggingStreamController.add('-------------');
        completer.complete();
        return;
      },
    );
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
      loggingStreamController.add('_runDecodeCommand: stdErr $line');
      debugPrint('stderr >> $line');
    });
    return completer.future;
  }

  Future<void> cutVideo(String videoFilename, String cutlistFilename) async {
    ref.read(pageIndexProvider.notifier).setPageIndex(1);
    await Future.delayed(const Duration(milliseconds: 500));
    final videoCutter = VideoCutter();
    await videoCutter.cutVideo(_settingsState.otrFolder, videoFilename,
        cutlistFilename, loggingStreamController,
        dryRun: false);
    Future<void>.delayed(const Duration(milliseconds: 500));
    reScanFolder();
  }

  Future<String> moveOtrkey() async {
    String result;
//    debugPrint('moveOtrkey called');
    final successCount = await _filesRepository.moveAllOtrFiles(
      _settingsState.downloadFolder,
      _settingsState.otrFolder,
    );
    if (successCount > 0) {
      result = 'moveOtrkey: $successCount Dateien Kopiert';
      loggingStreamController
          .add('moveOtrkey: $successCount Dateien von Downloads geholt');
    } else {
      await scanFolder();
      return '';
    }
    await scanFolder();
    return result;
  }

  void moveCutVideosToVideoFolder() {
    debugPrint('moveCutVideosToVideoFolder');
    for (final otrData in _fullOtrDataList) {
      if (otrData.isCutted) {
        debugPrint('${otrData.decodedBasename}');
        debugPrint('${otrData.otrkeyBasename}');
        debugPrint('${otrData.cutlistBasename}');
      }
    }
  }

  void cleanUp() {
    debugPrint('cleanUp');
  }

  Future<void> moveToTrashOrToMovies(String name) async {
    final otrData =
        _fullOtrDataList.firstWhere((otrData) => otrData.name == name);
    bool removeDecodedFile = otrData.isdeCoded;
    debugPrint('moveToTrashOrToMovies ${otrData.isCutted}');
    if (otrData.isCutted) {
      bool rc = await _filesRepository.moveOtrFile(
        _settingsState.otrFolder,
        _settingsState.videoFolder,
        otrData.cuttedBasename!,
      );
      loggingStreamController.add(
          'moveToTrashOrToMovies: otrData.cuttedBasename! nach ${_settingsState.videoFolder} verschoben');
    } else {
      if (otrData.isdeCoded) {
        bool rc = await _filesRepository.moveOtrFile(
          _settingsState.otrFolder,
          _settingsState.videoFolder,
          otrData.decodedBasename!,
        );
        removeDecodedFile = false;
      }
    }
    if (otrData.hasOtrkey) {
      await _filesRepository.moveToTrash(
          _settingsState.otrFolder, otrData.otrkeyBasename!);
      loggingStreamController.add(
          'moveToTrashOrToMovies: ${otrData.otrkeyBasename!} in Papierkorb verschoben');
    }
    if (otrData.hasCutlist) {
      await _filesRepository.moveToTrash(
          _settingsState.otrFolder, otrData.cutlistBasename!);
      loggingStreamController.add(
          'moveToTrashOrToMovies: ${otrData.cutlistBasename!} in Papierkorb verschoben');
    }
    if (removeDecodedFile) {
      await _filesRepository.moveToTrash(
          _settingsState.otrFolder, otrData.decodedBasename!);
      loggingStreamController.add(
          'moveToTrashOrToMovies: ${otrData.decodedBasename!} in Papierkorb verschoben');
    }
    reScanFolder();
  }

  moveAllToTrash(String name) async {
    final otrData =
        _fullOtrDataList.firstWhere((otrData) => otrData.name == name);
    if (otrData.hasOtrkey) {
      await _filesRepository.moveToTrash(
          _settingsState.otrFolder, otrData.otrkeyBasename!);
    }
    if (otrData.hasCutlist) {
      await _filesRepository.moveToTrash(
          _settingsState.otrFolder, otrData.cutlistBasename!);
    }
    scanFolder();
  }
}

final appControllerProvider = NotifierProvider<AppController, AppState>(() {
  return AppController();
});
