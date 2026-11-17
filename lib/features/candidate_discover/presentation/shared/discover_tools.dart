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
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SizedBox(
      height: MediaQuery.sizeOf(context).height * .7,
      child: FutureBuilder(
        future: repository.fetchProfile(),
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
          final required = offer.skills.map((s) => s.name).toSet();
          final common = required
              .where((s) => owned.contains(s.trim().toLowerCase()))
              .toList();
          final missing = required
              .where((s) => !owned.contains(s.trim().toLowerCase()))
              .toList();
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Vos compétences pour ${offer.title}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Comparaison des compétences déclarées dans votre profil avec celles de l’offre. Ce rapprochement par nom ne mesure pas votre niveau.',
              ),
              const SizedBox(height: 24),
              if (required.isEmpty)
                const Text('Cette offre ne précise aucune compétence.'),
              Text(
                'Déjà dans votre profil · ${common.length}',
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
                'Si vous possédez déjà une compétence, ajoutez-la à votre profil. Sinon, vous pouvez cibler un projet ou une formation pour la pratiquer.',
              ),
            ],
          );
        },
      ),
    ),
  );
}
