import 'dart:async';

import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class LoggerPage extends StatefulWidget {
  const LoggerPage(StreamController<String> logginStreamController, {super.key})
      : _loggingStreamController = logginStreamController;
  final StreamController<String> _loggingStreamController;

  @override
  State<LoggerPage> createState() => _LoggerPageState();
}

class _LoggerPageState extends State<LoggerPage> {
  final List<String> _lines = <String>[];
  StreamSubscription<String>? _streamSubscription;

  void onClear() {
    if (!mounted) {
      return;
    }
    setState(
      _lines.clear,
    );
  }

  @override
  void initState() {
    debugPrint('_LoggerPageState.initState');
    if (!mounted) {
      return;
    }
    super.initState();
    _streamSubscription = widget._loggingStreamController.stream.listen(
      (line) {
        setState(
          () {
            if (_lines.isNotEmpty &&
                _lines.last.contains('%') &&
                line.contains('%')) {
              _lines.removeLast();
              _lines.add(line);
            } else {
              _lines.add(line);
              // Future.delayed(const Duration(milliseconds: 50), () {
              //   _scrollToEnd(_scrollController);
              // });
            }
          },
        );
      },
    );
  }

  void onDispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _scrollToEnd(ScrollController scrollController) {
    debugPrint('_scrollToEnd');
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      children: [
        ContentArea(
          minWidth: 500,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Logger Ausgabe',
                        style: MacosTheme.of(context).typography.largeTitle,
                      ),
                      TextButton(onPressed: onClear, child: const Text('clear'))
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _lines.length,
                      itemBuilder: (context, index) {
                        return Text(_lines[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
