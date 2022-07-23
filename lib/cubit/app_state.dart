// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_cubit.dart';

@immutable
abstract class AppState {
  final String? primaryWord;
  AppState({
    this.primaryWord,
  });
}

class AppInitial extends AppState {}

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

class DetailsLoading extends AppState {}

class DetailsLoaded extends AppState {
  final String? fileType;
  final List<Detail> details;
  final String currentPathname;
  final int fileCount;
  final int primaryHitCount;
  final String? message;

  DetailsLoaded({
    this.fileType,
    required this.details,
    required this.currentPathname,
    required this.fileCount,
    required this.primaryHitCount,
    this.message,
    String? primaryWord,
    String? secondaryWord,
  }) : super(
          primaryWord: primaryWord,
        );

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
      message: message ?? this.message,
    );
  }
}
