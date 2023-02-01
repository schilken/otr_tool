import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      _prefs.getString('otrFolder') ??
      '/Users/aschilken/flutterdev/my_projects/otr_browser';

  String get videoFolder =>
      _prefs.getString('videoFolder') ?? '/Users/aschilken/movies';

  String get avidemuxApp =>
      _prefs.getString('avidemuxApp') ?? '/Applications/avidemux2.8.app';

  String get otrdecoderBinary =>
      _prefs.getString('otrdecoderBinary') ?? '/Applications/avidemux2.8.app';

  Future<void> setOtrFolder(value) async {
    await _prefs.setString('otrFolder', value);
    emitSettingsLoaded();
  }

  Future<void> setVideoFolder(value) async {
    await _prefs.setString('videoFolder', value);
    emitSettingsLoaded();
  }

  Future<void> setAvidemuxApp(value) async {
    await _prefs.setString('avidemuxApp', value);
    emitSettingsLoaded();
  }

  Future<void> setOtrdecoderBinary(value) async {
    await _prefs.setString('otrdecoderBinary', value);
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
}

extension PasswordExtension on String {
  String textOrStars(bool show) => show ? this : '**********';
}