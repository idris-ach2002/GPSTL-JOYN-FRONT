# Recette avant intégration

## Commandes

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

Référence de validation : Flutter 3.47.7 / Dart 3.13.5.
Les résultats exécutés sont consignés dans `verification.md`.

## Contrôles fonctionnels

- Basculer candidat/entreprise et sélectionner chacune des huit démonstrations.
- Import fictif : les champs se complètent et peuvent être réinitialisés.
- Compatibilité : quatre critères actifs donnent 100 %, trois donnent 75 % ;
  aucun score métier n'est prétendu.
- Candidature : les trois statuts défilent par action explicite.
- Messagerie : ajouter un message local et quitter la rubrique ; il n'est pas conservé.
- Carrousel : glisser, utiliser les boutons, les points, Tab puis ←/→.
- Vérifier les extrémités : absence de retour circulaire et boutons désactivés.
- Vérifier que les flèches ne sont pas capturées par le carrousel depuis la messagerie.
- Ouvrir les liens des quatre rubriques du footer et utiliser le retour à JOYN.
- Confirmer la conservation de la position de défilement au retour d'une page.
- Confirmer que le fil orange s'arrête quand le scroll s'arrête.

## Contrôles visuels

| Élément | Référence / attendu |
| --- | --- |
| Navbar | Capsule Orbix, palette JOYN, connexion/inscription côte à côte |
| Hero | Composition et lumières existantes, contenu sans hauteur forcée |
| Fonctionnalités | Sélection lisible, schémas et panneaux interactifs distincts |
| Univers | Fondu navy/orange/clair, halos diffus et grille ; aucun cercle infini |
| Tarifs | Cartes claires, JOYN+ navy, halo orange, aperçu Boost |
| Carrousel | Carte active mise en valeur ; aucune troncature des textes |
| Footer | Fond clair et rubriques Produit, Entreprises, Ressources, Légal de plans-footer.png |
| Pages | Intitulé propre, contenu associé au lien, retour explicite |
| Palette | Valeurs AppColors identiques aux sources |

Contrôler à 320, 390, 768, 1024, 1440 et 1920 px. Vérifier le texte agrandi,
le clavier seul, les préférences de réduction du mouvement et les hauteurs courtes.
Les tests automatisés couvrent notamment 320, 768 et 1440 px, ainsi que les tarifs
avec un facteur de texte de 1,6 à 390 px.

Une inspection de composition ne prouve pas une identité au pixel près avec
Figma : contrôler les mêmes dimensions et les états exacts des maquettes avant
validation finale. Le comportement natif préexistant reste testé, mais sa nouvelle
conception est différée comme demandé.

## Import de la livraison

Sur une copie du dépôt à `f719022`, reproduire des fichiers modifiés et les dossiers
non suivis du premier rsync. Exécuter `importer-joyn.sh` : vérifier leur sauvegarde
en stash, l'avance rapide de `landing-page`, les commits et un état propre.
Tester aussi un historique divergent : le script doit s'arrêter avant toute
sauvegarde ou modification des fichiers du dépôt cible.
