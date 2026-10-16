# Navigation

[Sommaire](README.md) · [Menu](fichiers/landing_mega_navigation.md) · [Routeur](fichiers/app_router.md)

## Routes actives

| URL | Écran | Traitement |
| --- | --- | --- |
| `/` | `LandingScreen` | Entrée générale |
| `/candidats` | `LandingScreen` | Rejoint le parcours candidat après le premier rendu |
| `/entreprises` | `LandingScreen` | Rejoint les usages candidat/recruteur |
| `/connexion` | `ServiceScreen` | Présente l’état de connexion indisponible |
| `/assistance` | `ServiceScreen` | Guides, informations et question reçue |
| `/assistance?theme=donnees` | `ServiceScreen` | Rend visible le bloc des données de navigation |
| `/assistance?theme=accessibilite` | `ServiceScreen` | Rend visible le bloc de navigation et mouvements |
| `/assistance?question=…` | `ServiceScreen` | Préremplit la question issue de la FAQ |

Une URL inconnue affiche un message et un retour à JOYN. Les ancres de section sont internes à la page : elles ne sont pas des routes indépendantes et ne modifient pas l’URL.

## Menu sur ordinateur

La barre complète apparaît à partir de 1280 pixels de largeur de vue. Elle expose les groupes d’indices `0`, `1`, `2`, `3` et `5` de `landingGroups`, puis Assistance et Connexion. Le groupe Ressources reste une définition de liens consultable par la recherche du menu ; il n’est pas un déclencheur de la barre.

`OverlayPortal` affiche le panneau. `LayerLink`, `CompositedTransformTarget` et `CompositedTransformFollower` le rattachent au bas de la barre. Le voile de fond commence sous la navigation, qui reste accessible pour changer de groupe.

Le survol ou le clic ouvre le groupe. Une sortie de pointeur programme la fermeture après 180 ms. Entrer dans la barre ou le panneau annule cette fermeture. L’ouverture verticale dure 250 ms. Assistance et Connexion partagent la même ligne de navigation.

La hauteur du panneau est bornée par la place restante dans la vue et par `menuPanelMaxHeight`. Ses liens sont disposés en colonnes, avec une zone de contexte qui reprend le lien survolé.

## Menu compact

Sous 1280 pixels, la barre affiche le signe JOYN, l’accès au compte et le bouton de menu. Le panneau occupe la hauteur restante. Son premier niveau présente les rubriques ; sélectionner une rubrique ouvre ses liens. Une commande permet de revenir au premier niveau.

La recherche examine les libellés et descriptions de tous les groupes, de l’assistance et du compte. Les liens sont dédoublonnés par la paire cible/libellé. Cette recherche utilise les minuscules ; contrairement à la recherche FAQ, elle ne remplace pas les accents.

## Résolution d’une cible

`LandingScreen.navigate` applique l’ordre suivant : routes de service, ouverture du chapitre mobile concerné, pages HTML autorisées, retour en haut, puis défilement vers une ancre. Après ouverture d’un chapitre, le déplacement est demandé au rendu suivant pour mesurer le contenu visible.

Le déplacement utilise `Scrollable.ensureVisible`. Le retour en haut utilise le contrôleur principal. La durée est nulle si la réduction des mouvements est demandée, ou si l’appelant précise `instant`.

## Pictogrammes

Les groupes utilisent `_groupSymbols`. Chaque lien de menu est résolu par son libellé dans `symbolFor`, indépendamment de sa destination. Deux actions vers une même section peuvent donc avoir des dessins différents.

Le dessin est exclu de l’arbre sémantique lorsque le libellé adjacent fournit déjà le sens. Les boutons uniquement iconographiques portent un libellé sémantique et une infobulle. Un libellé de lien sans association dans `symbolFor` lève une `ArgumentError` ; les tests vérifient les associations et la distinction entre liens d’un même groupe.

## Ajouter un lien

1. Définir le libellé, la description et la cible dans `landing_navigation.dart`.
2. Associer le libellé à un dessin dans `symbolFor`.
3. Pour une section, enregistrer sa clé dans `anchors`, son contenu dans `parts` et sa place dans `mobileChapters`.
4. Pour une route, l’enregistrer dans `appRouter` et dans la résolution des cibles si nécessaire.
5. Vérifier les modes ordinateur et compact, le clavier et le retour depuis le panneau.

Pour un guide, ajouter explicitement sa cible dans la liste autorisée de `openResource`. Une chaîne arbitraire n’est pas ouverte comme URL.
