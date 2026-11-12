import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../admin/presentation/shared/admin_ui.dart';
import '../../domain/company_verification.dart';

/// Badge du statut de vérification.
class VerificationStatusTag extends StatelessWidget {
  const VerificationStatusTag({required this.status, super.key});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      VerificationStatus.toReview => (
        AppColors.warningTint,
        AppColors.warningDeep,
      ),
      VerificationStatus.documentRequested => (
        AppColors.skyTint,
        AppColors.navy,
      ),
      VerificationStatus.verifiedAuto || VerificationStatus.verifiedManual => (
        AppColors.successTint,
        AppColors.successDeep,
      ),
      VerificationStatus.refused => (AppColors.errorTint, AppColors.errorDeep),
    };
    return AdminTag(
      label: status.label,
      background: background,
      foreground: foreground,
    );
  }
}

/// Badge du problème rencontré par la vérification automatique.
class VerificationIssueTag extends StatelessWidget {
  const VerificationIssueTag({required this.issue, super.key});

  final VerificationIssue issue;

  @override
  Widget build(BuildContext context) {
    final technical = issue == VerificationIssue.apiUnavailable;
    return AdminTag(
      label: issue.label,
      background: technical ? AppColors.track : AppColors.errorTint,
      foreground: technical ? AppColors.slateDark : AppColors.errorDeep,
    );
  }
}

/// Pastille carrée aux initiales de l'entreprise.
class VerificationLogo extends StatelessWidget {
  const VerificationLogo({required this.initials, this.size = 32, super.key});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.skyTint,
        borderRadius: BorderRadius.circular(size * 0.16),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

/// Un contrôle automatique : ✓ réussi, ✗ échoué, ? non vérifié.
class VerificationCheckRow extends StatelessWidget {
  const VerificationCheckRow({required this.check, super.key});

  final VerificationCheck check;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (icon, color, outcomeLabel) = switch (check.outcome) {
      CheckOutcome.passed => (
        Icons.check_circle_rounded,
        AppColors.successDeep,
        'réussi',
      ),
      CheckOutcome.failed => (
        Icons.cancel_rounded,
        AppColors.errorDeep,
        'échoué',
      ),
      CheckOutcome.unavailable => (
        Icons.help_rounded,
        AppColors.slate,
        'non vérifié',
      ),
    };
    return Semantics(
      label: '${check.label} : $outcomeLabel. ${check.detail}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    check.label,
                    style: textTheme.bodyMedium?.copyWith(fontSize: 13.5),
                  ),
                  if (check.detail.isNotEmpty)
                    Text(
                      check.detail,
                      style: textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// « il y a 3 h », « il y a 2 j ».
String formatVerificationAge(DateTime date, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(date);
  if (diff.inMinutes < 1) return 'à l’instant';
  if (diff.inHours < 1) return 'il y a ${diff.inMinutes} min';
  if (diff.inDays < 1) return 'il y a ${diff.inHours} h';
  return 'il y a ${diff.inDays} j';
}
