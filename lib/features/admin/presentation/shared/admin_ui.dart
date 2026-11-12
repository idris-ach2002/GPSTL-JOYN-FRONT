import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';

/// Bloc gris qui pulse, pour les squelettes de chargement.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    required this.width,
    this.height = 12,
    this.radius = 4,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_pulse),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.track,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Vue « accès refusé » (403).
class AdminForbiddenView extends StatelessWidget {
  const AdminForbiddenView({required this.onLeave, this.message, super.key});

  final VoidCallback onLeave;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.errorTint,
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 30,
                  color: AppColors.errorDeep,
                ),
              ),
              const SizedBox(height: 16),
              Text('Accès refusé', style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Erreur 403', style: textTheme.labelMedium),
              const SizedBox(height: 12),
              Text(
                message ?? 'Cette page est réservée aux administrateurs de la plateforme.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onLeave,
                child: const Text('Retour à mon espace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Notification (toast) après une action.
void showAdminToast(
  BuildContext context,
  String message, {
  bool error = false,
}) => showAdminToastWith(ScaffoldMessenger.of(context), message, error: error);

/// Variante à utiliser après un `await`, avec un messenger capturé avant.
void showAdminToastWith(
  ScaffoldMessengerState messenger,
  String message, {
  bool error = false,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.errorDeep : AppColors.textPrimary,
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: error ? AppColors.white : AppColors.success,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

/// Date courte : « 06/10/2026 ».
String formatAdminDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

// =============================================================================
// Mise en page sobre du back-office
// =============================================================================

/// Rayon des panneaux et des badges : discret, pour un rendu net.
const double adminRadius = 6;

/// Titre de page (sombre, compact) avec des actions à droite.
class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    required this.title,
    required this.subtitle,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(fontSize: 24),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
              ),
            ],
          ),
        ),
        for (final action in actions) ...[const SizedBox(width: 10), action],
      ],
    );
  }
}

/// Panneau blanc à bordure fine (sans ombre), pour les listes.
class AdminPanel extends StatelessWidget {
  const AdminPanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(adminRadius),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

/// Style commun des tableaux : lignes basses, séparateurs fins, en-tête
/// discrète sur fond clair.
class AdminTableTheme extends StatelessWidget {
  const AdminTableTheme({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        dividerTheme: const DividerThemeData(
          color: AppColors.lineSoft,
          thickness: 1,
          space: 1,
        ),
        dataTableTheme: DataTableThemeData(
          headingRowHeight: 40,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 58,
          horizontalMargin: 16,
          columnSpacing: 20,
          dividerThickness: 1,
          headingRowColor: const WidgetStatePropertyAll(AppColors.background),
          headingTextStyle: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.slate,
            fontSize: 11,
            letterSpacing: 0.4,
          ),
          dataTextStyle: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
          dataRowColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered)
                ? AppColors.background
                : null,
          ),
        ),
      ),
      child: child,
    );
  }
}

/// Champs plus compacts pour les barres de recherche et de filtres.
class AdminDenseFields extends StatelessWidget {
  const AdminDenseFields({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(fontSize: 13.5);
    final decoration = theme.inputDecorationTheme.copyWith(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      labelStyle: textStyle?.copyWith(color: AppColors.slate),
      hintStyle: textStyle?.copyWith(color: AppColors.placeholder),
    );
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: decoration,
        // Les menus déroulants reprennent les champs ci-dessus.
        dropdownMenuTheme: theme.dropdownMenuTheme.copyWith(
          textStyle: textStyle,
        ),
        textTheme: theme.textTheme.copyWith(bodyLarge: textStyle),
      ),
      child: child,
    );
  }
}

/// Badge rectangulaire : un point de couleur et un libellé.
class AdminTag extends StatelessWidget {
  const AdminTag({
    required this.label,
    required this.background,
    required this.foreground,
    super.key,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground,
                fontSize: 11.5,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pagination « 1–20 sur 64 · ‹ Page 1 / 4 › ».
class AdminPagination extends StatelessWidget {
  const AdminPagination({
    required this.firstIndex,
    required this.lastIndex,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.onPage,
    super.key,
  });

  final int firstIndex;
  final int lastIndex;
  final int total;
  final int page;
  final int totalPages;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$firstIndex–$lastIndex sur $total',
              style: textTheme.bodySmall,
            ),
          ),
          IconButton(
            tooltip: 'Page précédente',
            visualDensity: VisualDensity.compact,
            onPressed: page > 1 ? () => onPage(page - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
          ),
          Text('$page / $totalPages', style: textTheme.bodySmall),
          IconButton(
            tooltip: 'Page suivante',
            visualDensity: VisualDensity.compact,
            onPressed: page < totalPages ? () => onPage(page + 1) : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

/// Message centré (liste vide, erreur) avec une action facultative.
class AdminMessage extends StatelessWidget {
  const AdminMessage({
    required this.icon,
    required this.title,
    required this.text,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final action = this.action;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: AppColors.slate),
          const SizedBox(height: 10),
          Text(title, style: textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(text, textAlign: TextAlign.center, style: textTheme.bodySmall),
          if (action != null) ...[const SizedBox(height: 12), action],
        ],
      ),
    );
  }
}
