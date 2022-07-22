// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          NameWithOpenInEditor(
            name: detail.projectName ?? 'no project',
            path: detail.projectPathName,
          ),
        ],
      ),
    );
  }

}

class NameWithOpenInEditor extends StatelessWidget {
  const NameWithOpenInEditor({
    super.key,
    required this.name,
    this.path,
  });
  final String name;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
        MacosIconButton(
          icon: const MacosIcon(
            CupertinoIcons.link,
          ),
          shape: BoxShape.circle,
          onPressed: () {
            context.read<AppCubit>().openEditor(path);
          },
        ),
      ],
    );
  }
}
