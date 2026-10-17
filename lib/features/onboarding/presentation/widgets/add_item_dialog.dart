import 'package:flutter/material.dart';

import '../../../../design_system/components/joyn_button.dart';
import '../../../../design_system/components/joyn_text_field.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';

/// Demande un texte court (compétence, soft skill…). Renvoie `null` si annulé.
Future<String?> showAddItemDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String hintText,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) =>
        _AddItemDialog(title: title, label: label, hintText: hintText),
  );
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog({
    required this.title,
    required this.label,
    required this.hintText,
  });

  final String title;
  final String label;
  final String hintText;

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        widget.title,
        style: const TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      content: SizedBox(
        width: 380,
        child: JoynTextField(
          label: widget.label,
          controller: _controller,
          hintText: widget.hintText,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        JoynButton(
          label: 'Annuler',
          variant: JoynButtonVariant.outline,
          height: 44,
          fontSize: 15,
          borderRadius: 12,
          onPressed: () => Navigator.of(context).pop(),
        ),
        JoynButton(
          label: 'Ajouter',
          height: 44,
          fontSize: 15,
          borderRadius: 12,
          onPressed: _submit,
        ),
      ],
    );
  }
}
