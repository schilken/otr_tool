// ignore_for_file: public_member_api_docs, sort_constructors_first
class CutlistParser {
  final List<String> _lines;
  final String _videoFilename;

  CutlistParser(
    this._videoFilename,
    this._lines,
  );

  isValid() {
    return getValue('General', 'ApplyToFile') == _videoFilename;
  }

  List<String> get segmentLines => getAllSegmentStrings();

  List<String> getSection(String sectionName) {
    final sectionStart = _lines.indexOf('[$sectionName]');
    for (var ix = sectionStart + 1; ix < _lines.length; ix++) {
      final line = _lines[ix];
      if (line.startsWith('[')) {
        return _lines.sublist(sectionStart + 1, ix - 1);
      }
    }
    return _lines.sublist(sectionStart + 1, _lines.length - 1);
  }

  Map<String, String> getSectionAsMap(String sectionName) {
    final sectionLines = getSection(sectionName);
    final map = <String, String>{};
    for (var line in sectionLines) {
      final parts = line.split('=');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }

  String? getValue(String sectionName, String key) {
    final map = getSectionAsMap(sectionName);
    return map[key];
  }

  int getValueAsInt(String sectionName, String key) {
    final value = getValue(sectionName, key);
    return int.tryParse(value ?? '') ?? 0;
  }

  String getSegmentString(int index) {
    final startTimeInSeconds =
        double.tryParse(getValue('Cut$index', 'Start') ?? '');
    final durationInSeconds =
        double.tryParse(getValue('Cut$index', 'Duration') ?? '');
    if (startTimeInSeconds == null || durationInSeconds == null) {
      return '';
    }
    return 'adm.addSegment(0, ${startTimeInSeconds * 1000000}, ${durationInSeconds * 1000000})';
  }

  List<String> getAllSegmentStrings() {
    final segments = <String>[];
    final noOfCuts = getValueAsInt('General', 'NoOfCuts');
    for (final index in noOfCuts.range) {
      final segmentString = getSegmentString(index);
      if (segmentString.isNotEmpty) {
        segments.add(segmentString);
      }
    }
    return segments;
  }
}

extension IntRange on int {
  Iterable<int> get range => Iterable<int>.generate(this, (i) => i);
}
