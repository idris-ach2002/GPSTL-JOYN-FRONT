import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/page_metadata.dart';
import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/joyn_mark.dart';
import '../widgets/navigation_symbol.dart';
import '../widgets/product_atmosphere.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({
    super.key,
    required this.connection,
    this.topic = '',
    this.question = '',
  });
  final bool connection;
  final String topic;
  final String question;
  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final form = GlobalKey<FormState>();
  final topicKey = GlobalKey();
  final email = TextEditingController();
  final password = TextEditingController();
  late final question = TextEditingController(text: widget.question);
  bool revealed = false;
  String? message;
  String audience = 'Candidat';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      updatePageMetadata(widget.connection ? 'connexion' : 'assistance');
      final target = topicKey.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: MediaQuery.disableAnimationsOf(context)
              ? JoynTokens.instant
              : JoynTokens.duration,
        );
      }
    });
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    question.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Title(
    title: widget.connection ? 'JOYN — Connexion' : 'JOYN — Assistance',
    color: JoynTokens.ink,
    child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: JoynTokens.md,
                vertical: JoynTokens.xs,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        JoynMark(),
                        SizedBox(width: JoynTokens.sm),
                        Text('joyn'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go(
                      widget.connection ? '/assistance' : '/connexion',
                    ),
                    child: Text(widget.connection ? 'Aide' : 'Connexion'),
                  ),
                ],
              ),
            ),
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
      const SizedBox(height: JoynTokens.md),
      ProductSurface(
        key: widget.topic == 'donnees' ? topicKey : null,
        accent: widget.topic == 'donnees',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Données de navigation',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: JoynTokens.sm),
            const Text(
              'Les champs, favoris et choix restent en mémoire de la page. Les aperçus de cette page ne transmettent pas de candidature et ne déclenchent aucun paiement. Recharger efface ces choix.',
            ),
          ],
        ),
      ),
      const SizedBox(height: JoynTokens.md),
      ProductSurface(
        key: widget.topic == 'accessibilite' ? topicKey : null,
        accent: widget.topic == 'accessibilite',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Navigation et mouvements',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: JoynTokens.sm),
            const Text(
              'Les contrôles sont accessibles au clavier. Échap ferme le menu. Les rubriques mobiles s’ouvrent au toucher ; les détails de la landing restent repliables. La préférence de réduction des mouvements désactive les effets de profondeur et la scène au défilement.',
            ),
          ],
        ),
      ),
      const SizedBox(height: JoynTokens.lg),
      const Text(
        'Le contact avec l’assistance est momentanément indisponible.',
      ),
    ],
  );
}
