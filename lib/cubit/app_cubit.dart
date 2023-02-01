import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:otr_browser/services/files_repository.dart';

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
    print('create AppCubit');
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
  String? _primaryWord;
  String _currentFolderPath = "no file selected";
  final SettingsCubit _settingsCubit;
  List<OtrData> _fullOtrDataList = [];
  final List<OtrData> _filteredOtrDataList = [];

  // pathname → loist of 10 lines following hit
  final sectionsMap = <String, List<String>>{};

  void setPrimarySearchWord(String? word) {
    print('setPrimarySearchWord: $word');
    _primaryWord = word;
    if (_primaryWord != null && (_primaryWord ?? '').isEmpty) {
      _primaryWord = null;
    }
  }

  init() async {
    print('AppCubit.init');
    await scanFolder(folderPath: _settingsCubit.otrFolder);
    await search();
  }

  Future<void> search() async {
    emit(DetailsLoading());
    print('search: $_primaryWord');
    await Future.delayed(const Duration(milliseconds: 500));
    _filteredOtrDataList.clear();
    for (final otrData in _fullOtrDataList) {
      if (otrData.name.contains(_primaryWord ?? '')) {
        _filteredOtrDataList.add(otrData);
      }
    }
    emit(
      DetailsLoaded(
        currentPathname: _currentFolderPath,
        fileCount: _fullOtrDataList.length,
        primaryHitCount: _filteredOtrDataList.length,
        details: _filteredOtrDataList,
        primaryWord: _primaryWord,
        sidebarPageIndex: 0,
      ),
    );
  }

  Future<void> reScanFolder() async {
    return scanFolder(folderPath: _currentFolderPath);
  }

  Future<void> scanFolder({required String folderPath}) async {
    print('scanFolder: $folderPath');
    _settingsCubit.setOtrFolder(folderPath);
    emit(DetailsLoading());
    await Future.delayed(const Duration(seconds: 1));
    filesRepository.currentFolderPath = folderPath;
    final allFilePaths = await filesRepository.findOtrFiles(folderPath);
    allFilePaths.sort((a, b) => a.compareTo(b));
    _fullOtrDataList = filesRepository.consolidateOtrFiles(allFilePaths);
    _currentFolderPath = folderPath;
    await search();
  }

  void openEditor(String? filename) {
    final filePath = p.join(_settingsCubit.otrFolder, filename);
    print('openEditor: $filePath');
    Process.run('/usr/local/bin/code', [filePath]);
  }

  showInFinder(String filename) {
    final filePath = p.join(_settingsCubit.otrFolder, filename);
    Process.run('open', ['-R', filePath]);
  }

  Future<void> cutVideo(String videoFilename, String cutlistFilename) async {
    print('cutVideo: $videoFilename');
    final currentState = state as DetailsLoaded;
    final streamController = StreamController<String>.broadcast();

    emit(currentState.copyWith(
        sidebarPageIndex: 1, commandStdoutStream: streamController.stream));

    await Future.delayed(const Duration(milliseconds: 500));
    final videoCutter = VideoCutter();
    videoCutter.cutVideo(_settingsCubit.otrFolder, videoFilename,
        cutlistFilename, streamController,
        dryRun: false);
    streamController.stream.listen((line) {}).onDone(() {
      print('cutVideo: done');
      Future<void>.delayed(const Duration(milliseconds: 500));
      reScanFolder();
    });
  }

  copyToClipboard(String path) {
    Clipboard.setData(ClipboardData(text: path));
  }

  sidebarChanged(int index) {
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(sidebarPageIndex: index));
  }

  decodeAndCutVideo(String otrkeyBasename, String cutlistBasename) async {
    await decodeVideo(otrkeyBasename);
    final decodedBasename = otrkeyBasename.replaceFirst('.otrkey', '');
    print('decodeAndCutVideo#decodedBasename: ${decodedBasename}');
  }

  Future<void> decodeVideo(String filename) async {
    print('decodeVideo: $filename');
    var completer = Completer();
    final streamController = StreamController<String>.broadcast();
    _runDecodeCommand(filename, streamController);
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(
        sidebarPageIndex: 1, commandStdoutStream: streamController.stream));
    streamController.stream.listen((line) {}).onDone(() async {
      print('decodeVideo: done');
      Future<void>.delayed(const Duration(milliseconds: 500));
      await reScanFolder();
      completer.complete;
    });
    return completer.future;
  }

  Future<void> _runDecodeCommand(
    String filename,
    StreamController<String> streamController,
  ) async {
    final workingDirectory = _settingsCubit.otrFolder;
    final otrEmail = _settingsCubit.otrEmail;
    final otrPassword = _settingsCubit.otrPassword;
    final process = await Process.start(
      _settingsCubit.otrdecoderBinary,
      ['-i', filename, '-e', otrEmail, '-p', otrPassword],
      workingDirectory: workingDirectory,
    );

    process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .forEach(
      (line) {
        streamController.add(line);
//        print(line);
      },
          )
          .whenComplete(() {
        streamController.add('Stream closed in whenComplete');
        return streamController.close();
      }).onError((error, stackTrace) {
        streamController.add('Stream closed onError');
        return streamController.close();
      },
    );
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
      streamController.add(line);
      print('stderr >> $line');
    });
  }

  Future<String> moveOtrkey() async {
    String result;
//    print('moveOtrkey called');
    final successCount = await filesRepository.moveAllOtrFiles(
      '/Users/aschilken/Downloads',
      _settingsCubit.otrFolder,
    );
    if (successCount > 0) {
      result = 'moveOtrkey: $successCount Dateien Kopiert';
      scanFolder(folderPath: _settingsCubit.otrFolder);
    } else {
      result = 'moveOtrkey: keine Dateien gefunden';
    }
    return result;
  }

  void moveCutVideosToVideoFolder() {
    print('moveCutVideosToVideoFolder');
    for (final otrData in _filteredOtrDataList) {
      if (otrData.isCutted) {
        print('${otrData.decodedBasename}');
        print('${otrData.otrkeyBasename}');
        print('${otrData.cutlistBasename}');
      }
    }
  }

  void cleanUp() {
    print('cleanUp');
  }

  Future<void> moveToTrashOrToMovies(String name) async {
    final otrData =
        _filteredOtrDataList.firstWhere((otrData) => otrData.name == name);
    bool removeDecodedFile = otrData.isdeCoded;
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
        _filteredOtrDataList.firstWhere((otrData) => otrData.name == name);
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
