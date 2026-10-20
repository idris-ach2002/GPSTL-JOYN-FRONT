# Vérification de la livraison actuelle

## État de validation

Les commits jusqu'à `0fff9ee` avaient déjà été validés avec Flutter 3.47.7 / Dart
3.13.5 dans l'environnement de la livraison précédente. Les modifications de la
présente passe (Constat, démonstration de parcours, nettoyage éditorial, CTA et
fil lumineux autonome) ont été préparées dans un environnement où les exécutables
`flutter` et `dart` ne sont pas installés.

Il serait faux d'indiquer que `flutter analyze`, `flutter test` ou le build web ont
été exécutés ici sur ces nouveaux commits. Ils doivent donc être relancés après
import avec les commandes de `recette.md`.

## Contrôles effectués sur cette passe

- historique Git propre et découpé en commits français ;
- palette `AppColors` non modifiée ;
- recherche des libellés parasites signalés dans la landing ;
- vérification structurelle des fichiers Dart modifiés (délimiteurs équilibrés) ;
- inspection des routes de footer et de leur correspondance avec `informationPages` ;
- bundle Git et script d'import vérifiés séparément lors de la création de l'archive.

## Tests ajoutés

La suite couvre désormais aussi :

- le retour de la section Constat avec les deux indicateurs et la source ;
- l'accès aux deux audiences de `MatchingStoryDemo` et la sélection d'une étape ;
- les tests préexistants des fonctionnalités, tarifs, footer, responsive et entrée native.

La courbe du footer est volontairement une animation continue : le test qui
exigeait zéro callback d'animation sur la landing a été supprimé, car cette
hypothèse contredirait désormais le comportement produit demandé. La courbe est
figée lorsque la réduction des animations est activée.
