import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';

import 'cubit/settings_cubit.dart';
import 'textfield_dialog.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  promptEmail(BuildContext context) async {
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
      await context.read<SettingsCubit>().setOtrEmail(email);
    }
  }

  promptPassword(BuildContext context) async {
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
      await context.read<SettingsCubit>().setOtrPassword(password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      children: [
        ContentArea(
          minWidth: 500,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  if (state is SettingsLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Preferences',
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
                                promptEmail(context);
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
                              icon: const MacosIcon(
                                CupertinoIcons.pencil,
                              ),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(7),
                              onPressed: () async {
                                promptPassword(context);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        const Text(
                          'OTR Folder',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              state.otrFolder,
                            ),
                            MacosIconButton(
                              icon: const MacosIcon(
                                CupertinoIcons.folder_open,
                              ),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(7),
                              onPressed: () async {
                                String? selectedDirectory = await FilePicker
                                    .platform
                                    .getDirectoryPath();
                                if (selectedDirectory != null) {
                                  await context
                                      .read<SettingsCubit>()
                                      .setOtrFolder(selectedDirectory);
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        const Text(
                          'Avidemux Programm',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              state.otrFolder,
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
                                if (filePickerResult != null) {
                                  await context
                                      .read<SettingsCubit>()
                                      .setAvidemuxBinary(
                                          filePickerResult.paths.first);
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
