import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/admin_company.dart';

/// Badge de statut : orange (en attente), vert (validée), rouge (rejetée),
/// gris (suspendue).
class CompanyStatusBadge extends StatelessWidget {
  const CompanyStatusBadge({required this.status, super.key});

  final CompanyStatus status;

  static (Color, Color, IconData) colorsOf(CompanyStatus status) =>
      switch (status) {
        CompanyStatus.pending => (
          AppColors.warningTint,
          AppColors.warningDeep,
          Icons.schedule_rounded,
        ),
        CompanyStatus.approved => (
          AppColors.successTint,
          AppColors.successDeep,
          Icons.verified_outlined,
        ),
        CompanyStatus.rejected => (
          AppColors.errorTint,
          AppColors.errorDeep,
          Icons.block_rounded,
        ),
        CompanyStatus.suspended => (
          AppColors.track,
          AppColors.slateDark,
          Icons.pause_circle_outline_rounded,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = colorsOf(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status.label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: foreground, letterSpacing: 0),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo de l'entreprise : image, URL, ou initiales sur une pastille.
class CompanyLogoAvatar extends StatelessWidget {
  const CompanyLogoAvatar({
    required this.name,
    required this.initials,
    this.logo,
    this.size = 40,
    super.key,
  });

  final String name;
  final String initials;
  final CompanyLogo? logo;
  final double size;

  static const _palette = [
    Color(0xFFCDE8F6),
    Color(0xFFFFC7B0),
    Color(0xFFB7E3CB),
    Color(0xFFE6EDF1),
    Color(0xFFFDE68A),
  ];

  @override
  Widget build(BuildContext context) {
    final logo = this.logo;
    final bytes = logo?.bytes;
    final url = logo?.url;
    final ImageProvider? image = bytes != null
        ? MemoryImage(bytes)
        : (url != null && url.isNotEmpty ? NetworkImage(url) : null);

    return Semantics(
      label: 'Logo de $name',
      image: true,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _palette[name.hashCode.abs() % _palette.length],
          borderRadius: BorderRadius.circular(size * 0.25),
          image: image == null
              ? null
              : DecorationImage(image: image, fit: BoxFit.cover),
        ),
        child: image == null
            ? Text(
                initials,
                style: TextStyle(
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              )
            : null,
      ),
    );
  }
}

/// Bloc gris qui pulse, pour les squelettes de chargement.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    required this.width,
    this.height = 12,
    this.radius = 6,
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
String formatCompanyDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';
