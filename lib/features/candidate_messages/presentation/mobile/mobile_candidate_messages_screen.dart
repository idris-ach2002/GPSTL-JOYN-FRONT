import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/navigation/candidate_mobile_navigation.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../controllers/candidate_messages_controller.dart';
import '../shared/message_widgets.dart';

/// Page « Messages » du candidat (Mobile) : liste, puis fil en plein écran.
class MobileCandidateMessagesScreen extends StatefulWidget {
  const MobileCandidateMessagesScreen({super.key});

  @override
  State<MobileCandidateMessagesScreen> createState() =>
      _MobileCandidateMessagesScreenState();
}

class _MobileCandidateMessagesScreenState
    extends State<MobileCandidateMessagesScreen> {
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
      ..showSnackBar(SnackBar(content: Text(notice)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CandidateMessagesController>();
    final selected = controller.selected;
    final now = DateTime.now();

    final Widget body = switch (controller.status) {
      MessagesStatus.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      MessagesStatus.error => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(controller.error ?? 'Erreur de chargement.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: controller.load,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
      MessagesStatus.ready when selected != null => ColoredBox(
        color: AppColors.white,
        child: ConversationPane(
          controller: controller,
          thread: selected,
          now: now,
          compact: true,
          onBack: controller.unselect,
        ),
      ),
      MessagesStatus.ready => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Text(
              'Messages',
              style: TextStyle(
                fontFamily: AppFonts.display,
                color: AppColors.navy,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text(
              'Le chat se débloque dès que l’entreprise te propose un '
              'entretien.',
              style: TextStyle(
                fontFamily: AppFonts.body,
                color: AppColors.slate,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: ThreadList(
              controller: controller,
              now: now,
              onOpen: (t) => controller.select(t.id),
            ),
          ),
        ],
      ),
    };

    return JoynMaterialScope(
      child: PopScope(
        // Le bouton retour du téléphone revient d'abord à la liste.
        canPop: selected == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.unselect();
        },
        child: MobileAppSurface(
          backgroundColor: AppColors.background,
          child: Column(
            children: [
              Expanded(child: body),
              if (selected == null)
                CandidateMobileNavigation(
                  current: CandidateMobileTab.messages,
                  unreadMessages: controller.totalUnread,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
