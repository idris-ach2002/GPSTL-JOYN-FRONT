import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

enum JoynNoticeTone { info, success, warning, error }

/// Encart d'information dans une [Card] : bandeau d'erreur, avertissement…
class JoynNotice extends StatelessWidget {
  const JoynNotice({
    required this.message,
    this.tone = JoynNoticeTone.info,
    super.key,
  });

  final String message;
  final JoynNoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (tone) {
      JoynNoticeTone.info => (
        AppColors.skyTint,
        AppColors.navy,
        Icons.info_outline_rounded,
      ),
      JoynNoticeTone.success => (
        AppColors.successTint,
        AppColors.successDeep,
        Icons.check_circle_outline_rounded,
      ),
      JoynNoticeTone.warning => (
        AppColors.warningTint,
        AppColors.warningDeep,
        Icons.info_outline_rounded,
      ),
      JoynNoticeTone.error => (
        AppColors.errorTint,
        AppColors.errorDeep,
        Icons.error_outline_rounded,
      ),
    };

    return Semantics(
      liveRegion: tone == JoynNoticeTone.error,
      child: Card(
        color: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
