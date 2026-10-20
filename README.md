# JOYN — Landing Material 3

Branche `feat/landing-material`, créée depuis `f719022` sur le socle vierge fourni.
L'historique Git et le remote d'origine sont conservés. Aucun push n'a été réalisé.

## Démarrer

Utiliser le SDK Flutter du projet dont Dart satisfait `^3.13.5`, puis :

```sh
flutter pub get
flutter run -d chrome
```

Pour le parcours natif, lancer sur un appareil Android/iOS :

```sh
flutter run
```

Le web affiche la landing, même dans un navigateur étroit. Le natif ouvre une
animation de marque de 1,6 seconde puis remplace la route par `/connexion`.
La connexion et l'inscription sont des destinations d'intégration explicites :
aucune authentification ni facturation backend n'est implémentée dans cette branche.

## Vérifier

```sh
dart format lib test
flutter analyze
flutter test
flutter build web --release
```

**État de la livraison :** contrôles de structure et de Git réalisés ; commandes
Flutter non exécutées, car ni Flutter ni Dart ne sont installés dans l'environnement
de réalisation. La fidélité visuelle exacte, les débordements et le rendu sur
appareil restent à vérifier en exécutant l'application. Le workflow GitHub préparé
n'a pas été déclenché et ne constitue pas une preuve de réussite.

La contrainte Dart provient du projet fourni. Elle n'a pas été abaissée pour
contourner une incompatibilité de SDK. Le workflow utilise le canal stable ; si
son Dart ne satisfait pas `^3.13.5`, choisir le SDK du projet avant de relancer.

## Organisation

- `lib/app` : entrée, routes et thème Material 3 explicite.
- `lib/design_system` : palette JOYN inchangée, espacements et conteneur partagé.
- `lib/features/landing/domain` : contenu et propositions commerciales.
- `lib/features/landing/presentation` : sections et widgets de la landing web.
- `lib/features/startup` : introduction de l'application native.
- `lib/features/auth` : écrans d'attente à remplacer lors de l'intégration.
- `test/widget_test.dart` : interactions, accès premium, plateformes et largeurs.

Consulter [la conception détaillée](docs/landing-material.md) et
[la recette visuelle](docs/recette.md).
