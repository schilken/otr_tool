// ignore_for_file: public_member_api_docs, sort_constructors_first
class SettingsState {
  final String email;
  final String password;
  final String otrFolder;
  final String videoFolder;
  final String avidemuxApp;
  final String otrdecoderBinary;
  final String downloadFolder;
  final bool showPassword;

  SettingsState(
    this.email,
    this.password,
    this.otrFolder,
    this.videoFolder,
    this.avidemuxApp,
    this.otrdecoderBinary,
    this.downloadFolder,
    this.showPassword,
  );

  SettingsState copyWith({
    String? email,
    String? password,
    String? otrFolder,
    String? videoFolder,
    String? avidemuxApp,
    String? otrdecoderBinary,
    String? downloadFolder,
    bool? showPassword,
  }) {
    return SettingsState(
      email ?? this.email,
      password ?? this.password,
      otrFolder ?? this.otrFolder,
      videoFolder ?? this.videoFolder,
      avidemuxApp ?? this.avidemuxApp,
      otrdecoderBinary ?? this.otrdecoderBinary,
      downloadFolder ?? this.downloadFolder,
      showPassword ?? this.showPassword,
    );
  }
}
