
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../logging_stream.dart';

import '../providers/providers.dart';
import 'help_page.dart';
import 'logger_page.dart';
import 'main_page.dart';
import 'settings_page.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  final appLegalese = '© ${DateTime.now().year} Alfred Schilken';
  final apppIcon = Image.asset(
    'assets/images/app_icon_32x32@2x.png',
    width: 64,
    height: 64,
  );

  @override
  Widget build(BuildContext context) {
    final pageIndex = ref.watch(pageIndexProvider);
    final appVersion =
        ref.read(sharedPreferencesProvider).getString('appVersion');
    return PlatformMenuBar(
      menus: const [
        PlatformMenu(
          label: 'OTR Browser',
          menus: [
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.quit,
            ),
          ],
        ),
      ],
      child: MacosWindow(
        sidebar: Sidebar(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
          ),
          minWidth: 200,
          builder: (context, scrollController) => SidebarItems(
            currentIndex: pageIndex,
            onChanged: (index) {
              if (index == 0) {
                ref.read(appControllerProvider.notifier).scanFolder();
              }
              ref.read(pageIndexProvider.notifier).setPageIndex(index);
            },
            items: const [
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.search),
                label: Text('OTR Keys'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.graph_square),
                label: Text('Log'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.settings),
                label: Text('Einstellungen'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.info_circle),
                label: Text('Hilfe'),
              ),

            ],
          ),
          bottom: MacosListTile(
            leading: const MacosIcon(CupertinoIcons.info_circle),
            title: const Text(
              'OTR Browser',
              style: TextStyle(
                color: Colors.blueGrey,
              ),
            ),
            subtitle: Text('Version $appVersion'),
            onClick: () => showLicensePage(
              context: context,
              applicationName: 'OTR Browser',
              applicationLegalese: appLegalese,
              applicationIcon: apppIcon,
            ),
          ),
        ),
        child: IndexedStack(
          index: pageIndex,
          children: [
            const MainPage(),
            LoggerPage(loggingStreamController),
            const SettingsPage(),
            const HelpPage(),
          ],
        ),
      ),
    );
  }
}
