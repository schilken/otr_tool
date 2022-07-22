import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class SettingsWindow extends StatelessWidget {
  const SettingsWindow({
    super.key,
    required this.windowController,
    required this.args,
  });

  final WindowController windowController;
  final Map? args;

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'otr_browser',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      home: MacosWindow(
        child: MacosScaffold(
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
                        'Preferences',
                        style: MacosTheme.of(context).typography.largeTitle,
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Choose your Default Folders',
                      ),
                      SizedBox(height: 20),
                      const Text(
                        'Default Examples',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            '/Users/aschilken/flutterdev/examples',
                          ),
                          MacosIconButton(
                            icon: const MacosIcon(
                              CupertinoIcons.folder_open,
                            ),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(7),
                            onPressed: () async {
                              String? selectedDirectory =
                                  await FilePicker.platform.getDirectoryPath();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      const Text(
                        'Packages Folder',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      const Text(
                        '/Users/aschilken/.pub-cache/hosted/pub.dartlang.org',
                      ),
                      SizedBox(height: 20),
                      const Text(
                        'The Complete Flutter Source Folder',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      const Text(
                        '/Users/aschilken/flutterdev/flutter',
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
