// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

@immutable
abstract class SettingsState extends Equatable {}

class SettingsInitial extends SettingsState {
  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsState {
  String otrkeyFolder;
  SettingsLoaded({
    required this.otrkeyFolder,
  });
  
  @override
  List<Object?> get props => [
        otrkeyFolder,
      ];
}
