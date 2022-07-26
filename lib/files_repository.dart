import 'dart:io';
import 'package:path/path.dart' as p;

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

  Future<int> moveAllOtrFiles(String downloadsFolder, String otrFolder) async {
    var successCount = 0;
    List<String> list = await findOtrFiles(downloadsFolder);
    for (final file in list) {
      final src = p.join(downloadsFolder, file);
      final dst = p.join(otrFolder, file);
      print('moveOtrFile: $src -> $dst');
      bool rc = await moveFile(src, dst);
      if (rc) {
        successCount++;
      }
    }
    return successCount;
  }

  Future<List<String>> findOtrFiles(String folderPath) async {
    final Directory dir = Directory(folderPath);
    final list = await dir
        .list()
        .where((entry) => p.basename(entry.path).contains('_TVOON_'))
        .map((entity) => p.basename(entity.path))
        .toList();
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


}
