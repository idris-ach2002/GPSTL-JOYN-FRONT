# Conception de la landing — version améliorée

## Principes conservés

La palette `AppColors` reste inchangée. Le projet utilise Material 3 fourni par
Flutter, sans dépendance d'animation ou de carrousel ajoutée. Les composants
Material gardent le focus clavier, les sémantiques et les interactions standard.

Les sections retirées lors de la première passe restent exclues : avant/après,
analyse détaillée du CV, « JOYN dans ta poche », témoignages et carrousel de
candidatures marketing. La section **Constat** revient, car elle participe à la
narration principale de la maquette.

## Section Constat

`ConstatSection` reprend le contraste de la référence : texte éditorial à gauche,
deux cartes chiffrées à droite et mouvement d'entrée discret. Les chiffres de la
maquette initiale n'ont pas été repris lorsqu'ils ne correspondaient pas à une
source vérifiable.

Les deux indicateurs affichés proviennent du baromètre T1 2026 de La bonne
alternance : près de 320 000 candidatures déposées sur la plateforme et 74 % de
candidatures spontanées. La source apparaît aussi dans l'interface.

Source : https://labonnealternance.apprentissage.beta.gouv.fr/barometre

## Fonctionnalités

Le sélecteur Candidat / Entreprise pilote quatre fonctionnalités de chaque côté.
Chaque entrée conserve un contenu manipulable localement pour rendre la promesse
compréhensible sans appel réseau : profil, recommandations, suivi, conversation,
présentation entreprise, offre, talents recommandés et pipeline de recrutement.

Les références Trello restent attachées aux contenus du domaine pour auditer le
périmètre fonctionnel sans afficher des identifiants techniques dans la landing.

## Univers orange : démonstration de parcours

L'ancien bloc centré sur un score unique est remplacé par `MatchingStoryDemo`.
Il s'agit d'une démonstration auto-jouée en Flutter, pensée comme une courte vidéo
produit tout en restant nette à toutes les résolutions et sans asset pré-rendu.

Le parcours candidat enchaîne :

1. profil ;
2. offres recommandées ;
3. intérêt réciproque ;
4. suivi de candidature ;
5. conversation / entretien.

Le parcours entreprise enchaîne :

1. identité de l'entreprise ;
2. publication d'une offre ;
3. profils recommandés ;
4. suivi des candidatures ;
5. conversation.

La lecture bascule automatiquement d'une audience à l'autre. Les boutons
Candidat / Entreprise, les cinq segments de progression et lecture/pause donnent
un contrôle manuel complet. Avec la préférence système de réduction des
animations, l'autoplay est désactivé.

## Tarification

Le carrousel conserve le `PageView`, les boutons et la navigation clavier. Les
phrases de recette ou d'instruction (« glisse les cartes », modalités à confirmer,
etc.) ne sont plus rendues dans l'interface. Les montants candidat restent ceux
de la maquette fournie. Le contenu entreprise demeure présenté sans inventer un
prix fixe : la formule premium reste « Sur devis ».

## Navigation et accès au compte

La navbar garde la capsule inspirée d'Orbix. Les boutons Connexion et Inscription
ne reposent plus sur un simple changement d'échelle : survol et focus combinent
translation, inversion de surface, halo, dégradé et déplacement de l'icône. Aucun
ticker ne tourne au repos ; les transitions sont neutralisées si l'utilisateur
réduit les animations.

## Footer et pages publiques

Les libellés de production visibles ont été supprimés. Le footer conserve quatre
rubriques orientées utilisateur : Produit, Entreprises, Ressources et Légal.
Les pages associées décrivent les parcours et comportements réellement présents
dans le projet sans inventer d'identité juridique, de coordonnées de contact ou
de durée de conservation absentes des sources.

`FooterCurve` est désormais autonome : un `AnimationController` de 12 secondes
fait voyager un gradient bleu → orange sur une courbe sinusoïdale. Le halo est
peint dans un `RepaintBoundary`; il ne dépend plus du scroll. En réduction des
mouvements, le contrôleur est arrêté et la courbe reste fixe.

## Rendu et accessibilité

Les effets décoratifs lourds restent isolés par `RepaintBoundary`. Les widgets
interactifs Material assurent clavier, focus et sémantiques. Les breakpoints sont
traités par `LayoutBuilder` et les blocs évitent les hauteurs fixes pour conserver
la lisibilité avec agrandissement du texte.

Le parcours natif reste distinct du site web : le web conserve la landing, tandis
que l'entrée Android/iOS passe par le splash puis la route de connexion.
