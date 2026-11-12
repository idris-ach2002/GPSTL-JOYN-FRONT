import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../admin/presentation/shared/admin_ui.dart';
import '../../domain/admin_company.dart';

/// Badge de statut : orange (en attente), vert (validée), rouge (rejetée),
/// gris (suspendue).
class CompanyStatusBadge extends StatelessWidget {
  const CompanyStatusBadge({required this.status, super.key});

  final CompanyStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      CompanyStatus.pending => (AppColors.warningTint, AppColors.warningDeep),
      CompanyStatus.approved => (AppColors.successTint, AppColors.successDeep),
      CompanyStatus.rejected => (AppColors.errorTint, AppColors.errorDeep),
      CompanyStatus.suspended => (AppColors.track, AppColors.slateDark),
    };
    return AdminTag(
      label: status.label,
      background: background,
      foreground: foreground,
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
          borderRadius: BorderRadius.circular(size * 0.16),
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

/// Date courte : « 06/10/2026 ».
String formatCompanyDate(DateTime date) => formatAdminDate(date);
