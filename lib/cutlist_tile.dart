// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:otr_browser/cubit/app_cubit.dart';

import 'cubit/cutlist_item.dart';

class CutlistTile extends StatelessWidget {
  const CutlistTile({
    super.key,
    required this.cutlistItem,
  });
  final CutlistItem cutlistItem;

  @override
  Widget build(BuildContext context) {
    return MacosListTile(
      title: Text(cutlistItem.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 12,
          ),
          LabelValueRow(label: 'otr key', value: cutlistItem.otrkey),
          LabelValueRow(
              label: 'cut count', value: cutlistItem.cutCount.toString()),
          LabelValueRow(
              label: 'author', value: cutlistItem.author ?? 'unknown'),
          LabelValueRow(
              label: 'duration', value: cutlistItem.duration.toString()),
          Text(cutlistItem.channel),
          Text(cutlistItem.hits.toString()),
          Text(cutlistItem.quality),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTilePullDownMenu(cutlistItem: cutlistItem),
              const SizedBox(width: 12),
              Text(cutlistItem.comment ?? 'no comment'),
            ],
          ),
        ],
      ),
    );
  }
}

class LabelValueRow extends StatelessWidget {
  const LabelValueRow({
    super.key,
    required this.label,
    required this.value,
  });
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 12),
        Text(value),
      ],
    );
  }
}

class ListTilePullDownMenu extends StatelessWidget {
  const ListTilePullDownMenu({
    super.key,
    required this.cutlistItem,
  });

  final CutlistItem cutlistItem;

  @override
  Widget build(BuildContext context) {
    return MacosPulldownButton(
      icon: CupertinoIcons.ellipsis_circle,
      items: [
        MacosPulldownMenuItem(
          title: const Text('fetch details'),
          onTap: () => debugPrint("decode otrfile"),
        ),
        MacosPulldownMenuItem(
          title: const Text('fetch cutlist'),
          onTap: () => context.read<AppCubit>().menuAction(
                SearchResultAction.fetchCutlistForOtrKey,
                'detail.otrKey',
              ),
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text('Show File in Finder'),
          onTap: () =>
              context.read<AppCubit>().showInFinder('detail.filePathName'),
        ),
        MacosPulldownMenuItem(
          title: const Text('Copy FilePath to Clipboard'),
          onTap: () =>
              context.read<AppCubit>().copyToClipboard('detail.filePathName'),
        ),
        MacosPulldownMenuItem(
          title: const Text('Open File in VScode'),
          onTap: () =>
              context.read<AppCubit>().openEditor('detail.filePathName'),
        ),
      ],
    );
  }
}
