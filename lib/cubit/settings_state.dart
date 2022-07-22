// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

@immutable
abstract class SettingsState extends Equatable {}

class SettingsInitial extends SettingsState {
  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsState {
  String examplesFolder;
  String packagesFolder;
  String flutterFolder;
  String myProjectsFolder;
  String lineFilter;
  String testFileFilter;
  String exampleFileFilter;
  SettingsLoaded({
    required this.examplesFolder,
    required this.packagesFolder,
    required this.flutterFolder,
    required this.myProjectsFolder,
    required this.lineFilter,
    required this.testFileFilter,
    required this.exampleFileFilter,
  });
  
  @override
  List<Object?> get props => [
        examplesFolder,
        packagesFolder,
        flutterFolder,
        myProjectsFolder,
        lineFilter,
        testFileFilter,
        exampleFileFilter,
      ];
}
