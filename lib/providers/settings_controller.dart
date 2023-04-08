import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'providers.dart';

class SettingsController extends Notifier<SettingsState> {
  late SharedPreferences _prefs;
  bool _showOtrPassword = false;

  @override
  SettingsState build() {
    debugPrint('SettingsController.build');
    _prefs = ref.watch(sharedPreferencesProvider);
    return SettingsState(
      otrEmail,
      otrPassword.textOrStars(_showOtrPassword),
      otrFolder,
      videoFolder,
      avidemuxApp,
      otrdecoderBinary,
      downloadFolder,
      _showOtrPassword,
    );
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

  Future<void> setOtrFolder(String directoryPath) async {
    final reducedPath = _startWithUsersFolder(directoryPath);
    await _prefs.setString('otrFolder', reducedPath);
    state = state.copyWith(otrFolder: reducedPath);
  }

  Future<void> setDownloadFolder(String directoryPath) async {
    final reducedPath = _startWithUsersFolder(directoryPath);
    await _prefs.setString('downloadFolder', reducedPath);
    state = state.copyWith(downloadFolder: reducedPath);
  }

  Future<void> setVideoFolder(String directoryPath) async {
    final reducedPath = _startWithUsersFolder(directoryPath);
    await _prefs.setString('videoFolder', reducedPath);
    state = state.copyWith(videoFolder: reducedPath);
  }

  Future<void> setAvidemuxApp(String path) async {
    await _prefs.setString('avidemuxApp', path);
    state = state.copyWith(avidemuxApp: path);
  }

  Future<void> setOtrdecoderBinary(String path) async {
    final reducedPath = _startWithUsersFolder(path);
    await _prefs.setString('otrdecoderBinary', reducedPath);
    state = state.copyWith(otrdecoderBinary: reducedPath);
  }

  Future<void> setOtrEmail(String email) async {
    await _prefs.setString('otrEmail', email); //   emitSettingsLoaded();
    state = state.copyWith(otrEmail: email);
  }

  Future<void> setOtrPassword(String password) async {
    await _prefs.setString('otrPassword', password);
    state =
        state.copyWith(otrPassword: otrPassword.textOrStars(_showOtrPassword));
  }

  Future<void> toggleShowPassword() async {
    _showOtrPassword = !_showOtrPassword;
    state =
        state.copyWith(
      otrPassword: otrPassword.textOrStars(_showOtrPassword),
      showPassword: _showOtrPassword,
    );
  }

  String _startWithUsersFolder(String fullPathName) {
    final parts = p.split(fullPathName);
    if (parts.length > 3 && parts[3] == 'Users') {
      return '/${p.joinAll(parts.sublist(3))}';
    }
    return fullPathName;
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(() {
  return SettingsController();
});

extension PasswordExtension on String {
  String textOrStars(bool show) => show ? this : '**********';
}
