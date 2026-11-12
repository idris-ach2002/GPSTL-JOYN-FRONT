import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/candidate_application.dart';

/// Couleur de la pastille d'un statut (en-têtes de colonnes, filtres).
Color statusColor(ApplicationStatus status) => switch (status) {
  ApplicationStatus.interested || ApplicationStatus.sent => AppColors.navy,
  ApplicationStatus.interview => AppColors.success,
  ApplicationStatus.rejected => AppColors.error,
};
