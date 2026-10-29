import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../scoring/score.dart';

/// A text field for a value such as `0.40`, with an error for invalid
/// input.
class ManualValueField extends StatelessWidget {
  const ManualValueField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: 'Value',
        hintText: 'e.g. 0.40',
        border: const OutlineInputBorder(),
        errorText: text.isEmpty || Score.tryParse(text) != null
            ? null
            : 'Enter a value like 0.40',
      ),
      onChanged: (_) => onChanged(),
    );
  }
}
