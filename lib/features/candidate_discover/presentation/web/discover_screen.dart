import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/feedback/coming_soon.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../dashboard/presentation/web/widgets/dashboard_top_bar.dart';
import '../../../profile/presentation/shared/profile_view_sections.dart';
import '../../domain/recommended_offer.dart';
import '../controllers/discover_controller.dart';
import '../shared/discover_formatters.dart';
import '../shared/discover_states.dart';
import '../shared/match_breakdown_card.dart';
import '../shared/offer_swipe_card.dart';
import '../shared/swipe_action_bar.dart';
import '../shared/swipe_deck.dart';

/// Page « Matchs » du candidat (Web) — CA82.
///
/// Pile de cartes au centre, détail du score à droite. Au clavier :
/// ← passer, → intéressé, ↑ sauvegarder, Retour arrière pour annuler.
class WebDiscoverScreen extends StatefulWidget {
  const WebDiscoverScreen({super.key});

  @override
  State<WebDiscoverScreen> createState() => _WebDiscoverScreenState();
}

class _WebDiscoverScreenState extends State<WebDiscoverScreen>
    with DiscoverSnackBarCleanup {
  final _deckKey = GlobalKey<SwipeDeckState>();
  final _focusNode = FocusNode(debugLabel: 'discover-shortcuts');

  /// Taille de la pile, calée sur la maquette.
  static const Size _deckSize = Size(440, 480);
  static const double _panelWidth = 270;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _swipe(SwipeDecision decision) => _deckKey.currentState?.swipe(decision);

  void _showDetails(RecommendedOffer offer) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: OfferDetailsView(offer: offer),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DiscoverController>();
    final width = MediaQuery.sizeOf(context).width;
    final sidePanel = width >= 980;

    return JoynMaterialScope(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              _swipe(SwipeDecision.interested),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              _swipe(SwipeDecision.skip),
          const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
              _swipe(SwipeDecision.save),
          const SingleActivator(LogicalKeyboardKey.backspace): () {
            if (controller.canUndo) undoDiscoverDecision(context, controller);
          },
        },
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          child: Scaffold(
            body: Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: profileHeroGradient),
                  ),
                ),
                // Mêmes marges que le Dashboard et « Mes candidatures », et
                // contenu calé en haut : la barre ne bouge pas pendant le
                // chargement.
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DashboardTopBar(
                              isWide: width >= 900,
                              activeTab: DashboardTab.offers,
                            ),
                            const SizedBox(height: 40),
                            _Heading(controller: controller),
                            const SizedBox(height: 40),
                            _body(controller, sidePanel),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(DiscoverController controller, bool sidePanel) {
    switch (controller.status) {
      case DiscoverStatus.loading:
        return SizedBox(
          height: _deckSize.height,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.white),
          ),
        );
      case DiscoverStatus.error:
        return SizedBox(
          height: _deckSize.height,
          child: DiscoverErrorState(
            message: controller.errorMessage ?? 'Erreur de chargement.',
            onRetry: controller.load,
            onDark: true,
          ),
        );
      case DiscoverStatus.ready:
        break;
    }

    final current = controller.current;
    if (current == null) {
      return SizedBox(
        height: _deckSize.height,
        child: DiscoverEmptyState(
          interestedCount: controller.interestedCount,
          onReload: controller.load,
          onUndo: controller.canUndo
              ? () => undoDiscoverDecision(context, controller)
              : null,
          onDark: true,
        ),
      );
    }

    final deck = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.fromSize(
          size: _deckSize,
          child: SwipeDeck(
            key: _deckKey,
            offers: controller.offers,
            onSwiped: (decision) =>
                applyDiscoverDecision(context, controller, decision),
            cardBuilder: (context, offer) => OfferSwipeCard(
              offer: offer,
              onViewDetails: () => _showDetails(offer),
            ),
          ),
        ),
        // Les boutons chevauchent le bas de la carte, comme sur la maquette.
        Transform.translate(
          offset: const Offset(0, -30),
          child: SwipeActionBar(
            onDecision: _swipe,
            onUndo: controller.canUndo
                ? () => undoDiscoverDecision(context, controller)
                : null,
          ),
        ),
      ],
    );

    final breakdown = SizedBox(
      width: _panelWidth,
      child: MatchBreakdownCard(
        offer: current,
        onSkillGap: () => showComingSoon(context, 'Le Skill Gap'),
      ),
    );

    if (!sidePanel) {
      return Column(
        children: [
          deck,
          SizedBox(width: _deckSize.width, child: breakdown),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [deck, const SizedBox(width: 24), breakdown],
    );
  }
}

/// Titre « Matchs », compteur et pastilles de préférences.
class _Heading extends StatelessWidget {
  const _Heading({required this.controller});

  final DiscoverController controller;

  @override
  Widget build(BuildContext context) {
    final filters = controller.filters;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Matchs',
          style: TextStyle(
            fontFamily: AppFonts.display,
            color: AppColors.white,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          controller.status == DiscoverStatus.ready
              ? compatibleOffersLabel(controller.offers.length)
              : 'Recherche des offres compatibles avec votre profil…',
          style: TextStyle(
            fontFamily: AppFonts.body,
            color: AppColors.white.withValues(alpha: 0.9),
            fontSize: 16,
          ),
        ),
      ],
    );

    final chips = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (filters.rhythm != null) _FilterPill(label: filters.rhythm!),
        if (filters.location != null) _FilterPill(label: filters.location!),
        FilledButton.icon(
          onPressed: () => showComingSoon(context, 'Les filtres'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.navy,
          ),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: const Text('Filtres'),
        ),
      ],
    );

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 16,
      spacing: 24,
      children: [title, chips],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
