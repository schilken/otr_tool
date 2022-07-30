import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:otr_browser/cubit/app_cubit.dart';
import 'package:otr_browser/cubit/settings_cubit.dart';
import 'package:otr_browser/toolbar_searchfield.dart';

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

ToolBar getCustomToolBar(BuildContext context) {
  return ToolBar(
    title: const Text('OTR Browser'),
    titleWidth: 250.0,
    actions: [
      ToolBarIconButton(
        label: 'Toggle Sidebar',
        icon: const MacosIcon(CupertinoIcons.sidebar_left),
        showLabel: false,
        tooltipMessage: 'Toggle Sidebar',
        onPressed: () {
          MacosWindowScope.of(context).toggleSidebar();
        },
      ),
      ToolBarSpacer(spacerUnits: 3),
      ToolBarPullDownButton(
        label: "Actions",
        icon: CupertinoIcons.ellipsis_circle,
        tooltipMessage: "Perform tasks with the selected items",
        items: [

          MacosPulldownMenuItem(
            title: const Text("Wähle Verzeichnis der otrkey Dateien"),
            onTap: () async {
              String? selectedDirectory =
                  await FilePicker.platform.getDirectoryPath();
              if (selectedDirectory != null) {
                context
                    .read<AppCubit>()
                    .scanFolder(folderPath: selectedDirectory);
              }
            },
          ),
          MacosPulldownMenuItem(
              title: const Text(
                  "Kopiere OTRKEY + cutlist vom Downloads Verzeichnis"),
              onTap: () async {
                final result = await context.read<AppCubit>().moveOtrkey();
                BotToast.showText(
                  text: result,
                  duration: const Duration(seconds: 3),
                  align: const Alignment(0, 0.3),
                );

              }),
          MacosPulldownMenuItem(
              title: const Text(
                  "Verschiebe geschnittene Otrkeys ins Video-Verzeichnis"),
              onTap: () async {
                context.read<AppCubit>().moveCutVideosToVideoFolder();
              }),
          MacosPulldownMenuItem(
              title: const Text("Delete Otrkeys, cutlists and uncut Videos"),
              onTap: () async {
                context.read<AppCubit>().cleanUp();
              }),

          const MacosPulldownMenuDivider(),
        ],
      ),
      const ToolBarDivider(),
      ToolbarSearchfield(
        placeholder: 'Primary word',
        onChanged: (word) =>
            context.read<AppCubit>().setPrimarySearchWord(word),
        onSubmitted: (word) {
          context.read<AppCubit>().setPrimarySearchWord(word);
          context.read<AppCubit>().search();
        },
      ),
      ToolBarIconButton(
        label: "Search",
        icon: const MacosIcon(
          CupertinoIcons.search,
        ),
        onPressed: () => context.read<AppCubit>().search(),
        showLabel: false,
      ),
      const ToolBarDivider(),
      ToolBarIconButton(
        label: "Share",
        icon: const MacosIcon(
          CupertinoIcons.share,
        ),
        onPressed: () => debugPrint("pressed"),
        showLabel: false,
      ),
    ],
    );
  }



