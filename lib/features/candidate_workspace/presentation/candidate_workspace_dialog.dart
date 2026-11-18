import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';
import '../../../design_system/documents/pdf_preview.dart';
import '../../recruiter_workspace/data/recruiter_workspace_repository.dart';

/// Opens additional candidate tools without changing the existing navigation.
Future<void> showCandidateWorkspace(
  BuildContext context, {
  int initialTab = 0,
}) async {
  final api = context.read<ApiClient?>();
  if (api == null) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) =>
        CandidateWorkspaceDialog(api: api, initialTab: initialTab),
  );
}

class CandidateWorkspaceDialog extends StatefulWidget {
  const CandidateWorkspaceDialog({
    super.key,
    required this.api,
    this.initialTab = 0,
  });
  final ApiClient api;
  final int initialTab;

  @override
  State<CandidateWorkspaceDialog> createState() =>
      _CandidateWorkspaceDialogState();
}

class _CandidateWorkspaceDialogState extends State<CandidateWorkspaceDialog> {
  static const base = '/api/v1/candidates/workspace';
  late int _tab;
  late Future<Map<String, dynamic>> _workspace;
  late Future<Map<String, dynamic>> _catalog;
  late Future<Map<String, dynamic>> _applicationsPage;
  int _applicationPageNumber = 1;
  final _search = TextEditingController();
  final _location = TextEditingController();
  final _salary = TextEditingController();
  final _rhythm = TextEditingController();
  String? _remote;
  String? _contract;
  int _page = 1;
  final Set<int> _toCompare = {};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    _location.dispose();
    _salary.dispose();
    _rhythm.dispose();
    super.dispose();
  }

  void _reload() {
    _workspace = _fetchWorkspace();
    _catalog = _fetchCatalog();
    _applicationsPage = _fetchApplicationsPage();
  }

  Future<Map<String, dynamic>> _fetchApplicationsPage() async => apiObject(
    await widget.api.getJson(
      '/api/v1/candidates/applications',
      query: {'page': '$_applicationPageNumber', 'limit': '50'},
    ),
  );

  Future<Map<String, dynamic>> _fetchWorkspace() async =>
      apiObject(await widget.api.getJson(base));

  Future<Map<String, dynamic>> _fetchCatalog() async => apiObject(
    await widget.api.getJson(
      '/api/v1/candidates/catalog',
      query: {
        'page': '$_page',
        'limit': '20',
        if (_search.text.trim().isNotEmpty) 'q': _search.text.trim(),
        if (_location.text.trim().isNotEmpty) 'location': _location.text.trim(),
        if (_remote != null) 'remote': _remote,
        if (_contract != null) 'contract_type': _contract,
        if (_rhythm.text.trim().isNotEmpty) 'rhythm_type': _rhythm.text.trim(),
        if (_salary.text.trim().isNotEmpty) 'salary_min': _salary.text.trim(),
      },
    ),
  );

  void _refresh({bool catalogOnly = false}) {
    if (!mounted) return;
    setState(() {
      _workspace = _fetchWorkspace();
      if (catalogOnly) _page = 1;
      _catalog = _fetchCatalog();
      _applicationsPage = _fetchApplicationsPage();
    });
  }

  Future<void> _change(
    Future<Object?> Function() request, {
    String success = 'Modifications enregistrées',
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await request();
      if (!mounted) return;
      _refresh();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(success)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Échec de l’opération : $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static List<Map<String, dynamic>> _rows(Object? rows) => rows is List
      ? rows.whereType<Map>().map((r) => Map<String, dynamic>.from(r)).toList()
      : [];
  static int _id(Map<String, dynamic> item, [String key = 'id']) =>
      int.tryParse('${item[key]}') ?? 0;
  static String _str(Object? value) => value?.toString() ?? '';

  Future<void> _bookmark(
    int id, {
    String state = 'SAVED',
    String collection = 'Plus tard',
    String note = '',
  }) => _change(
    () => widget.api.putJson(
      '$base/offers/$id',
      body: {'state': state, 'collection_name': collection, 'note': note},
    ),
    success: 'Offre enregistrée',
  );

  Future<void> _editBookmark(Map<String, dynamic> item) async {
    var state = _str(item['state']);
    var collection = _str(item['collection_name']);
    var note = _str(item['note']);
    final result = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, redraw) => AlertDialog(
          title: Text('Organiser : ${item['title']}'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue:
                      ['SAVED', 'INTERESTED', 'HIDDEN'].contains(state)
                      ? state
                      : 'SAVED',
                  decoration: const InputDecoration(labelText: 'Statut'),
                  items: const [
                    DropdownMenuItem(value: 'SAVED', child: Text('Favori')),
                    DropdownMenuItem(
                      value: 'INTERESTED',
                      child: Text('À postuler'),
                    ),
                    DropdownMenuItem(value: 'HIDDEN', child: Text('Ignorée')),
                  ],
                  onChanged: (v) => redraw(() => state = v ?? state),
                ),
                TextFormField(
                  initialValue: collection,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'Collection'),
                  onChanged: (v) => collection = v,
                ),
                TextFormField(
                  initialValue: note,
                  maxLines: 3,
                  maxLength: 3000,
                  decoration: const InputDecoration(labelText: 'Note privée'),
                  onChanged: (v) => note = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      await _bookmark(
        _id(item, 'job_offer_id'),
        state: state,
        collection: collection.trim().isEmpty ? 'Plus tard' : collection,
        note: note,
      );
    }
  }

  Future<void> _offerDetails(int id) async {
    try {
      final body = apiObject(
        await widget.api.getJson('/api/v1/candidates/offers/$id'),
      );
      final offer = apiObject(body['offer']);
      final company = apiObject(body['company']);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(_str(offer['title'])),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${company['name'] ?? ''} · ${offer['location'] ?? ''}'),
                  const SizedBox(height: 10),
                  Text(
                    '${offer['contract_type'] ?? ''}  ·  ${offer['remote_policy'] ?? ''}',
                  ),
                  if (offer['salary_min'] != null ||
                      offer['salary_max'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Rémunération : ${offer['salary_min'] ?? '—'} – ${offer['salary_max'] ?? '—'} ${offer['currency'] ?? 'EUR'} / ${offer['salary_period'] ?? ''}',
                      ),
                    ),
                  const SizedBox(height: 14),
                  SelectableText(_str(offer['description'])),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final skill in offer['skills'] as List? ?? [])
                        Chip(label: Text('$skill')),
                    ],
                  ),
                  if (offer['rhythm_type'] != null)
                    Text('Rythme : ${offer['rhythm_type']}'),
                  if (offer['start_date'] != null)
                    Text('Début : ${offer['start_date']}'),
                  if (offer['duration_months'] != null)
                    Text('Durée : ${offer['duration_months']} mois'),
                  if (offer['degree_level_required'] != null)
                    Text('Niveau : ${offer['degree_level_required']}'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Fermer'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(c);
                _bookmark(id, state: 'INTERESTED', collection: 'À postuler');
              },
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('À postuler'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d’ouvrir cette offre : $error')),
        );
      }
    }
  }

  Widget _catalogTab() => FutureBuilder<Map<String, dynamic>>(
    future: _catalog,
    builder: (context, snapshot) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _search,
                  onSubmitted: (_) => _refresh(catalogOnly: true),
                  decoration: const InputDecoration(
                    labelText: 'Poste, compétence, entreprise',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(
                width: 190,
                child: TextField(
                  controller: _location,
                  onSubmitted: (_) => _refresh(catalogOnly: true),
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
              ),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _contract,
                  decoration: const InputDecoration(labelText: 'Contrat'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tous')),
                    DropdownMenuItem(value: 'CDI', child: Text('CDI')),
                    DropdownMenuItem(value: 'CDD', child: Text('CDD')),
                    DropdownMenuItem(value: 'INTERNSHIP', child: Text('Stage')),
                    DropdownMenuItem(
                      value: 'APPRENTICESHIP',
                      child: Text('Alternance'),
                    ),
                    DropdownMenuItem(
                      value: 'PROFESSIONALIZATION',
                      child: Text(
                        'Professionnalisation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _contract = v),
                ),
              ),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _rhythm,
                  onSubmitted: (_) => _refresh(catalogOnly: true),
                  decoration: const InputDecoration(labelText: 'Rythme'),
                ),
              ),
              SizedBox(
                width: 145,
                child: TextField(
                  controller: _salary,
                  onSubmitted: (_) => _refresh(catalogOnly: true),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Salaire minimum',
                  ),
                ),
              ),
              SizedBox(
                width: 145,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _remote,
                  decoration: const InputDecoration(labelText: 'Travail'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tous')),
                    DropdownMenuItem(
                      value: 'ONSITE',
                      child: Text('Présentiel'),
                    ),
                    DropdownMenuItem(value: 'HYBRID', child: Text('Hybride')),
                    DropdownMenuItem(
                      value: 'REMOTE',
                      child: Text('À distance'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _remote = v),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _refresh(catalogOnly: true),
                icon: const Icon(Icons.search),
                label: const Text('Rechercher'),
              ),
              OutlinedButton.icon(
                onPressed: _saveSearch,
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Enregistrer cette recherche'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (snapshot.connectionState != ConnectionState.done)
            const Center(child: CircularProgressIndicator())
          else if (snapshot.hasError)
            Text('Recherche impossible : ${snapshot.error}')
          else ...[
            Text('${snapshot.data?['totalElements'] ?? 0} offre(s) trouvée(s)'),
            const SizedBox(height: 8),
            for (final item in _rows(snapshot.data?['content']))
              Card(
                child: ListTile(
                  title: Text(_str(item['title'])),
                  subtitle: Text(
                    '${item['company_name'] ?? ''} · ${item['location'] ?? ''} · ${item['contract_type'] ?? ''}',
                  ),
                  onTap: () => _offerDetails(_id(item)),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Comparer',
                        icon: Icon(
                          _toCompare.contains(_id(item))
                              ? Icons.check_box
                              : Icons.compare_arrows,
                        ),
                        onPressed: () => setState(() {
                          if (!_toCompare.remove(_id(item))) {
                            if (_toCompare.length >= 2) _toCompare.clear();
                            _toCompare.add(_id(item));
                          }
                        }),
                      ),
                      IconButton(
                        tooltip: 'Sauvegarder',
                        icon: const Icon(Icons.bookmark_border),
                        onPressed: () => _bookmark(_id(item)),
                      ),
                    ],
                  ),
                ),
              ),
            if (_toCompare.length == 2)
              FilledButton.icon(
                onPressed: _compare,
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Comparer les deux offres'),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Page $_page'),
                IconButton(
                  onPressed: _page <= 1
                      ? null
                      : () => setState(() {
                          _page--;
                          _catalog = _fetchCatalog();
                        }),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: snapshot.data?['hasNext'] != true
                      ? null
                      : () => setState(() {
                          _page++;
                          _catalog = _fetchCatalog();
                        }),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ],
      );
    },
  );

  Future<void> _compare() async {
    try {
      final ids = _toCompare.toList();
      final responses = await Future.wait(
        ids.map((id) => widget.api.getJson('/api/v1/candidates/offers/$id')),
      );
      final offers = responses
          .map((v) => apiObject(apiObject(v)['offer']))
          .toList();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Comparer les offres'),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(color: Theme.of(c).dividerColor),
                columnWidths: const {0: FixedColumnWidth(125)},
                children: [
                  for (final field in [
                    'title',
                    'contract_type',
                    'location',
                    'remote_policy',
                    'salary_min',
                    'salary_max',
                    'salary_period',
                    'experience_level',
                    'rhythm_type',
                    'duration_months',
                    'degree_level_required',
                  ])
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(field),
                        ),
                        for (final offer in offers)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              _str(offer[field]).isEmpty
                                  ? '—'
                                  : _str(offer[field]),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  Future<void> _saveSearch() async {
    var name = _search.text.trim().isEmpty
        ? 'Recherche ${_location.text.trim()}'
        : _search.text.trim();
    final accepted = await showDialog<String>(
      context: context,
      builder: (c) => _TextDialog(
        title: 'Nom de la recherche et alertes',
        label: 'Nom',
        initial: name,
        maxLength: 100,
      ),
    );
    if (accepted == null || accepted.trim().isEmpty) return;
    await _change(
      () => widget.api.postJson(
        '$base/searches',
        body: {
          'name': accepted.trim(),
          'alerts_enabled': true,
          'filters': {
            if (_search.text.trim().isNotEmpty) 'q': _search.text.trim(),
            if (_location.text.trim().isNotEmpty)
              'location': _location.text.trim(),
            if (_contract != null) 'contract_type': _contract,
            if (_remote != null) 'remote': _remote,
            if (_rhythm.text.trim().isNotEmpty)
              'rhythm_type': _rhythm.text.trim(),
            if (_salary.text.trim().isNotEmpty)
              'salary_min': _salary.text.trim(),
          },
        },
      ),
      success: 'Recherche enregistrée : alertes activées',
    );
  }

  Widget _bookmarksTab(Map<String, dynamic> data) {
    final items = _rows(data['bookmarks']);
    if (items.isEmpty) {
      return const _Empty(
        'Aucune offre enregistrée. Explore les offres et sélectionne le marque-page.',
      );
    }
    return Column(
      children: [
        for (final item in items)
          Card(
            child: ListTile(
              title: Text(_str(item['title'])),
              subtitle: Text(
                '${item['company_name'] ?? ''} · ${item['location'] ?? ''}\n'
                '${item['state'] == 'INTERESTED'
                    ? 'À postuler'
                    : item['state'] == 'HIDDEN'
                    ? 'Ignorée'
                    : 'Favori'} · ${item['collection_name'] ?? ''}'
                '${_str(item['note']).isEmpty ? '' : '\nNote : ${item['note']}'}',
              ),
              isThreeLine: true,
              onTap: () => _offerDetails(_id(item, 'job_offer_id')),
              trailing: Wrap(
                children: [
                  IconButton(
                    tooltip: 'Organiser et annoter',
                    icon: const Icon(Icons.edit_note),
                    onPressed: () => _editBookmark(item),
                  ),
                  IconButton(
                    tooltip: 'Retirer de ma liste',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _change(
                      () => widget.api.deleteJson(
                        '$base/offers/${item['job_offer_id']}',
                      ),
                      success: 'Offre retirée',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _searchesTab(Map<String, dynamic> data) {
    final searches = _rows(data['searches']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Les recherches enregistrées déclenchent une notification JOYN quand une nouvelle offre correspond à leurs critères.',
        ),
        const SizedBox(height: 10),
        if (searches.isEmpty)
          const _Empty(
            'Aucune recherche enregistrée. Crée-en une depuis Explorer.',
          ),
        for (final search in searches)
          Card(
            child: ListTile(
              leading: Icon(
                search['alerts_enabled'] == true
                    ? Icons.notifications_active_outlined
                    : Icons.search,
              ),
              title: Text(_str(search['name'])),
              subtitle: Text(_str(search['filters_json'])),
              onTap: () {
                final filters = _decodeFilters(search['filters_json']);
                _search.text = _str(filters['q']);
                _location.text = _str(filters['location']);
                _contract = _str(filters['contract_type']).isEmpty
                    ? null
                    : _str(filters['contract_type']);
                _remote = _str(filters['remote']).isEmpty
                    ? null
                    : _str(filters['remote']);
                _rhythm.text = _str(filters['rhythm_type']);
                _salary.text = _str(filters['salary_min']);
                setState(() {
                  _tab = 0;
                  _page = 1;
                  _catalog = _fetchCatalog();
                });
              },
              trailing: Wrap(
                children: [
                  IconButton(
                    tooltip: search['alerts_enabled'] == true
                        ? 'Désactiver les alertes'
                        : 'Activer les alertes',
                    icon: Icon(
                      search['alerts_enabled'] == true
                          ? Icons.notifications_off_outlined
                          : Icons.notifications_active_outlined,
                    ),
                    onPressed: () => _change(
                      () => widget.api.putJson(
                        '$base/searches/${search['id']}',
                        body: {
                          'name': search['name'],
                          'filters': _decodeFilters(search['filters_json']),
                          'alerts_enabled': search['alerts_enabled'] != true,
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Supprimer cette recherche',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _change(
                      () => widget.api.deleteJson(
                        '$base/searches/${search['id']}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static Map<String, dynamic> _decodeFilters(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is String) {
      try {
        return apiObject(_decodeJson(value));
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  static Object? _decodeJson(String value) => jsonDecode(value);

  Future<void> _projectForm([Map<String, dynamic>? project]) async {
    var title = _str(project?['title']);
    var description = _str(project?['description']);
    var url = _str(project?['project_url']);
    var skills = _str(project?['skills']);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          project == null ? 'Ajouter un projet' : 'Modifier le projet',
        ),
        content: SizedBox(
          width: 470,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: title,
                  maxLength: 150,
                  decoration: const InputDecoration(
                    labelText: 'Titre du projet *',
                  ),
                  onChanged: (v) => title = v,
                ),
                TextFormField(
                  initialValue: description,
                  maxLines: 3,
                  maxLength: 3000,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (v) => description = v,
                ),
                TextFormField(
                  initialValue: url,
                  maxLength: 1200,
                  decoration: const InputDecoration(
                    labelText: 'Lien HTTPS (facultatif)',
                  ),
                  onChanged: (v) => url = v,
                ),
                TextFormField(
                  initialValue: skills,
                  maxLength: 1200,
                  decoration: const InputDecoration(
                    labelText: 'Compétences (séparées par des virgules)',
                  ),
                  onChanged: (v) => skills = v,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (accepted != true || title.trim().isEmpty) return;
    final body = {
      'title': title,
      'description': description,
      'project_url': url,
      'skills': skills,
    };
    if (project == null) {
      await _change(() => widget.api.postJson('$base/projects', body: body));
    } else {
      await _change(
        () => widget.api.putJson('$base/projects/${project['id']}', body: body),
      );
    }
  }

  Widget _projectsTab(Map<String, dynamic> data) {
    final projects = _rows(data['projects']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () => _projectForm(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un projet'),
          ),
        ),
        const SizedBox(height: 10),
        if (projects.isEmpty)
          const _Empty(
            'Ajoute tes réalisations avec une description, des compétences et, si possible, un lien de démonstration.',
          ),
        for (final project in projects)
          Card(
            child: ListTile(
              title: Text(_str(project['title'])),
              subtitle: Text(
                '${project['description'] ?? ''}\nCompétences : ${project['skills'] ?? ''}',
              ),
              isThreeLine: true,
              onTap: _str(project['project_url']).isEmpty
                  ? () => _projectForm(project)
                  : () async {
                      final url = Uri.tryParse(_str(project['project_url']));
                      if (url != null && url.scheme == 'https') {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
              trailing: Wrap(
                children: [
                  IconButton(
                    tooltip: 'Modifier',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _projectForm(project),
                  ),
                  IconButton(
                    tooltip: 'Supprimer',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _change(
                      () => widget.api.deleteJson(
                        '$base/projects/${project['id']}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _applicationsTab(Map<String, dynamic> data) => FutureBuilder<Object?>(
    future: _applicationsPage,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return snapshot.hasError
            ? Text('Chargement impossible : ${snapshot.error}')
            : const Center(child: CircularProgressIndicator());
      }
      final root = apiObject(snapshot.data);
      final applications = _rows(
        root['items'] ?? root['content'] ?? root['applications'],
      );
      final notes = _rows(data['notes']);
      if (applications.isEmpty) {
        return const _Empty('Tu n’as pas encore envoyé de candidature.');
      }
      return Column(
        children: [
          const Text(
            'Notes personnelles et rappels : seul ton compte peut les consulter.',
          ),
          for (final app in applications)
            Card(
              child: ListTile(
                title: Text(_str(app['jobTitle'] ?? app['job_title'])),
                subtitle: Text(
                  '${app['companyName'] ?? app['company_name'] ?? ''} · ${app['status'] ?? ''}\n'
                  '${notes.where((n) => '${n['application_id']}' == '${app['id']}').map((n) => n['note']).join('')}',
                ),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _history(_id(app)),
                      icon: const Icon(Icons.history),
                      label: const Text('Historique'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _editNote(app, notes),
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Notes / rappel'),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Page $_applicationPageNumber / ${root['totalPages'] ?? 1}'),
              IconButton(
                tooltip: 'Page précédente',
                onPressed: _applicationPageNumber == 1
                    ? null
                    : () => setState(() {
                        _applicationPageNumber--;
                        _applicationsPage = _fetchApplicationsPage();
                      }),
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                tooltip: 'Page suivante',
                onPressed: root['hasNext'] != true
                    ? null
                    : () => setState(() {
                        _applicationPageNumber++;
                        _applicationsPage = _fetchApplicationsPage();
                      }),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      );
    },
  );

  Future<void> _history(int applicationId) async {
    try {
      final rows = _rows(
        await widget.api.getJson('$base/applications/$applicationId/history'),
      );
      if (!mounted) return;
      const translations = {
        'PENDING': 'Envoyée',
        'VIEWED': 'Consultée',
        'IN_REVIEW': 'En cours d’étude',
        'MATCHED': 'Correspondance retenue',
        'INTERVIEW': 'Entretien',
        'ACCEPTED': 'Acceptée',
        'REJECTED': 'Refusée',
        'WITHDRAWN': 'Retirée',
      };
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Historique de la candidature'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (rows.isEmpty)
                    const Text(
                      'Aucun événement enregistré depuis l’activation du suivi. Le suivi ne reconstitue pas les événements passés.',
                    ),
                  for (final row in rows)
                    ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(
                        translations[_str(row['status_code'])] ??
                            _str(row['status_code']),
                      ),
                      subtitle: Text(
                        _str(row['created_at']).replaceFirst('T', ' '),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Historique impossible à charger : $error')),
        );
      }
    }
  }

  Future<void> _editNote(
    Map<String, dynamic> app,
    List<Map<String, dynamic>> notes,
  ) async {
    final id = _id(app);
    final current = notes
        .where((note) => _id(note, 'application_id') == id)
        .firstOrNull;
    var note = _str(current?['note']);
    DateTime? reminder = DateTime.tryParse(_str(current?['remind_at']))
        ?.toLocal();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, update) => AlertDialog(
          title: const Text('Note privée et rappel'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: note,
                  maxLength: 3000,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Note'),
                  onChanged: (v) => note = v,
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(
                    reminder == null
                        ? 'Ajouter un rappel'
                        : 'Rappel : ${reminder!.day}/${reminder!.month}/${reminder!.year} à ${reminder!.hour}:${reminder!.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: IconButton(
                    tooltip: 'Supprimer le rappel',
                    icon: const Icon(Icons.close),
                    onPressed: () => update(() => reminder = null),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: c,
                      initialDate: reminder ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (date == null || !c.mounted) return;
                    final time = await showTimePicker(
                      context: c,
                      initialTime: TimeOfDay.fromDateTime(
                        reminder ?? DateTime.now(),
                      ),
                    );
                    if (!c.mounted) return;
                    if (time != null) {
                      update(
                        () => reminder = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true) {
      await _change(
        () => widget.api.putJson(
          '$base/applications/$id/note',
          body: {
            'note': note,
            'remind_at': reminder?.toUtc().toIso8601String(),
          },
        ),
      );
    }
  }

  Future<int> _lastWeekApplications() async {
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    var count = 0;
    for (var page = 1; ; page++) {
      final data = apiObject(
        await widget.api.getJson(
          '/api/v1/candidates/applications',
          query: {'page': '$page', 'limit': '50'},
        ),
      );
      for (final app in _rows(data['content'] ?? data['items'])) {
        final date = DateTime.tryParse(
          _str(app['createdAt'] ?? app['created_at']),
        );
        if (date != null && date.isAfter(threshold)) count++;
      }
      final pages = int.tryParse('${data['totalPages'] ?? 1}') ?? 1;
      if (page >= pages || page >= 100) return count;
    }
  }

  Future<void> _uploadCv() async {
    try {
      final selected = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (selected == null || !mounted) return;
      final size = selected.lengthSync() ?? await selected.length() ?? 0;
      if (!mounted) return;
      if (size == 0 ||
          size > 5 * 1024 * 1024 ||
          !selected.name.toLowerCase().endsWith('.pdf')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choisir un PDF de 5 Mo maximum.')),
        );
        return;
      }
      final label = await showDialog<String>(
        context: context,
        builder: (c) => _TextDialog(
          title: 'Nom de cette version du CV',
          label: 'Par exemple : Développement backend',
          initial: selected.name.replaceAll(
            RegExp(r'\.pdf$', caseSensitive: false),
            '',
          ),
          maxLength: 100,
        ),
      );
      if (label == null || label.trim().isEmpty || !mounted) return;
      final bytes = await selected.readAsBytes();
      await _change(
        () => widget.api.sendMultipart(
          'POST',
          '$base/cvs',
          fields: {'label': label.trim()},
          fileBytes: bytes,
          fileField: 'file',
          fileName: selected.name,
        ),
        success: 'Version du CV ajoutée',
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l’envoi du CV : $error')),
        );
      }
    }
  }

  Widget _cvTab(Map<String, dynamic> data) {
    final cvs = _rows(data['cvs']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Gère plusieurs CV PDF. La version active est utilisée pour les nouvelles candidatures. Les documents des candidatures déjà envoyées restent inchangés.',
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _uploadCv,
            icon: const Icon(Icons.upload_file),
            label: const Text('Ajouter un CV PDF'),
          ),
        ),
        const SizedBox(height: 12),
        if (cvs.isEmpty)
          const _Empty(
            'Aucune version du CV dans cette bibliothèque. Le CV initial peut toujours être présent dans ton profil.',
          ),
        for (final cv in cvs)
          Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(_str(cv['label'])),
              subtitle: Text(
                '${cv['filename'] ?? ''}${cv['active'] == true ? ' · CV actif' : ''}',
              ),
              onTap: () => showPdfPreview(
                context,
                widget.api,
                '$base/cvs/${cv['id']}/preview',
                _str(cv['label']),
              ),
              trailing: Wrap(
                children: [
                  if (cv['active'] != true)
                    TextButton(
                      onPressed: () => _change(
                        () => widget.api.putJson(
                          '$base/cvs/${cv['id']}/activate',
                        ),
                        success: 'CV activé pour les futures candidatures',
                      ),
                      child: const Text('Activer'),
                    ),
                  if (cv['active'] != true)
                    IconButton(
                      tooltip: 'Supprimer cette version',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _change(
                        () => widget.api.deleteJson('$base/cvs/${cv['id']}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _settingsTab(Map<String, dynamic> data) {
    final prefs = apiObject(data['preferences']);
    final goal = int.tryParse('${prefs['weekly_goal']}') ?? 5;
    final alerts = prefs['alerts_enabled'] != false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Définis tes objectifs et choisis si les recherches enregistrées peuvent t’envoyer des notifications JOYN.',
        ),
        const SizedBox(height: 16),
        FutureBuilder<int>(
          future: _lastWeekApplications(),
          builder: (c, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final count = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Objectif hebdomadaire : $count / $goal candidatures'),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: (count / goal).clamp(0.0, 1.0)),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () async {
            final value = await showDialog<String>(
              context: context,
              builder: (c) => _TextDialog(
                title: 'Objectif hebdomadaire',
                label: 'Candidatures par semaine (1 à 100)',
                initial: '$goal',
                keyboardType: TextInputType.number,
                maxLength: 3,
              ),
            );
            final parsed = int.tryParse(value ?? '');
            if (parsed == null || parsed < 1 || parsed > 100) return;
            await _change(
              () => widget.api.putJson(
                '$base/preferences',
                body: {'weekly_goal': parsed, 'alerts_enabled': alerts},
              ),
            );
          },
          icon: const Icon(Icons.flag_outlined),
          label: const Text('Changer mon objectif'),
        ),
        SwitchListTile(
          title: const Text('Alertes de recherches enregistrées'),
          subtitle: const Text(
            'Notifications JOYN lorsqu’une nouvelle offre correspond à une recherche.',
          ),
          value: alerts,
          onChanged: (enabled) => _change(
            () => widget.api.putJson(
              '$base/preferences',
              body: {'weekly_goal': goal, 'alerts_enabled': enabled},
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final tabs = [
      'Explorer',
      'Favoris',
      'Recherches',
      'Candidatures',
      'Portfolio',
      'Mes CV',
      'Objectifs',
    ];
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width < 600 ? 8 : 24,
        vertical: 18,
      ),
      child: SizedBox(
        width: size.width < 600 ? size.width - 16 : 1000,
        height: size.height * .88,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 8, 6),
              child: Row(
                children: [
                  const Icon(Icons.workspaces_outline),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Mes outils JOYN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_busy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  IconButton(
                    tooltip: 'Actualiser',
                    icon: const Icon(Icons.refresh),
                    onPressed: _refresh,
                  ),
                  IconButton(
                    tooltip: 'Fermer',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(tabs[i]),
                        selected: _tab == i,
                        onSelected: (_) => setState(() => _tab = i),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _workspace,
                builder: (context, snapshot) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: snapshot.connectionState != ConnectionState.done
                      ? const Center(child: CircularProgressIndicator())
                      : snapshot.hasError
                      ? Column(
                          children: [
                            Text(
                              'Impossible de charger les données : ${snapshot.error}',
                            ),
                            TextButton(
                              onPressed: _refresh,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        )
                      : switch (_tab) {
                          0 => _catalogTab(),
                          1 => _bookmarksTab(snapshot.data!),
                          2 => _searchesTab(snapshot.data!),
                          3 => _applicationsTab(snapshot.data!),
                          4 => _projectsTab(snapshot.data!),
                          5 => _cvTab(snapshot.data!),
                          _ => _settingsTab(snapshot.data!),
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextDialog extends StatefulWidget {
  const _TextDialog({
    required this.title,
    required this.label,
    required this.initial,
    this.maxLength = 150,
    this.keyboardType,
  });
  final String title, label, initial;
  final int maxLength;
  final TextInputType? keyboardType;
  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late String _value = widget.initial;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextFormField(
      initialValue: widget.initial,
      autofocus: true,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (v) => _value = v,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _value),
        child: const Text('Enregistrer'),
      ),
    ],
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(22),
    child: Center(child: Text(message, textAlign: TextAlign.center)),
  );
}
