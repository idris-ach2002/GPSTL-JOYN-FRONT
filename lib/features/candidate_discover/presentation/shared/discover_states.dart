import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../domain/recommended_offer.dart';
import '../controllers/discover_controller.dart';
import 'discover_formatters.dart';
import 'match_breakdown_card.dart';
import 'offer_swipe_card.dart';

/// Applique un geste puis confirme (ou signale l'erreur) dans un SnackBar.
///
/// Partagé Web / Mobile pour que le retour soit identique des deux côtés.
/// [bottomOffset] remonte le message au-dessus d'une barre de navigation
/// posée dans le corps de la page (Mobile), pour ne pas la recouvrir.
/// [confirmSuccess] à `false` n'affiche que les erreurs : sur Mobile, le
/// message recouvrirait les boutons d'action pendant qu'on enchaîne les
/// cartes, et le tampon + le bouton « Annuler » suffisent comme retour.
Future<void> applyDiscoverDecision(
  BuildContext context,
  DiscoverController controller,
  SwipeDecision decision, {
  double bottomOffset = 0,
  bool confirmSuccess = true,
}) async {
  final offer = controller.current;
  if (offer == null) return;
  final messenger = ScaffoldMessenger.of(context);
  final ok = await controller.decide(decision);
  if (ok && !confirmSuccess) {
    messenger.hideCurrentSnackBar();
    return;
  }

  final message = ok
      ? switch (decision) {
          SwipeDecision.interested =>
            '${offer.company.name} ajoutée à vos candidatures « Intéressé ».',
          SwipeDecision.save => 'Offre sauvegardée.',
          SwipeDecision.skip => 'Offre ignorée.',
        }
      : controller.actionError ?? 'Une erreur est survenue.';

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: bottomOffset > 0
            ? EdgeInsets.fromLTRB(16, 0, 16, bottomOffset)
            : null,
        duration: const Duration(seconds: 3),
        action: ok
            ? SnackBarAction(label: 'Annuler', onPressed: controller.undo)
            : null,
      ),
    );
}

/// Contenu détaillé d'une offre (« Voir l'offre complète »).
class OfferDetailsView extends StatelessWidget {
  const OfferDetailsView({super.key, required this.offer});

  final RecommendedOffer offer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          offer.company.name,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            color: AppColors.slate,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          offer.title,
          style: const TextStyle(
            fontFamily: AppFonts.display,
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            if (offer.contractType.isNotEmpty)
              _Fact(Icons.work_outline_rounded, offer.contractType),
            for (final (icon, label) in offerFacts(offer)) _Fact(icon, label),
            if (offer.monthlySalary != null)
              _Fact(
                Icons.payments_outlined,
                formatSalary(offer.monthlySalary!),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          offer.description,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            color: AppColors.slateDark,
            fontSize: 15,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final skill in offer.skills) OfferSkillChip(skill: skill),
          ],
        ),
        const SizedBox(height: 20),
        MatchBreakdownCard(offer: offer, framed: false),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: AppColors.slate),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          fontFamily: AppFonts.body,
          color: AppColors.slate,
        ),
      ),
    ],
  );
}

/// Pile vide : toutes les offres du jour ont été traitées.
class DiscoverEmptyState extends StatelessWidget {
  const DiscoverEmptyState({
    super.key,
    required this.interestedCount,
    required this.onReload,
    this.onUndo,
    this.onDark = false,
  });

  final int interestedCount;
  final VoidCallback onReload;
  final VoidCallback? onUndo;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final title = onDark ? AppColors.white : AppColors.textPrimary;
    final body = onDark
        ? AppColors.white.withValues(alpha: 0.8)
        : AppColors.slate;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.orangeTint,
              child: Icon(
                Icons.done_all_rounded,
                color: AppColors.orange,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vous avez tout vu pour aujourd’hui',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.display,
                color: title,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              interestedCount == 0
                  ? 'De nouvelles offres compatibles arrivent chaque jour.'
                  : interestedCount == 1
                  ? '1 offre à envoyer depuis « Mes candidatures ». De nouvelles '
                        'offres arrivent '
                        'chaque jour.'
                  : '$interestedCount offres à envoyer depuis « Mes candidatures ». '
                        'De nouvelles offres '
                        'arrivent chaque jour.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.body,
                color: body,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                if (onUndo != null)
                  OutlinedButton.icon(
                    onPressed: onUndo,
                    icon: const Icon(Icons.undo_rounded),
                    label: const Text('Revoir la dernière'),
                  ),
                FilledButton.icon(
                  onPressed: onReload,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Actualiser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Erreur de chargement de la pile.
class DiscoverErrorState extends StatelessWidget {
  const DiscoverErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.onDark = false,
  });

  final String message;
  final VoidCallback onRetry;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 40,
            color: onDark ? AppColors.white : AppColors.slate,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.body,
              color: onDark ? AppColors.white : AppColors.slate,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}

/// Annule le dernier geste et retire le message de confirmation devenu faux.
Future<void> undoDiscoverDecision(
  BuildContext context,
  DiscoverController controller,
) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  return controller.undo();
}

/// Retire, en quittant « Matchs », le message dont le bouton « Annuler »
/// n'aurait plus d'effet visible sur la page suivante.
mixin DiscoverSnackBarCleanup<T extends StatefulWidget> on State<T> {
  ScaffoldMessengerState? _messenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    _messenger?.hideCurrentSnackBar();
    super.dispose();
  }
}
