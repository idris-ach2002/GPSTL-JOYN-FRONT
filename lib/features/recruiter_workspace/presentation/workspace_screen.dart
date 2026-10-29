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
      backgroundColor: const Color(0xFFF4F7F9),
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
                color: const Color(0xFFE9F2FA),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: const Text(
                  'Démonstration · vos modifications sont conservées pendant cette session.',
                  style: TextStyle(fontSize: 12, color: workspaceNavy),
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
                'notifications' => const _Notifications(),
                'profile' =>
                  controller.profile == null
                      ? const _Waiting()
                      : _Profile(
                          key: ValueKey(controller.profile),
                          value: controller.profile!,
                        ),
                _ =>
                  controller.settings == null
                      ? const _Waiting()
                      : _Settings(
                          key: ValueKey(controller.settings),
                          value: controller.settings!,
                        ),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE0E8EF)),
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

class _Settings extends StatefulWidget {
  const _Settings({super.key, required this.value});
  final Map<String, dynamic> value;
  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  late final Map<String, dynamic> _value = Map.from(widget.value);
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WorkspaceController>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: WorkspaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Vos préférences',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  for (final e in const {
                    'emailNotifications':
                        'Recevoir les notifications par e-mail',
                    'messageNotifications': 'Être averti des nouveaux messages',
                    'matchNotifications': 'Être averti des nouveaux matches',
                    'profileVisible':
                        'Rendre le profil entreprise visible aux candidats',
                  }.entries)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(e.value),
                      value: _value[e.key] == true,
                      onChanged: controller.busy
                          ? null
                          : (v) => setState(() => _value[e.key] = v),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.busy
                        ? null
                        : () async {
                            final ok = await controller.saveSettings(_value);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Préférences enregistrées.'
                                        : 'Impossible d’enregistrer.',
                                  ),
                                ),
                              );
                            }
                          },
                    child: const Text('Enregistrer les préférences'),
                  ),
                  const Divider(height: 40),
                  const Text(
                    'Compte et sécurité',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_reset),
                    title: const Text('Réinitialiser mon mot de passe'),
                    subtitle: const Text(
                      'Recevoir un lien à l’adresse du compte',
                    ),
                    onTap: () async {
                      final auth = context.read<AuthController>();
                      final ok = await auth.sendPasswordReset(auth.user!.email);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Demande de réinitialisation envoyée.'
                                  : auth.errorMessage ?? 'Échec de la demande.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout),
                    title: const Text('Se déconnecter'),
                    onTap: () async {
                      final yes = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Se déconnecter ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Annuler'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Se déconnecter'),
                            ),
                          ],
                        ),
                      );
                      if (yes == true && context.mounted) {
                        try {
                          await context.read<AuthController>().signOut();
                        } catch (_) {
                          /* La session locale est effacée même si le serveur ne répond pas. */
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Notifications extends StatefulWidget {
  const _Notifications();
  @override
  State<_Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<_Notifications> {
  bool _unreadOnly = false;
  @override
  Widget build(BuildContext context) {
    final c = context.watch<WorkspaceController>();
    final items = c.notifications
        .where((n) => !_unreadOnly || n['read'] != true)
        .toList();
    return RefreshIndicator(
      onRefresh: () async {
        await c.load('notifications');
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    children: [
                      FilterChip(
                        label: Text('Non lues (${c.unread})'),
                        selected: _unreadOnly,
                        onSelected: (v) => setState(() => _unreadOnly = v),
                      ),
                      TextButton.icon(
                        onPressed: c.busy || c.unread == 0 ? null : c.readAll,
                        icon: const Icon(Icons.done_all),
                        label: const Text('Tout marquer comme lu'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (items.isEmpty && !c.busy)
                    const WorkspaceCard(
                      child: Text(
                        'Vous êtes à jour. Aucune notification à afficher.',
                      ),
                    ),
                  for (final n in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: WorkspaceCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              n['kind'] == 'message'
                                  ? Icons.chat_bubble_outline
                                  : Icons.notifications_outlined,
                              color: n['read'] == true
                                  ? Colors.blueGrey
                                  : Colors.deepOrange,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${n['title']}',
                                    style: TextStyle(
                                      fontWeight: n['read'] == true
                                          ? FontWeight.w500
                                          : FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('${n['body'] ?? ''}'),
                                  const SizedBox(height: 6),
                                  Text(
                                    _date(n['createdAt']),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      TextButton(
                                        onPressed: c.busy
                                            ? null
                                            : () async {
                                                final ok = await c
                                                    .readNotification(
                                                      '${n['id']}',
                                                    );
                                                if (!context.mounted || !ok) {
                                                  return;
                                                }
                                                final target = '${n['target']}';
                                                final allowed = {
                                                  AppRoutes.recruiterMessages,
                                                  AppRoutes.recruiterCandidates,
                                                  AppRoutes.recruiterJobs,
                                                  AppRoutes.recruiterProfile,
                                                  AppRoutes.recruiterDashboard,
                                                };
                                                if (allowed.contains(target)) {
                                                  context.go(target);
                                                }
                                              },
                                        child: const Text('Ouvrir'),
                                      ),
                                      if (n['read'] != true)
                                        TextButton(
                                          onPressed: c.busy
                                              ? null
                                              : () => c.readNotification(
                                                  '${n['id']}',
                                                ),
                                          child: const Text('Marquer comme lu'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Supprimer la notification',
                              onPressed: c.busy
                                  ? null
                                  : () => c.deleteNotification('${n['id']}'),
                              icon: const Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _date(Object? value) {
    final d = DateTime.tryParse('$value')?.toLocal();
    return d == null
        ? ''
        : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
