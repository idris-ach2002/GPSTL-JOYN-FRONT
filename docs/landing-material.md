# Conception et intégration

## Sources et périmètre

Sources utilisateur examinées le 20 octobre 2026 :

- `GPSTL-JOYN-FRONT-New-Branch-landing-page.zip` : base vierge, commit `f719022`.
- `GPSTL-JOYN-FRONT(1).zip` : référence de code pour le hero et les tokens.
- `maquette-figma-GPSTL JOYN.zip` : planche Figma et exports PNG.
- `Base.zip` : captures de l'implémentation existante.
- `orbix-navbar.png` : référence de structure de la navigation.
- `Capture d’écran 2026-10-20 à 18.57.24.png` : référence du footer bleu nuit.
- `trello- gpstl-joyn.json` : source du périmètre fonctionnel, pas une preuve de
  disponibilité des services ni un document de tarification validée.

La palette `AppColors` est copiée à l'identique depuis l'implémentation fournie.
Le thème utilise explicitement ses rôles Material : pas de génération de palette
par `ColorScheme.fromSeed`. Les transparences et gradients déjà présents dans
le hero sont conservés ; les nouveaux panneaux utilisent les tokens JOYN.

## Material UI dans ce projet

Le projet est Flutter/Dart. La bibliothèque retenue est **Material 3 intégrée à
Flutter**, importée via `package:flutter/material.dart`. Aucun package React MUI
ni bibliothèque Flutter tierce non identifiée n'a été ajouté.

Références officielles Flutter, consultées le 20 octobre 2026 :

- Flutter, « The ThemeData.useMaterial3 flag is true by default » :
  https://docs.flutter.dev/release/breaking-changes/material-3-default
- Flutter, « Use themes to share colors and font styles » :
  https://docs.flutter.dev/cookbook/design/themes

L'ancienne landing activait déjà Material 3. Le changement porte donc sur
l'utilisation des composants prêts à l'emploi et la réduction du code spécifique,
plutôt que sur une migration d'un moteur Flutter différent.

## Composition de la page

| Ordre | Section | Décision |
| --- | --- | --- |
| 1 | Hero et navbar | Hero conservé ; capsule Orbix blanche, groupe de liens, deux actions côte à côte |
| 2 | Fonctionnalités | SegmentedButton candidat/entreprise, quatre rubriques par audience et détail sélectionnable |
| 3 | Entreprises | Panneau bleu nuit, bénéfices issus du backlog et aperçu illustratif |
| 4 | Changement d'univers | Grande section orange statique ; aucun cercle mobile |
| 5 | Formules | Même structure candidat, offre entreprise à deux niveaux |
| 6 | Aide courte | ExpansionTile Material avec réponses locales |
| 7 | Footer | Bleu nuit, promesse de la capture, quatre colonnes, courbe orange animée |

Les sections avant/après, comment ça marche, analyse CV, JOYN dans ta poche,
témoignages et carrousel d'offres/candidatures ne sont pas intégrées.
La démo interactive d'analyse n'est pas reprise. La section orange ne calcule ni
ne simule de score. Les chiffres du hero sont uniquement ceux d'un aperçu
illustratif ; ils ne représentent pas une mesure de performance du produit.

## Choix des composants

- `SegmentedButton` remplace les sélecteurs faits de Containers et InkWell.
- `MenuAnchor` / `MenuItemButton` remplacent le mega-menu à OverlayEntry et timers.
- `FilledButton`, `OutlinedButton`, `TextButton` conservent leurs interactions
  Material, focus, activation clavier et surface de contact.
- `Card`, `ListTile`, `Chip`, `ExpansionTile` portent les surfaces et interactions.
- `AnimatedScale`, `AnimatedContainer`, `AnimatedSwitcher` assurent les transitions
  simples. Aucun moteur d'animation externe n'est ajouté.
- Les personnalisations restent limitées au hero repris, au symbole JOYN et à la
  courbe de footer. Les dessins décoratifs ne portent pas de logique métier.

La navigation est compacte sous 1080 px de largeur utile. Sous 650 px utiles,
les accès au compte restent côte à côte sur une deuxième ligne. Le navigateur
mobile conserve ainsi une landing consultable, différente du parcours natif.

## État, navigation et cycle de vie

Chaque sélecteur détient son état local : modifier les fonctionnalités ne change
pas l'audience des tarifs. Le changement d'audience réinitialise le détail actif.
Les contenus statiques sont séparés dans des objets immuables et des listes const.
Pas de gestionnaire d'état global pour une sélection purement visuelle.

