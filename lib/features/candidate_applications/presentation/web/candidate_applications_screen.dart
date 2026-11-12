import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/core/theme/app_colors.dart';
import 'package:joyn_front/core/theme/app_dimens.dart';
import 'package:joyn_front/core/theme/app_text_styles.dart';
import 'package:joyn_front/core/widgets/joyn_button.dart';
import 'package:joyn_front/features/candidate_applications/domain/candidate_application.dart';
import 'package:joyn_front/features/candidate_applications/presentation/candidate_applications_controller.dart';
import 'package:joyn_front/features/candidate_applications/presentation/shared/application_card.dart';
import 'package:joyn_front/features/candidate_applications/presentation/shared/application_formatters.dart';
import 'package:joyn_front/features/candidate_applications/presentation/shared/open_conversation.dart';
import 'package:joyn_front/features/candidate_applications/presentation/shared/status_color.dart';
import 'package:joyn_front/features/dashboard/presentation/widgets/dashboard_top_bar.dart';

/// « Mes candidatures » (route `/candidate/applications`), version web.
///
/// Une colonne par statut (Intéressé, Envoyées, Entretiens, Refus) ;
/// les colonnes passent les unes sous les autres sur petit écran.
class WebCandidateApplicationsScreen extends StatelessWidget {
  const WebCandidateApplicationsScreen({super.key});

  static const double _maxContentWidth = 1200;

  /// Hauteur dont les colonnes remontent sur le bandeau bleu.
  static const double _boardOverlap = 40;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CandidateApplicationsController>();
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;
    final gutter = isWide ? AppSpacing.xl : AppSpacing.md;

    Widget constrained(Widget child) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: child,
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.xl + _boardOverlap,
                  ),
                  child: constrained(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DashboardTopBar(
                          isWide: isWide,
                          activeTab: DashboardTab.applications,
                        ),
                        SizedBox(
                          height: isWide ? AppSpacing.xl : AppSpacing.lg,
                        ),
                        _Title(controller: controller, isWide: isWide),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -_boardOverlap),
              child: constrained(
                _Board(controller: controller, isWide: isWide),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.controller, required this.isWide});

  final CandidateApplicationsController controller;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes candidatures',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWide ? 34 : 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                ApplicationFormatters.summary(
                  applications: controller.totalItems,
                  interviews: controller.interviewsThisWeek,
                ),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: isWide ? 18 : 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Actualiser',
          onPressed: controller.isLoading ? null : controller.load,
          icon: const Icon(Icons.refresh_rounded),
          color: Colors.white,
        ),
      ],
    );
  }
}

/// Colonnes de statut, ou chargement / erreur.
class _Board extends StatelessWidget {
  const _Board({required this.controller, required this.isWide});

  final CandidateApplicationsController controller;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final error = controller.errorMessage;
    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          children: [
            Text(error, style: AppTextStyles.muted),
            const SizedBox(height: AppSpacing.md),
            JoynButton(
              label: 'Réessayer',
              expand: false,
              onPressed: controller.load,
            ),
          ],
        ),
      );
    }

    final columns = [
      for (final status in ApplicationStatus.values)
        _StatusColumn(
          status: status,
          applications: controller.byStatus(status),
          controller: controller,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        children: [
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < columns.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(child: columns[i]),
                ],
              ],
            )
          else
            for (var i = 0; i < columns.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              columns[i],
            ],
          if (controller.hasMore) ...[
            const SizedBox(height: AppSpacing.lg),
            JoynButton(
              label: 'Charger plus',
              variant: JoynButtonVariant.secondary,
              expand: false,
              isLoading: controller.isLoadingMore,
              onPressed: controller.loadMore,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  const _StatusColumn({
    required this.status,
    required this.applications,
    required this.controller,
  });

  final ApplicationStatus status;
  final List<CandidateApplication> applications;
  final CandidateApplicationsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ColumnHeader(status: status, count: applications.length),
          const SizedBox(height: AppSpacing.md),
          if (applications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'Aucune candidature pour le moment.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ),
          for (final application in applications) ...[
            ApplicationCard(
              application: application,
              now: controller.now,
              isBusy: controller.openingId == application.id,
              onTap: () => openApplicationConversation(context, application),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({required this.status, required this.count});

  final ApplicationStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor(status),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            status.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.caption.copyWith(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
