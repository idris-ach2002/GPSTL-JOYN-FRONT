import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../domain/candidate_application.dart';
import '../candidate_applications_controller.dart';
import '../shared/application_card.dart';
import '../shared/application_formatters.dart';
import '../shared/open_conversation.dart';
import '../shared/status_color.dart';

/// « Mes candidatures », version mobile : filtres par statut puis liste.
class MobileCandidateApplicationsScreen extends StatefulWidget {
  const MobileCandidateApplicationsScreen({super.key});

  @override
  State<MobileCandidateApplicationsScreen> createState() =>
      _MobileCandidateApplicationsScreenState();
}

class _MobileCandidateApplicationsScreenState
    extends State<MobileCandidateApplicationsScreen> {
  /// `null` = tous les statuts.
  ApplicationStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CandidateApplicationsController>();
    final visible = _filter == null
        ? controller.items
        : controller.byStatus(_filter!);

    return MobileAppSurface(
      child: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const _Header(),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Mes candidatures',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ApplicationFormatters.summary(
                applications: controller.totalItems,
                interviews: controller.interviewsThisWeek,
              ),
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            _Filters(
              controller: controller,
              selected: _filter,
              onSelected: (status) => setState(() => _filter = status),
            ),
            const SizedBox(height: AppSpacing.md),
            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.errorMessage != null)
              _Message(
                text: controller.errorMessage!,
                action: TextButton(
                  onPressed: controller.load,
                  child: const Text('Réessayer'),
                ),
              )
            else if (visible.isEmpty)
              const _Message(text: 'Aucune candidature pour le moment.')
            else
              for (final application in visible) ...[
                ApplicationCard(
                  application: application,
                  now: controller.now,
                  isBusy: controller.openingId == application.id,
                  onTap: () =>
                      openApplicationConversation(context, application),
                ),
                const SizedBox(height: 12),
              ],
            if (controller.hasMore && !controller.isLoading)
              Center(
                child: TextButton(
                  onPressed: controller.isLoadingMore
                      ? null
                      : controller.loadMore,
                  child: Text(
                    controller.isLoadingMore ? 'Chargement…' : 'Charger plus',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Retour au dashboard, logo et avatar du compte connecté.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthController>().user?.email;
    final initials = (email == null || email.isEmpty)
        ? '?'
        : email.substring(0, 1).toUpperCase();

    return Row(
      children: [
        IconButton(
          tooltip: 'Retour',
          onPressed: () => context.go(AppRoutes.dashboard),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const MobileBrandMark(compact: true),
        const Spacer(),
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.navy,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.controller,
    required this.selected,
    required this.onSelected,
  });

  final CandidateApplicationsController controller;
  final ApplicationStatus? selected;
  final ValueChanged<ApplicationStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, ApplicationStatus? status, int count) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: ChoiceChip(
          selected: selected == status,
          onSelected: (_) => onSelected(status),
          avatar: status == null
              ? null
              : CircleAvatar(radius: 4, backgroundColor: statusColor(status)),
          label: Text('$label ($count)'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Toutes', null, controller.items.length),
          for (final status in ApplicationStatus.values)
            chip(status.label, status, controller.byStatus(status).length),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Text(text, textAlign: TextAlign.center, style: AppTextStyles.muted),
          ?action,
        ],
      ),
    );
  }
}
