import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:otr_browser/pages/about_window.dart';
import 'package:otr_browser/cubit/app_cubit.dart';
import 'package:otr_browser/services/files_repository.dart';
import 'package:otr_browser/components/filter_settings.dart';

import 'pages/logger_page.dart';
import 'pages/main_page.dart';
import 'preferences/settings_cubit.dart';
import 'preferences/settings_page.dart';

void main(List<String> args) {
  print('main: $args');
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final arguments = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;
    if (arguments['args1'] == 'About') {
      runApp(AboutWindow(
        windowController: WindowController.fromWindowId(windowId),
        args: arguments,
      ));
    } 
  } else {
    runApp(App());
  }
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SettingsCubit>(
        future: SettingsCubit().initialize(),
        builder: (context, snapshot) {
          print('builder: ${snapshot.hasData}');
          if (!snapshot.hasData) {
            return Container();
          }
          return RepositoryProvider(
            create: (context) => FilesRepository(),
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: snapshot.data!,
                ),
                BlocProvider(
                  create: (context) => AppCubit(
                    context.read<SettingsCubit>(),
                    context.read<FilesRepository>(),
                  )..init(),
                ),
              ],
              child: MacosApp(
                title: 'otr_browser',
                theme: MacosThemeData.light(),
                darkTheme: MacosThemeData.dark(),
                themeMode: ThemeMode.system,
                home: const MainView(),
                debugShowCheckedModeBanner: false,
                builder: BotToastInit(),
                navigatorObservers: [BotToastNavigatorObserver()],
              ),
            ),
          );
        });
  }
}

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
                top: FilterSettings(),
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
                  MainPage(),
                  LoggerPage(state.commandStdoutStream ?? Stream.empty()),
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
