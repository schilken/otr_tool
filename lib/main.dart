import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:otr_browser/logging_stream.dart';
import 'package:otr_browser/pages/about_window.dart';
import 'package:otr_browser/cubit/app_cubit.dart';
import 'package:otr_browser/services/files_repository.dart';

import 'cubit/settings_cubit.dart';
import 'pages/main_view.dart';

void main(List<String> args) {
  loggingStreamController = StreamController<String>.broadcast();
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
    runApp(const App());
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
