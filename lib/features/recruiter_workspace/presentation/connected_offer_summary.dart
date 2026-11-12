import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routing/app_routes.dart';
import '../../recruiter_dashboard/data/recruiter_dashboard_repository.dart';
import '../../recruiter_dashboard/domain/recruiter_dashboard_models.dart';
import 'application_panel.dart';
import 'workspace_controller.dart';

class ConnectedOfferSummary extends StatefulWidget {
  const ConnectedOfferSummary({super.key, required this.offerId});
  final int offerId;

  @override
  State<ConnectedOfferSummary> createState() => _ConnectedOfferSummaryState();
}

class _ConnectedOfferSummaryState extends State<ConnectedOfferSummary> {
  late Future<OfferAnalyticsData> summary;

  Future<OfferAnalyticsData> load() => context
      .read<RecruiterDashboardRepository>()
      .fetchOfferAnalytics(widget.offerId, DashboardPeriod.all);

  @override
  void initState() {
    super.initState();
    summary = load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Offre n°${widget.offerId}'),
      leading: BackButton(onPressed: () => context.go(AppRoutes.recruiterJobs)),
    ),
    body: FutureBuilder<OfferAnalyticsData>(
      future: summary,
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(
            child: TextButton(
              onPressed: () => setState(() => summary = load()),
              child: const Text(
                'Offre indisponible pour ce compte · Réessayer',
              ),
            ),
          );
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final offer = snapshot.requireData.offer;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          [
                            offer.location,
                            offer.contract,
                            offer.status,
                          ].where((v) => v.isNotEmpty).join(' · '),
                        ),
                        const Divider(height: 32),
                        Text('${offer.applications} candidature(s) reçue(s)'),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            FilledButton.icon(
                              icon: const Icon(Icons.people_outline),
                              label: const Text('Voir les postulants'),
                              onPressed: () {
                                final repo = context
                                    .read<WorkspaceController>()
                                    .repository;
                                showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => FractionallySizedBox(
                                    heightFactor: .85,
                                    child: ApplicationPanel(
                                      repository: repo,
                                      jobId: widget.offerId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            OutlinedButton(
                              onPressed: () => context.go(
                                AppRoutes.recruiterDashboardOffer(
                                  widget.offerId,
                                ),
                              ),
                              child: const Text('Performances'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
