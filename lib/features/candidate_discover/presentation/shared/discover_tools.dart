import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../profile/data/profile_repository.dart';
import '../../domain/recommended_offer.dart';
import '../controllers/discover_controller.dart';

Future<void> showDiscoverFilters(
  BuildContext context,
  DiscoverController controller,
) async {
  final current = controller.filters;
  final location = TextEditingController(text: current.location);
  final rhythm = TextEditingController(text: current.rhythm);
  String? contract = current.contractType;
  String? remote = current.remote;
  final result = await showDialog<DiscoverFilters>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Filtrer les offres'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: location,
                  decoration: const InputDecoration(
                    labelText: 'Ville ou localisation',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: contract,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Contrat'),
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text('Tous les contrats'),
                    ),
                    DropdownMenuItem(value: 'CDI', child: Text('CDI')),
                    DropdownMenuItem(value: 'CDD', child: Text('CDD')),
                    DropdownMenuItem(value: 'INTERNSHIP', child: Text('Stage')),
                    DropdownMenuItem(
                      value: 'APPRENTICESHIP',
                      child: Text('Alternance'),
                    ),
                    DropdownMenuItem(
                      value: 'FREELANCE',
                      child: Text('Freelance'),
                    ),
                  ],
                  onChanged: (v) => setState(() => contract = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: remote,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Mode de travail',
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Tous')),
                    DropdownMenuItem(
                      value: 'ONSITE',
                      child: Text('Présentiel'),
                    ),
                    DropdownMenuItem(value: 'HYBRID', child: Text('Hybride')),
                    DropdownMenuItem(
                      value: 'REMOTE',
                      child: Text('Télétravail'),
                    ),
                  ],
                  onChanged: (v) => setState(() => remote = v),
                ),
                TextField(
                  controller: rhythm,
                  decoration: const InputDecoration(
                    labelText: 'Rythme (facultatif)',
                    hintText: 'Ex. 3/2',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, const DiscoverFilters()),
            child: const Text('Réinitialiser'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              DiscoverFilters(
                location: location.text.trim(),
                rhythm: rhythm.text.trim(),
                contractType: contract,
                remote: remote,
              ),
            ),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    ),
  );
  // Dialog widgets dispose their text fields at the end of the exit transition.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  location.dispose();
  rhythm.dispose();
  if (result != null) await controller.applyFilters(result);
}

Future<void> showSkillGap(BuildContext context, RecommendedOffer offer) async {
  final repository = context.read<ProfileRepository>();
  final profile = repository.fetchProfile();
  final router = GoRouter.of(context);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SizedBox(
      height: MediaQuery.sizeOf(context).height * .7,
      child: FutureBuilder(
        future: profile,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Impossible de charger votre profil. Fermez puis réessayez.',
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final owned = snapshot.data!.skills
              .map((s) => s.name.trim().toLowerCase())
              .toSet();
          final required = {
            for (final skill in offer.skills)
              if (skill.name.trim().isNotEmpty)
                skill.name.trim().toLowerCase(): skill.name.trim(),
          }.values.toList();
          final common = required
              .where((s) => owned.contains(s.trim().toLowerCase()))
              .toList();
          final missing = required
              .where((s) => !owned.contains(s.trim().toLowerCase()))
              .toList();
          final coverage = required.isEmpty
              ? null
              : common.length / required.length;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Vos compétences pour ${offer.title}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                coverage == null
                    ? 'Couverture des compétences non calculable'
                    : '${common.length} compétence(s) sur ${required.length} retrouvée(s)',
              ),
              if (offer.remotePolicy == 'REMOTE')
                const Text('Offre en télétravail complet'),
              if (offer.remotePolicy != 'REMOTE' && offer.distanceKm != null)
                Text('${offer.distanceKm!.round()} km à vol d’oiseau'),

              const SizedBox(height: 8),
              if (coverage != null) ...[
                Text(
                  'Compétences couvertes · ${(coverage * 100).round()} % (${common.length}/${required.length})',
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: coverage),
              ],
              const SizedBox(height: 8),
              const Text(
                'Chaque compétence demandée compte une fois. La couverture correspond aux compétences retrouvées dans votre profil, divisées par celles de l’offre.',
              ),

              const SizedBox(height: 24),
              if (required.isEmpty)
                const Text('Cette offre ne précise aucune compétence.'),
              Text(
                'Compétences acquises · ${common.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in common)
                    Chip(
                      avatar: const Icon(Icons.check, size: 16),
                      label: Text(s),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'À développer ou à renseigner · ${missing.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in missing)
                    Chip(
                      avatar: const Icon(Icons.school_outlined, size: 16),
                      label: Text(s),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Si vous possédez déjà une compétence, ajoutez-la à votre profil.',
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    router.go(AppRoutes.candidateProfileEdit);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Mettre à jour mes compétences'),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
