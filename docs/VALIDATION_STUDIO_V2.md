# Validation — Studio recruteur V2

Contrôles exécutés le 29 octobre 2026. Livraison basée sur `4a888dd`, sur
`feat/espace-recruteur`. Les commits utilisent exclusivement l’identité Git configurée
Idris Achabou ; aucun co-auteur ajouté.

## Résultats

| Contrôle | Résultat |
| --- | --- |
| Analyse Flutter | Aucune erreur, aucun avertissement, aucun diagnostic |
| Suite complète | 163 tests réussis |
| Compilation web release, mode mock | Réussie |
| Compilation web release, mode API | Réussie avec URL de démonstration, sans connexion à un serveur réel |
| Mise en page | Parcours recruteur à 320, 390, 768 et 1440 px, clair et sombre |
| Texte agrandi | Parcours à 320 et 1440 px, sombre, texte à 130 %, contraste et animations réduites |
| Contrôle visuel | Captures Flutter des pages recruteur sur mobile et bureau, clair et sombre |
| Import Git | Application depuis `4a888dd`, deuxième passage sans changement, refus d’un dépôt modifié |

## Ce que les tests vérifient

- Restauration des préférences, isolation des comptes, réponses tardives ignorées et mutations séquencées.
- Restauration du mock profil/messages/notifications et retour à l’état confirmé si une écriture locale échoue.
- Contrat GET/PATCH du workspace, dont le cas PATCH 204 suivi d’un GET.
- Duplication en brouillon, valeurs par défaut et modèles d’offres.
- CSV avec échappement et protection des formules ; ICS UTC avec échappement et pliage des lignes.
- Navigation des sous-menus mobiles, choix du thème, archivage/restauration d’une notification,
  création et réalisation d’une action, préparation d’entretien, signature et modèle de message.
- Confirmation de sortie d’un profil modifié, enregistrement du profil, recherche globale depuis
  l’en-tête et le clavier, personnalisation et restauration du dashboard.
- Les tests historiques V1 restent inclus dans la suite complète.

## Reproduire

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release -t lib/main.dart --dart-define-from-file=config/mock.json
flutter build web --release -t lib/main.dart \
  --dart-define=JOYN_DATA_MODE=api \
  --dart-define=JOYN_API_BASE_URL=https://api.joyn.example
```

Environnement de contrôle : Flutter 3.47.8 / Dart 3.13.7, Linux.
La compilation web est une compilation JavaScript release ; le contrôle préliminaire Wasm
réussit également, mais aucun livrable Wasm ni test d’exécution Wasm n’est revendiqué.

## Limites de cette validation

Aucun backend réel n’a été fourni. Les contrats HTTP testés ne remplacent pas une recette avec
le serveur : autorisations, concurrence entre appareils, distribution des notifications,
validation et persistance serveur restent à vérifier avec lui.

Les dimensions mobiles sont vérifiées dans Flutter. Aucune compilation ni exécution native
Android/iOS n’a été réalisée dans cet environnement. Il faut encore tester sur appareils réels,
notamment clavier, retour système, export de fichiers et intégration des préférences.

La validation de taille de texte et les contrôles visuels ne sont pas une certification WCAG.
Voir `STUDIO_RECRUTEUR_V2.md` pour les limites fonctionnelles et de persistance du mock.
