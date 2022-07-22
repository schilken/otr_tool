// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:otr_browser/cubit/app_cubit.dart';
import 'package:otr_browser/highlighted_text.dart';

class DetailTile extends StatelessWidget {
  const DetailTile({
    Key? key,
    required this.detail,
    required this.highlights,
    required this.displayLinesCount,
    this.fileType,
  }) : super(key: key);
  final Detail detail;
  final List<String> highlights;
  final int displayLinesCount;
  final String? fileType;

  @override
  Widget build(BuildContext context) {
    return MacosListTile(
      title: HighlightedText(
        text: detail.previewText ?? 'no preview',
        highlights: highlights,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 12,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTilePullDownMenu(detail: detail),
              const SizedBox(width: 12),
              HighlightedText(
                text: detail.projectName ?? 'no filename',
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



class ListTilePullDownMenu extends StatelessWidget {
  const ListTilePullDownMenu({
    Key? key,
    required this.detail,
  }) : super(key: key);

  final Detail detail;

  @override
  Widget build(BuildContext context) {
    return MacosPulldownButton(
      icon: CupertinoIcons.ellipsis_circle,
      items: [
        MacosPulldownMenuItem(
          title: const Text('decode otrfile'),
          onTap: () => debugPrint("decode otrfile"),
        ),
        MacosPulldownMenuItem(
          title: const Text('fetch cutlist'),
          onTap: () => context.read<AppCubit>().menuAction(
                SearchResultAction.showOnlyFilesInsameFolder,
                'a parameter',
              ),
        ),
        MacosPulldownMenuItem(
          title: const Text('cut video'),
          onTap: () => context.read<AppCubit>().menuAction(
                SearchResultAction.showOnlyFilesInsameFolder,
                'a parameter',
              ),
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text('Show File in Finder'),
          onTap: () => detail.filePathName == null
              ? null
              : context.read<AppCubit>().showInFinder(detail.filePathName!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Copy FilePath to Clipboard'),
          onTap: () => detail.filePathName == null
              ? null
              : context.read<AppCubit>().copyToClipboard(detail.filePathName!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Open File in VScode'),
          onTap: () => detail.filePathName == null
              ? null
              : context.read<AppCubit>().openEditor(detail.filePathName!),
        ),
      ],
    );
  }
}
