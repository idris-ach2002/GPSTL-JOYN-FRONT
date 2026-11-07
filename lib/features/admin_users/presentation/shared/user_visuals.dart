import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../admin/presentation/shared/admin_ui.dart';
import '../../domain/admin_user.dart';

/// Badge de rôle : Candidat (bleu clair), Recruteur (orange), Admin (bleu nuit).
class RoleBadge extends StatelessWidget {
  const RoleBadge({required this.role, super.key});

  final AccountRole role;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (role) {
      AccountRole.candidate => (AppColors.skyTint, AppColors.navy),
      AccountRole.recruiter => (AppColors.orangeTint, AppColors.orangeDeep),
      AccountRole.admin => (const Color(0xFFE3E8EE), const Color(0xFF10212D)),
    };
    return AdminTag(
      label: role.label,
      background: background,
      foreground: foreground,
    );
  }
}

/// Badge de statut : Actif (vert), En attente (orange), Suspendu (rouge),
/// Banni (noir).
class AccountStatusBadge extends StatelessWidget {
  const AccountStatusBadge({required this.status, super.key});

  final AccountStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      AccountStatus.active => (AppColors.successTint, AppColors.successDeep),
      AccountStatus.pending => (AppColors.warningTint, AppColors.warningDeep),
      AccountStatus.suspended => (AppColors.errorTint, AppColors.errorDeep),
      AccountStatus.banned => (
        const Color(0xFFE5E7EB),
        const Color(0xFF111827),
      ),
    };
    return AdminTag(
      label: status.label,
      background: background,
      foreground: foreground,
    );
  }
}

/// Avatar : photo si disponible, sinon initiales sur fond pêche.
class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.user, this.radius = 20, super.key});

  final AdminUserAccount user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = user.avatarUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFFFE8CC),
      backgroundImage: url == null || url.isEmpty ? null : NetworkImage(url),
      child: url == null || url.isEmpty
          ? Text(
              user.initials,
              style: TextStyle(
                fontSize: radius * 0.72,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            )
          : null,
    );
  }
}

/// « il y a 3 j », « il y a 2 h », « jamais ».
String formatLastSeen(DateTime? date, {DateTime? now}) {
  if (date == null) return 'Jamais connecté·e';
  final diff = (now ?? DateTime.now()).difference(date);
  if (diff.inMinutes < 1) return 'À l’instant';
  if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
  if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
  if (diff.inDays < 30) return 'Il y a ${diff.inDays} j';
  return 'Il y a ${diff.inDays ~/ 30} mois';
}
