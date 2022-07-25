// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_cubit.dart';

@immutable
abstract class AppState extends Equatable {
  final String? primaryWord;
  AppState({
    this.primaryWord,
  });
}

class AppInitial extends AppState {
  @override
  List<Object?> get props => [];
}

class Detail {
  final String? title;
  final String otrKey;
  final String? previewText;
  final String? imageUrl;
  final String filePathName;

  Detail({
    this.title,
    required this.otrKey,
    required this.filePathName,
    this.previewText,
    this.imageUrl,
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
      previewText: previewText ?? this.previewText,
      imageUrl: imageUrl ?? this.imageUrl,
      filePathName: filePathName ?? this.filePathName,
    );
  }
}

class DetailsLoading extends AppState {
  List<Object?> get props => [];
}

class DetailsLoaded extends AppState {
  final String? fileType;
  final List<Detail> details;
  final String currentPathname;
  final int fileCount;
  final int primaryHitCount;
  final String? message;
  final int sidebarPageIndex;
  final String? selectedOtrkeyPath;
  final Stream<String>? commandStdoutStream;

  DetailsLoaded({
    this.fileType,
    required this.details,
    required this.currentPathname,
    required this.fileCount,
    required this.primaryHitCount,
    required this.sidebarPageIndex,
    this.message,
    String? primaryWord,
    this.selectedOtrkeyPath,
    this.commandStdoutStream,
  }) : super(
          primaryWord: primaryWord,
        );

  DetailsLoaded copyWith({
    String? fileType,
    List<Detail>? details,
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
      primaryHitCount: primaryHitCount ?? this.primaryHitCount,
      message: message ?? this.message,
      sidebarPageIndex: sidebarPageIndex ?? this.sidebarPageIndex,
      selectedOtrkeyPath: selectedOtrkeyPath ?? this.selectedOtrkeyPath,
      commandStdoutStream: commandStdoutStream ?? this.commandStdoutStream,
    );
  }
  List<Object?> get props => [
        details,
        currentPathname,
        fileCount,
        primaryHitCount,
        message,
        sidebarPageIndex,
        selectedOtrkeyPath,
        commandStdoutStream,
      ];

}
