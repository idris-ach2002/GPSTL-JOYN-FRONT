# Conception de la landing — version améliorée

## Références

Sources utilisateur examinées : les deux archives de code originales, le socle
vierge `GPSTL-JOYN-FRONT-New-Branch-landing-page.zip`, la planche Figma,
`Base.zip`, le Trello, Orbix, puis `univers.png`, `plans-footer.png` et le journal
`Texte collé(2).txt` fournis pour cette passe.

La nouvelle capture `plans-footer.png` remplace la référence précédente du footer
bleu nuit : le footer est désormais clair, avec les mêmes rubriques et intitulés.
La courbe orange de la proposition précédente est conservée, pilotée par le scroll.
Les sections avant/après, analyse CV, JOYN dans ta poche, témoignages et carrousel
d'offres/candidatures restent exclues. Le carrousel demandé ici concerne les tarifs.

La palette définie par `AppColors` conserve toutes les valeurs de l'archive de
référence. Le formatage Dart peut modifier les espaces, jamais ces couleurs.
Les nouveaux décors utilisent les mêmes tokens et leurs transparences.

## Material 3 et structure

Le projet reste Flutter/Dart, avec la bibliothèque Material 3 intégrée au SDK.
Aucun package React MUI, moteur d'animation ou package de carrousel n'est ajouté.
Roboto est embarquée depuis les ressources du SDK, avec sa licence ; le rendu
web ne dépend pas d'un téléchargement de police externe.
`SegmentedButton`, `PageView`, `ListTile`, `Card`, `Chip`, `TextField`, les boutons
Material, `Shortcuts`, `Actions` et `Focus` portent les interactions standard.

- `lib/app` : thème explicite et déclaration des routes.
- `lib/features/landing/domain` : contenus fonctionnels et propositions tarifaires.
- `lib/features/landing/presentation` : sections, démonstrations et décoration.
- `lib/features/information` : pages éditoriales et catalogue des liens de footer.
- `lib/features/auth` : destinations de raccordement au parcours de compte.
- `lib/features/startup` : parcours natif préexistant, non redessiné dans cette passe.

Références officielles Flutter, consultées le 20 octobre 2026 :
https://docs.flutter.dev/release/breaking-changes/material-3-default
https://docs.flutter.dev/cookbook/design/themes
https://docs.flutter.dev/install/manual

## Transition d'univers et coût du rendu

`ScrollAtmosphere` dessine une couche indépendante : fondu bleu nuit/orange/fond
clair, grille discrète, halos au `MaskFilter.blur` et voile lumineux courbe.
La phase des halos dépend de la position de défilement. Aucun cercle ne traverse
la page en boucle. Le contenu ne se reconstruit pas à chaque pixel de scroll :
le painter reçoit directement le contrôleur en tant que Listenable.

`RepaintBoundary` isole la décoration. Le flou est réservé à des formes simples,
plutôt qu'à un BackdropFilter sur l'ensemble de la page. Mesurer néanmoins le
rendu sur les machines cibles, particulièrement sur des GPU intégrés.
La réduction des animations neutralise la parallaxe, les transitions et les
changements d'échelle ; les informations et interactions restent accessibles.

## Démonstrations des fonctionnalités

Chaque audience possède quatre rubriques et un laboratoire propre :

| Candidat | Interaction locale |
| --- | --- |
| Profil | Simuler un préremplissage de trois champs, puis réinitialiser |
| Recommandations | Activer quatre critères ; score pédagogique = critères actifs / 4 × 100 |
| Candidatures | Faire évoluer Envoyée → En étude → Entretien |
| Conversation | Ajouter au plus trois messages à l'état de la vue |

| Entreprise | Interaction locale |
| --- | --- |
| Présentation | Passer d'un profil à compléter à un profil renseigné |
| Offres | Simuler une publication puis une clôture |
| Profils recommandés | Sélectionner trois profils fictifs et consulter leurs parcours |
| Candidatures | Faire évoluer le statut d'une candidature fictive |

Le label « Démo interactive · données fictives » est toujours visible.
Aucun fichier CV n'est lu, aucun message n'est transmis et aucune offre réelle
n'est créée. Le champ de message est vidé lors de l'ajout ; les messages et le
TextEditingController sont libérés au démontage. Le nombre de messages est borné.
Le score local est une illustration expliquée, pas la formule métier du backend.
Le changement de rubrique recrée la démo et réinitialise ses données.

