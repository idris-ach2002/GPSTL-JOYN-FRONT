import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routing/app_routes.dart';
import '../../recruiter_dashboard/data/recruiter_dashboard_repository.dart';
import '../../recruiter_dashboard/domain/recruiter_dashboard_models.dart';
import '../../recruiter_dashboard/presentation/shared/analytics_charts.dart';
import '../../recruiter_offers/data/api_recruiter_offers_repository.dart';
import '../../recruiter_offers/data/recruiter_offers_repository.dart';
import '../../recruiter_offers/presentation/shared/offer_ui.dart';
import 'application_panel.dart';
import 'workspace_controller.dart';

/// One responsive, read-only view for existing API offers on web and mobile.
/// Missing job fields are never inferred from dashboard summaries.
class ConnectedOfferSummary extends StatefulWidget {
  const ConnectedOfferSummary({super.key, required this.offerId});
  final int offerId;

  @override
  State<ConnectedOfferSummary> createState() => _ConnectedOfferSummaryState();
}

class _ConnectedOfferSummaryState extends State<ConnectedOfferSummary> {
  late Future<OfferAnalyticsData> _analytics;
  late Future<Map<String, dynamic>> _context;
  int _revision = 0;
  final _applicantsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _analytics = context
        .read<RecruiterDashboardRepository>()
        .fetchOfferAnalytics(widget.offerId, DashboardPeriod.all);
    final repo = context.read<RecruiterOffersRepository>();
    _context = repo is ApiRecruiterOffersRepository
        ? repo
              .fetchOfferContext(widget.offerId)
              .catchError(
                (Object error) => <String, dynamic>{'unavailable': true},
              )
        : Future.value(<String, dynamic>{});
  }

  void _refresh() => setState(() {
    _revision++;
    _load();
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Détail de l’offre'),
      leading: BackButton(onPressed: () => context.go(AppRoutes.recruiterJobs)),
      actions: [
        IconButton(
          onPressed: _refresh,
          tooltip: 'Actualiser',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<OfferAnalyticsData>(
      future: _analytics,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Impossible de charger cette offre pour ce compte.',
                  ),
                  TextButton(
                    onPressed: _refresh,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.requireData;
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 16 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _hero(data, compact),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, box) {
                            final columns = box.maxWidth < 520
                                ? 2
                                : box.maxWidth < 950
                                ? 3
                                : 5;
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                for (final kpi in data.kpis)
                                  SizedBox(
                                    width:
                                        (box.maxWidth - 12 * (columns - 1)) /
                                        columns,
                                    child: _card(
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            kpi.value,
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(kpi.label),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _context,
                          builder: (context, details) =>
                              _information(data, details, compact),
                        ),
                        const SizedBox(height: 20),
                        _card(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _title('Compétences recherchées'),
                              const Text(
                                'Part des candidats possédant chaque compétence demandée par l’offre.',
                              ),
                              const SizedBox(height: 16),
                              if (data.skills.isEmpty)
                                const Text(
                                  'Aucune compétence transmise pour cette offre.',
                                ),
                              for (final skill in data.skills)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: Text(skill.label)),
                                          Text(
                                            '${skill.value.toStringAsFixed(0)} %',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      LinearProgressIndicator(
                                        value: (skill.value / 100).clamp(
                                          0.0,
                                          1.0,
                                        ),
                                        minHeight: 6,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _card(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _title('Suivi des candidatures'),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final step in data.pipeline)
                                    Chip(
                                      label: Text(
                                        '${step.label} · ${step.value.toStringAsFixed(0)}',
                                      ),
                                    ),
                                ],
                              ),
                              if (data.pipeline.isEmpty)
                                const Text('Aucune étape disponible.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          key: _applicantsKey,
                          child: _card(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _title('Les candidats à cette offre'),
                                const Text(
                                  'Consultez les profils, leur adéquation et leur statut, puis contactez-les dans JOYN.',
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: compact ? 520 : 600,
                                  child: ApplicationPanel(
                                    key: ValueKey(
                                      '${widget.offerId}/$_revision',
                                    ),
                                    repository: context
                                        .read<WorkspaceController>()
                                        .repository,
                                    jobId: widget.offerId,
                                    embedded: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _card(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _title('Évolution des candidatures'),
                              const Text('Toutes les périodes disponibles'),
                              const SizedBox(height: 16),
                              InteractiveMultiSeriesChart(
                                points: data.trend,
                                height: compact ? 240 : 300,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _card(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _title('Origine des candidatures'),
                              if (data.sources.isEmpty)
                                const Text('Aucune source disponible.'),
                              for (final source in data.sources)
                                _source(source, data.sources),
                            ],
                          ),
                        ),
                        if (data.actions.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _card(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _title('À suivre pour cette offre'),
                                for (final action in data.actions)
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.checklist_outlined,
                                    ),
                                    title: Text(action.title),
                                    subtitle: Text(action.subtitle),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );

  Widget _hero(OfferAnalyticsData data, bool compact) => Container(
    padding: EdgeInsets.all(compact ? 22 : 32),
    decoration: BoxDecoration(
      color: const Color(0xFF001E3B),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OFFRE N°${widget.offerId} · ${data.offer.status}',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Text(
          data.offer.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 28 : 36,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${data.offer.location} · ${data.offer.contract}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: () {
                final target = _applicantsKey.currentContext;
                if (target != null) {
                  Scrollable.ensureVisible(
                    target,
                    duration: const Duration(milliseconds: 300),
                  );
                }
              },
              icon: const Icon(Icons.people_outline),
              label: Text('${data.offer.applications} candidatures'),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              onPressed: () =>
                  context.go(AppRoutes.recruiterDashboardOffer(widget.offerId)),
              icon: const Icon(Icons.bar_chart),
              label: const Text('Analyser par période'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _information(
    OfferAnalyticsData data,
    AsyncSnapshot<Map<String, dynamic>> details,
    bool compact,
  ) {
    final values = details.data ?? const <String, dynamic>{};
    final job = values['job'] as Map? ?? const {};
    final company = values['company'] as Map? ?? const {};
    final remote = switch (job['remotePolicy']) {
      'ONSITE' => 'Présentiel',
      'HYBRID' => 'Hybride',
      'REMOTE' => 'Télétravail',
      _ => 'Non disponible',
    };
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Le poste et l’entreprise'),
          if (details.connectionState != ConnectionState.done)
            const LinearProgressIndicator(),
          if (details.hasError || values['unavailable'] == true)
            TextButton(
              onPressed: _refresh,
              child: const Text(
                'Informations entreprise indisponibles · Réessayer',
              ),
            ),
          _line('Poste', data.offer.title),
          _line('Contrat', data.offer.contract),
          _line('Localisation', data.offer.location),
          _line('Organisation du travail', remote),
          _line(
            'Publication',
            dateLabel(DateTime.tryParse('${job['publishedAt']}')),
          ),
          _line('Entreprise', '${company['name'] ?? 'Non disponible'}'),
          if (company['sector'] != null)
            _line('Secteur', '${company['sector']}'),
          if (company['companySize'] != null)
            _line('Taille', '${company['companySize']}'),
          if (company['address'] != null)
            _line('Adresse', '${company['address']}'),
          if (company['website'] != null)
            _line('Site internet', '${company['website']}'),
          if ('${company['description'] ?? ''}'.trim().isNotEmpty) ...[
            const Divider(height: 28),
            _title('À propos de l’entreprise'),
            SelectableText('${company['description']}'),
          ],
          const Divider(height: 28),
          _title('Description et conditions du poste'),
          const Text(
            'La description, la rémunération, le niveau d’expérience et la date de début ne sont pas disponibles dans les données reçues pour cette offre.',
          ),
        ],
      ),
    );
  }

  Widget _source(
    DashboardDistributionItem item,
    List<DashboardDistributionItem> sources,
  ) {
    final total = sources.fold<double>(0, (sum, row) => sum + row.value);
    final percentage = total > 0 ? 100 * item.value / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(item.label)),
          Text(
            '${item.value.toStringAsFixed(0)} · ${percentage.toStringAsFixed(0)} %',
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        Text('$label :', style: const TextStyle(fontWeight: FontWeight.w700)),
        SelectableText(value.trim().isEmpty ? 'Non disponible' : value),
      ],
    ),
  );
  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
    ),
  );
  Widget _card(Widget child) => Card(
    margin: EdgeInsets.zero,
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );
}
