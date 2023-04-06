import 'package:path/path.dart' as p;

class OtrData {
  final String name;
  final String? otrkeyBasename;
  final String? cutlistBasename;
  final String? decodedBasename;
  final String? cuttedBasename;

  OtrData({
    required this.name,
    this.otrkeyBasename,
    this.cutlistBasename,
    this.decodedBasename,
    this.cuttedBasename,
  });

  bool get hasOtrkey => otrkeyBasename != null;
  bool get hasCutlist => cutlistBasename != null;
  bool get isdeCoded => decodedBasename != null;
  bool get isCutted => cuttedBasename != null;

  bool get isExactCutlist =>
      hasCutlist &&
      isdeCoded &&
      p.basenameWithoutExtension(cutlistBasename!) == decodedBasename!;

}
