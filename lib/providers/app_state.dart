// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../model/otr_data.dart';

class Detail {
  final String? title;
  final String otrKey;
  final String filePathName;

  Detail({
    this.title,
    required this.otrKey,
    required this.filePathName,
  });

  Detail copyWith({
    String? title,
    String? otrKey,
    String? filePathName,
  }) {
    return Detail(
      title: title ?? this.title,
      otrKey: otrKey ?? this.otrKey,
      filePathName: filePathName ?? this.filePathName,
    );
  }
}

class AppState {
  final String? fileType;
  final List<OtrData> details;
  final String currentPathname;
  final int fileCount;
  final String? message;
  final String? selectedOtrkeyPath;
  final Stream<String>? commandStdoutStream;
  final bool isLoading;

  AppState({
    this.fileType,
    required this.details,
    required this.currentPathname,
    required this.fileCount,
    this.message,
    this.selectedOtrkeyPath,
    this.commandStdoutStream,
    required this.isLoading,
  });

  AppState copyWith({
    String? fileType,
    List<OtrData>? details,
    String? currentPathname,
    int? fileCount,
    int? primaryHitCount,
    String? message,
    String? selectedOtrkeyPath,
    Stream<String>? commandStdoutStream,
    bool? isLoading,
  }) {
    return AppState(
      fileType: fileType ?? this.fileType,
      details: details ?? this.details,
      currentPathname: currentPathname ?? this.currentPathname,
      fileCount: fileCount ?? this.fileCount,
      message: message ?? this.message,
      selectedOtrkeyPath: selectedOtrkeyPath ?? this.selectedOtrkeyPath,
      commandStdoutStream: commandStdoutStream ?? this.commandStdoutStream,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
