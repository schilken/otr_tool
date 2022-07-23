// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:otr_browser/files_repository.dart';

import 'cutlist_item.dart';

part 'cutlist_state.dart';

class CutlistCubit extends Cubit<CutlistState> {
  CutlistCubit(
    this.filesRepository,
  ) : super(CutlistLoading()) {
    print('CutlistCubit.constructor');
  }
  final FilesRepository filesRepository;

  Future<void> load(String? filePath) async {
    if (filePath == null) {
      return;
    }
    emit(CutlistLoading());
    await Future.delayed(Duration(milliseconds: 500));
    final response = CutlistResponse.fromJson(CutlistResponse.testResponse);
//    final cutlist = await buildCutlist(filePath);
    emit(CutlistLoaded(
      filePath,
      response.items,
    ));
  }

  Future<String> _cutlistFile(String path) async {
    final contentString = await File(path).readAsString();
    return contentString;
  }

  // Future<List<Cut>> buildCutlist(String filePath) async {
  //   final list = <Cut>[];
  //   list.add(Cut(100.0, 300.0));
  //   list.add(Cut(1000.0, 2500.0));
  //   return list;
  // }

  refresh() {
    print('refresh');
  }
}
