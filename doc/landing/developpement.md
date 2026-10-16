# Développement et tests

[Sommaire](README.md) · [Référence des tests](fichiers/widget_test.md)

## Prérequis

Utiliser Flutter avec un SDK Dart satisfaisant `^3.13.5`, comme déclaré dans `pubspec.yaml`. Chrome est utilisé pour l’exécution Web locale.

```bash
flutter pub get
flutter run -d chrome
```

Les dépendances sont déclarées dans `pubspec.yaml` et résolues dans `pubspec.lock`. Un message proposant des versions plus récentes ne demande pas, à lui seul, une mise à niveau des dépendances.

## Vérifications

Exécuter depuis la racine du projet :

```bash
dart format lib test
flutter analyze
flutter test test/widget_test.dart
flutter build web --release
```

Le build est produit dans `build/web`.

## Portée des tests

La suite comprend la vérification des couleurs des boutons de texte, des chapitres mobiles, du menu et de son retour de focus, de la disponibilité de la connexion, des favoris, du profil, de la mise en relation illustrée, des pictogrammes, de l’explication du CV, de la FAQ et du carrousel. Elle monte également la landing aux largeurs 320, 390, 768, 1024 et 1440 pixels.

`setViewport` règle `tester.view.physicalSize` et `devicePixelRatio` à 1 pour que la largeur logique vue par `MediaQuery` corresponde à la largeur demandée. Les valeurs sont restaurées après chaque test. `mount` applique le thème, une zone défilable et attend la stabilisation. `activate` rend un contrôle visible avant de cliquer.

Les contrôles clavier sont testés après placement explicite du focus. Un test de texte doit distinguer le contenu d’un `EditableText` et son aperçu lorsque les deux portent la même chaîne.

La suite vérifie des comportements de widgets. Elle ne teste pas de service d’authentification, de traitement de CV ni d’envoi de candidature. Une compilation Web ne remplace pas les vérifications visuelles des titres, panneaux, grands textes et gestes dans le navigateur.

## Modification d’une section

Conserver les valeurs visuelles dans les jetons, utiliser les compositions existantes et maintenir la résolution des ancres dans `LandingScreen`. Pour un nouveau lien, consulter [la navigation](navigation.md). Pour une nouvelle question, consulter [la FAQ](faq.md).

Mettre à jour la référence du fichier concerné en même temps que ses déclarations publiques, son état ou ses interactions. Les noms entre crochets dans les commentaires Dart sont réservés aux symboles réellement résolus ; les liens de documentation restent des chemins de fichiers.
