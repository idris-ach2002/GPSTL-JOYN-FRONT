import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../recruiter_dashboard/presentation/recruiter_dashboard_controller.dart';
import '../data/studio_export.dart';
import 'studio_export_dialog.dart';
import 'studio_components.dart';
import 'studio_controller.dart';

bool studioPanelVisible(BuildContext context, String key) =>
    !(context.watch<StudioController?>()?.preferences['dashboardHidden']
                as List? ??
            [])
        .contains(key);

class StudioDashboardToolbar extends StatelessWidget {
  const StudioDashboardToolbar({super.key});
  @override
  Widget build(BuildContext context) {
    final studio = context.watch<StudioController?>();
    if (studio == null) return const SizedBox.shrink();
    final c = context.watch<RecruiterDashboardController>();
    final data = c.overview;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: StudioCard(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PopupMenuButton<String>(
              tooltip: 'Personnaliser le dashboard',
              onSelected: (key) {
                final hidden = List<String>.from(
                  studio.preferences['dashboardHidden'] as List? ?? [],
                );
                hidden.contains(key) ? hidden.remove(key) : hidden.add(key);
                studio.setPreference('dashboardHidden', hidden);
              },
              itemBuilder: (_) => [
                for (final e in {
                  'actions': 'Mes prochaines actions',
                  'kpis': 'Indicateurs',
                  'charts': 'Graphiques et analyses',
                  'activity': 'Activité récente',
                  'offers': 'Top des offres',
                }.entries)
                  CheckedPopupMenuItem(
                    value: e.key,
                    checked:
                        !(studio.preferences['dashboardHidden'] as List? ?? [])
                            .contains(e.key),
                    child: Text(e.value),
                  ),
              ],
              child: const Chip(
                avatar: Icon(Icons.dashboard_customize_outlined, size: 17),
                label: Text('Personnaliser ma vue'),
              ),
            ),
            TextButton.icon(
              onPressed: data == null || c.isLoading
                  ? null
                  : () => studioExport(
                      context,
                      name: 'joyn-indicateurs-${c.period.queryValue}.csv',
                      extension: 'csv',
                      text: studioCsv([
                        ['Période', c.period.label],
                        ['Indicateur', 'Valeur', 'Variation (%)'],
                        for (final k in data.kpis)
                          [k.label, k.value, k.deltaPercent],
                        [],
                        [
                          'Date',
                          'Candidatures',
                          'Matches',
                          'Entretiens',
                          'Candidatures N-1',
                        ],
                        for (final p in data.trend)
                          [
                            studioDate(p.date.toIso8601String()),
                            p.applications,
                            p.matches,
                            p.interviews,
                            p.previousApplications,
                          ],
                      ]),
                    ),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Exporter les indicateurs'),
            ),
            TextButton.icon(
              onPressed: () =>
                  studio.setPreference('dashboardHidden', <String>[]),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Tout afficher'),
            ),
          ],
        ),
      ),
    );
  }
}
