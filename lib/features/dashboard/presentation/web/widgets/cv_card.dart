import 'package:flutter/material.dart';

import 'package:joyn_front/core/theme/app_colors.dart';
import 'package:joyn_front/core/theme/app_dimens.dart';
import 'package:joyn_front/core/theme/app_text_styles.dart';
import 'package:joyn_front/core/utils/placeholders.dart';
import 'package:joyn_front/core/widgets/coming_soon.dart';
import 'package:joyn_front/features/dashboard/domain/cv_document.dart';
import 'package:joyn_front/features/dashboard/presentation/widgets/dashboard_card.dart';

/// CV du candidat et lien vers son profil détaillé.
class CvCard extends StatelessWidget {
  const CvCard({super.key, required this.cv});

  final CvDocument? cv;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.field);

    return DashboardCard(
      title: 'CV',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: AppColors.surfaceMuted,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              // TODO(backend): ouvrir cv.url.
              onTap: () => showComingSoon(context, 'Téléchargement du CV'),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: AppColors.error,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Placeholders.text(cv?.fileName),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            Placeholders.text(cv?.updatedLabel),
                            style: AppTextStyles.caption.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => showComingSoon(context, 'Profil détaillé'),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('Voir le profil détaillé →'),
          ),
        ],
      ),
    );
  }
}
