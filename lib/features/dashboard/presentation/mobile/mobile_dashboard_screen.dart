import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/mobile/mobile_bottom_navigation.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/candidate_profile.dart';
import '../dashboard_controller.dart';

class MobileDashboardScreen extends StatefulWidget {
  const MobileDashboardScreen({super.key});

  @override
  State<MobileDashboardScreen> createState() => _MobileDashboardScreenState();
}

class _MobileDashboardScreenState extends State<MobileDashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final profile = controller.profile ?? const CandidateProfile();

    return MobileAppSurface(
      backgroundColor: const Color(0xFFF7F8F2),
      child: Column(
        children: [
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: controller.load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                      children: [
                        const _DashboardHeader(),
                        const SizedBox(height: 26),
                        Text(
                          _tab == 0 ? 'Bonjour 👋' : _tabTitle(_tab),
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 30,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tab == 0
                              ? 'Voici le profil qui mérite ton attention aujourd’hui.'
                              : 'Cette section est prête pour le branchement de la donnée réelle.',
                          style: const TextStyle(
                            color: AppColors.slate,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (_tab == 0) ...[
                          _CandidateMatchCard(profile: profile),
                          const SizedBox(height: 16),
                          const _QuickActions(),
                          const SizedBox(height: 16),
                          _MatchReasons(profile: profile),
                        ] else
                          const _ComingSection(),
                      ],
                    ),
                  ),
          ),
          MobileBottomNavigation(
            selectedIndex: _tab,
            onSelected: (index) => setState(() => _tab = index),
            items: const [
              MobileNavItem(icon: Icons.home_rounded, label: 'Accueil'),
              MobileNavItem(icon: Icons.search_rounded, label: 'Talents'),
              MobileNavItem(icon: Icons.work_rounded, label: 'Offres'),
              MobileNavItem(icon: Icons.chat_bubble_rounded, label: 'Messages'),
              MobileNavItem(icon: Icons.person_rounded, label: 'Profil'),
            ],
          ),
        ],
      ),
    );
  }

  String _tabTitle(int index) => switch (index) {
    1 => 'Talents',
    2 => 'Tes offres',
    3 => 'Messages',
    _ => 'Profil entreprise',
  };
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const MobileBrandMark(compact: true),
      const Spacer(),
      IconButton.filledTonal(
        onPressed: () {},
        icon: const Icon(Icons.notifications_none_rounded),
      ),
      const SizedBox(width: 6),
      const CircleAvatar(
        radius: 19,
        backgroundColor: AppColors.navy,
        child: Text(
          'CM',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ],
  );
}

class _CandidateMatchCard extends StatelessWidget {
  const _CandidateMatchCard({required this.profile});
  final CandidateProfile profile;

  @override
  Widget build(BuildContext context) {
    final score = profile.matchScore ?? 92;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, Color(0xFF0B3A67)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE7F3FF),
                child: Text(
                  profile.initials ?? 'AD',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName ?? 'Alex Dupont',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.headline ?? 'Développeur Full-Stack',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFBED1E2),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$score%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            profile.offerTitle ?? 'Développeur·se Full-Stack',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            [
              profile.school ?? 'Sorbonne Université',
              profile.location ?? 'Paris',
            ].join(' · '),
            style: const TextStyle(
              color: Color(0xFFBED1E2),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ActionCard(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Contacter',
          onTap: () {},
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _ActionCard(
          icon: Icons.description_outlined,
          label: 'Voir le CV',
          onTap: () {},
        ),
      ),
    ],
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.orange, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MatchReasons extends StatelessWidget {
  const _MatchReasons({required this.profile});
  final CandidateProfile profile;
  @override
  Widget build(BuildContext context) {
    final reasons =
        profile.matchHighlights ??
        ['Stack compatible', 'Rythme adapté', 'Localisation cohérente'];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pourquoi ça matche',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          for (final reason in reasons.take(4)) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(
                      color: AppColors.slate,
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ComingSection extends StatelessWidget {
  const _ComingSection();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
    ),
    child: const Column(
      children: [
        Icon(Icons.auto_awesome_rounded, color: AppColors.orange, size: 34),
        SizedBox(height: 12),
        Text(
          'Interface mobile prête',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'La navigation est séparée du web et peut maintenant recevoir les données de chaque feature.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.slate, fontSize: 12, height: 1.4),
        ),
      ],
    ),
  );
}
