import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial()) {
    print('create SettingsCubit');
  }
  late SharedPreferences _prefs;
  bool showPassword = false;

  Future<SettingsCubit> initialize() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _prefs = await SharedPreferences.getInstance();
    emitSettingsLoaded();
    return this;
  }

  String get otrEmail => _prefs.getString('otrEmail') ?? 'not set';

  String get otrPassword => _prefs.getString('otrPassword') ?? 'not set';

  bool get showOtrPassword => _prefs.getBool('showOtrPassword') ?? false;

  String get otrFolder =>
      _prefs.getString('otrFolder') ?? Platform.environment['HOME']!;

  String get downloadFolder =>
      _prefs.getString('downloadFolder') ?? Platform.environment['HOME']!;

  String get videoFolder =>
      _prefs.getString('videoFolder') ?? Platform.environment['HOME']!;

  String get avidemuxApp =>
      _prefs.getString('avidemuxApp') ?? '/Applications/avidemux2.8.app';

  String get otrdecoderBinary =>
      _prefs.getString('otrdecoderBinary') ?? '/Applications/avidemux2.8.app';

  Future<void> setOtrFolder(directoryPath) async {
    final reducedPath = _startWithUsersFolder(directoryPath);
    await _prefs.setString('otrFolder', reducedPath);
    emitSettingsLoaded();
  }

  Future<void> setDownloadFolder(directoryPath) async {
    final reducedPath = _startWithUsersFolder(directoryPath);
    await _prefs.setString('downloadFolder', reducedPath);
    emitSettingsLoaded();
  }

  Future<void> setVideoFolder(directoryPath) async {
    final reducedPath = _startWithUsersFolder(directoryPath);
    await _prefs.setString('videoFolder', reducedPath);
    emitSettingsLoaded();
  }

  Future<void> setAvidemuxApp(value) async {
    await _prefs.setString('avidemuxApp', value);
    emitSettingsLoaded();
  }

  Future<void> setOtrdecoderBinary(directoryPath) async {
    final reducedPath = _startWithUsersFolder(directoryPath);
    await _prefs.setString('otrdecoderBinary', reducedPath);
    emitSettingsLoaded();
  }

  Future<void> setOtrEmail(value) async {
    await _prefs.setString('otrEmail', value);
    emitSettingsLoaded();
  }

  Future<void> setOtrPassword(value) async {
    await _prefs.setString('otrPassword', value);
    emitSettingsLoaded();
  }

  void emitSettingsLoaded() {
    print('SettingsCubit emit');
    emit(SettingsLoaded(
      otrEmail,
      otrPassword.textOrStars(showPassword),
      otrFolder,
      videoFolder,
      avidemuxApp,
      otrdecoderBinary,
      downloadFolder,
      showPassword,
    ));
  }

  void toggleShowPassword() async {
    final newValue = !showOtrPassword;
    await _prefs.setBool('showOtrPassword', newValue);
    final currentState = state as SettingsLoaded;
    emit(currentState.copyWith(
      showPassword: newValue,
      password: otrPassword.textOrStars(newValue),
    ));
  }

  String _startWithUsersFolder(String fullPathName) {
    final parts = p.split(fullPathName);
    if (parts.length > 3 && parts[3] == 'Users') {
      return '/${p.joinAll(parts.sublist(3))}';
    }
    return fullPathName;
  }
}

extension PasswordExtension on String {
  String textOrStars(bool show) => show ? this : '**********';
}
