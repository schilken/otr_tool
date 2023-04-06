import 'package:bot_toast/bot_toast.dart';
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
    titleWidth: 250,
    actions: [
      const ToolBarSpacer(spacerUnits: 3),
      ToolBarPullDownButton(
        label: 'Actions',
        icon: CupertinoIcons.ellipsis_circle,
        items: [
          MacosPulldownMenuItem(
              title: const Text(
              'Kopiere OTRKEY + cutlist vom Downloads Verzeichnis',
            ),
              onTap: () async {
              var result = await appController.moveOtrkey();
                result =
                    (result.isNotEmpty) ? result : 'Keine OTR-Dateien gefunden';
                BotToast.showText(
                  text: result,
                  duration: const Duration(seconds: 3),
                  align: const Alignment(0, 0.3),
                );
            },
          ),
          MacosPulldownMenuItem(
              title: const Text(
              'Verschiebe geschnittene Otrkeys ins Video-Verzeichnis',
            ),
              onTap: () async {
                appController.moveCutVideosToVideoFolder();
            },
          ),
          MacosPulldownMenuItem(
            title: const Text('Delete Otrkeys, cutlists and uncut Videos'),
              onTap: () async {
                appController.cleanUp();
            },
          ),
        ],
      ),
    ],
  );
}
