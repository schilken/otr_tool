// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:macos_ui/macos_ui.dart';

typedef StringCallback = void Function(String);

class ToolbarSearchfield extends ToolbarItem {
  const ToolbarSearchfield({
    Key? key,
    this.placeholder,
    required this.onChanged,
    required this.onSubmitted,
  }) : super(key: key);
  final String? placeholder;
  final StringCallback onChanged;
  final StringCallback onSubmitted;

  @override
  Widget build(BuildContext context, ToolbarItemDisplayMode displayMode) {
    return SizedBox(
      width: 120,
      child: HookedSearchField(
        placeholder: placeholder,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class HookedSearchField extends HookWidget {
  const HookedSearchField({
    Key? key,
    this.placeholder,
    required this.onChanged,
    required this.onSubmitted,

  }) : super(key: key);
  final String? placeholder;
  final StringCallback onChanged;
  final StringCallback onSubmitted;


  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    controller.addListener(() {
      onChanged('');
    });
    return MacosTextField(
      controller: controller,
      placeholder: placeholder,
      maxLines: 1,
      onTap: () {},
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
