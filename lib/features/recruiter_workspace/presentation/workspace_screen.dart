import '../../recruiter_studio/presentation/studio_settings.dart';
import '../../recruiter_studio/presentation/studio_notifications.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routing/app_routes.dart';
import '../../auth/presentation/auth_controller.dart';
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
      if (mounted) context.read<WorkspaceController>().load(widget.section);
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: compact
          ? AppBar(
              title: Text(title),
              leading: IconButton(
                tooltip: 'Dashboard',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(AppRoutes.recruiterDashboard),
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
                        style: const TextStyle(
                          color: workspaceNavy,
                          fontSize: 30,
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
                      : _Profile(
                          key: ValueKey(controller.profile),
                          value: controller.profile!,
                        ),
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

class _Profile extends StatefulWidget {
  const _Profile({super.key, required this.value});
  final Map<String, dynamic> value;
  @override
  State<_Profile> createState() => _ProfileState();
}

class _ProfileState extends State<_Profile> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  bool _dirty = false;
  static const labels = {
    'firstName': 'Prénom',
    'lastName': 'Nom',
    'jobTitle': 'Fonction',
    'phone': 'Téléphone professionnel',
    'companyName': 'Entreprise',
    'city': 'Ville',
    'website': 'Site internet',
    'description': 'Présentation de votre entreprise',
  };
  @override
  void initState() {
    super.initState();
    _fields = {
      for (final key in labels.keys)
        key: TextEditingController(text: '${widget.value[key] ?? ''}'),
    };
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WorkspaceController>();
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Quitter sans enregistrer ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Rester'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Quitter'),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) {
          setState(() => _dirty = false);
          context.go(AppRoutes.recruiterDashboard);
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: WorkspaceCard(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Votre identité professionnelle',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: workspaceNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.read<AuthController>().user?.email ?? '',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, box) => Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            for (final entry in labels.entries)
                              SizedBox(
                                width:
                                    box.maxWidth > 620 &&
                                        entry.key != 'description'
                                    ? (box.maxWidth - 20) / 2
                                    : box.maxWidth,
                                child: TextFormField(
                                  controller: _fields[entry.key],
                                  onChanged: (_) => _dirty = true,
                                  enabled: !controller.busy,
                                  maxLines: entry.key == 'description' ? 4 : 1,
                                  maxLength: entry.key == 'description'
                                      ? 2000
                                      : 200,
                                  keyboardType: entry.key == 'phone'
                                      ? TextInputType.phone
                                      : entry.key == 'website'
                                      ? TextInputType.url
                                      : TextInputType.text,
                                  decoration: InputDecoration(
                                    labelText: entry.value,
                                    border: const OutlineInputBorder(),
                                    counterText: '',
                                  ),
                                  validator: (v) {
                                    final text = (v ?? '').trim();
                                    if ([
                                          'firstName',
                                          'lastName',
                                          'companyName',
                                        ].contains(entry.key) &&
                                        text.isEmpty) {
                                      return 'Champ obligatoire';
                                    }
                                    if (entry.key == 'website' &&
                                        text.isNotEmpty) {
                                      final uri = Uri.tryParse(text);
                                      if (uri == null ||
                                          ![
                                            'https',
                                            'http',
                                          ].contains(uri.scheme) ||
                                          uri.host.isEmpty) {
                                        return 'URL complète attendue (https://…)';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: controller.busy
                            ? null
                            : () async {
                                if (!_form.currentState!.validate()) return;
                                final ok = await controller.saveProfile({
                                  for (final e in _fields.entries)
                                    e.key: e.value.text.trim(),
                                });
                                if (!context.mounted) return;
                                if (ok) _dirty = false;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok ? 'Profil enregistré.' : 'Enregistrement impossible. Vos champs sont conservés.',
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.check),
                        label: const Text('Enregistrer le profil'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