Traçabilité Trello conservée dans les objets de contenu : CA29/53/56/68 pour le
profil, CA20/33 pour les recommandations, CA27/30/57/76 pour les candidatures,
CO31/26 pour les échanges ; R46/59/65/A62 pour l'entreprise, R38/39/58/70/71 pour
les offres, R45/34/47/49 pour les profils et R72/74 pour les statuts recruteur.
Ces cartes décrivent le périmètre prévu, pas la disponibilité des services.

## Carrousel de tarification

Le `PageView` montre trois cartes sur grand écran et une carte centrale avec
aperçus latéraux sur une fenêtre étroite. La position initiale est JOYN+ côté
candidat et Membre premium côté entreprise. Chaque audience possède son contrôleur.
Un changement de largeur qui modifie le nombre de cartes visibles réinitialise
ce contrôleur sur la formule centrale : choix volontaire pour conserver une
composition cohérente après changement de breakpoint.

Le déplacement utilise une courbe easeInOutCubic. Les cartes latérales sont
légèrement abaissées et réduites. Le survol accentue bordure et halo ; la carte
JOYN+ conserve son fond navy et son aura orange. Le fond est lié au scroll.
La hauteur du PageView vient d'une mesure réelle hors scène des cartes, sans
focus ni Spacer, puis est partagée par les cartes visibles. Aucune estimation
de police ni hauteur fixe n'est utilisée pour leur contenu. La mesure suit le
texte agrandi et les retours à la ligne, pour éviter de tronquer les cartes.

Les boutons précédent/suivant et les points de pagination donnent le focus au
carrousel. `Shortcuts` et `Actions` traitent ←/→ uniquement dans son sous-arbre :
ils ne capturent pas les touches de la messagerie ou d'autres parties de la page.
Aux extrémités, les commandes n'avancent pas et le bouton correspondant est désactivé.
Avec mouvements réduits, le contrôleur utilise `jumpToPage`, sans durée nulle
passée à une animation de scroll. Tous les contrôleurs et le FocusNode sont libérés.

Les montants candidat (0 €, 15,99 €/mois, 4,99 €/48 h), l'essai et les avantages
visuels viennent des maquettes. Les accès premium reprennent ceux de base.
Le Boost est un complément de visibilité ; sa scène est un aperçu fictif.
Les offres entreprise restent des propositions, sans montant inventé.
La note de confirmation commerciale est visible ; les CTA ne déclenchent pas de paiement.

## Footer, liens et retour

Le catalogue `footer_links.dart` est partagé avec les tests :
Produit, Entreprises, Ressources et Légal conservent exactement les intitulés de
la capture. Tarifs pointe sur l'ancre existante, Espace recruteur sur la connexion.
Les dix autres liens ouvrent leurs pages publiques via MaterialApp.routes.

`InformationScreen` conserve une structure commune, un contenu propre à chaque
route, une action éventuelle et un retour explicite. Le retour dépile les pages
jusqu'à la landing : son état et sa position de scroll restent montés. Une entrée
directe sans route précédente utilise le remplacement vers `/`.
Les routes fonctionnent aussi via les URL nommées du routeur Flutter.

Les documents juridiques et coordonnées officielles n'étant pas fournis, leurs
pages signalent ce qui reste à publier. Aucune clause contractuelle, adresse ou
politique de données officielle n'est inventée. Remplace-moi est présenté comme
un concept de la maquette dont les modalités restent à préciser.

`FooterCurve` n'a plus de Timer ni AnimationController. Sa sinusoïde dépend de
`scroll.offset / 240`, puis s'immobilise lorsque le défilement s'arrête. Il n'utilise
plus `TickerMode.of`, mentionné comme déprécié dans le journal utilisateur.

## Erreurs du journal utilisateur

La carte principale du hero avait une hauteur imposée de 340 px alors que son
contenu pouvait dépasser 400 px. La hauteur fixe est supprimée et la composition
sur le canvas est agrandie : les cartes conservent leur contenu naturel.

Les tests avançaient l'horloge directement après une action. Le premier frame
installait alors seulement l'animation, laissant la route sortante ou l'ancien
contenu d'AnimatedSwitcher encore présents. `finishTransition` installe un frame,
avance l'animation, puis traite le dernier frame avant les assertions.
Les nouvelles interactions et le retour depuis le footer ont leurs tests dédiés.

L'arrêt inattendu du compilateur signalé dans le journal ne contient pas sa cause.
Il ne faut donc pas l'attribuer sans preuve aux échecs de tests. Les résultats de
la nouvelle compilation et des vérifications sont consignés séparément.
