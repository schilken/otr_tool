// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:otr_browser/cubit/app_cubit.dart';
import 'package:otr_browser/components/highlighted_text.dart';

import '../model/otr_data.dart';

class OtrDataTile extends StatelessWidget {
  const OtrDataTile({
    Key? key,
    required this.otrData,
    required this.highlights,
  }) : super(key: key);
  final OtrData otrData;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return MacosListTile(
      title: HighlightedText(
        text: otrData.name,
        style: TextStyle(fontWeight: FontWeight.bold),
        highlights: highlights,
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
            SizedBox(width: 12),
            AlternativeTexts(
              showFirst: otrData.isdeCoded,
              first: 'schon decodiert',
              second: 'noch nicht decodiert',
            ),
            SizedBox(width: 12),
            AlternativeTexts(
              showFirst: otrData.hasCutlist,
              first: 'Cutlist vorhanden',
              second: 'Keine Cutlist vorhanden',
            ),
            SizedBox(width: 12),
            AlternativeTexts(
              showFirst: otrData.isExactCutlist,
              first: 'exakter Name',
              second: 'anderer Name',
            ),
            SizedBox(width: 12),
            AlternativeTexts(
              showFirst: otrData.isCutted,
              first: 'schon geschnitten',
              second: 'noch nicht geschnitten',
            ),
          ]),
          const SizedBox(
            height: 12,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTilePullDownMenu(otrData: otrData),
              const SizedBox(width: 12),
              HighlightedText(
                text: otrData.otrkeyBasename ?? '',
                style: const TextStyle(
                  color: Colors.blueGrey,
                ),
                highlights: highlights,
                caseSensitive: false,
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
    Key? key,
    required this.showFirst,
    required this.first,
    required this.second,
    this.firstColor = Colors.blueGrey,
    this.secondColor = Colors.red,
  }) : super(key: key);
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

class ListTilePullDownMenu extends StatelessWidget {
  const ListTilePullDownMenu({
    Key? key,
    required this.otrData,
  }) : super(key: key);

  final OtrData otrData;

  @override
  Widget build(BuildContext context) {
    return MacosPulldownButton(
      icon: CupertinoIcons.ellipsis_circle,
      items: [
        // MacosPulldownMenuItem(
        //   title: const Text('Decodiere&Schneide Video'),
        //   enabled:
        //       otrData.otrkeyBasename != null && otrData.cutlistBasename != null,
        //   onTap: () => context.read<AppCubit>().decodeAndCutVideo(
        //         otrData.otrkeyBasename!,
        //         otrData.cutlistBasename!,
        //       ),
        // ),

        MacosPulldownMenuItem(
          title: const Text('Decodiere otrkey'),
          enabled: otrData.otrkeyBasename != null,
          onTap: () =>
              context.read<AppCubit>().decodeVideo(otrData.otrkeyBasename!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Schneide Video'),
          enabled: otrData.decodedBasename != null &&
              otrData.cutlistBasename != null,
          onTap: () => context.read<AppCubit>().cutVideo(
                otrData.decodedBasename!,
                otrData.cutlistBasename!,
              ),
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text('Zeige otrkey Datei im Finder'),
          enabled: otrData.otrkeyBasename != null,
          onTap: () =>
              context.read<AppCubit>().showInFinder(otrData.otrkeyBasename!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Kopiere otrkey Name ins Clipboard'),
          enabled: otrData.otrkeyBasename != null,
          onTap: () => context.read<AppCubit>().copyToClipboard(otrData.name),
        ),
        MacosPulldownMenuItem(
          title: const Text('Öffne cutlist Datei in VScode'),
          enabled: otrData.cutlistBasename != null,
          onTap: () =>
              context.read<AppCubit>().openEditor(otrData.cutlistBasename),
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text(
              'Alles außer geschnittenes Video in Papierkorb verschieben'),
          enabled: otrData.isCutted,
          onTap: () async {
            await context.read<AppCubit>().moveToTrashOrToMovies(otrData.name);
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
            await context.read<AppCubit>().moveAllToTrash(otrData.name);
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
