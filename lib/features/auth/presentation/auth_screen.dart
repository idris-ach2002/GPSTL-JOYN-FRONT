import 'package:flutter/material.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../landing/presentation/widgets/joyn_mark.dart';

/// Destination d'intégration de l'authentification, sans faux appel réseau.
///
/// La branche vierge ne contient ni service d'authentification, ni formulaire
/// métier. Cet écran réserve les routes pour les branches U14/CA51/R46.
/// Aucun identifiant n'est collecté avant leur intégration.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, this.registration = false});
  final bool registration;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('JOYN')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const JoynMark(size: 72),
                const SizedBox(height: 32),
                Text(registration ? 'Rejoins JOYN.' : 'Content de te revoir.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.navy, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Text(registration
                  ? 'L’inscription candidat et entreprise sera disponible ici.'
                  : 'La connexion à ton espace sera disponible ici.',
                  textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text('Écran de connexion à intégrer au service d’authentification.',
                  textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context,
                    registration ? '/connexion' : '/inscription'),
                  child: Text(registration ? 'Déjà un compte ? Connexion'
                    : 'Pas encore de compte ? Inscription'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
