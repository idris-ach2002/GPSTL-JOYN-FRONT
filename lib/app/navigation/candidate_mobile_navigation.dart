import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/mobile/mobile_bottom_navigation.dart';
import '../routing/app_routes.dart';

/// Onglets de la barre du bas de l'espace candidat (Mobile).
enum CandidateMobileTab { matches, home, applications, messages, profile }

/// Barre du bas commune aux écrans candidat Mobile.
class CandidateMobileNavigation extends StatelessWidget {
  const CandidateMobileNavigation({
    super.key,
    required this.current,
    this.unreadMessages = 0,
  });

  final CandidateMobileTab current;

  /// Pastille sur l'onglet Messages (non affichée à 0).
  final int unreadMessages;

  static const Map<CandidateMobileTab, String> _routes = {
    CandidateMobileTab.matches: AppRoutes.candidateDiscover,
    CandidateMobileTab.home: AppRoutes.dashboard,
    CandidateMobileTab.applications: AppRoutes.candidateApplications,
    CandidateMobileTab.messages: AppRoutes.candidateMessages,
    CandidateMobileTab.profile: AppRoutes.candidateProfile,
  };

  @override
  Widget build(BuildContext context) {
    return MobileBottomNavigation(
      selectedIndex: current.index,
      onSelected: (index) {
        final tab = CandidateMobileTab.values[index];
        if (tab != current) context.go(_routes[tab]!);
      },
      items: [
        const MobileNavItem(icon: Icons.style_rounded, label: 'Matchs'),
        const MobileNavItem(icon: Icons.grid_view_rounded, label: 'Accueil'),
        const MobileNavItem(icon: Icons.article_rounded, label: 'Candidatures'),
        MobileNavItem(
          icon: Icons.chat_bubble_rounded,
          label: unreadMessages > 0 ? 'Messages ($unreadMessages)' : 'Messages',
        ),
        const MobileNavItem(icon: Icons.person_rounded, label: 'Profil'),
      ],
    );
  }
}
