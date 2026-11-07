import 'package:flutter/material.dart';

import '../../../../app/routing/app_routes.dart';

/// Rubriques de l'espace d'administration.
enum AdminSection {
  dashboard('Tableau de bord', Icons.grid_view_rounded, null),
  users('Utilisateurs', Icons.group_outlined, AppRoutes.adminUsers),
  companies('Entreprises', Icons.apartment_rounded, AppRoutes.adminCompanies),
  moderation('Modération', Icons.flag_outlined, null),
  revenue('Revenus', Icons.payments_outlined, null);

  const AdminSection(this.label, this.icon, this.route);

  final String label;
  final IconData icon;

  /// `null` tant que la page n'existe pas (« arrive bientôt »).
  final String? route;
}
