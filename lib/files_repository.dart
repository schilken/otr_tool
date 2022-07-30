// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import 'model/otr_data.dart';

class FilesRepository {
  String? currentFolderPath;
  String? _fileType;
  List<String> _allFilePaths = [];


  // Future<int> runFindCommand(String fileType) async {
  //   _fileType = fileType;
  //   print('scanFolder: $currentFolderPath for $fileType');
  //   if (currentFolderPath == null || _fileType == null) {
  //     _allFilePaths = [];
  //     return 0;
  //   }
  //   _allFilePaths = (await _runFindCommand(currentFolderPath!, _fileType!))
  //       .where((path) => path.isNotEmpty)
  //       .toList();
  //   return _allFilePaths.length;
  // }

  // List<String> get allFilePaths => _allFilePaths;

  // Future<List<String>> _runFindCommand(
  //     String workingDir, String extension) async {
  //   var process = await Process.run(
  //       'find', [workingDir, '-name', '*$extension', '-type', 'f']);
  //   return process.stdout.split('\n');
  // }

  Future<int> moveAllOtrFiles(
      String sourceFolder, String destinationFolder) async {
    var successCount = 0;
    List<String> list = await findOtrFiles(sourceFolder);
    for (final file in list) {
      bool rc = await moveOtrFile(sourceFolder, destinationFolder, file);
      if (rc) {
        successCount++;
      }
    }
    return successCount;
  }

  Future<bool> moveOtrFile(
      String sourceFolder, String destinationFolder, String filename) async {
    final src = p.join(sourceFolder, filename);
    final dst = p.join(destinationFolder, filename);
    print('moveOtrFile: $src -> $dst');
    bool rc = await moveFile(src, dst);
    return rc;
  }

  Future<List<String>> findOtrFiles(String folderPath) async {
    final Directory dir = Directory(folderPath);
    final list = await dir
        .list()
        .where((entry) =>
            p.basename(entry.path).contains('_TVOON_DE') && entry is File)
        .map((entity) => p.basename(entity.path))
        .toList();
    return list;
  }

  String nameFromPath(String path) => path.split('_TVOON_DE').first;

  List<OtrData> consolidateOtrFiles(List<String> filePaths) {
    final List<OtrData> list = [];
    final nameSet = filePaths.map(nameFromPath).toSet();
    for (final name in nameSet) {
      final otrData = OtrData(
        name,
        filePaths.firstWhereOrNull((path) =>
            nameFromPath(path) == name && p.extension(path) == '.otrkey'),
        filePaths.firstWhereOrNull((path) =>
            nameFromPath(path) == name && p.extension(path) == '.cutlist'),
        filePaths.firstWhereOrNull((path) {
          return nameFromPath(path) == name &&
              p.extension(path) != '.otrkey' &&
              p.extension(path) != '.cutlist' &&
              !p.basename(path).contains('_TVOON_DE-cut');
        }),
        filePaths.firstWhereOrNull((path) =>
            nameFromPath(path) == name &&
            p.basename(path).contains('_TVOON_DE-cut')),
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
    } on FileSystemException catch (e) {
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return await newFile.exists();
    }
  }

// osascript -e "tell application \"Finder\" to delete POSIX file \"${PWD}/${InputFile}\""
  Future<List<String>> moveToTrash(String workingDir, String filename) async {
    var process = await Process.run('osascript', [
      '-e',
      'tell application "Finder" to delete POSIX file "${workingDir}/${filename}"'
    ]);
    return process.stdout.split('\n');
  }


}
