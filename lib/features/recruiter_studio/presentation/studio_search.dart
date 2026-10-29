import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../recruiter_workspace/presentation/workspace_controller.dart';
import 'studio_controller.dart';
import 'studio_actions.dart';

Future<void> studioOpenSearch(BuildContext context, {GoRouter? router}) async {
  final navigation = router ?? GoRouter.of(context);
  final target = await showDialog<String>(
    context: context,
    builder: (_) => const _StudioSearchDialog(),
  );
  if (target == null || !context.mounted) return;
  if (target == 'task') {
    await studioEditTask(context);
  } else if (target == 'interview') {
    await studioEditInterview(context);
  } else {
    navigation.go(target);
  }
}

class _StudioSearchDialog extends StatefulWidget {
  const _StudioSearchDialog();
  @override
  State<_StudioSearchDialog> createState() => _StudioSearchDialogState();
}

class _StudioSearchDialogState extends State<_StudioSearchDialog> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final c = context.watch<StudioController?>();
    final workspace = context.watch<WorkspaceController?>();
    final entries =
        <({String label, String subtitle, String target, IconData icon})>[
              (
                label: 'Dashboard',
                subtitle: 'Indicateurs et prochaine action',
                target: '/recruiter/dashboard',
                icon: Icons.dashboard_outlined,
              ),
              (
                label: 'Offres',
                subtitle: 'Gérer vos recrutements',
                target: '/recruiter/jobs',
                icon: Icons.work_outline,
              ),
              (
                label: 'Créer une offre',
                subtitle: 'Démarrer une nouvelle opportunité',
                target: '/recruiter/jobs/new',
                icon: Icons.add_circle_outline,
              ),
              (
                label: 'Talents',
                subtitle: 'Profils recommandés et recherches enregistrées',
                target: '/recruiter/candidates',
                icon: Icons.people_outline,
              ),
              (
                label: 'Comparer les talents',
                subtitle: 'Jusqu’à trois profils',
                target: '/recruiter/compare',
                icon: Icons.compare_arrows,
              ),
              (
                label: 'Centre de travail',
                subtitle: 'Actions et relances',
                target: '/recruiter/planner',
                icon: Icons.task_alt,
              ),
              (
                label: 'Entretiens',
                subtitle: 'Agenda et exports calendrier',
                target: '/recruiter/planner?tab=1',
                icon: Icons.calendar_month_outlined,
              ),
              (
                label: 'Pipeline',
                subtitle: 'Les prochaines étapes de vos talents',
                target: '/recruiter/planner?tab=2',
                icon: Icons.view_kanban_outlined,
              ),
              (
                label: 'Notes privées',
                subtitle: 'Retrouver vos observations',
                target: '/recruiter/planner?tab=3',
                icon: Icons.sticky_note_2_outlined,
              ),
              (
                label: 'Messages',
                subtitle: 'Échanges avec les candidats',
                target: '/recruiter/messages',
                icon: Icons.chat_outlined,
              ),
              (
                label: 'Notifications',
                subtitle: 'Les actualités à suivre',
                target: '/recruiter/notifications',
                icon: Icons.notifications_outlined,
              ),
              (
                label: 'Profil et entreprise',
                subtitle: 'Présentation et marque employeur',
                target: '/recruiter/profile',
                icon: Icons.account_circle_outlined,
              ),
              (
                label: 'Paramètres',
                subtitle: 'Apparence, confidentialité et préférences',
                target: '/recruiter/settings',
                icon: Icons.tune,
              ),
              (
                label: 'Nouvelle action',
                subtitle: 'Créer une tâche ou une relance',
                target: 'task',
                icon: Icons.add_task,
              ),
              (
                label: 'Préparer un entretien',
                subtitle: 'Ajouter un créneau à votre agenda',
                target: 'interview',
                icon: Icons.event_available_outlined,
              ),
              for (final conversation
                  in workspace?.conversations ?? <Map<String, dynamic>>[])
                (
                  label: '${conversation['name']}',
                  subtitle:
                      'Conversation · ${conversation['offerTitle'] ?? ''}',
                  target: Uri(
                    path: '/recruiter/messages',
                    queryParameters: {
                      'candidateId': '${conversation['candidateId']}',
                      'name': '${conversation['name']}',
                    },
                  ).toString(),
                  icon: Icons.forum_outlined,
                ),
              for (final task in c?.list('tasks') ?? <Map<String, dynamic>>[])
                if (task['done'] != true)
                  (
                    label: '${task['title']}',
                    subtitle: 'Action à suivre',
                    target: '/recruiter/planner',
                    icon: Icons.task_alt,
                  ),
            ]
            .where(
              (v) => '${v.label} ${v.subtitle}'.toLowerCase().contains(_query),
            )
            .toList();
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
        width: 650,
        height: 560,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Une page, un talent, une action…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) =>
                    setState(() => _query = v.toLowerCase().trim()),
                onSubmitted: (_) {
                  if (entries.isNotEmpty) {
                    Navigator.pop(context, entries.first.target);
                  }
                },
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  if (entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Text('Aucun résultat. Essayez un autre mot.'),
                    ),
                  for (final e in entries)
                    ListTile(
                      leading: Icon(e.icon),
                      title: Text(e.label),
                      subtitle: Text(e.subtitle),
                      trailing: const Icon(Icons.north_east, size: 16),
                      onTap: () => Navigator.pop(context, e.target),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Entrée pour ouvrir · Échap pour fermer',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
