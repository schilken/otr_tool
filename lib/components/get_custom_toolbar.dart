import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:otr_browser/cubit/app_cubit.dart';
import 'package:otr_browser/components/toolbar_searchfield.dart';

ToolBar getCustomToolBar(BuildContext context) {
  return ToolBar(
    leading: MacosIconButton(
      icon: const MacosIcon(
        CupertinoIcons.sidebar_left,
        size: 40,
        color: CupertinoColors.black,
      ),
      onPressed: () {
        MacosWindowScope.of(context).toggleSidebar();
      },
    ),

    title: const Text('OTR Browser'),
    titleWidth: 250.0,
    actions: [
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
      // const ToolBarDivider(),
      // ToolbarSearchfield(
      //   placeholder: 'Primary word',
      //   onChanged: (word) =>
      //       context.read<AppCubit>().setPrimarySearchWord(word),
      //   onSubmitted: (word) {
      //     context.read<AppCubit>().setPrimarySearchWord(word);
      //     context.read<AppCubit>().search();
      //   },
      // ),
      // ToolBarIconButton(
      //   label: "Search",
      //   icon: const MacosIcon(
      //     CupertinoIcons.search,
      //   ),
      //   onPressed: () => context.read<AppCubit>().search(),
      //   showLabel: false,
      // ),
      // const ToolBarDivider(),
      // ToolBarIconButton(
      //   label: "Share",
      //   icon: const MacosIcon(
      //     CupertinoIcons.share,
      //   ),
      //   onPressed: () => debugPrint("pressed"),
      //   showLabel: false,
      // ),
    ],
  );
}
