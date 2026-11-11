import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/feedback/coming_soon.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/mobile/mobile_bottom_navigation.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../domain/recommended_offer.dart';
import '../controllers/discover_controller.dart';
import '../shared/discover_formatters.dart';
import '../shared/discover_states.dart';
import '../shared/match_breakdown_card.dart';
import '../shared/offer_swipe_card.dart';
import '../shared/swipe_action_bar.dart';
import '../shared/swipe_deck.dart';

/// Page « Matchs » du candidat (Mobile) — CA82.
///
/// La pile occupe tout l'écran ; le détail du score s'ouvre dans une
/// bottom sheet.
class MobileDiscoverScreen extends StatefulWidget {
  const MobileDiscoverScreen({super.key});

  @override
  State<MobileDiscoverScreen> createState() => _MobileDiscoverScreenState();
}

class _MobileDiscoverScreenState extends State<MobileDiscoverScreen>
    with DiscoverSnackBarCleanup {
  final _deckKey = GlobalKey<SwipeDeckState>();

  void _swipe(SwipeDecision decision) => _deckKey.currentState?.swipe(decision);

  void _showSheet(Widget child) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: child,
        ),
      ),
    );
  }

  void _onNavSelected(int index) {
    switch (index) {
      case 1:
        context.go(AppRoutes.dashboard);
      case 2:
        context.go(AppRoutes.candidateApplications);
      case 3:
        context.go(AppRoutes.candidateProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DiscoverController>();

    return JoynMaterialScope(
      child: MobileAppSurface(
        backgroundColor: AppColors.background,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Header(),
                    const SizedBox(height: 18),
                    _Heading(controller: controller),
                    const SizedBox(height: 14),
                    Expanded(child: _body(controller)),
                  ],
                ),
              ),
            ),
            MobileBottomNavigation(
              selectedIndex: 0,
              onSelected: _onNavSelected,
              items: const [
                MobileNavItem(icon: Icons.style_rounded, label: 'Matchs'),
                MobileNavItem(icon: Icons.grid_view_rounded, label: 'Accueil'),
                MobileNavItem(
                  icon: Icons.article_rounded,
                  label: 'Candidatures',
                ),
                MobileNavItem(icon: Icons.person_rounded, label: 'Profil'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(DiscoverController controller) {
    switch (controller.status) {
      case DiscoverStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case DiscoverStatus.error:
        return DiscoverErrorState(
          message: controller.errorMessage ?? 'Erreur de chargement.',
          onRetry: controller.load,
        );
      case DiscoverStatus.ready:
        break;
    }

    final current = controller.current;
    if (current == null) {
      return DiscoverEmptyState(
        interestedCount: controller.interestedCount,
        onReload: controller.load,
        onUndo: controller.canUndo
            ? () => undoDiscoverDecision(context, controller)
            : null,
      );
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            // Place pour les cartes du dessous qui dépassent en haut.
            padding: const EdgeInsets.only(top: 22),
            child: SwipeDeck(
              key: _deckKey,
              offers: controller.offers,
              stackOffset: 10,
              onSwiped: (decision) => applyDiscoverDecision(
                context,
                controller,
                decision,
                // Barre de navigation du bas (68 px) + marge.
                bottomOffset: 76 + MediaQuery.paddingOf(context).bottom,
                confirmSuccess: false,
              ),
              cardBuilder: (context, offer) => OfferSwipeCard(
                offer: offer,
                compact: true,
                onViewDetails: () => _showSheet(OfferDetailsView(offer: offer)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => _showSheet(
            MatchBreakdownCard(
              offer: current,
              framed: false,
              onSkillGap: () => showComingSoon(context, 'Le Skill Gap'),
            ),
          ),
          icon: const Icon(Icons.insights_rounded, size: 18),
          label: Text('Pourquoi ${current.compatibility} % ?'),
        ),
        const SizedBox(height: 4),
        SwipeActionBar(
          scale: 0.9,
          onDecision: _swipe,
          onUndo: controller.canUndo
              ? () => undoDiscoverDecision(context, controller)
              : null,
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const MobileBrandMark(compact: true),
      const Spacer(),
      IconButton.filledTonal(
        tooltip: 'Notifications',
        onPressed: () => showComingSoon(context, 'Les notifications'),
        icon: const Badge(
          smallSize: 8,
          backgroundColor: AppColors.orange,
          child: Icon(Icons.notifications_none_rounded),
        ),
      ),
      IconButton.filledTonal(
        tooltip: 'Messages',
        onPressed: () => showComingSoon(context, 'La messagerie'),
        icon: const Icon(Icons.chat_bubble_outline_rounded),
      ),
    ],
  );
}

class _Heading extends StatelessWidget {
  const _Heading({required this.controller});

  final DiscoverController controller;

  @override
  Widget build(BuildContext context) {
    final filters = controller.filters;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Matchs',
          style: TextStyle(
            fontFamily: AppFonts.display,
            color: AppColors.navy,
            fontSize: 30,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          controller.status == DiscoverStatus.ready
              ? compatibleOffersLabel(controller.offers.length)
              : 'Recherche des offres compatibles…',
          style: const TextStyle(
            fontFamily: AppFonts.body,
            color: AppColors.slate,
            fontSize: 13,
          ),
        ),
        if (filters.rhythm != null || filters.location != null) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final label in [filters.rhythm, filters.location])
                  if (label != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(label),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ActionChip(
                  avatar: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text('Filtres'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => showComingSoon(context, 'Les filtres'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
