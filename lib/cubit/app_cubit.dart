import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:otr_browser/cubit/settings_cubit.dart';
import 'package:otr_browser/files_repository.dart';

import '../model/otr_data.dart';
import '../video_cutter.dart';

part 'app_state.dart';

enum SearchResultAction {
  fetchCutlistForOtrKey,
  fetchCutlistMinimalName,
}

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
  List<String> _allFilePaths = [];

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
    search();
  }

  Future<void> search() async {
    var primaryHitCount = 0;
    emit(DetailsLoading());
    print('search: $_primaryWord');
    await Future.delayed(const Duration(milliseconds: 500));
    final otrDataList =
        await filesRepository.consolidateOtrFiles(_allFilePaths);
    final filteredOtrDataList = <OtrData>[];
    for (final otrData in otrDataList) {
      if (otrData.name.contains(_primaryWord ?? '')) {
        primaryHitCount++;
        filteredOtrDataList.add(otrData);
      }
    }
    emit(
      DetailsLoaded(
        currentPathname: _currentFolderPath,
        fileCount: otrDataList.length,
        primaryHitCount: primaryHitCount,
        details: filteredOtrDataList,
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
    emit(DetailsLoading());
    await Future.delayed(const Duration(seconds: 1));

    _settingsCubit.setOtrFolder(folderPath);

    filesRepository.currentFolderPath = folderPath;
    _allFilePaths = await filesRepository.findOtrFiles(folderPath);
    _allFilePaths.sort((a, b) => a.compareTo(b));
    _currentFolderPath = folderPath;
    search();
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

  menuAction(SearchResultAction menuAction, String parameter) {
    switch (menuAction) {
      case SearchResultAction.fetchCutlistForOtrKey:
        fetchCutlists(parameter);
        break;
      case SearchResultAction.fetchCutlistMinimalName:
        final minimalName = parameter.split('_TVOON').first;
        fetchCutlists(minimalName);
        break;
    }
  }

  fetchCutlists(String searchString) {
    print('fetchCutlists: $searchString');
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(
        sidebarPageIndex: 1, selectedOtrkeyPath: searchString));
  }

  cutVideo(String videoFilename, String cutlistFilename) async {
    print('cutVideo: $videoFilename');
    final currentState = state as DetailsLoaded;
    final streamController = StreamController<String>();

    emit(currentState.copyWith(
        sidebarPageIndex: 2, commandStdoutStream: streamController.stream));

    await Future.delayed(const Duration(milliseconds: 500));
    final videoCutter = VideoCutter();
    videoCutter.cutVideo(videoFilename, cutlistFilename, streamController,
        dryRun: false);
  }

  copyToClipboard(String path) {
    Clipboard.setData(ClipboardData(text: path));
  }

  sidebarChanged(int index) {
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(sidebarPageIndex: index));
  }

  decodeVideo(String filename) async {
    print('decodeVideo: $filename');
    final streamController = StreamController<String>();
    _runDecodeCommand(filename, streamController);
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(
        sidebarPageIndex: 2, commandStdoutStream: streamController.stream));
  }

  void _runDecodeCommand(
      String filename, StreamController<String> streamController) {
    final workingDirectory = _settingsCubit.otrFolder;
    final otrEmail = _settingsCubit.otrEmail;
    final otrPassword = _settingsCubit.otrPassword;
    final process = Process.start(
      './otrdecoder',
      ['-i', filename, '-e', otrEmail, '-p', otrPassword],
      workingDirectory: workingDirectory,
    ).then(
      (proc) => proc.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .forEach(
            (line) => streamController.add(line),
          )
          .whenComplete(() {
        streamController.add('Stream closed in whenComplete');
        return streamController.close();
      }).onError((error, stackTrace) {
        streamController.add('Stream closed onError');
        return streamController.close();
      }),
    );
  }

  Future<void> moveOtrkey() async {
    // final clipboardData = await Clipboard.getData('text/plain');
    // final url = clipboardData?.text;
    print('moveOtrkey called');
    final successCount = await filesRepository.moveAllOtrFiles(
      '/Users/aschilken/Downloads',
      _settingsCubit.otrFolder,
    );
    if (successCount > 0) {
      print('moveOtrkey: $successCount files moved');
      scanFolder(folderPath: _settingsCubit.otrFolder);
    } else {
      print('moveOtrkey: no files moved');
    }
  }

  void moveCutVideosToVideoFolder() {
    print('moveCutVideosToVideoFolder');
  }

  void cleanUp() {
    print('cleanUp');
  }
}
