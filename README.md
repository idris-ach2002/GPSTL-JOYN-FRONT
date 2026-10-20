# JOYN — Landing Material 3

Branche **`landing-page`**, basée sur le socle vierge `f719022` puis la première
livraison `2eef6de`. Historique Git conservé ; aucun push distant effectué.

## Démarrer

Environnement de référence : Flutter 3.47.7 / Dart 3.13.5.

```sh
flutter pub get
flutter run -d chrome
```

## Vérifier

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

Les résultats effectivement obtenus figurent dans [verification.md](docs/verification.md).
Le workflow GitHub utilise la même version de Flutter et inclut `landing-page`.
Le verrou `pubspec.lock` est suivi pour rendre les dépendances reproductibles.

## Version améliorée

- Transition navy/orange/lumière avec halos diffus, grille et parallaxe au scroll.
- Fonctionnalités candidat/entreprise : huit démonstrations locales, schémas et
  interactions distincts, avec données explicitement fictives.
- Carrousel de tarifs : glissement, boutons, pagination, focus et flèches clavier.
  JOYN+ reste sombre avec son halo orange ; le Boost retrouve son aperçu visuel.
- Footer clair avec les rubriques et intitulés de `plans-footer.png`.
- Dix pages publiques pour les liens qui n'ont pas leur contenu sur la landing.
- Courbe orange exclusivement liée au scroll, sans animation infinie.
- Hero à hauteur naturelle et tests de transitions corrigés.

Le parcours mobile n'a pas été repensé dans cette passe. Les écrans de connexion
et d'inscription restent des destinations d'intégration. Les pages légales
expliquent l'absence de documents officiels ; aucune politique n'est inventée.
Les tarifs et avantages proposés ne sont pas des autorisations backend.

## Récupérer les commits dans le dépôt existant

La livraison contient `joyn-landing.bundle` et `importer-joyn.sh` en plus du dossier
source. Depuis le dépôt local sur `landing-page`, exécuter le script de l'archive
décompressée. Il importe les commits avec Git puis synchronise les fichiers avec
`rsync`, en excluant toujours `.git`.

Le script sauvegarde les modifications et fichiers non suivis dans un stash,
puis accepte uniquement une avance rapide. Il s'arrête en cas de divergence.
Il ne réapplique pas automatiquement les anciens fichiers de la première copie.
Les détails sont dans [importer-la-livraison.md](docs/importer-la-livraison.md).

## Architecture et recette

- [Conception, animation et intégration](docs/landing-material.md)
- [Recette fonctionnelle et visuelle](docs/recette.md)
