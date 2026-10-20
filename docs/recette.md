# Recette avant intégration

## Commandes

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

Référence du dépôt : Flutter 3.47.7 / Dart 3.13.5.

## Contrôles fonctionnels

- Vérifier la section **Le constat** et la présence de la source sous les cartes.
- Basculer Candidat / Entreprise dans les fonctionnalités et ouvrir chaque entrée.
- Dans l'univers orange, laisser la démonstration terminer un cycle candidat puis
  entreprise ; tester lecture/pause et les cinq segments cliquables.
- Vérifier que la préférence « réduire les animations » bloque l'autoplay.
- Carrousel : glisser, utiliser les boutons, les points, Tab puis ←/→.
- Ouvrir les liens des quatre rubriques du footer et revenir à la landing.
- Vérifier la conservation du scroll après retour d'une page publique.
- Laisser le footer visible : le fil lumineux doit évoluer lentement sans scroll,
  du bleu vers l'orange, puis recommencer sans saut brutal.
- Vérifier que les boutons Connexion / Inscription réagissent au survol et au
  focus clavier sans modifier la palette officielle.

## Contrôles visuels

| Élément | Attendu |
| --- | --- |
| Navbar | Capsule claire, CTA Connexion / Inscription animés et lisibles |
| Hero | Composition Figma, sans libellé « Aperçu illustratif » |
| Constat | Titre à gauche, deux cartes métriques à droite, source visible |
| Fonctionnalités | Sélecteur Candidat / Entreprise et détails interactifs |
| Univers | Fond orange fort + parcours animé complet, sans cercle traversant |
| Tarifs | Carrousel propre, aucun texte d'instruction de recette |
| Footer | Quatre rubriques, fil lumineux bleu → orange autonome |
| Pages | Contenu formel, sans « à compléter » ni promesse inventée |
| Palette | Valeurs `AppColors` strictement inchangées |

Contrôler à 320, 390, 768, 1024, 1440 et 1920 px, avec navigation clavier et
texte agrandi. Une inspection visuelle reste nécessaire pour juger la fidélité
pixel à pixel avec Figma.

## Import de la livraison

Depuis le dépôt local sur `landing-page`, le bundle Git doit permettre une avance
rapide. Le script de livraison sauvegarde d'abord tout changement local dans un
stash, importe la branche, vérifie le HEAD final puis affiche les nouveaux commits.
En cas d'historique divergent, il s'arrête sans reset ni écrasement du dépôt.
