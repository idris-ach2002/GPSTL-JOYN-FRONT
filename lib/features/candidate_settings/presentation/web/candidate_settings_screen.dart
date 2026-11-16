import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../dashboard/presentation/web/widgets/dashboard_top_bar.dart';
import '../../../notifications/presentation/shared/notifications_panel.dart';
import '../../../profile/presentation/shared/profile_view_sections.dart';
import '../candidate_settings_controller.dart';
import '../shared/settings_sections.dart';

/// Page « Paramètres » du candidat (Web).
class WebCandidateSettingsScreen extends StatefulWidget {
  const WebCandidateSettingsScreen({super.key});

  @override
  State<WebCandidateSettingsScreen> createState() =>
      _WebCandidateSettingsScreenState();
}

class _WebCandidateSettingsScreenState
    extends State<WebCandidateSettingsScreen> {
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
      ..showSnackBar(
        SnackBar(content: Text(notice), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _signOut() async {
    await context.read<AuthController>().signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CandidateSettingsController>();
    final width = MediaQuery.sizeOf(context).width;
    final twoColumns = width >= 1100;

    final Widget body = switch (c.status) {
      SettingsStatus.loading => const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator(color: AppColors.white)),
      ),
      SettingsStatus.error => Center(
        child: Column(
          children: [
            const Text(
              'Impossible de charger tes paramètres.',
              style: TextStyle(color: AppColors.white),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: c.load, child: const Text('Réessayer')),
          ],
        ),
      ),
      SettingsStatus.ready when twoColumns => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              children: [
                SearchSection(),
                SizedBox(height: 20),
                VisibilitySection(),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                NotificationsSection(
                  onOpen: () => showNotificationsPanel(context, asSheet: false),
                ),
                const SizedBox(height: 20),
                AccountSection(onSignOut: _signOut),
              ],
            ),
          ),
        ],
      ),
      SettingsStatus.ready => Column(
        children: [
          const SearchSection(),
          const SizedBox(height: 20),
          const VisibilitySection(),
          const SizedBox(height: 20),
          NotificationsSection(
            onOpen: () => showNotificationsPanel(context, asSheet: false),
          ),
          const SizedBox(height: 20),
          AccountSection(onSignOut: _signOut),
        ],
      ),
    };

    return JoynMaterialScope(
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 560,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: profileHeroGradient),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardTopBar(
                          isWide: width >= 900,
                          activeTab: DashboardTab.settings,
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Paramètres',
                          style: TextStyle(
                            fontFamily: AppFonts.display,
                            color: AppColors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ta recherche, ta visibilité et tes notifications. '
                          'Ton parcours et tes compétences se modifient '
                          'depuis ton profil.',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 28),
                        body,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
