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

  get lineFilter => _prefs.getString('lineFilter') ?? 'All Lines';

  get testFileFilter =>
      _prefs.getString('testFileFilter') ?? 'Include Test Files';

  get exampleFileFilter =>
      _prefs.getString('exampleFileFilter') ?? 'Include Example Files';

  Future<SettingsCubit> initialize() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _prefs = await SharedPreferences.getInstance();
    emitSettingsLoaded();
    return this;
  }

  String get myProjectsFolder =>
      _prefs.getString('myProjectsFolder') ??
      '/Users/aschilken/flutterdev/my_projects';

  String get examplesFolder =>
      _prefs.getString('examplesFolder') ??
      '/Users/aschilken/flutterdev/examples';

  String get packagesFolder =>
      _prefs.getString('packagesFolder') ??
      '/Users/aschilken/.pub-cache/hosted/pub.dartlang.org';

  String get flutterSourceFolder =>
      _prefs.getString('flutterSourceFolder') ??
      '/Users/aschilken/flutterdev/flutter';

  Future<void> setTestFileFilter(value) async {
    await _prefs.setString('testFileFilter', value);
    emitSettingsLoaded();
  }

  Future<void> setExampleFileFilter(value) async {
    await _prefs.setString('exampleFileFilter', value);
    emitSettingsLoaded();
  }

  Future<void> setLineFilter(value) async {
    await _prefs.setString('lineFilter', value);
    emitSettingsLoaded();
  }

  void emitSettingsLoaded() {
    print('SettingsCubit emit');
    emit(SettingsLoaded(
      examplesFolder: examplesFolder,
      flutterFolder: flutterSourceFolder,
      myProjectsFolder: myProjectsFolder,
      packagesFolder: packagesFolder,
      exampleFileFilter: exampleFileFilter,
      lineFilter: lineFilter,
      testFileFilter: testFileFilter,
    ));
  }

}
