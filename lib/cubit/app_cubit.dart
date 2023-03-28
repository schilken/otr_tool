import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:otr_browser/services/files_repository.dart';

import '../logging_stream.dart';
import '../model/otr_data.dart';
import '../preferences/settings_cubit.dart';
import '../services/video_cutter.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(
    SettingsCubit settingsCubit,
    this.filesRepository,
  )   : _settingsCubit = settingsCubit,
        super(AppInitial()) {
    debugPrint('create AppCubit');
    if (settingsCubit.state is SettingsLoaded) {
//      _applyFilters(_settingsCubit.state as SettingsLoaded);
    }
    _settingsCubit.stream.listen((settings) {
      if (settings is SettingsLoaded) {
//        _applyFilters(settings);
      }
    });
  }
  final FilesRepository filesRepository;
  String _currentFolderPath = "no file selected";
  final SettingsCubit _settingsCubit;
  List<OtrData> _fullOtrDataList = [];

  // pathname → loist of 10 lines following hit
  final sectionsMap = <String, List<String>>{};

  init() async {
    debugPrint('AppCubit.init');
    await scanFolder(folderPath: _settingsCubit.otrFolder);
  }

  Future<void> reScanFolder() async {
    return scanFolder(folderPath: _currentFolderPath);
  }

  Future<void> scanFolder({required String folderPath}) async {
    debugPrint('scanFolder: $folderPath');
    _settingsCubit.setOtrFolder(folderPath);
    emit(DetailsLoading());
    await Future.delayed(const Duration(seconds: 1));
    filesRepository.currentFolderPath = folderPath;
    final allFilePaths = await filesRepository.findOtrFiles(folderPath);
    allFilePaths.sort((a, b) => a.compareTo(b));
    _fullOtrDataList = filesRepository.consolidateOtrFiles(allFilePaths);
    _currentFolderPath = folderPath;
    emit(
      DetailsLoaded(
        currentPathname: _currentFolderPath,
        fileCount: _fullOtrDataList.length,
        details: _fullOtrDataList,
        sidebarPageIndex: 0,
      ),
    );
  }

  void openEditor(String? filename) {
    final filePath = p.join(_settingsCubit.otrFolder, filename);
    debugPrint('openEditor: $filePath');
    Process.run('/usr/local/bin/code', [filePath]);
  }

  showInFinder(String filename) {
    final filePath = p.join(_settingsCubit.otrFolder, filename);
    Process.run('open', ['-R', filePath]);
  }

  openTrash() {
    debugPrint('openTrash');
    Process.run('open', ['/Users/aschilken/.Trash']);
  }

  Future<void> cutVideo(String videoFilename, String cutlistFilename) async {
    loggingStreamController.add('cutVideo: started');
    debugPrint('cutVideo: $videoFilename');
    var completer = Completer();
    final currentState = state as DetailsLoaded;

    emit(currentState.copyWith(sidebarPageIndex: 1));

    await Future.delayed(const Duration(milliseconds: 500));
    final videoCutter = VideoCutter();
    videoCutter.cutVideo(_settingsCubit.otrFolder, videoFilename,
        cutlistFilename, loggingStreamController,
        dryRun: false);
    loggingStreamController.stream.listen((line) {}).onDone(() {
      debugPrint('cutVideo: done');
      Future<void>.delayed(const Duration(milliseconds: 500));
      reScanFolder();
      completer.complete();
    });
    return completer.future;
  }

  copyToClipboard(String path) {
    Clipboard.setData(ClipboardData(text: path));
  }

  sidebarChanged(int index) {
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(sidebarPageIndex: index));
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
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(sidebarPageIndex: 1));
    await _runDecodeCommand(filename, loggingStreamController);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await reScanFolder();
  }

  Future<void> _runDecodeCommand(
    String filename,
    StreamController<String> loggingStreamController,
  ) async {
    loggingStreamController
        .add('_runDecodeCommand: ${_settingsCubit.otrdecoderBinary} started');
    var completer = Completer();
    final workingDirectory = _settingsCubit.otrFolder;
    final otrEmail = _settingsCubit.otrEmail;
    final otrPassword = _settingsCubit.otrPassword;
    final process = await Process.start(
      _settingsCubit.otrdecoderBinary,
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

  Future<String> moveOtrkey() async {
    String result;
//    debugPrint('moveOtrkey called');
    final successCount = await filesRepository.moveAllOtrFiles(
      '/Users/aschilken/Downloads',
      _settingsCubit.otrFolder,
    );
    if (successCount > 0) {
      result = 'moveOtrkey: $successCount Dateien Kopiert';
      scanFolder(folderPath: _settingsCubit.otrFolder);
    } else {
      return '';
    }
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
      bool rc = await filesRepository.moveOtrFile(
        _settingsCubit.otrFolder,
        _settingsCubit.videoFolder,
        otrData.cuttedBasename!,
      );
    } else {
      if (otrData.isdeCoded) {
        bool rc = await filesRepository.moveOtrFile(
          _settingsCubit.otrFolder,
          _settingsCubit.videoFolder,
          otrData.decodedBasename!,
        );
        removeDecodedFile = false;
      }
    }
    if (otrData.hasOtrkey) {
      await filesRepository.moveToTrash(
          _currentFolderPath, otrData.otrkeyBasename!);
    }
    if (otrData.hasCutlist) {
      await filesRepository.moveToTrash(
          _currentFolderPath, otrData.cutlistBasename!);
    }
    if (removeDecodedFile) {
      await filesRepository.moveToTrash(
          _currentFolderPath, otrData.decodedBasename!);
    }
    scanFolder(folderPath: _settingsCubit.otrFolder);
  }

  moveAllToTrash(String name) async {
    final otrData =
        _fullOtrDataList.firstWhere((otrData) => otrData.name == name);
    if (otrData.hasOtrkey) {
      await filesRepository.moveToTrash(
          _currentFolderPath, otrData.otrkeyBasename!);
    }
    if (otrData.hasCutlist) {
      await filesRepository.moveToTrash(
          _currentFolderPath, otrData.cutlistBasename!);
    }
    scanFolder(folderPath: _settingsCubit.otrFolder);
  }
}
