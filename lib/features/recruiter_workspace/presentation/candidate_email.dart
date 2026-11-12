import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routing/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../recruiter_studio/presentation/studio_components.dart';
import '../data/recruiter_workspace_repository.dart';

class CandidateEmail extends StatefulWidget {
  const CandidateEmail({
    super.key,
    required this.api,
    this.profileId,
    this.interview,
  });
  final ApiClient api;
  final String? profileId;
  final Map<String, dynamic>? interview;

  @override
  State<CandidateEmail> createState() => _CandidateEmailState();
}

class _CandidateEmailState extends State<CandidateEmail> {
  final subject = TextEditingController();
  final body = TextEditingController();
  late Future<Map<String, dynamic>> profile;

  Future<Map<String, dynamic>> load() async {
    final id = int.tryParse(widget.profileId ?? '');
    if (id == null || id < 1) return {};
    return apiObject(
      await widget.api.getJson('/api/v1/candidates/$id/profile'),
    );
  }

  @override
  void initState() {
    super.initState();
    profile = load();
    final event = widget.interview;
    subject.text = event == null ? 'Votre candidature' : '${event['title']}';
    if (event != null) {
      final start = DateTime.parse('${event['start']}').toLocal();
      final clock =
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
      final place = '${event['location'] ?? ''}'.trim();
      body.text =
          'Bonjour,\n\nJe vous propose un entretien le ${studioDate(event['start'])} '
          'à $clock (${start.timeZoneName}), pour une durée de ${event['duration']} minutes.'
          '${place.isEmpty ? '' : '\nLieu ou lien : $place'}\n\nCe créneau vous convient-il ?';
    }
  }

  @override
  void dispose() {
    subject.dispose();
    body.dispose();
    super.dispose();
  }

  Future<void> compose(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=${Uri.encodeComponent(subject.text)}&body=${Uri.encodeComponent(body.text)}',
    );
    try {
      if (await launchUrl(uri)) return;
    } catch (_) {
      // A mail client may be unavailable on this device.
    }
    if (mounted)
      studioToast(
        context,
        'Aucune application e-mail disponible. Copiez le brouillon pour votre webmail.',
      );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profileId == null) {
      return Center(
        child: FilledButton.icon(
          onPressed: () => context.go(AppRoutes.recruiterCandidates),
          icon: const Icon(Icons.people_outline),
          label: const Text('Choisir un postulant à contacter'),
        ),
      );
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: profile,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: () => setState(() => profile = load()),
              child: const Text('Profil indisponible · Réessayer'),
            ),
          );
        }
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final data = snapshot.requireData;
        final email = '${data['email'] ?? ''}'.trim();
        final name = [
          data['first_name'],
          data['last_name'],
        ].whereType<String>().join(' ');
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                if (email.isEmpty)
                  const Text(
                    'Le profil ne partage aucune adresse e-mail avec les recruteurs.',
                  )
                else ...[
                  SelectableText(email),
                  TextField(
                    controller: subject,
                    decoration: const InputDecoration(labelText: 'Objet'),
                  ),
                  TextField(
                    controller: body,
                    minLines: 3,
                    maxLines: 9,
                    decoration: const InputDecoration(labelText: 'Message'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => compose(email),
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('Ouvrir dans ma messagerie'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text:
                              'À : $email\nObjet : ${subject.text}\n\n${body.text}',
                        ),
                      );
                      if (context.mounted)
                        studioToast(context, 'Brouillon copié.');
                    },
                    child: const Text('Copier pour mon webmail'),
                  ),
                  const Text(
                    'Confirmez l’envoi dans votre application e-mail.',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
