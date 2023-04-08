import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/get_custom_toolbar.dart';
import '../components/otr_data_tile.dart';
import '../providers/providers.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {

  @override
  void initState() {
    debugPrint('MainPage.initState');
    ref.read(appControllerProvider.notifier).moveOtrkey().then((result) {
      if (result.isNotEmpty) {
        BotToast.showText(
          text: result,
          duration: const Duration(seconds: 3),
          align: const Alignment(0, 0.3),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appControllerProvider);
    final appController = ref.watch(appControllerProvider.notifier);

    return Builder(builder: (context) {
      return MacosScaffold(
        backgroundColor: Colors.white,
        toolBar: getCustomToolBar(context, ref),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return Column(
                      children: [
                        Container(
                          color: Colors.blueGrey[100],
                          padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                      child: Row(
                            children: [
                          const Text('OTR Verzeichnis: '),
                        Text(appState.currentPathname),
                              MacosIconButton(
                            onPressed: appController.scanFolder,
                                icon: const MacosIcon(
                                  CupertinoIcons.refresh,
                                ),
                              ),
                            ],
                          ),
                        ),
                  if (appState.message != null)
                          Container(
                              padding: const EdgeInsets.all(20),
                              color: Colors.red[100],
                        child: Text(appState.message!),
                      ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            controller: ScrollController(),
                      itemCount: appState.details.length,
                            itemBuilder: (context, index) {
                        final detail = appState.details[index];
                              return OtrDataTile(
                                otrData: detail,
                              );
                            },
                            separatorBuilder:
                                (context, index) {
                              return const Divider(
                                thickness: 2,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                ],
              );
            },
          ),
        ],
      );
      },
    );
  }
}
