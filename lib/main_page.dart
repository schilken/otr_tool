import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:otr_browser/cubit/app_cubit.dart';
import 'get_custom_toolbar.dart';
import 'otr_data_tile.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
        return MacosScaffold(
          toolBar: getCustomToolBar(context),
          children: [
            ContentArea(
              builder: (context, scrollController) {
                return BlocBuilder<AppCubit, AppState>(
                  builder: (context, state) {
                    if (state is DetailsLoaded) {
                      return Column(
                        children: [
                          Container(
                            color: Colors.blueGrey[100],
                            padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (state.fileType == null)
                                  const Text('Paths from File: ')
                                else
                                Text('Inhalt von: '),
                                Text(state.currentPathname),
                              MacosIconButton(
                                onPressed: () =>
                                    context.read<AppCubit>().reScanFolder(),
                                icon: const MacosIcon(
                                  CupertinoIcons.refresh,
                                ),
                              ),
                                const Spacer(),
                                Text(
                                  '${state.fileCount}|${state.primaryHitCount}'),
                              ],
                            ),
                          ),
                          if (state.message != null)
                            Container(
                                padding: const EdgeInsets.all(20),
                                color: Colors.red[100],
                                child: Text(state.message!)),
                        const SizedBox(height: 12),
                          Expanded(
                            child: ListView.separated(
                              controller: ScrollController(),
                              itemCount: state.details.length,
                              itemBuilder: (context, index) {
                                final highlights = [
                                state.primaryWord ?? '@',
                                ];

                              final detail = state.details[index];
                              return OtrDataTile(
                                otrData: detail,
                                highlights: highlights,
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider(
                                  thickness: 2,
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 12),
                        ],
                      );
                    } else if (state is DetailsLoading) {
                      return const CupertinoActivityIndicator();
                    }
                    return const Center(child: Text('No file selected'));
                  },
                );
              },
            ),
            // ResizablePane(
            //     minWidth: 300,
            //     startWidth: 300,
            //     windowBreakpoint: 500,
            //     resizableSide: ResizableSide.left,
            //     builder: (_, __) {
            //       return const Center(child: Text('Details'));
            //     })
          ],
        );
    });
  }
}





