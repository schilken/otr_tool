import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:otr_browser/cubit/app_cubit.dart';

import '../components/get_custom_toolbar.dart';
import '../components/otr_data_tile.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    debugPrint('MainPage.initState');
    context.read<AppCubit>().moveOtrkey().then((result) {
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
    return Builder(builder: (context) {
      return MacosScaffold(
        backgroundColor: Colors.white,
        toolBar: getCustomToolBar(context),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  if (state is DetailsLoaded) {
                    return Column(
                      children: [
                        Container(
                          color: Colors.blueGrey[100],
                          padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text('OtrFolder:'),
                              Text(state.currentPathname),
                              MacosIconButton(
                                onPressed: () => context
                                    .read<AppCubit>()
                                    .scanFolder(state.currentPathname),
                                icon: const MacosIcon(
                                  CupertinoIcons.refresh,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.message != null)
                          Container(
                              padding: const EdgeInsets.all(20),
                              color: Colors.red[100],
                              child: Text(state.message!)),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            controller: ScrollController(),
                            itemCount: state.details.length,
                            itemBuilder: (context, index) {
                              final detail = state.details[index];
                              return OtrDataTile(
                                otrData: detail,
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const Divider(
                                thickness: 2,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  } else if (state is DetailsLoading) {
                    return const CupertinoActivityIndicator();
                  }
                  return const Center(child: Text('No file selected'));
                },
              );
            },
          ),
        ],
      );
    });
  }
}
