// Affiche les pages de connexion et d’assistance avec leur état de disponibilité.
//
// Référence : doc/landing.md#service_screendart.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/page_metadata.dart';
import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/landing_mega_navigation.dart';
import '../widgets/navigation_symbol.dart';
import '../widgets/product_atmosphere.dart';

/// Écran de connexion ou d’assistance, choisi par le paramètre connection.
class ServiceScreen extends StatefulWidget {
  /// Initialise les paramètres de ServiceScreen ; les valeurs par défaut figurent dans la signature.
  const ServiceScreen({
    super.key,
    required this.connection,
    this.question = '',
  });

  /// Sélectionne l’écran de connexion plutôt que l’assistance.
  final bool connection;

  /// Question reçue par la route ou contrôleur de sa saisie, selon la portée.
  final String question;

  /// Crée l’état local associé au widget.
  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

/// État de ServiceScreen ; définit ses données mutables et son rendu.
class _ServiceScreenState extends State<ServiceScreen> {
  /// Clé du formulaire utilisée pour déclencher la validation de ses champs.
  final form = GlobalKey<FormState>();

  /// Contrôleur du champ d’adresse e-mail.
  final email = TextEditingController();

  /// Contrôleur du champ de mot de passe.
  final password = TextEditingController();

  /// Question reçue par la route ou contrôleur de sa saisie, selon la portée.
  late final question = TextEditingController(text: widget.question);

  /// Indique si le texte du mot de passe est visible.
  bool revealed = false;

  /// Message facultatif présenté sous le formulaire.
  String? message;

  /// Acteur ou point d’entrée utilisé pour adapter la présentation.
  String audience = 'Candidat';

  /// Initialise les abonnements ou programme le travail qui nécessite le premier rendu.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      updatePageMetadata(widget.connection ? 'connexion' : 'assistance');
    });
  }

  /// Garde tous les menus accessibles et transmet les ancres vers la landing.
  void navigate(String target) {
    if (target == 'connexion' || target == 'assistance') {
      context.go('/$target');
    } else if (target.startsWith('guide-') || target == 'presentation') {
      openResource(target);
    } else {
      context.go(
        Uri(path: '/', queryParameters: {'section': target}).toString(),
      );
    }
  }

  /// Libère les ressources détenues par cet état avant sa destruction.
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    question.dispose();
    super.dispose();
  }

  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => Title(
    title: widget.connection ? 'JOYN — Connexion' : 'JOYN — Assistance',
    color: JoynTokens.ink,
    child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LandingMegaNavigation(onNavigate: navigate),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: EditorialSection(
                  child: widget.connection
                      ? connection(context)
                      : assistance(context),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  /// Construit l’espace de connexion avec son état indisponible et ses champs désactivés.
  Widget connection(BuildContext context) => EditorialSplit(
    leading: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NavigationSymbol(
          kind: NavigationSymbolKind.account,
          active: true,
        ),
        const SizedBox(height: JoynTokens.md),
        Text(
          'Ton espace JOYN.',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: JoynTokens.md),
        const Text('Retrouver ton parcours commence ici.'),
        const SizedBox(height: JoynTokens.lg),
        const Text(
          'La connexion est momentanément indisponible. Aucun identifiant ne sera envoyé depuis cette page.',
        ),
        const SizedBox(height: JoynTokens.md),
        TextButton(
          onPressed: () => context.go('/candidats'),
          child: const Text('Consulter le parcours candidat →'),
        ),
      ],
    ),
    trailing: ProductSurface(
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connexion', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: JoynTokens.md),
            Wrap(
              spacing: JoynTokens.xs,
              runSpacing: JoynTokens.xs,
              children: [
                for (final role in const ['Candidat', 'Recruteur'])
                  Semantics(
                    selected: audience == role,
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        audience = role;
                        message = null;
                      }),
                      child: Text('$role${audience == role ? ' —' : ''}'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: JoynTokens.md),
            TextFormField(
              enabled: false,
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(labelText: 'Adresse e-mail'),
              validator: (value) => value != null && value.contains('@')
                  ? null
                  : 'Renseigne une adresse e-mail valide.',
            ),
            const SizedBox(height: JoynTokens.md),
            TextFormField(
              enabled: false,
              controller: password,
              obscureText: !revealed,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Renseigne ton mot de passe.'
                  : null,
            ),
            TextButton(
              onPressed: () => setState(() => revealed = !revealed),
              child: Text(revealed ? 'Masquer le texte' : 'Afficher le texte'),
            ),
            const SizedBox(height: JoynTokens.md),
            const FilledButton(
              onPressed: null,
              child: Text('CONNEXION INDISPONIBLE'),
            ),
            if (message != null) ...[
              const SizedBox(height: JoynTokens.md),
              Semantics(liveRegion: true, child: Text(message!)),
            ],
            const SizedBox(height: JoynTokens.sm),
            TextButton(
              onPressed: () => context.go('/assistance'),
              child: const Text('Besoin d’aide pour accéder au compte ?'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Construit les guides, la question reçue et les informations de navigation.
  Widget assistance(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const NavigationSymbol(kind: NavigationSymbolKind.support, active: true),
      const SizedBox(height: JoynTokens.md),
      Text(
        'Comment peut-on t’aider ?',
        style: Theme.of(context).textTheme.displayMedium,
      ),
      const SizedBox(height: JoynTokens.md),
      const Text(
        'Des réponses sur le profil, les recommandations et les candidatures.',
      ),
      const SizedBox(height: JoynTokens.lg),
      TextField(
        controller: question,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Ta question',
          helperText: 'Aucun message ne sera envoyé depuis ce champ.',
        ),
      ),
      const SizedBox(height: JoynTokens.md),
      for (final item in const [
        (
          'Profil et compétences',
          'Présenter son expérience et ses réalisations.',
          'guide-profil',
        ),
        (
          'Comprendre le matching',
          'Comprendre les offres correspondant au profil.',
          'guide-matching',
        ),
        (
          'Préparer un échange',
          'Raconter un projet et préparer ses questions.',
          'guide-entretien',
        ),
      ]) ...[
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: JoynTokens.md),
          child: EditorialSplit(
            leading: Text(
              item.$1,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.$2),
                TextButton(
                  onPressed: () => openResource(item.$3),
                  child: const Text('Lire le guide →'),
                ),
              ],
            ),
          ),
        ),
      ],
      const SizedBox(height: JoynTokens.lg),
      const Text(
        'Le contact avec l’assistance est momentanément indisponible.',
      ),
    ],
  );
}
