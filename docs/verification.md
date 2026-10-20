# État des vérifications — 20 octobre 2026

## Réalisé

- 31 fichiers Dart contrôlés pour la résolution des imports locaux et l'équilibre
  des délimiteurs, en ignorant commentaires et chaînes.
- Palette comparée octet par octet avec la version utilisateur : identique.
- SHA-256 de `app_colors.dart` :
  `80bc33d006f729b35bb8cff3efebb72513628bbfba5bbf51c56d1c071311a452`.
- `git diff --check` : aucune erreur d'espacement détectée.
- `git fsck --no-dangling` : intégrité du dépôt vérifiée.
- Routes d'accès déclarées et boutons de la landing reliés à ces routes ou aux
  ancres présentes. Aucun callback vide `onPressed: () {}` conservé.
- Les sections exclues ne sont ni importées ni incluses dans l'assemblage livré.

Ces contrôles sont statiques ; ils ne prouvent pas que le programme compile.

## Non exécuté

- `dart format` : Dart absent.
- `flutter analyze`, `flutter test`, `flutter build web` : Flutter absent
  (`flutter: command not found`).
- Rendu web, comparaison Figma au pixel près et exécution Android/iOS.
- Workflow GitHub : non déclenché, aucun push effectué.

Les tests et la recette sont fournis pour permettre ces vérifications dans
l'environnement du projet. Aucun test Flutter n'est présenté comme réussi.
