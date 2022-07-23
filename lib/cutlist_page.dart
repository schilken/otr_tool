import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:otr_browser/cubit/app_cubit.dart';
import 'package:otr_browser/cubit/cutlist_cubit.dart';
import 'package:otr_browser/files_repository.dart';
import 'package:otr_browser/main_page.dart';

import 'cutlist_tile.dart';

class CutlistPage extends StatelessWidget {
  const CutlistPage({super.key, required this.filePath});
  final String? filePath;

  @override
  Widget build(BuildContext context) {
    print('CutlistPage.build $filePath');
    return Builder(builder: (context) {
      context.read<CutlistCubit>().load(filePath);
        return MacosScaffold(
          toolBar: getCustomToolBar(context),
          children: [
            ContentArea(
              builder: (context, scrollController) {
              return BlocBuilder<CutlistCubit, CutlistState>(
                  builder: (context, state) {
//                    print('builder: $state');
                  if (state is CutlistLoaded) {
                      return Column(
                        children: [
                          Container(
                            color: Colors.blueGrey[100],
                            padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                              const Text('search: '),
                              Text(state.searchString),
                                const Spacer(),
                              Text('${state.items.length}'),
                              ],
                            ),
                          ),

                          Expanded(
                            child: ListView.separated(
                              controller: ScrollController(),
                            itemCount: state.items.length,
                              itemBuilder: (context, index) {
                              final item = state.items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8),
                                child: CutlistTile(
                                  cutlistItem: item,
                                ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider(
                                  thickness: 2,
                                );
                              },
                            ),
                          )
                        ],
                      );
                  } else if (state is CutlistLoading) {
                      return const CupertinoActivityIndicator();
                    }
                    return Center(
                        child: TextButton(
                            onPressed: () =>
                              context.read<CutlistCubit>().refresh(),
                            child: Text('refresh')));
                  },
                );
              },
            ),
          ],
        );
    });
  }
}
