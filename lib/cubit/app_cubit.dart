import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:otr_browser/cubit/settings_cubit.dart';
import 'package:otr_browser/files_repository.dart';

part 'app_state.dart';

enum SearchResultAction {
  fetchCutlistForOtrKey,
  fetchCutlistMinimalName,
  cutVideo,
}

class AppCubit extends Cubit<AppState> {
  AppCubit(
    SettingsCubit settingsCubit,
    this.filesRepository,
  )
      : _settingsCubit = settingsCubit,
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
  String _currentPathname = "no file selected";
  int _fileCount = 0;
  String? _fileType;
  int _primaryHitCount = 0;
  String? _folderPath;
  final SettingsCubit _settingsCubit;
  List<String>? _allFilePaths;

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
    await scanFolder(
        type: 'otrkey',
        folderPath: '/Users/aschilken/flutterdev/my_projects/otr_browser');
    search();
  }

  Future<void> search() async {
    emit(DetailsLoading());
    print('search: $_primaryWord');
    if (_currentPathname == "no filelist selected") {
      emit(
        DetailsLoaded(
            currentPathname: _currentPathname,
            fileType: _fileType,
            fileCount: _fileCount,
            primaryHitCount: _primaryHitCount,
            details: [],
            message: 'No filelist loaded',
            sidebarPageIndex: 0),
      );
      return;
    }
    await searchInFilename();
  }

  Future<void> searchInFilename() async {
    final primaryResult = <Detail>[];
    for (final path in _allFilePaths!) {
        _primaryHitCount++;
        var shortPath = path;
        if (_folderPath != null) {
          shortPath = path.replaceFirst('${_folderPath!}/', '');
        }
        primaryResult.add(Detail(
          title: shortPath.split('/assets').last,
        otrKey: shortPath.split('/assets').first,
        filePathName: shortPath,
        ));
    }
    emit(
      DetailsLoaded(
        currentPathname: _currentPathname,
        fileType: _fileType,
        fileCount: _fileCount,
        primaryHitCount: _primaryHitCount,
        details: primaryResult,
        primaryWord: _primaryWord,
        sidebarPageIndex: 0,
      ),
    );
  }

  Future<void> scanFolder(
      {required String type, required String folderPath}) async {
    print('scanFolder: $folderPath for $type');
    _folderPath = folderPath;
    _fileType = type;
    
    if (folderPath != null) {
      filesRepository.currentFolderPath = folderPath;
      await filesRepository.runFindCommand(type);
      _allFilePaths = filesRepository.allFilePaths;
      _currentPathname = folderPath;
      _fileCount = _allFilePaths?.length ?? 0;
    } else {
      _currentPathname = "no file selected";
      _fileCount = 0;
    }
    search();
  }

  Future<List<String>> _runFindCommand(
      String workingDir, String extension) async {
    var process = await Process.run(
        'find', [workingDir, '-name', '*$extension', '-type', 'f']);
    return process.stdout.split('\n');
  }

  void saveFileList() {}
  
  void openEditor(String? filePathName) {
    Process.run('code', [filePathName!]);
  }

  showInFinder(String filePath) {
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
      case SearchResultAction.cutVideo:
        cutVideo(parameter);
        break;
    }
  }

  fetchCutlists(String searchString) {
    print('fetchCutlists: $searchString');
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(sidebarPageIndex: 1));
  }

  cutVideo(String filePath) {
    print('cutVideo: $filePath');
  }

  copyToClipboard(String path) {
    Clipboard.setData(ClipboardData(text: path));
  }

  sidebarChanged(int index) {
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(sidebarPageIndex: index));
  }

}
