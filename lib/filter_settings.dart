import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:otr_browser/cubit/settings_cubit.dart';

class FilterSettings extends StatelessWidget {
  const FilterSettings({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 8),
            // Text('Filter Files', style: TextStyle(fontWeight: FontWeight.bold)),
            // SizedBox(height: 16),
            // MacosPopupButton<String>(
            //   value: context.read<SettingsCubit>().exampleFileFilter,
            //   onChanged: (String? value) async {
            //     await context.read<SettingsCubit>().setExampleFileFilter(value);
            //   },
            //   items: <String>[
            //     'Include Example Files',
            //     'Only */example/*',
            //     'Without */example/*'
            //   ].map<MacosPopupMenuItem<String>>((String value) {
            //     return MacosPopupMenuItem<String>(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            // ),
            // SizedBox(height: 16),
            // MacosPopupButton<String>(
            //   value: context.read<SettingsCubit>().testFileFilter,
            //   onChanged: (String? newValue) async {
            //     await context.read<SettingsCubit>().setOtrEmail(newValue);
            //   },
            //   items: <String>[
            //     'Include Test Files',
            //     'Only *_test.dart',
            //     'Without *_test.dart'
            //   ].map<MacosPopupMenuItem<String>>((String value) {
            //     return MacosPopupMenuItem<String>(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            // ),
            // SizedBox(height: 32),
            // Text('Filter Lines', style: TextStyle(fontWeight: FontWeight.bold)),
            // SizedBox(height: 16),
            // MacosPopupButton<String>(
            //   value: context.read<SettingsCubit>().lineFilter,
            //   onChanged: (String? newValue) async {
            //     await context.read<SettingsCubit>().setLineFilter(newValue);
            //   },
            //   items: <String>['Only First Line', 'First Two Lines', 'All Lines']
            //       .map<MacosPopupMenuItem<String>>((String value) {
            //     return MacosPopupMenuItem<String>(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            // ),
            // SizedBox(height: 32),
          ],
        );
      },
    );
  }
}
