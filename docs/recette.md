# Recette avant fusion

## Vérifications automatisées à exécuter

1. Installer le SDK du projet (Dart compatible avec `^3.13.5`).
2. Exécuter `flutter pub get` puis `dart format lib test`.
3. Exécuter `flutter analyze`, corriger les erreurs et avertissements.
4. Exécuter `flutter test` : droits hérités, bascule des deux sélecteurs,
   navigation vers la connexion, parcours natif, annulation du timer,
   réduction des mouvements et affichage web à 320, 768 et 1440 px.
5. Exécuter `flutter build web --release`.
6. Ne considérer le workflow GitHub comme validé qu'après sa réussite effective.

## Comparaison visuelle à effectuer

Ouvrir les maquettes et l'application à largeur identique. Les exports PNG seuls
ne fournissent pas toutes les propriétés Figma, notamment les réglages de chaque
texte. Ajuster les écarts constatés après rendu, sans modifier AppColors.

| Élément | Résultat attendu |
| --- | --- |
| Navbar | Capsule Orbix ; palette JOYN ; connexion et inscription côte à côte ; aucun débordement |
| Hero | Hiérarchie et composition du hero existant ; halos contenus dans la section |
| Retraits | Aucun avant/après, schéma CV, bloc mobile, témoignage ou carrousel |
| Fonctionnalités | Candidat et entreprise montrent des contenus distincts ; sélection du détail réinitialisée |
| Entreprises | Texte et aperçu lisibles, sans données personnelles réelles |
| Orange | Rupture nette, aucun cercle animé traversant la page |
| Tarifs candidat | 3 cartes, JOYN+ sombre, montants identiques à la référence |
| Tarifs entreprise | 2 cartes ; premium comprend les droits de base ; aucun prix chiffré inventé |
| Footer | Fond navy, texte de la capture, 4 colonnes, fine courbe orange animée |
| Authentification | Routes accessibles ; disponibilité limitée expliquée ; aucun faux succès de connexion |

Contrôler à 320, 390, 768, 1024, 1440 et 1920 px, puis avec agrandissement du texte
et navigation uniquement au clavier. Vérifier aussi les hauteurs courtes en
paysage et l'ouverture/fermeture du menu compact.

## Parcours natif à exécuter sur Android/iOS

- Démarrage : marque sur fond navy puis `/connexion`, sans afficher la landing.
- Retour : ne revient pas à l'introduction après son remplacement.
- Réduction des animations système : accès immédiat à la route de connexion.
- Mise en arrière-plan et retour : absence d'erreur de timer ou de contrôleur.
- Après intégration de l'authentification : clavier virtuel, champs, validation,
  appels backend et erreurs réseau à tester dans leur branche métier.
