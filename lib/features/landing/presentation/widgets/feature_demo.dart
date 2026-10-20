import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/landing_content.dart';

/// Laboratoire de présentation isolé : les interactions modifient uniquement
/// cet état local. Les données sont fictives, sans stockage ni appel au backend.
///
/// Chaque rubrique dispose d'une démonstration adaptée, au lieu de réutiliser
/// la même liste de texte. Changer de rubrique recrée ce widget via sa clé.
class FeatureDemo extends StatefulWidget {
  const FeatureDemo({required this.audience, required this.index, super.key});
  final Audience audience;
  final int index;

  @override
  State<FeatureDemo> createState() => _FeatureDemoState();
}

class _FeatureDemoState extends State<FeatureDemo> {
  bool _imported = false;
  bool _interested = false;
  bool _published = false;
  int _stage = 0;
  int _selectedProfile = 0;
  final Set<int> _criteria = {0, 1, 2};
  final _messageController = TextEditingController();
  final List<String> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = widget.audience == Audience.candidate;
    final panel = candidate
        ? switch (widget.index) {
            0 => _profileDemo(),
            1 => _matchingDemo(),
            2 => _pipelineDemo(false),
            _ => _conversationDemo(),
          }
        : switch (widget.index) {
            0 => _companyDemo(),
            1 => _offerDemo(),
            2 => _talentDemo(),
            _ => _pipelineDemo(true),
          };
    return Container(
      key: ValueKey('demo-${widget.audience.name}-${widget.index}'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: .14),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.science_outlined, size: 16, color: AppColors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'DÉMO INTERACTIVE · DONNÉES FICTIVES',
                    style: TextStyle(
                      color: AppColors.blueGreyDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 280),
              alignment: Alignment.topCenter,
              child: panel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _heading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 21,
          color: AppColors.navy,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.blueGreyDark,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 20),
    ],
  );

  Widget _profileDemo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'Du parcours au profil.',
        'Teste le préremplissage puis vérifie chaque information.',
      ),
      const DemoFlow(
        labels: ['Document', 'Informations', 'Profil'],
        icons: [
          Icons.description_outlined,
          Icons.tune_rounded,
          Icons.badge_outlined,
        ],
      ),
      const SizedBox(height: 20),
      _dataRow(
        Icons.person_outline,
        'Prénom',
        _imported ? 'Camille' : 'À compléter',
      ),
      _dataRow(
        Icons.school_outlined,
        'Formation',
        _imported ? 'Master informatique' : 'À compléter',
      ),
      _dataRow(
        Icons.code_rounded,
        'Compétences',
        _imported ? 'Flutter · Dart' : 'À compléter',
      ),
      const SizedBox(height: 18),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: _imported ? 1.0 : .15),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 650),
        builder: (_, value, child) => LinearProgressIndicator(
          value: value,
          color: AppColors.orange,
          backgroundColor: AppColors.blueGrey10,
          minHeight: 7,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        key: const ValueKey('demo-import'),
        onPressed: () => setState(() => _imported = !_imported),
        icon: Icon(_imported ? Icons.restart_alt : Icons.upload_file),
        label: Text(_imported ? 'Recommencer la démo' : 'Simuler l’import'),
      ),
    ],
  );

  Widget _matchingDemo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'Comprends la compatibilité.',
        'Active les critères de cet exemple pour faire évoluer son score.',
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (i, label) in [
            'Compétences',
            'Formation',
            'Rythme',
            'Localisation',
          ].indexed)
            FilterChip(
              key: ValueKey('demo-criterion-$i'),
              label: Text(label),
              selected: _criteria.contains(i),
              onSelected: (value) => setState(() {
                if (value) {
                  _criteria.add(i);
                } else {
                  _criteria.remove(i);
                }
              }),
            ),
        ],
      ),
      const SizedBox(height: 24),
      Center(
        child: SizedBox.square(
          dimension: 130,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: _criteria.length / 4),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 700),
            builder: (_, value, child) => Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 9,
                    color: AppColors.orange,
                    backgroundColor: AppColors.blueGrey10,
                  ),
                ),
                Text(
                  '${(value * 100).round()} %',
                  key: const ValueKey('demo-score'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 22),
      const Text(
        'Exemple : développeur Flutter en alternance',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      Text(
        '${_criteria.length} critères actifs sur 4 · score pédagogique, non contractuel.',
        style: const TextStyle(fontSize: 12, color: AppColors.blueGreyDark),
      ),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => setState(() => _interested = !_interested),
        icon: Icon(_interested ? Icons.favorite : Icons.favorite_border),
        label: Text(
          _interested ? 'Intérêt ajouté à la démo' : 'Marquer mon intérêt',
        ),
      ),
    ],
  );

  Widget _pipelineDemo(bool company) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        company ? 'Un recrutement lisible.' : 'Chaque étape, en vue.',
        'Fais avancer une candidature fictive et observe son statut.',
      ),
      DemoFlow(
        labels: const ['Envoyée', 'En étude', 'Entretien'],
        icons: const [
          Icons.send_outlined,
          Icons.manage_search,
          Icons.event_available,
        ],
        active: _stage,
      ),
      const SizedBox(height: 24),
      _dataRow(Icons.work_outline, 'Offre', 'Développeur Flutter'),
      _dataRow(Icons.person_outline, 'Candidat', 'Camille · profil fictif'),
      _dataRow(
        Icons.flag_outlined,
        'Statut',
        const ['Envoyée', 'En étude', 'Entretien'][_stage],
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        key: const ValueKey('demo-next-stage'),
        onPressed: () => setState(() => _stage = (_stage + 1) % 3),
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Simuler l’étape suivante'),
      ),
    ],
  );

  Widget _conversationDemo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'Une conversation, un contexte.',
        'Ajoute un message à cette démo. Il reste uniquement dans cette vue.',
      ),
      const Chip(
        avatar: Icon(Icons.work_outline, size: 16),
        label: Text('Offre · Développeur Flutter'),
      ),
      const SizedBox(height: 12),
      _bubble('Bonjour Camille, parlons de votre parcours.', false),
      _bubble('Avec plaisir ! Quelles sont les prochaines étapes ?', true),
      for (final message in _messages) _bubble(message, true),
      const SizedBox(height: 16),
      TextField(
        controller: _messageController,
        maxLength: 180,
        decoration: const InputDecoration(
          labelText: 'Ton message de démonstration',
        ),
        onSubmitted: (_) => _addMessage(),
      ),
      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed: _addMessage,
        icon: const Icon(Icons.send_outlined),
        label: const Text('Ajouter à la démo'),
      ),
    ],
  );

  void _addMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    setState(() {
      // Une démo doit rester courte : garder au plus trois messages utilisateur.
      if (_messages.length == 3) _messages.removeAt(0);
      _messages.add(message);
      _messageController.clear();
    });
  }

  Widget _companyDemo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'Une identité claire.',
        'Aperçu du parcours de présentation d’une entreprise.',
      ),
      const DemoFlow(
        labels: ['Compte', 'Entreprise', 'Validation'],
        icons: [Icons.person_outline, Icons.apartment, Icons.verified_outlined],
      ),
      const SizedBox(height: 20),
      _dataRow(Icons.apartment, 'Entreprise', 'Atelier Horizon · fictif'),
      _dataRow(Icons.location_on_outlined, 'Lieu', 'Paris'),
      _dataRow(
        Icons.verified_outlined,
        'Présentation',
        _imported ? 'Informations complétées' : 'À compléter',
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: () => setState(() => _imported = !_imported),
        child: Text(
          _imported ? 'Revenir au brouillon' : 'Simuler un profil complété',
        ),
      ),
    ],
  );

  Widget _offerDemo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'L’offre reste entre vos mains.',
        'Préparez, publiez et clôturez : aperçu des états.',
      ),
      _dataRow(Icons.work_outline, 'Poste', 'Développeur Flutter'),
      _dataRow(Icons.calendar_month_outlined, 'Contrat', 'Alternance'),
      _dataRow(
        Icons.public_outlined,
        'Visibilité',
        _published ? 'Publiée dans la démo' : 'Brouillon de démonstration',
      ),
      const SizedBox(height: 18),
      AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _published ? AppColors.blueGrey10 : AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              _published ? Icons.check_circle_outline : Icons.edit_outlined,
              color: AppColors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _published
                    ? 'Votre offre apparaît ici comme publiée.'
                    : 'Votre offre est prête à être relue.',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: () => setState(() => _published = !_published),
        child: Text(
          _published ? 'Simuler la clôture' : 'Simuler la publication',
        ),
      ),
    ],
  );

  Widget _talentDemo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'Les profils prennent du relief.',
        'Sélectionnez un profil pour voir son parcours.',
      ),
      for (final (i, name) in ['Camille', 'Alex', 'Noa'].indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: _selectedProfile == i
                ? AppColors.blueGrey10
                : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              selected: _selectedProfile == i,
              onTap: () => setState(() => _selectedProfile = i),
              leading: CircleAvatar(child: Text(name.substring(0, 1))),
              title: Text(name),
              subtitle: Text(
                const [
                  'Flutter · Dart',
                  'Vue · TypeScript',
                  'Java · Spring',
                ][i],
              ),
              trailing: const Icon(Icons.arrow_forward, size: 18),
            ),
          ),
        ),
      const SizedBox(height: 12),
      _dataRow(
        Icons.school_outlined,
        'Parcours sélectionné',
        const [
          'Master informatique',
          'Licence informatique',
          'École d’ingénieurs',
        ][_selectedProfile],
      ),
    ],
  );

  Widget _dataRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppColors.cyanBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.blueGreyDark,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _bubble(String message, bool mine) => Align(
    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(14),
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        color: mine ? AppColors.navy : AppColors.blueGrey10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: mine ? AppColors.white : AppColors.navy,
          height: 1.4,
          fontSize: 13,
        ),
      ),
    ),
  );
}

/// Schéma compact en trois étapes. Les liaisons restent lisibles au clavier
/// comme au pointeur ; aucun déplacement automatique de sélection.
class DemoFlow extends StatelessWidget {
  const DemoFlow({
    required this.labels,
    required this.icons,
    this.active = 2,
    super.key,
  });
  final List<String> labels;
  final List<IconData> icons;
  final int active;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < labels.length; i++) ...[
        if (i != 0)
          const Padding(
            padding: EdgeInsets.only(top: 17),
            child: Icon(
              Icons.arrow_right_alt,
              color: AppColors.orange,
              size: 20,
            ),
          ),
        Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 350),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= active ? AppColors.navy : AppColors.blueGrey10,
                  boxShadow: i == active
                      ? [
                          BoxShadow(
                            color: AppColors.orange.withValues(alpha: .25),
                            blurRadius: 16,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  icons[i],
                  color: i <= active ? AppColors.white : AppColors.navy,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                labels[i],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
