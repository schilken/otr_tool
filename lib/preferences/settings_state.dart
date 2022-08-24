// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'settings_cubit.dart';

@immutable
abstract class SettingsState extends Equatable {}

class SettingsInitial extends SettingsState {
  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsState {
  final String email;
  final String password;
  final String otrFolder;
  final String videoFolder;
  final String avidemuxApp;
  final String otrdecoderBinary;
  final bool showPassword;

  SettingsLoaded(
    this.email,
    this.password,
    this.otrFolder,
    this.videoFolder,
    this.avidemuxApp,
    this.otrdecoderBinary,
    this.showPassword,
  );

  @override
  List<Object?> get props => [
        email,
        password,
        otrFolder,
        videoFolder,
        avidemuxApp,
        otrdecoderBinary,
        showPassword,
      ];

  SettingsLoaded copyWith({
    String? email,
    String? password,
    String? otrFolder,
    String? videoFolder,
    String? avidemuxApp,
    String? otrdecoderBinary,
    bool? showPassword,
  }) {
    return SettingsLoaded(
      email ?? this.email,
      password ?? this.password,
      otrFolder ?? this.otrFolder,
      videoFolder ?? this.videoFolder,
      avidemuxApp ?? this.avidemuxApp,
      otrdecoderBinary ?? this.otrdecoderBinary,
      showPassword ?? this.showPassword,
    );
  }
}
