import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:otr_browser/logging_stream.dart';
import 'package:otr_browser/cubit/app_cubit.dart';

import 'logger_page.dart';
import 'main_page.dart';
import 'settings_page.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'OpenSourceBrowser',
          menus: [
            PlatformMenuItem(
              label: 'About',
              onSelected: () async {
                final window = await DesktopMultiWindow.createWindow(jsonEncode(
                  {
                    'args1': 'About',
                    'args2': 500,
                    'args3': true,
                  },
                ));
                debugPrint('$window');
                window
                  ..setFrame(const Offset(0, 0) & const Size(350, 350))
                  ..center()
                  ..setTitle('About otr_browser')
                  ..show();
              },
            ),
            const PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.quit,
            ),
          ],
        ),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          if (state is DetailsLoaded) {
            return MacosWindow(
              sidebar: Sidebar(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                minWidth: 200,
                builder: (context, scrollController) => SidebarItems(
                  currentIndex: state.sidebarPageIndex,
                  onChanged: (index) =>
                      context.read<AppCubit>().sidebarChanged(index),
                  items: [
                    const SidebarItem(
                      leading: MacosIcon(CupertinoIcons.search),
                      label: Text('OTR Keys'),
                    ),
                    const SidebarItem(
                      leading: MacosIcon(CupertinoIcons.graph_square),
                      label: Text('Log'),
                    ),
                    const SidebarItem(
                      leading: MacosIcon(CupertinoIcons.settings),
                      label: Text('Einstellungen'),
                    ),
                  ],
                ),
                bottom: const MacosListTile(
                  leading: MacosIcon(CupertinoIcons.profile_circled),
                  title: Text('Alfred Schilken'),
                  subtitle: Text('alfred@schilken.de'),
                ),
              ),
              child: IndexedStack(
                index: state.sidebarPageIndex,
                children: [
                  const MainPage(),
                  LoggerPage(loggingStreamController),
                  SettingsPage(),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
