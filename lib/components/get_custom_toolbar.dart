import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../providers/providers.dart';

ToolBar getCustomToolBar(BuildContext context, WidgetRef ref) {
  final appController = ref.watch(appControllerProvider.notifier);
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
                appController.scanFolder();
              }
            },
          ),
          MacosPulldownMenuItem(
              title: const Text(
                  "Kopiere OTRKEY + cutlist vom Downloads Verzeichnis"),
              onTap: () async {
                String result = await appController.moveOtrkey();
                result =
                    (result.isNotEmpty) ? result : 'Keine OTR-Dateien gefunden';
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
                appController.moveCutVideosToVideoFolder();
              }),
          MacosPulldownMenuItem(
              title: const Text("Delete Otrkeys, cutlists and uncut Videos"),
              onTap: () async {
                appController.cleanUp();
              }),
          const MacosPulldownMenuDivider(),
        ],
      ),
    ],
  );
}
