import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/navigation/candidate_mobile_navigation.dart';
import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../notifications/presentation/shared/notifications_panel.dart';
import '../candidate_settings_controller.dart';
import '../shared/settings_sections.dart';

/// Page « Paramètres » du candidat (Mobile).
class MobileCandidateSettingsScreen extends StatefulWidget {
  const MobileCandidateSettingsScreen({super.key});

  @override
  State<MobileCandidateSettingsScreen> createState() =>
      _MobileCandidateSettingsScreenState();
}

class _MobileCandidateSettingsScreenState
    extends State<MobileCandidateSettingsScreen> {
  late final CandidateSettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<CandidateSettingsController>()
      ..addListener(_showNotice);
  }

  @override
  void dispose() {
    _controller.removeListener(_showNotice);
    super.dispose();
  }

  void _showNotice() {
    final notice = _controller.notice;
    if (notice == null || !mounted) return;
    _controller.notice = null;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(notice)));
  }

  Future<void> _signOut() async {
    await context.read<AuthController>().signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CandidateSettingsController>();
    final Widget body = switch (c.status) {
      SettingsStatus.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      SettingsStatus.error => Center(
        child: FilledButton(onPressed: c.load, child: const Text('Réessayer')),
      ),
      SettingsStatus.ready => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SearchSection(),
          const SizedBox(height: 14),
          const VisibilitySection(),
          const SizedBox(height: 14),
          NotificationsSection(
            onOpen: () => showNotificationsPanel(context, asSheet: true),
          ),
          const SizedBox(height: 14),
          AccountSection(onSignOut: _signOut),
        ],
      ),
    };

    return JoynMaterialScope(
      child: MobileAppSurface(
        backgroundColor: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Retour',
                    onPressed: () => context.go(AppRoutes.candidateProfile),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Text(
                    'Paramètres',
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      color: AppColors.navy,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
            const CandidateMobileNavigation(
              current: CandidateMobileTab.profile,
            ),
          ],
        ),
      ),
    );
  }
}
