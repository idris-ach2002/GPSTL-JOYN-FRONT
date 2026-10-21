import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_fonts.dart';

enum JoynFieldMessageTone { hint, success, error }

/// Message affiché sous un champ : astuce, confirmation ou erreur.
class JoynFieldMessage extends StatelessWidget {
  const JoynFieldMessage(
    this.message, {
    this.tone = JoynFieldMessageTone.hint,
    super.key,
  });

  const JoynFieldMessage.success(this.message, {super.key})
    : tone = JoynFieldMessageTone.success;

  const JoynFieldMessage.error(this.message, {super.key})
    : tone = JoynFieldMessageTone.error;

  final String message;
  final JoynFieldMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final (color, icon, weight) = switch (tone) {
      JoynFieldMessageTone.hint => (AppColors.slate, null, FontWeight.w400),
      JoynFieldMessageTone.success => (
        AppColors.successDeep,
        Icons.check_circle_rounded,
        FontWeight.w600,
      ),
      JoynFieldMessageTone.error => (
        AppColors.errorDeep,
        Icons.error_outline_rounded,
        FontWeight.w600,
      ),
    };

    return Semantics(
      liveRegion: tone != JoynFieldMessageTone.hint,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 7),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                height: 1.4,
                fontWeight: weight,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
