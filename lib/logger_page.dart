import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class LoggerPage extends StatefulWidget {
  const LoggerPage(Stream<String>? commandStdout, {super.key})
      : _commandStdout = commandStdout;
  final Stream<String>? _commandStdout;

  @override
  State<LoggerPage> createState() => _LoggerPageState();

}

class _LoggerPageState extends State<LoggerPage> {
  final List<String> _lines = <String>[];

  void onClear() {
    setState(
      () {
        _lines.clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('_LoggerPageState build');
    return MacosScaffold(
      children: [
        ContentArea(
          minWidth: 500,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Logger Ausgabe',
                        style: MacosTheme.of(context).typography.largeTitle,
                      ),
                      TextButton(onPressed: onClear, child: Text('clear'))
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Command',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder(
                      stream: widget._commandStdout,
                      initialData: '',
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        _lines.add(snapshot.data);
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: _lines.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Text(_lines[index]);
                          },
                        );
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
