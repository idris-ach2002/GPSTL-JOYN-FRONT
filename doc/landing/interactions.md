# Interactions et accessibilité

[Sommaire](README.md) · [Jetons](fichiers/joyn_tokens.md)

## Commandes et états

| Élément | Interaction | Effet et limites |
| --- | --- | --- |
| Menu | Survol, clic, clavier | Ouvre un groupe ; Échap ferme et rend le focus au déclencheur |
| Carrousel | Boutons, balayage, flèches gauche/droite avec focus interne | Change de page sans boucler ; commandes de bord désactivées |
| Profil | Saisie, validation, exemple et effacement | Change l’aperçu local ; aucune création de compte |
| Offres | Recherche, filtre Paris et favoris | Filtrage local ; favoris conservés pendant la visite |
| Usages | Onglets candidat/recruteur et balayage horizontal | Partage une même zone de présentation ; vitesse seuil de 240 pixels/s |
| FAQ | Texte, catégorie, pagination et dépliage | Recherche dans questions et réponses ; lien vers l’assistance |
| Chapitres mobiles | Déplier/replier | Un chapitre ouvert à la fois ; contenu conservé hors focus |
| Pied de page | Liens ; groupes dépliables sur mobile | Navigation via le même callback que la barre |

Les flèches du carrousel ne sont pas des raccourcis globaux de page. Elles agissent lorsque le focus se trouve dans le sous-arbre associé à `CallbackShortcuts`.

## Mouvement

Les dessins de menu associent un tracé orange à un agrandissement de 12 %. Le signe JOYN effectue une rotation limitée lorsque son état actif change. Ces animations sont déclenchées par l’interaction et ne tournent pas en boucle.

`GentleDepth` normalise la position du pointeur entre -1 et 1 sur chaque axe, puis la multiplie par `parallaxTravel`, soit 8 pixels. Sortir de la zone remet la cible à zéro. Le composant rend directement son enfant sous 1024 pixels ou avec réduction des mouvements.

La liaison de `MatchSignature` interpole son tracé entre les deux états de la scène. Elle représente une mise en relation illustrée, pas l’envoi d’un message.

## Scène liée au défilement

La scène de `ScrollJourneySection` dispose d’un espace de document égal à trois fois la hauteur utile. La hauteur utile est la hauteur de vue moins `topInset`. Le déplacement est borné entre zéro et deux hauteurs utiles ; la progression est ce déplacement divisé par sa distance totale. Le composant utilise cette progression pour afficher l’une des quatre étapes.

Le carrousel remplace la scène si la largeur est inférieure à 1024 pixels, si la hauteur utile est inférieure à 812 pixels, si la taille de texte dépasse 110 % de la taille de référence ou si les mouvements sont réduits. La scène écoute le défilement existant ; elle n’installe pas de gestionnaire de roue global.

## Clavier et sémantique

Les contrôles reposent sur des boutons et champs Flutter. Les états sélectionné, déplié et activé sont portés par `Semantics` selon leur usage. Les résultats dynamiques de recherche, de sélection et d’aperçu utilisent des régions vivantes aux endroits prévus dans le code.

Les boutons exposent un focus visible. Les chapitres masqués sont exclus du parcours de focus. Les commandes de menu fournissent un curseur de clic. Les illustrations accompagnées de texte sont décoratives pour éviter des annonces redondantes.

Le test de contraste vérifie le texte bleu nuit des boutons de texte sur leurs fonds résolus, y compris survol et focus. Il ne constitue pas un audit exhaustif de toutes les combinaisons de couleurs ni une certification d’accessibilité.

## Mouvements réduits

Les composants animés consultent `MediaQuery.disableAnimationsOf`. Les transitions concernées utilisent une durée nulle et la scène au scroll devient un carrousel. Les pages HTML désactivent le défilement doux avec `prefers-reduced-motion`.

## Conservation des données

Les interactions de présentation restent dans leurs états Flutter. Un rechargement recrée les états. La connexion, les candidatures et les messages ne doivent pas être déduits du résultat d’une scène illustrée ; consulter [les limites de service](integration.md).
