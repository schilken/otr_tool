// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_cubit.dart';

@immutable
abstract class AppState extends Equatable {}

class AppInitial extends AppState {
  @override
  List<Object?> get props => [];
}

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
    String? previewText,
    String? imageUrl,
    String? filePathName,
  }) {
    return Detail(
      title: title ?? this.title,
      otrKey: otrKey ?? this.otrKey,
      filePathName: filePathName ?? this.filePathName,
    );
  }
}

class DetailsLoading extends AppState {
  List<Object?> get props => [];
}

class DetailsLoaded extends AppState {
  final String? fileType;
  final List<OtrData> details;
  final String currentPathname;
  final int fileCount;
  final String? message;
  final int sidebarPageIndex;
  final String? selectedOtrkeyPath;
  final Stream<String>? commandStdoutStream;

  DetailsLoaded({
    this.fileType,
    required this.details,
    required this.currentPathname,
    required this.fileCount,
    required this.sidebarPageIndex,
    this.message,
    this.selectedOtrkeyPath,
    this.commandStdoutStream,
  });

  DetailsLoaded copyWith({
    String? fileType,
    List<OtrData>? details,
    String? currentPathname,
    int? fileCount,
    int? primaryHitCount,
    String? message,
    int? sidebarPageIndex,
    String? selectedOtrkeyPath,
    Stream<String>? commandStdoutStream,
  }) {
    return DetailsLoaded(
      fileType: fileType ?? this.fileType,
      details: details ?? this.details,
      currentPathname: currentPathname ?? this.currentPathname,
      fileCount: fileCount ?? this.fileCount,
      message: message ?? this.message,
      sidebarPageIndex: sidebarPageIndex ?? this.sidebarPageIndex,
      selectedOtrkeyPath: selectedOtrkeyPath ?? this.selectedOtrkeyPath,
      commandStdoutStream: commandStdoutStream ?? this.commandStdoutStream,
    );
  }

  @override
  List<Object?> get props => [
        details,
        currentPathname,
        fileCount,
        message,
        sidebarPageIndex,
        selectedOtrkeyPath,
        commandStdoutStream,
      ];
}
