import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:otr_browser/cubit/app_cubit.dart';
import 'package:otr_browser/cubit/statistics_cubit.dart';
import 'package:otr_browser/files_repository.dart';
import 'package:otr_browser/main_page.dart';

class CutlistPage extends StatelessWidget {
  const CutlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('StatisticsPage.build');
    return BlocProvider<StatisticsCubit>(
      create: (context) => StatisticsCubit(context.read<FilesRepository>()),
      child: Builder(builder: (context) {
        return MacosScaffold(
          toolBar: getCustomToolBar(context),
          children: [
            ContentArea(
              builder: (context, scrollController) {
                return BlocBuilder<StatisticsCubit, StatisticsState>(
                  builder: (context, state) {
//                    print('builder: $state');
                    if (state is StatisticsLoaded) {
                      return Column(
                        children: [
                          Container(
                            color: Colors.blueGrey[100],
                            padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('Paths from File: '),
                                Text(state.currentPathname),
                                const Spacer(),
                                Text('${state.fileCount}'),
                              ],
                            ),
                          ),
                          Center(
                              child: TextButton(
                                  onPressed: () =>
                                      context.read<StatisticsCubit>().load(),
                                  child: Text('refresh'))),
                          Expanded(
                            child: ListView.separated(
                              controller: ScrollController(),
                              itemCount: state.frequencies.length,
                              itemBuilder: (context, index) {
                                final nameAndCount = state.frequencies[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8),
                                  child: Row(children: [
                                    Text(nameAndCount.name),
                                    SizedBox(width: 12),
                                    Text(nameAndCount.count.toString()),
                                  ]),
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
                    } else if (state is StatisticsLoading) {
                      return const CupertinoActivityIndicator();
                    }
                    return Center(
                        child: TextButton(
                            onPressed: () =>
                                context.read<StatisticsCubit>().load(),
                            child: Text('refresh')));
                  },
                );
              },
            ),
          ],
        );
      }),
    );
  }
}
