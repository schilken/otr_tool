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

  get otrEmail => _prefs.getString('otrEmail') ?? 'not set';
  get otrPassword => _prefs.getString('otrPassword') ?? 'not set';

  Future<SettingsCubit> initialize() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _prefs = await SharedPreferences.getInstance();
    emitSettingsLoaded();
    return this;
  }

  String get otrkeyFolder =>
      _prefs.getString('otrkeyFolder') ??
      '/Users/aschilken/flutterdev/my_projects/otr_browser';

  Future<void> setOtrkeyFolder(value) async {
    await _prefs.setString('otrkeyFolder', value);
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
      otrkeyFolder: otrkeyFolder,
    ));
  }

}
