// ignore_for_file: public_member_api_docs, sort_constructors_first
class SettingsState {
  final String otrEmail;
  final String otrPassword;
  final String otrFolder;
  final String videoFolder;
  final String avidemuxApp;
  final String otrdecoderBinary;
  final String downloadFolder;
  final bool showPassword;

  SettingsState(
    this.otrEmail,
    this.otrPassword,
    this.otrFolder,
    this.videoFolder,
    this.avidemuxApp,
    this.otrdecoderBinary,
    this.downloadFolder,
    this.showPassword,
  );

  SettingsState copyWith({
    String? otrEmail,
    String? otrPassword,
    String? otrFolder,
    String? videoFolder,
    String? avidemuxApp,
    String? otrdecoderBinary,
    String? downloadFolder,
    bool? showPassword,
  }) {
    return SettingsState(
      otrEmail ?? this.otrEmail,
      otrPassword ?? this.otrPassword,
      otrFolder ?? this.otrFolder,
      videoFolder ?? this.videoFolder,
      avidemuxApp ?? this.avidemuxApp,
      otrdecoderBinary ?? this.otrdecoderBinary,
      downloadFolder ?? this.downloadFolder,
      showPassword ?? this.showPassword,
    );
  }
}
