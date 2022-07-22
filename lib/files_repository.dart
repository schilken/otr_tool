import 'dart:io';

class FilesRepository {
  String? currentFolderPath;
  String? _fileType;
  List<String> _allFilePaths = [];


  Future<int> runFindCommand(String fileType) async {
    _fileType = fileType;
    print('scanFolder: $currentFolderPath for $fileType');
    if (currentFolderPath == null || _fileType == null) {
      _allFilePaths = [];
      return 0;
    }
    _allFilePaths = (await _runFindCommand(currentFolderPath!, _fileType!))
        .where((path) => path.isNotEmpty)
        .toList();
    return _allFilePaths.length;
  }

  List<String> get allFilePaths => _allFilePaths;

  Future<List<String>> _runFindCommand(
      String workingDir, String extension) async {
    var process = await Process.run(
        'find', [workingDir, '-name', '*$extension', '-type', 'f']);
    return process.stdout.split('\n');
  }
}
