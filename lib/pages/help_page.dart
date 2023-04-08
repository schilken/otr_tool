import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/get_custom_toolbar.dart';

const _helpMarkdown = '''
# OTR Tool für macOS

## OTR Tool ist eine grafische Benutzeroberfläche zum Dekodieren und Schneiden von Otrkeys unter macOS

## Konfigurieren
- Öffne die Einstellungen
- Trage deine OTR E-Email und dein OTR Passwort ein, mit dem du dich auf https://onlinetvrecorder.com anmeldest
- Wähle dein Download-Verzeichnis aus, von hier werden die otrkey-Dateien geladen
- Das OTR-Verzeichnis ist das Arbeitsverzeichnis fürs Decodieren und Schneiden
- Wähle dein Video-Verzeichnis aus, in dem deine Videos liegen 
- Konfiguriere, wo das **otrdecoder** Programm installiert ist. Du kannst es (64 Bit Dekoder für Catalina) herunterladen von https://www.onlinetvrecorder.com/v2/software/MacOS 
- Konfiguriere, wo das **Avidemux** Programm installiert ist. Suche im Internet nach Avidemux und lade es beispielsweise von https://www.heise.de herunter.

## Verwenden
- Lade deine otrkey Dateien und die Schneidelisten ins Download Verzeichnis, beispielsweise von https://otr.datenkeller.net
- Starte die App, um alle otrkey und Schneidelisten vom Download-Verzeichnis ins OTR-Verzeichnis zu kopieren
- Falls OTR Tool schon geöffnet ist, klicke auf das refresh-Icon
- Wähle im Menu den Eintrag **Dekodieren&Schneiden&Kopieren** aus
- Die geschnittenen Videos findest du im Video-Verzeichnis
''';

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MacosScaffold(
      toolBar: getCustomToolBar(context, ref),
      children: [
        ContentArea(
          minWidth: 500,
          builder: (context, scrollController) {
            return Markdown(
              //            controller: controller,
              data: _helpMarkdown,
              selectable: true,
              styleSheet: MarkdownStyleSheet().copyWith(
                h1Padding: const EdgeInsets.only(top: 12, bottom: 4),
                h1: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                h2Padding: const EdgeInsets.only(top: 12, bottom: 4),
                h2: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                p: const TextStyle(
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
