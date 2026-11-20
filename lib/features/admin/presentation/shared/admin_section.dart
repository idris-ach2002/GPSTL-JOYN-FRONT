import 'package:flutter/material.dart';

import '../../../../app/routing/app_routes.dart';

/// Rubriques de l'espace d'administration (uniquement celles qui existent).
enum AdminSection {
  candidates('Candidats', Icons.school_outlined, AppRoutes.adminCandidates),
  recruiters('Recruteurs', Icons.badge_outlined, AppRoutes.adminRecruiters),
  companies('Entreprises', Icons.apartment_rounded, AppRoutes.adminCompanies),
  verifications(
    'Vérifications',
    Icons.verified_user_outlined,
    AppRoutes.adminVerifications,
  );

  const AdminSection(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
