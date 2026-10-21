import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/components/joyn_logo.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';

class RecruiterOffersTopBar extends StatelessWidget {
  const RecruiterOffersTopBar({super.key, this.active = RecruiterTopTab.offers});
  final RecruiterTopTab active;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showLabels = width >= 880;
    return Row(
      children: [
        const JoynLogo(onDark: true, markSize: 34),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .18),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text('Entreprise', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: Colors.white.withValues(alpha: .55)),
          ),
          child: Row(
            children: [
              _Tab(label: 'Dashboard', icon: Icons.grid_view_rounded, active: active == RecruiterTopTab.dashboard, showLabel: showLabels, onTap: () => context.go(AppRoutes.dashboard)),
              _Tab(label: 'Offres', icon: Icons.work_outline_rounded, active: active == RecruiterTopTab.offers, showLabel: showLabels, onTap: () => context.go(AppRoutes.recruiterJobs)),
              _Tab(label: 'Candidats', icon: Icons.badge_outlined, active: active == RecruiterTopTab.candidates, showLabel: showLabels, onTap: () {}),
            ],
          ),
        ),
        const Spacer(),
        for (final icon in [Icons.notifications_none_rounded, Icons.settings_outlined, Icons.chat_bubble_outline_rounded]) ...[
          _CircleButton(icon: icon),
          const SizedBox(width: 8),
        ],
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          child: Text('E', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}

enum RecruiterTopTab { dashboard, offers, candidates }

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.icon, required this.active, required this.showLabel, required this.onTap});
  final String label;
  final IconData icon;
  final bool active;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: active ? Colors.white : Colors.transparent,
    borderRadius: BorderRadius.circular(999),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: showLabel ? 16 : 12, vertical: 9),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: active ? AppColors.navy : Colors.white),
          if (showLabel) ...[
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: active ? AppColors.navy : Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ]),
      ),
    ),
  );
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () {},
    icon: Icon(icon, size: 19),
    color: Colors.white,
    style: IconButton.styleFrom(side: BorderSide(color: Colors.white.withValues(alpha: .55)), minimumSize: const Size.square(38)),
  );
}
