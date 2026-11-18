import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

Future<bool?> showInterviewProposal(
  BuildContext context,
  ApiClient api, {
  String? applicationId,
  int? offerId,
}) => showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _InterviewDialog(
    api: api,
    applicationId: applicationId,
    offerId: offerId,
  ),
);

class _Applicant {
  const _Applicant(this.id, this.name);
  final int id;
  final String name;
}

class _Offer {
  const _Offer(this.id, this.title, this.applicants);
  final int id;
  final String title;
  final List<_Applicant> applicants;
}

class _InterviewDialog extends StatefulWidget {
  const _InterviewDialog({required this.api, this.applicationId, this.offerId});
  final ApiClient api;
  final String? applicationId;
  final int? offerId;

  @override
  State<_InterviewDialog> createState() => _InterviewDialogState();
}

class _InterviewDialogState extends State<_InterviewDialog> {
  final _title = TextEditingController();
  final _location = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  int _duration = 30;
  String _mode = 'VIDEO';
  List<_Offer> _offers = [];
  _Offer? _offer;
  _Applicant? _applicant;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await widget.api.getJson(
        '/api/v1/interviews/options',
        query: {'applicationId': widget.applicationId},
      ) as List;
      final offers = [
        for (final row in raw.cast<Map>())
          _Offer(row['id'] as int, row['title'] as String, [
            for (final item in (row['applicants'] as List).cast<Map>())
              _Applicant(item['applicationId'] as int, item['name'] as String),
          ]),
      ];
      final preset = int.tryParse(widget.applicationId ?? '');
      if (!mounted) return;
      setState(() {
        _offers = offers;
        _offer = preset == null
            ? offers.where((o) => o.id == widget.offerId).firstOrNull
            : offers
                  .where((o) => o.applicants.any((a) => a.id == preset))
                  .firstOrNull;
        _applicant = _offer?.applicants
            .where((a) => a.id == preset)
            .firstOrNull;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = widget.applicationId == null
              ? 'Impossible de charger vos offres. Réessayez.'
              : 'Cette candidature est indisponible ou n’est plus en cours.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _chooseDay() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (day != null && mounted) {
      setState(
        () => _date = DateTime(
          day.year,
          day.month,
          day.day,
          _date.hour,
          _date.minute,
        ),
      );
    }
  }

  Future<void> _chooseTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (time != null && mounted) {
      setState(
        () => _date = DateTime(
          _date.year,
          _date.month,
          _date.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (_date.isBefore(DateTime.now())) {
      setState(() => _error = 'Choisissez un créneau à venir.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.postJson(
        '/api/v1/interviews',
        body: {
          'applicationId': _applicant!.id,
          'title': _title.text.trim(),
          'scheduledAt': _date.toUtc().toIso8601String(),
          'durationMinutes': _duration,
          'mode': _mode,
          'locationOrLink': _location.text.trim(),
        },
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (mounted) {
        setState(
          () => _error = error.statusCode == 409
              ? 'Le créneau est déjà occupé ou la candidature est clôturée.'
              : 'La proposition n’a pas pu être enregistrée. Réessayez.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final applicants = _offer?.applicants ?? const <_Applicant>[];
    final fixed = widget.applicationId != null;
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: const Text('Proposer un entretien'),
        content: SizedBox(
          width: 510,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_loading || _saving) const LinearProgressIndicator(),
                if (!_loading) ...[
                  DropdownButtonFormField<_Offer>(
                    key: ObjectKey(_offers),
                    initialValue: _offer,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Offre'),
                    items: [
                      for (final o in _offers)
                        DropdownMenuItem(
                          value: o,
                          child: Text(o.title, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: fixed || _saving
                        ? null
                        : (offer) => setState(() {
                            _offer = offer;
                            _applicant = null;
                            _error = null;
                          }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<_Applicant>(
                    key: ObjectKey(_offer),
                    initialValue: _applicant,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Candidat'),
                    items: [
                      for (final a in applicants)
                        DropdownMenuItem(
                          value: a,
                          child: Text(a.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: fixed || _saving || applicants.isEmpty
                        ? null
                        : (value) => setState(() => _applicant = value),
                  ),
                  if (_offer != null && applicants.isEmpty)
                    const Text('Aucune candidature en cours pour cette offre.'),
                  if (_offers.isEmpty && _error == null)
                    const Text('Vous n’avez aucune offre disponible.'),
                  const SizedBox(height: 12),
                  TextField(
                    enabled: !_saving,
                    controller: _title,
                    maxLength: 160,
                    decoration: const InputDecoration(
                      labelText: 'Objet (facultatif)',
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _chooseDay,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(localizations.formatCompactDate(_date)),
                      ),
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _chooseTime,
                        icon: const Icon(Icons.schedule),
                        label: Text(
                          localizations.formatTimeOfDay(
                            TimeOfDay.fromDateTime(_date),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _duration,
                    decoration: const InputDecoration(labelText: 'Durée'),
                    items: [
                      for (final minutes in [15, 30, 45, 60, 90])
                        DropdownMenuItem(
                          value: minutes,
                          child: Text('$minutes min'),
                        ),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _duration = value!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _mode,
                    decoration: const InputDecoration(labelText: 'Format'),
                    items: const [
                      DropdownMenuItem(
                        value: 'VIDEO',
                        child: Text('Visioconférence'),
                      ),
                      DropdownMenuItem(
                        value: 'ONSITE',
                        child: Text('Sur place'),
                      ),
                      DropdownMenuItem(
                        value: 'PHONE',
                        child: Text('Téléphone'),
                      ),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _mode = value!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    enabled: !_saving,
                    controller: _location,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      labelText: 'Lieu, lien ou numéro',
                    ),
                  ),
                  const Text(
                    'Le message d’invitation est envoyé automatiquement dans JOYN.',
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  if (_offers.isEmpty && !_loading)
                    TextButton(
                      onPressed: _load,
                      child: const Text('Réessayer'),
                    ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          FilledButton(
            onPressed: _saving || _loading || _applicant == null
                ? null
                : _submit,
            child: const Text('Enregistrer et envoyer'),
          ),
        ],
      ),
    );
  }
}
