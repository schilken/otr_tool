// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../model/otr_data.dart';
import '../providers/providers.dart';

class OtrDataTile extends StatelessWidget {
  const OtrDataTile({
    super.key,
    required this.otrData,
  });
  final OtrData otrData;

  @override
  Widget build(BuildContext context) {
    return MacosListTile(
      title: Text(
        otrData.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 12,
          ),
          Row(children: [
            AlternativeTexts(
              showFirst: otrData.hasOtrkey,
              first: 'OTR Key vorhanden',
              second: 'Kein OTR Key vorhanden',
            ),
              const SizedBox(width: 12),
            AlternativeTexts(
              showFirst: otrData.isdeCoded,
              first: 'schon decodiert',
              second: 'noch nicht decodiert',
            ),
              const SizedBox(width: 12),
            AlternativeTexts(
              showFirst: otrData.hasCutlist,
              first: 'Cutlist vorhanden',
              second: 'Keine Cutlist vorhanden',
            ),
              const SizedBox(width: 12),
            AlternativeTexts(
              showFirst: otrData.isExactCutlist,
              first: 'exakter Name',
              second: 'anderer Name',
            ),
              const SizedBox(width: 12),
            AlternativeTexts(
              showFirst: otrData.isCutted,
              first: 'schon geschnitten',
              second: 'noch nicht geschnitten',
            ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              ListTilePullDownMenu(otrData: otrData),
              const SizedBox(width: 12),
              Text(
                otrData.otrkeyBasename ?? '',
                style: const TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AlternativeTexts extends StatelessWidget {
  const AlternativeTexts({
    super.key,
    required this.showFirst,
    required this.first,
    required this.second,
    this.firstColor = Colors.blueGrey,
    this.secondColor = Colors.red,
  });
  final bool showFirst;
  final String first;
  final String second;
  final Color firstColor;
  final Color secondColor;

  @override
  Widget build(BuildContext context) {
    return showFirst
        ? Text(
            first,
            style: TextStyle(color: firstColor),
          )
        : Text(
            second,
            style: TextStyle(color: secondColor),
          );
  }
}

class ListTilePullDownMenu extends ConsumerWidget {
  const ListTilePullDownMenu({
    super.key,
    required this.otrData,
  });

  final OtrData otrData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appController = ref.watch(appControllerProvider.notifier);
    return MacosPulldownButton(
      icon: CupertinoIcons.ellipsis_circle,
      items: [
        MacosPulldownMenuItem(
          title: const Text('Decodieren&Schneiden&Kopieren'),
          enabled:
              otrData.otrkeyBasename != null && otrData.cutlistBasename != null,
          onTap: () async {
            await appController.decodeCutAndCopyVideo(
                  otrData.otrkeyBasename!,
                  otrData.cutlistBasename!,
                  otrData.name,
                );
//            await context.read<AppCubit>().openTrash();
            BotToast.showText(
              text: 'Dateien in Papierkorb bzw. Film-Ordner verschoben',
              duration: const Duration(seconds: 3),
              align: const Alignment(0, 0.3),
            );
          },
        ),
        MacosPulldownMenuItem(
          title: const Text('Decodiere&Schneide Video'),
          enabled:
              otrData.otrkeyBasename != null && otrData.cutlistBasename != null,
          onTap: () => appController.decodeAndCutVideo(
                otrData.otrkeyBasename!,
                otrData.cutlistBasename!,
              ),
        ),
        MacosPulldownMenuItem(
          title: const Text('Decodiere otrkey'),
          enabled: otrData.otrkeyBasename != null,
          onTap: () =>
              appController.decodeVideo(otrData.otrkeyBasename!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Schneide Video'),
          enabled: otrData.decodedBasename != null &&
              otrData.cutlistBasename != null,
          onTap: () => appController.cutVideo(
                otrData.decodedBasename!,
                otrData.cutlistBasename!,
              ),
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text('Öffne Video in Avidemux'),
          enabled: otrData.decodedBasename != null &&
              otrData.cutlistBasename == null,
          onTap: () => appController.openVideoInAvidemux(
            otrData.decodedBasename!,
          ),
        ),
        MacosPulldownMenuItem(
          title: const Text('Kopiere Video in Files'),
          enabled: otrData.decodedBasename != null && otrData.isCutted,
          onTap: () => appController.copyCutVideo(
            otrData.name,
          ),
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text('Zeige otrkey Datei im Finder'),
          enabled: otrData.otrkeyBasename != null,
          onTap: () =>
              appController.showInFinder(otrData.otrkeyBasename!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Kopiere otrkey Name ins Clipboard'),
          enabled: otrData.otrkeyBasename != null,
          onTap: () => appController.copyToClipboard(otrData.name),
        ),
        MacosPulldownMenuItem(
          title: const Text('Öffne cutlist Datei in VScode'),
          enabled: otrData.cutlistBasename != null,
          onTap: () =>
              appController.openEditor(otrData.cutlistBasename),
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text(
            'Alles außer geschnittenes Video in Papierkorb verschieben',
          ),
          enabled: otrData.isCutted,
          onTap: () async {
            await appController.moveToTrashOrToMovies(otrData.name);
            appController.openTrash();
            BotToast.showText(
              text: 'Dateien in Papierkorb bzw. Film-Ordner verschoben',
              duration: const Duration(seconds: 3),
              align: const Alignment(0, 0.3),
            );
          },
        ),
        MacosPulldownMenuItem(
          title: const Text('Alles in Papierkorb verschieben'),
          onTap: () async {
            await appController.moveAllToTrash(otrData.name);
            BotToast.showText(
              text: 'Dateien in Papierkorb verschoben',
              duration: const Duration(seconds: 3),
              align: const Alignment(0, 0.3),
            );
          },
        ),
      ],
    );
  }
}
