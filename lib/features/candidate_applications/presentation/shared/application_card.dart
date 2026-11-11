import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/placeholders.dart';
import '../../../../core/widgets/coming_soon.dart';
import '../../domain/candidate_application.dart';
import '../candidate_applications_controller.dart';
import 'application_formatters.dart';

/// Carte d'une candidature : entreprise, poste, date, score et pied adapté
/// au statut (boutons, « En attente », date d'entretien, refus).
class ApplicationCard extends StatelessWidget {
  const ApplicationCard({
    super.key,
    required this.application,
    required this.now,
    required this.onTap,
    this.isBusy = false,
  });

  final CandidateApplication application;
  final DateTime now;
  final VoidCallback onTap;

  /// Ouverture de la conversation en cours.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);

    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        key: ValueKey('application-${application.id}'),
        borderRadius: radius,
        onTap: isBusy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(application: application),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ApplicationFormatters.relativeDay(
                        application.appliedAt,
                        now,
                      ),
                      style: AppTextStyles.caption,
                    ),
                  ),
                  _ScorePill(score: application.matchScore),
                ],
              ),
              const SizedBox(height: 12),
              if (isBusy)
                const LinearProgressIndicator(minHeight: 2)
              else
                _Footer(application: application),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.application});

  final CandidateApplication application;

  @override
  Widget build(BuildContext context) {
    // TODO(backend): afficher companyLogoUrl (Image.network) quand il existe.
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.coralSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            ApplicationFormatters.companyInitials(application.companyName),
            style: const TextStyle(
              color: AppColors.coral,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Placeholders.text(application.companyName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                Placeholders.text(application.jobTitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score});

  final int? score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.skySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        Placeholders.percent(score),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

/// Pied de carte, différent selon le statut.
class _Footer extends StatelessWidget {
  const _Footer({required this.application});

  final CandidateApplication application;

  @override
  Widget build(BuildContext context) {
    return switch (application.status) {
      ApplicationStatus.interested => _InterestedActions(
        application: application,
      ),
      ApplicationStatus.sent => const _StatusStrip(
        label: 'En attente de l’entreprise',
        background: AppColors.skySoft,
        foreground: AppColors.info,
      ),
      ApplicationStatus.interview => _StatusStrip(
        label:
            'Entretien · '
            '${ApplicationFormatters.shortDate(application.interviewAt)}',
        background: AppColors.successSoft,
        foreground: AppColors.success,
      ),
      ApplicationStatus.rejected => const _StatusStrip(
        label: 'Candidature refusée',
        background: AppColors.surfaceMuted,
        foreground: AppColors.textMuted,
      ),
    };
  }
}

class _InterestedActions extends StatelessWidget {
  const _InterestedActions({required this.application});

  final CandidateApplication application;

  Future<void> _send(BuildContext context) async {
    final controller = context.read<CandidateApplicationsController>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await controller.send(application);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            ok
                ? 'Candidature envoyée à '
                      '${application.companyName ?? 'l’entreprise'}.'
                : 'La candidature n’a pas pu être envoyée. Réessaie.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // TODO(backend): « Détails » ouvrira la fiche de l'offre (route à créer).
    final sending = context.select<CandidateApplicationsController, bool>(
      (c) => c.isSending(application.id),
    );
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        FilledButton.icon(
          onPressed: sending ? null : () => _send(context),
          icon: const Icon(Icons.send_rounded, size: 14),
          label: const Text('Envoyer ma candidature'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.coral,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () => showComingSoon(context, 'Détail de l’offre'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Détails'),
        ),
      ],
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
