// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import '../model/otr_data.dart';

class FilesRepository {
  String? currentFolderPath;

  Future<int> moveAllOtrFiles(
    String sourceFolder,
    String destinationFolder,
  ) async {
    var successCount = 0;
    final list = await findOtrFiles(sourceFolder);
    for (final file in list) {
      final rc = await moveOtrFile(sourceFolder, destinationFolder, file);
      if (rc) {
        successCount++;
      }
    }
    return successCount;
  }

  Future<bool> moveOtrFile(
    String sourceFolder,
    String destinationFolder,
    String filename,
  ) async {
    final src = p.join(sourceFolder, filename);
    final dst = p.join(destinationFolder, filename);
//    print('moveOtrFile: $src -> $dst');
    final rc = await moveFile(src, dst);
    return rc;
  }

  Future<List<String>> findOtrFiles(String folderPath) async {
    final dir = Directory(folderPath);
    final list = await dir
        .list()
        .where((entry) =>
              p.basename(entry.path).contains('_TVOON_DE') && entry is File,
        )
        .map((entity) => p.basename(entity.path))
        .toList();
    return list;
  }

  String nameFromPath(String path) => path.split('_TVOON_DE').first;

  List<OtrData> consolidateOtrFiles(List<String> filePaths) {
    final list = <OtrData>[];
    final nameSet = filePaths.map(nameFromPath).toSet();
    for (final name in nameSet) {
      final otrData = OtrData(
        name: name,
        otrkeyBasename: filePaths.firstWhereOrNull((path) =>
              nameFromPath(path) == name && p.extension(path) == '.otrkey',
        ),
        cutlistBasename: filePaths.firstWhereOrNull((path) =>
              nameFromPath(path) == name && p.extension(path) == '.cutlist',
        ),
        decodedBasename: filePaths.firstWhereOrNull((path) {
          return nameFromPath(path) == name &&
              p.extension(path) != '.otrkey' &&
              p.extension(path) != '.cutlist' &&
              !p.basename(path).contains('_TVOON_DE-cut');
        }),
        cuttedBasename: filePaths.firstWhereOrNull((path) =>
            nameFromPath(path) == name &&
              p.basename(path).contains('_TVOON_DE-cut'),
        ),
      );
      list.add(otrData);
    }
    return list;
  }

  Future<bool> moveFile(String sourcePath, String newPath) async {
    final sourceFile = File(sourcePath);
    try {
      // prefer using rename as it is probably faster
      final newFile = await sourceFile.rename(newPath);
      return await newFile.exists();
    } on FileSystemException {
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile.exists();
    }
  }

// osascript -e "tell application \"Finder\" to delete POSIX file \"${PWD}/${InputFile}\""
  Future<List<String>> moveToTrash(String workingDir, String filename) async {
    final process = await Process.run('osascript', [
      '-e',
      'tell application "Finder" to delete POSIX file "$workingDir/$filename"'
    ]);
    return (process.stdout as String).split('\n');
  }
}

final filesRepositoryProvider = Provider<FilesRepository>(
  (ref) => FilesRepository(),
);
