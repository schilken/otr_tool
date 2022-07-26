import 'package:equatable/equatable.dart';

class OtrData extends Equatable {
  final String name;
  final String? otrkeyBasename;
  final String? cutlistBasename;
  final String? decodedBasename;
  final String? cuttedBasename;

  OtrData(
    this.name,
    this.otrkeyBasename,
    this.cutlistBasename,
    this.decodedBasename,
    this.cuttedBasename,
  );

  @override
  List<Object?> get props => [
        name,
        otrkeyBasename,
        cutlistBasename,
        decodedBasename,
        cuttedBasename,
      ];
}
