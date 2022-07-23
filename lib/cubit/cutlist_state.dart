// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'cutlist_cubit.dart';

// class Cut {
//   final double start;
//   final double duration;

//   Cut(this.start, this.duration);
// }

// class Cutlist {
//   final List<Cut> cuts;
//   final String otrKey;
//   final double totalDuration;
//   final int noOfCuts;

//   Cutlist(this.cuts, this.otrKey, this.totalDuration, this.noOfCuts);
// }

abstract class CutlistState extends Equatable {
  const CutlistState();

  @override
  List<Object> get props => [];
}

class CutlistLoading extends CutlistState {
  @override
  List<Object> get props => [];
}

class CutlistLoaded extends CutlistState {
  final List<CutlistItem> items;
  final String searchString;
  CutlistLoaded(this.searchString, this.items);

  @override
  List<Object> get props => [searchString, items];
}

// class CutlistLoaded extends CutlistState {
//   final int noOfCuts;
//   final List<Cut> cuts;
//   final String otrkey;
//   final double totalDuration;
//   CutlistLoaded({
//     required this.noOfCuts,
//     required this.cuts,
//     required this.otrkey,
//     required this.totalDuration,
//   });

//   @override
//   List<Object> get props => [noOfCuts, cuts, otrkey, totalDuration];
// }