`LandingScreen` possède le ScrollController et les clés de sections. Les liens
utilisent `Scrollable.ensureVisible`. Les sections restent montées, y compris
lorsqu'elles ne sont pas visibles, afin que les ancres puissent être résolues.
Ce choix convient à une page marketing courte ; il est à reconsidérer si le
contenu devient volumineux. Le contrôleur est libéré au démontage.

Les accès `/connexion` et `/inscription` utilisent les routes MaterialApp.
Le splash choisit son parcours via `kIsWeb`, sans confondre plateforme et largeur.
Il annule son Timer au démontage et utilise `pushReplacementNamed` pour éviter
que le bouton Retour rejoue l'introduction.

La préférence `disableAnimations` désactive les apparitions, le survol animé,
les transitions de sélection et la courbe ; elle court-circuite l'attente native.
La courbe est décorative, isolée dans une RepaintBoundary, et se repeint via
CustomPainter.repaint. Son contrôleur est libéré correctement. Elle reste active
lorsque la landing est montée, même si le footer est hors de l'écran : mesurer
ce coût sur appareil avant de décider d'une détection de visibilité supplémentaire.

## Traçabilité du contenu fonctionnel

| Audience / rubrique | Cartes Trello |
| --- | --- |
| Profil candidat / CV | CA29, CA53, CA56, CA68 |
| Recommandations d'offres | CA20, CA33 |
| Candidatures et dashboard | CA27, CA30, CA57, CA76 |
| Messagerie | CO31, CO26 |
| Entreprise et validation | R46, R59, R65, A62 |
| Création, modification, clôture d'offres | R38, R39, R58, R70, R71 |
| Profils recommandés et dashboard recruteur | R45, R34, R47, R49 |
| Statuts et échanges recruteur | R72, R74, CO31, CO26 |

Les fonctionnalités ne sont pas annoncées comme déjà connectées à un backend.
Les anciennes promesses non étayées dans ces cartes (formation Skill Gap,
Remplace-moi, alertes par seuil) ne sont pas reprises dans le nouveau sélecteur.

## Tarifs : référence et propositions

Les trois montants candidat viennent de Figma : 0 €, 15,99 €/mois, 4,99 €/48 h.
Le badge de sept jours offerts et le quota gratuit de dix « Intéressé » par jour
viennent aussi de la maquette. Ils ne sont pas des règles backend existantes.
JOYN+ reprend explicitement les accès de base, remplace le quota par l'illimité
et ajoute les avantages visuels de la référence. Le Boost est un complément de
visibilité, pas un troisième abonnement dont les droits seraient incomplets.

La proposition entreprise distingue Membre (présentation) et Membre premium
(recrutement). Premium inclut tous les droits de Membre et ajoute la gestion des
offres, les recommandations, les candidatures et la messagerie. Aucun montant
entreprise n'est inventé : la carte indique « Sur devis / Tarif à définir ».

La page affiche que tarifs, essais et limites restent à confirmer avant ouverture.
Les CTA ouvrent l'inscription ; ils ne déclenchent aucun paiement. Le backend
devra être la source de vérité des autorisations et quotas si ces offres sont
validées. Les textes et listes se modifient dans `pricing_plan.dart`.

## Raccordement de l'authentification

Les écrans livrés sont des destinations d'attente, sans formulaire ni collecte
de mot de passe. Les références Git incluses contiennent d'autres travaux :

- `connexion-dashboard` : `lib/features/auth/presentation/login_page.dart`,
  contrôleur et repository simulé ; sa palette est différente de celle de la
  landing. Ne pas fusionner ce thème sans adaptation aux tokens JOYN retenus.
- `feature/inscription` : parcours d'inscription et onboarding, avec dépôts simulés.

Ils n'ont pas été fusionnés automatiquement : leur intégration complète dépasse
la landing et introduirait des écrans, dépendances et simulations supplémentaires.
Remplacer les builders des routes dans `lib/app/app.dart` lors de l'intégration.
La navigation native vers `/connexion` est déjà en place.

## Limites de validation

Aucun SDK Flutter/Dart n'est installé dans l'environnement de réalisation.
Le code n'a donc pas été compilé, formaté avec dart format, analysé par Dart ou
rendu dans un navigateur. La comparaison visuelle au pixel près n'est pas faite.
Les tests ajoutés et le workflow sont préparés, non exécutés. Le rapport statique
ne se substitue pas à Flutter analyze ni à la recette visuelle.
