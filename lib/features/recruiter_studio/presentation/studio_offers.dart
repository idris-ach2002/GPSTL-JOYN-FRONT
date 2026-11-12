import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../recruiter_offers/domain/job_offer.dart';
import '../../recruiter_offers/presentation/controllers/offer_management_controller.dart';
import '../data/studio_export.dart';
import 'studio_export_dialog.dart';
import 'studio_components.dart';
import 'studio_controller.dart';

Map<String, dynamic> studioOfferTemplate(JobOffer o) => {
  'title': o.title,
  'contract': o.contractType.apiValue,
  'location': o.location,
  'remote': o.remoteMode.apiValue,
  'experience': o.experienceLevel.apiValue,
  'description': o.description,
  'salaryMin': o.salaryMin,
  'salaryMax': o.salaryMax,
  'currency': o.currency,
  'salaryPeriod': o.salaryPeriod.apiValue,
  'skills': o.skills,
  'rhythmType': o.rhythmType,
  'durationMonths': o.durationMonths,
  'degreeLevelRequired': o.degreeLevelRequired,
};

class StudioOffersToolbar extends StatelessWidget {
  const StudioOffersToolbar({super.key});
  @override
  Widget build(BuildContext context) {
    final studio = context.watch<StudioController?>();
    if (studio == null) return const SizedBox.shrink();
    final c = context.watch<OfferManagementController>();
    final disabled =
        c.isLoading || c.isClosing || c.isDeleting || c.isDuplicating;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: StudioCard(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: disabled || c.offers.isEmpty
                  ? null
                  : () => _choose(context, c, studio, 'duplicate'),
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('Dupliquer une offre'),
            ),
            OutlinedButton.icon(
              onPressed: disabled || c.offers.isEmpty
                  ? null
                  : () => _choose(context, c, studio, 'template'),
              icon: const Icon(Icons.library_add_outlined),
              label: const Text('Créer un modèle'),
            ),
            PopupMenuButton<String>(
              tooltip: 'Modèles d’offres',
              enabled: studio.list('offerTemplates').isNotEmpty,
              onSelected: (id) =>
                  context.go('/recruiter/jobs/new?template=$id'),
              itemBuilder: (_) => [
                for (final t in studio.list('offerTemplates'))
                  PopupMenuItem(
                    value: '${t['id']}',
                    child: Text('${t['name']}'),
                  ),
              ],
              child: Chip(
                avatar: const Icon(Icons.library_books_outlined, size: 16),
                label: Text(
                  '${studio.list('offerTemplates').length} modèle(s)',
                ),
              ),
            ),
            TextButton.icon(
              onPressed: c.visibleOffers.isEmpty
                  ? null
                  : () => studioExport(
                      context,
                      name: 'joyn-offres.csv',
                      extension: 'csv',
                      text: studioCsv([
                        [
                          'Titre',
                          'Entreprise',
                          'Contrat',
                          'Ville',
                          'Organisation',
                          'Statut',
                          'Salaire minimum',
                          'Salaire maximum',
                          'Devise',
                          'Période',
                          'Candidatures',
                        ],
                        for (final o in c.visibleOffers)
                          [
                            o.title,
                            c.companyFor(o.companyId)?.name ?? '',
                            o.contractType.label,
                            o.location,
                            o.remoteMode.label,
                            o.status.label,
                            o.salaryMin,
                            o.salaryMax,
                            o.currency,
                            o.salaryPeriod.label,
                            o.candidateCount,
                          ],
                      ]),
                    ),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Exporter la vue'),
            ),
            TextButton.icon(
              onPressed: disabled || c.visibleOffers.isEmpty
                  ? null
                  : () => showDialog<void>(
                      context: context,
                      builder: (_) => _BulkOffers(controller: c),
                    ),
              icon: const Icon(Icons.checklist),
              label: const Text('Actions groupées'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _choose(
    BuildContext context,
    OfferManagementController controller,
    StudioController studio,
    String action,
  ) async {
    final offer = await showModalBottomSheet<JobOffer>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * .6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                action == 'duplicate'
                    ? 'Quelle offre souhaitez-vous dupliquer ?'
                    : 'Créer un modèle à partir d’une offre',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final o in controller.offers)
                    ListTile(
                      leading: const Icon(Icons.work_outline),
                      title: Text(o.title),
                      subtitle: Text(
                        '${o.contractType.label} · ${o.status.label}',
                      ),
                      onTap: () => Navigator.pop(ctx, o),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (offer == null || !context.mounted) return;
    if (action == 'duplicate') {
      if (!await studioConfirm(
            context,
            'Créer une copie en brouillon ?',
            'L’offre originale reste disponible. La copie ne sera pas publiée automatiquement.',
            action: 'Créer le brouillon',
          ) ||
          !context.mounted) {
        return;
      }
      final result = await controller.duplicateOffer(offer.id);
      if (context.mounted) {
        studioToast(
          context,
          result == null
              ? 'Impossible de dupliquer cette offre.'
              : 'Brouillon créé. Retrouvez-le dans vos offres.',
        );
      }
    } else {
      final ok = await studio.upsert('offerTemplates', {
        'id': StudioController.newId(),
        'name': offer.title,
        'offer': studioOfferTemplate(offer),
      });
      if (context.mounted) {
        studioToast(
          context,
          ok
              ? 'Modèle enregistré. Il est disponible dans le menu Modèles.'
              : 'Impossible d’enregistrer le modèle.',
        );
      }
    }
  }
}

class _BulkOffers extends StatefulWidget {
  const _BulkOffers({required this.controller});
  final OfferManagementController controller;
  @override
  State<_BulkOffers> createState() => _BulkOffersState();
}

class _BulkOffersState extends State<_BulkOffers> {
  final Set<int> _ids = {};
  bool _busy = false;
  String? _result;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const Text('Agir sur plusieurs offres'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          children: [
            const Text(
              'Les opérations sont appliquées une par une. Les éventuels échecs restent sélectionnés.',
            ),
            if (_busy) const LinearProgressIndicator(),
            if (_result != null)
              Padding(padding: const EdgeInsets.all(12), child: Text(_result!)),
            Expanded(
              child: ListView(
                children: [
                  for (final offer in widget.controller.visibleOffers)
                    CheckboxListTile(
                      value: _ids.contains(offer.id),
                      onChanged: _busy
                          ? null
                          : (v) => setState(() {
                              v == true
                                  ? _ids.add(offer.id)
                                  : _ids.remove(offer.id);
                            }),
                      title: Text(offer.title),
                      subtitle: Text(offer.status.label),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
        OutlinedButton(
          onPressed: _busy || _ids.isEmpty ? null : () => _run(false),
          child: const Text('Clôturer'),
        ),
        FilledButton(
          onPressed: _busy || _ids.isEmpty ? null : () => _run(true),
          child: const Text('Supprimer la sélection'),
        ),
      ],
    ),
  );
  Future<void> _run(bool delete) async {
    if (!await studioConfirm(
          context,
          delete
              ? 'Supprimer ${_ids.length} offre(s) ?'
              : 'Clôturer ${_ids.length} offre(s) ?',
          delete
              ? 'La suppression est définitive. Vérifiez votre sélection.'
              : 'Les offres seront retirées des recommandations.',
          action: delete ? 'Supprimer' : 'Clôturer',
        ) ||
        !mounted) {
      return;
    }
    setState(() => _busy = true);
    var success = 0;
    for (final id in _ids.toList()) {
      final ok = delete
          ? await widget.controller.deleteOffer(id)
          : await widget.controller.closeOffer(id);
      if (ok) {
        success++;
        _ids.remove(id);
      }
    }
    if (mounted) {
      setState(() {
        _busy = false;
        _result =
            '$success opération(s) réussie(s). ${_ids.length} à réessayer.';
      });
    }
  }
}
