import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/textfield_dialog.dart';
import '../providers/providers.dart';

typedef StringCallback = void Function(String);

class SettingsPage extends ConsumerWidget {
  SettingsPage({super.key});

  promptEmail(BuildContext context, WidgetRef ref) async {
    final email = await textFieldDialog(
      context,
      title: const Text('Enter OTR Email'),
      description:
          const Text('The E-Mail you use to login to onlinetvrecorder.com.\n'),
      initialValue: '',
      textOK: const Text('OK'),
      textCancel: const Text('Abbrechen'),
      validator: (String? value) {
        if (value == null || value.isEmpty || value.length < 2) {
          return 'Mindestens 2 Buchstaben oder Ziffern';
        }
        return null;
      },
      barrierDismissible: true,
      textCapitalization: TextCapitalization.words,
      textAlign: TextAlign.center,
    );
    if (email != null) {
      await ref.read(settingsControllerProvider.notifier).setOtrEmail(email);
    }
  }

  promptPassword(BuildContext context, WidgetRef ref) async {
    final password = await textFieldDialog(
      context,
      title: const Text('Enter OTR Password'),
      description: const Text(
          'The Password you use to login to onlinetvrecorder.com.\n'),
      initialValue: '',
      textOK: const Text('OK'),
      textCancel: const Text('Abbrechen'),
      validator: (String? value) {
        if (value == null || value.isEmpty || value.length < 2) {
          return 'Mindestens 2 Buchstaben oder Ziffern';
        }
        return null;
      },
      barrierDismissible: true,
      textCapitalization: TextCapitalization.words,
      textAlign: TextAlign.center,
    );
    if (password != null) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setOtrPassword(password);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    final settingsController = ref.watch(settingsControllerProvider.notifier);
    return MacosScaffold(
      children: [
        ContentArea(
          minWidth: 500,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Einstellungen',
                    style: MacosTheme.of(context).typography.largeTitle,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'OTR E-Mail',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(state.email),
                      MacosIconButton(
                        icon: const MacosIcon(
                          CupertinoIcons.pencil,
                        ),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(7),
                        onPressed: () async {
                          promptEmail(context, ref);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  const Text(
                    'OTR Password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        state.password,
                      ),
                      MacosIconButton(
                        icon: MacosIcon(
                          size: 60,
                          state.showPassword
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye,
                        ),
                        // shape: BoxShape.rectangle,
                        // borderRadius: BorderRadius.circular(7),
                        onPressed: () async {
                          settingsController.toggleShowPassword();
                        },
                      ),
                      MacosIconButton(
                        icon: const MacosIcon(
                          CupertinoIcons.pencil,
                        ),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(7),
                        onPressed: () async {
                          promptPassword(context, ref);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  const Text(
                    'Download Folder',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ShowAndSelectFolder(
                    folder: state.downloadFolder,
                    onSelected: (String? value) async {
                      await settingsController.setDownloadFolder(value);
                    },
                  ),
                  SizedBox(height: 16),
                  const Text(
                    'OTR Folder',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ShowAndSelectFolder(
                    folder: state.otrFolder,
                    onSelected: (String? value) async {
                      await settingsController.setOtrFolder(value);
                    },
                  ),
                  SizedBox(height: 16),
                  const Text(
                    'Video Folder',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ShowAndSelectFolder(
                    folder: state.videoFolder,
                    onSelected: (String value) async {
                      await settingsController.setVideoFolder(value);
                    },
                  ),
                  SizedBox(height: 16),
                  const Text(
                    'Avidemux Programm',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ShowAndSelectFile(
                    filename: state.avidemuxApp,
                    onSelected: (String value) async {
                      await settingsController.setAvidemuxApp(value);
                    },
                  ),
                  SizedBox(height: 16),
                  const Text(
                    'otrdecoder Programm',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ShowAndSelectFile(
                    filename: state.otrdecoderBinary,
                    onSelected: (String value) async {
                      await settingsController.setOtrdecoderBinary(value);
                    },
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class ShowAndSelectFolder extends StatelessWidget {
  const ShowAndSelectFolder({
    super.key,
    required this.folder,
    required this.onSelected,
  });
  final String folder;
  final StringCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          folder,
        ),
        MacosIconButton(
          icon: const MacosIcon(
            CupertinoIcons.folder_open,
          ),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(7),
          onPressed: () async {
            String? selectedDirectory =
                await FilePicker.platform.getDirectoryPath(
              initialDirectory: Platform.environment['HOME']!,
            );
            if (selectedDirectory != null) {
              onSelected(selectedDirectory);
            }
          },
        ),
      ],
    );
  }
}

class ShowAndSelectFile extends StatelessWidget {
  const ShowAndSelectFile({
    super.key,
    required this.filename,
    required this.onSelected,
  });
  final String filename;
  final StringCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          filename,
        ),
        MacosIconButton(
          icon: const MacosIcon(
            CupertinoIcons.folder_open,
          ),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(7),
          onPressed: () async {
            FilePickerResult? filePickerResult =
                await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['app'],
            );
            if (filePickerResult?.paths.first != null) {
              onSelected(filePickerResult!.paths.first!);
            }
          },
        ),
      ],
    );
  }
}
