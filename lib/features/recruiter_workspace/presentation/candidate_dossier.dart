import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../design_system/documents/pdf_preview.dart';
import '../data/recruiter_workspace_repository.dart';

Future<void> showCandidateDossier(
  BuildContext context,
  ApiClient api,
  String applicationId,
) => showDialog<void>(
  context: context,
  builder: (_) => _CandidateDossier(api: api, applicationId: applicationId),
);

class _CandidateDossier extends StatefulWidget {
  const _CandidateDossier({required this.api, required this.applicationId});
  final ApiClient api;
  final String applicationId;

  @override
  State<_CandidateDossier> createState() => _CandidateDossierState();
}

class _CandidateDossierState extends State<_CandidateDossier> {
  String get _path => '/api/v1/applications/${widget.applicationId}/dossier';
  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<Map<String, dynamic>> _load() async =>
      apiObject(await widget.api.getJson(_path));

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(14),
    child: SizedBox(
      width: 750,
      height: MediaQuery.sizeOf(context).height * .86,
      child: Column(
        children: [
          ListTile(
            title: const Text('Dossier de candidature'),
            trailing: IconButton(
              tooltip: 'Fermer',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return Center(
                    child: TextButton(
                      onPressed: () => setState(() => _data = _load()),
                      child: const Text('Dossier indisponible · Réessayer'),
                    ),
                  );
                }
                return _content(snapshot.data!);
              },
            ),
          ),
        ],
      ),
    ),
  );

  Widget _content(Map<String, dynamic> dossier) {
    final profile = apiObject(dossier['profile']);
    final preferences = apiObject(profile['preferences']);
    final availability = apiObject(profile['alternance']);
    final links = apiObject(profile['links']);
    final name = _join([profile['first_name'], profile['last_name']]);
    final address = _join([
      profile['address'],
      profile['location'],
    ], separator: ' · ');
    final contact = _join([
      profile['email'],
      profile['phone'],
    ], separator: ' · ');
    final skills = profile['skills'] as List? ?? const [];
    final experiences = profile['experiences'] as List? ?? const [];
    final schools = profile['educations'] as List? ?? const [];
    final letter = '${dossier['coverMessage'] ?? ''}'.trim();
    final hasPdf = dossier['hasCoverPdf'] == true;
    final minimum = preferences['min_salary'];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(name, style: Theme.of(context).textTheme.headlineSmall),
        if (profile['headline'] != null) Text('${profile['headline']}'),
        if (dossier['offerTitle'] != null)
          Text('Offre · ${dossier['offerTitle']}'),
        if (address.isNotEmpty) Text(address),
        if (contact.isNotEmpty) SelectableText(contact),
        if ('${profile['bio'] ?? ''}'.trim().isNotEmpty) ...[
          _heading('Présentation'),
          SelectableText('${profile['bio']}'),
        ],
        _heading('Documents'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (profile['cv_url'] != null)
              OutlinedButton.icon(
                onPressed: () => showPdfPreview(
                  context,
                  widget.api,
                  '$_path/cv',
                  'CV · $name',
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Voir le CV'),
              )
            else
              const Text('Aucun CV disponible.'),
            if (hasPdf)
              OutlinedButton.icon(
                onPressed: () => showPdfPreview(
                  context,
                  widget.api,
                  '$_path/lettre',
                  'Lettre · $name',
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Voir la lettre PDF'),
              ),
          ],
        ),
        if (letter.isNotEmpty) ...[
          _heading('Lettre de motivation'),
          SelectableText(letter),
        ] else if (!hasPdf)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Aucune lettre jointe à cette candidature.'),
          ),
        _heading('Compétences'),
        if (skills.isEmpty) const Text('Aucune compétence renseignée.'),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [for (final skill in skills) Chip(label: Text('$skill'))],
        ),
        _heading('Expérience'),
        if (profile['years_of_experience'] != null)
          Text('${profile['years_of_experience']} an(s) d’expérience déclarée'),
        if (experiences.isEmpty) const Text('Aucune expérience détaillée.'),
        for (final item in experiences.cast<Map>())
          _entry(
            _join([item['title'], item['organization']], separator: ' · '),
            _join([
              item['start_date'],
              item['currently_working'] == true ? 'En cours' : item['end_date'],
            ], separator: ' – '),
            item['description'],
          ),
        _heading('Formation'),
        if (schools.isEmpty) const Text('Aucune formation renseignée.'),
        for (final item in schools.cast<Map>())
          _entry(
            _join([
              item['field_of_study'],
              item['school_name'],
            ], separator: ' · '),
            _join([
              item['degree'],
              item['postbac_year'],
              item['school_address'],
            ], separator: ' · '),
            _join([
              item['start_year'],
              item['currently_studying'] == true
                  ? 'En cours'
                  : item['end_year'],
            ], separator: ' – '),
          ),
        _heading('Disponibilité et préférences'),
        _detail('Disponible à partir du', availability['available_from']),
        _detail('Rythme', availability['rhythm_type']),
        _detail(
          'Durée souhaitée',
          availability['contract_duration_months'] == null
              ? null
              : '${availability['contract_duration_months']} mois',
        ),
        _detail(
          'Contrats',
          (preferences['contract_types'] as List? ?? const []).join(', '),
        ),
        _detail('Télétravail', preferences['remote_policy']),
        _detail(
          'Salaire minimum',
          minimum == null ? null : '$minimum ${preferences['currency'] ?? ''}',
        ),
        if (links.values.whereType<String>().any(
          (link) => link.isNotEmpty,
        )) ...[
          _heading('Liens'),
          _detail('LinkedIn', links['linkedin']),
          _detail('GitHub', links['github']),
          _detail('Portfolio', links['portfolio']),
        ],
      ],
    );
  }

  Widget _heading(String label) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 6),
    child: Text(label, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _detail(String label, Object? value) =>
      value == null || '$value'.trim().isEmpty
      ? const SizedBox.shrink()
      : SelectableText('$label · $value');

  Widget _entry(String title, String subtitle, Object? text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        if (subtitle.isNotEmpty) Text(subtitle),
        if (text != null && '$text'.trim().isNotEmpty) SelectableText('$text'),
      ],
    ),
  );

  String _join(List<Object?> values, {String separator = ' '}) =>
      values.where((v) => v != null && '$v'.trim().isNotEmpty).join(separator);
}
