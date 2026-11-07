import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routing/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';

class ConnectedRecruiterScreen extends StatefulWidget {
  const ConnectedRecruiterScreen(this.api, {super.key, this.registration = false});
  final ApiClient api;
  final bool registration;

  @override
  State<ConnectedRecruiterScreen> createState() => _ConnectedRecruiterScreenState();
}

class _ConnectedRecruiterScreenState extends State<ConnectedRecruiterScreen> {
  final form = GlobalKey<FormState>();
  final fields = <String, String>{};
  String action = 'Candidat';
  String status = 'IN_REVIEW';
  bool busy = false;
  String message = '';
  static const statuses = {'VIEWED':'Vue','IN_REVIEW':'En étude','INTERVIEW':'Entretien','ACCEPTED':'Acceptée','REJECTED':'Refusée'};

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    form.currentState!.save();
    setState(() { busy = true; message = ''; });
    final id = fields['id'];
    try {
      if (widget.registration) {
        await widget.api.postJson('/api/v1/recruiters/register', body: fields);
        if (mounted) context.go(AppRoutes.login);
      } else if (action == 'Candidat') {
        final data = await widget.api.getJson('/api/v1/candidates/$id/profile') as Map;
        message = [data['first_name'], data['last_name'], data['headline'], data['bio'],
          data['location'], (data['skills'] as List?)?.join(', ')].whereType<String>().join('\n');
      } else if (action == 'Entreprise') {
        final data = await widget.api.getJson('/api/v1/companies/$id') as Map;
        message = [data['name'], data['description'], data['website'],
          for (final job in data['jobs'] as List? ?? const []) '${job['title']} · ${job['location'] ?? ''}'].whereType<String>().join('\n');
      } else if (action == 'Présentation entreprise') {
        await widget.api.patchJson('/api/v1/companies/$id',body:{'description':fields['description']});
        message = 'Présentation enregistrée.';
      } else {
        await widget.api.patchJson('/api/v1/applications/$id/status',body:{'status':status});
        message = 'Statut enregistré.';
      }
    } on ApiException catch (e) {
      message = switch (e.statusCode) {
        401 => 'Veuillez vous reconnecter.',
        403 => 'Votre compte ne peut pas effectuer cette action.',
        404 => 'Élément introuvable ou inaccessible.',
        409 => 'Le serveur a refusé cette inscription. Vérifiez les informations saisies.',
        null => 'Serveur inaccessible. Vérifiez la connexion avant de réessayer.',
        _ => 'Requête refusée (HTTP ${e.statusCode}).',
      };
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget field(String key, String label) => TextFormField(
    key: ValueKey('$action-$key'), enabled: !busy, obscureText: key == 'password',
    decoration: InputDecoration(labelText: label),
    validator: (s) => (s ?? '').trim().isEmpty ? 'Champ requis' :
      key == 'id' && (int.tryParse(s!.trim()) ?? 0) < 1 ? 'Identifiant numérique requis' : null,
    onSaved: (s) => fields[key] = key == 'password' ? s! : s!.trim(),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.registration ? 'Créer mon compte recruteur' : 'Espace recruteur'),
      actions: [if (!widget.registration) IconButton(tooltip:'Déconnexion',icon:const Icon(Icons.logout),
        onPressed: () => context.read<AuthController>().signOut())]),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680),
      child: Form(key: form,child: ListView(padding: const EdgeInsets.all(24),children: [
        if (widget.registration) ...[
          field('firstName','Prénom'),field('lastName','Nom'),field('companyName','Nom de l’entreprise'),
          field('email','E-mail'),field('password','Mot de passe'),
        ] else ...[
          for (final entry in {'Mon profil':AppRoutes.recruiterProfile,'Mes offres':AppRoutes.recruiterJobs,
            'Créer une offre':AppRoutes.recruiterJobCreate,'Agenda personnel':'/recruiter/planner'}.entries)
            ListTile(title:Text(entry.key),trailing:const Icon(Icons.chevron_right),onTap:()=>context.go(entry.value)),
          const Divider(),
          DropdownButton<String>(value:action,isExpanded:true,
            items:[for(final a in ['Candidat','Entreprise','Présentation entreprise','Statut de candidature'])
              DropdownMenuItem(value:a,child:Text(a))],
            onChanged:busy ? null : (v)=>setState(() {action=v!;message='';fields.clear();})),
          field('id',switch(action){'Candidat'=>'Identifiant du candidat','Statut de candidature'=>'Identifiant de candidature',_=>'Identifiant de l’entreprise'}),
          if(action=='Présentation entreprise') field('description','Nouvelle présentation'),
          if(action=='Statut de candidature') DropdownButton<String>(value:status,
            items:[for(final e in statuses.entries) DropdownMenuItem(value:e.key,child:Text(e.value))],
            onChanged:busy ? null : (v)=>setState(()=>status=v!)),
        ],
        const SizedBox(height:16),
        FilledButton(onPressed: busy ? null : submit,child:Text(widget.registration ? 'Créer mon compte' :
          action=='Candidat' || action=='Entreprise' ? 'Consulter' : 'Enregistrer')),
        if(message.isNotEmpty) SelectableText(message),
      ])))),
  );
}
