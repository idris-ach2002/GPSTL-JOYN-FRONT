import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../dashboard/presentation/web/widgets/dashboard_top_bar.dart';
import '../../../profile/presentation/shared/profile_view_sections.dart';
import '../controllers/candidate_messages_controller.dart';
import '../shared/message_widgets.dart';

/// Page « Messages » du candidat (Web) : liste à gauche, fil à droite.
class WebCandidateMessagesScreen extends StatefulWidget {
  const WebCandidateMessagesScreen({super.key});

  @override
  State<WebCandidateMessagesScreen> createState() =>
      _WebCandidateMessagesScreenState();
}

class _WebCandidateMessagesScreenState
    extends State<WebCandidateMessagesScreen> {
  late final CandidateMessagesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<CandidateMessagesController>()
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CandidateMessagesController>();
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 900;
    final now = DateTime.now();
    final paneHeight = (size.height - 230).clamp(480.0, 900.0);

    Widget card(Widget child) => DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(24), child: child),
    );

    final selected = controller.selected;
    final Widget content = switch (controller.status) {
      MessagesStatus.loading => const Center(
        child: CircularProgressIndicator(color: AppColors.white),
      ),
      MessagesStatus.error => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.error ?? 'Erreur de chargement.',
              style: const TextStyle(color: AppColors.white),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: controller.load,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
      MessagesStatus.ready => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: wide ? 360 : 300,
            child: card(
              ThreadList(
                controller: controller,
                now: now,
                onOpen: (t) => controller.select(t.id),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: card(
              selected == null
                  ? const _NoSelection()
                  : ConversationPane(
                      controller: controller,
                      thread: selected,
                      now: now,
                      compact: !wide,
                      onViewOffer: () =>
                          context.go(AppRoutes.candidateApplications),
                    ),
            ),
          ),
        ],
      ),
    };

    return JoynMaterialScope(
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
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
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardTopBar(
                          isWide: size.width >= 900,
                          activeTab: DashboardTab.messages,
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Messages',
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
                          'Quand tu candidates, ton message et ton CV partent '
                          'tout de suite. Le chat se débloque dès que '
                          'l’entreprise te propose un entretien.',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(height: paneHeight, child: content),
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

class _NoSelection extends StatelessWidget {
  const _NoSelection();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 44, color: AppColors.cyanBlue),
            SizedBox(height: 12),
            Text(
              'Sélectionne une conversation',
              style: TextStyle(
                fontFamily: AppFonts.display,
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tes échanges avec les recruteurs apparaissent ici, liés à '
              'chaque candidature.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.body,
                color: AppColors.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
