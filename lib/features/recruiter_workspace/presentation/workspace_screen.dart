import '../../recruiter_studio/presentation/studio_components.dart';
import '../../recruiter_studio/presentation/studio_controller.dart';
import '../../recruiter_studio/presentation/studio_profile.dart';
import '../../recruiter_studio/presentation/studio_settings.dart';
import '../../recruiter_studio/presentation/studio_notifications.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routing/app_routes.dart';
import '../../recruiter_offers/presentation/web/recruiter_offers_top_bar.dart';
import 'workspace_controller.dart';
import 'workspace_messages.dart';

const workspaceNavy = Color(0xFF001E3B);

class RecruiterWorkspaceScreen extends StatefulWidget {
  const RecruiterWorkspaceScreen({
    super.key,
    required this.section,
    this.candidateId,
    this.candidateName,
    this.mobile = false,
  });
  final String section;
  final String? candidateId;
  final String? candidateName;
  final bool mobile;
  @override
  State<RecruiterWorkspaceScreen> createState() =>
      _RecruiterWorkspaceScreenState();
}

class _RecruiterWorkspaceScreenState extends State<RecruiterWorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = context.read<WorkspaceController>();
      if (c.repository.isMock || widget.section == 'profile') c.load(widget.section);
    });
  }

  @override
  void didUpdateWidget(covariant RecruiterWorkspaceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section) _load();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WorkspaceController>();
    final compact = widget.mobile || MediaQuery.sizeOf(context).width < 760;
    final title = switch (widget.section) {
      'profile' => 'Mon profil recruteur',
      'notifications' => 'Notifications',
      'messages' => 'Messagerie',
      _ => 'Paramètres',
    };
    if (!controller.repository.isMock && widget.section != 'profile') {
      return Scaffold(appBar: AppBar(title: Text(title), leading: BackButton(
        onPressed: () => context.go(AppRoutes.recruiterDashboard))),
        body: const Center(child: Text('Cette rubrique attend son raccordement au serveur.')));
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: compact
          ? AppBar(
              title: Text(title),
              leading: IconButton(
                tooltip: widget.section == 'settings' ? 'Retour' : 'Dashboard',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  final back = context.read<StudioController?>()?.settingsBack;
                  if (widget.section == 'settings' && back != null) {
                    back();
                  } else {
                    context.go(AppRoutes.recruiterDashboard);
                  }
                },
              ),
              actions: [
                IconButton(
                  tooltip: 'Mon profil',
                  onPressed: () => context.go(AppRoutes.recruiterProfile),
                  icon: const Icon(Icons.account_circle_outlined),
                ),
              ],
            )
          : null,
      bottomNavigationBar: compact
          ? NavigationBar(
              selectedIndex: widget.section == 'messages' ? 3 : 4,
              onDestinationSelected: (i) => context.go(
                [
                  AppRoutes.recruiterDashboard,
                  AppRoutes.recruiterCandidates,
                  AppRoutes.recruiterJobs,
                  AppRoutes.recruiterMessages,
                  AppRoutes.recruiterSettings,
                ][i],
              ),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  label: 'Talents',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline),
                  label: 'Offres',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_outlined),
                  label: 'Messages',
                ),
                NavigationDestination(icon: Icon(Icons.tune), label: 'Plus'),
              ],
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (!compact)
              Container(
                color: workspaceNavy,
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 22,
                ),
                child: const RecruiterOffersTopBar(
                  active: RecruiterTopTab.workspace,
                ),
              ),
            if (controller.repository.isMock)
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Espace de démonstration',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const StudioLoadNotice(showSaving: false),
            if (controller.busy) const LinearProgressIndicator(minHeight: 2),
            if (controller.error != null)
              MaterialBanner(
                content: Text(controller.error!),
                actions: [
                  TextButton(
                    onPressed: controller.busy
                        ? null
                        : () => controller.load(widget.section),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            if (!compact)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'BricolageGrotesque',
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: controller.busy
                          ? null
                          : () => controller.load(widget.section),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualiser'),
                    ),
                  ],
                ),
              ),
            if (widget.section != 'messages')
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final entry in const {
                      'profile': 'Profil et entreprise',
                      'notifications': 'Notifications',
                      'messages': 'Messages',
                      'settings': 'Paramètres',
                    }.entries)
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: ChoiceChip(
                          label: Text(entry.value),
                          selected: widget.section == entry.key,
                          onSelected: (_) =>
                              context.go('/recruiter/${entry.key}'),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: switch (widget.section) {
                'messages' => WorkspaceMessages(
                  key: ValueKey(widget.candidateId),
                  candidateId: widget.candidateId,
                  candidateName: widget.candidateName,
                ),
                'notifications' => const StudioNotifications(),
                'profile' =>
                  controller.profile == null
                      ? const _Waiting()
                      : StudioProfile(value: controller.profile!),
                _ => const StudioSettings(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting();
  @override
  Widget build(BuildContext context) => Center(
    child: context.watch<WorkspaceController>().busy
        ? const CircularProgressIndicator()
        : const Text('Aucune donnée chargée.'),
  );
}

class WorkspaceCard extends StatelessWidget {
  const WorkspaceCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Material(color: Colors.transparent, child: child),
  );
}
