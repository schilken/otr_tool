// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_cubit.dart';

@immutable
abstract class AppState {
  final String? primaryWord;
  final String? secondaryWord;
  AppState({
    this.primaryWord,
    this.secondaryWord,
  });
}

class AppInitial extends AppState {}

class Detail {
  final String? title;
  final String? projectName;
  final String? previewText;
  final String? imageUrl;
  final int? lineNumber;
  final String? filePathName;
  final String? projectPathName;

  Detail({
    this.title,
    this.projectName,
    this.previewText,
    this.imageUrl,
    this.lineNumber,
    this.filePathName,
    this.projectPathName,
  });

  Detail copyWith({
    String? title,
    String? projectName,
    String? previewText,
    String? imageUrl,
    int? lineNumber,
    String? filePathName,
    String? projectPathName,
  }) {
    return Detail(
      title: title ?? this.title,
      projectName: projectName ?? this.projectName,
      previewText: previewText ?? this.previewText,
      imageUrl: imageUrl ?? this.imageUrl,
      lineNumber: lineNumber ?? this.lineNumber,
      filePathName: filePathName ?? this.filePathName,
      projectPathName: projectPathName ?? this.projectPathName,
    );
  }
}

class DetailsLoading extends AppState {}

class DetailsLoaded extends AppState {
  final String? fileType;
  final List<Detail> details;
  final String currentPathname;
  final int fileCount;
  final int primaryHitCount;
  final int secondaryHitCount;
  final String? message;
  final int? displayLineCount;

  DetailsLoaded({
    this.fileType,
    required this.details,
    required this.currentPathname,
    required this.fileCount,
    required this.primaryHitCount,
    required this.secondaryHitCount,
    this.message,
    String? primaryWord,
    String? secondaryWord,
    this.displayLineCount,
  }) : super(primaryWord: primaryWord, secondaryWord: secondaryWord);

  DetailsLoaded copyWith({
    String? fileType,
    List<Detail>? details,
    String? currentPathname,
    int? fileCount,
    int? primaryHitCount,
    int? secondaryHitCount,
    String? message,
    int? displayLineCount,
  }) {
    return DetailsLoaded(
      fileType: fileType ?? this.fileType,
      details: details ?? this.details,
      currentPathname: currentPathname ?? this.currentPathname,
      fileCount: fileCount ?? this.fileCount,
      primaryHitCount: primaryHitCount ?? this.primaryHitCount,
      secondaryHitCount: secondaryHitCount ?? this.secondaryHitCount,
      message: message ?? this.message,
      displayLineCount: displayLineCount ?? this.displayLineCount,
    );
  }
}
