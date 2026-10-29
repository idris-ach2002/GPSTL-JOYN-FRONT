# Validation de la livraison

Contrôles exécutés le 29 octobre 2026 avec Flutter 3.47.8 / Dart 3.13.7 sous Linux.
Le projet demande Dart ^3.13.5 ; les dépendances du lockfile ont été conservées.

| Contrôle | Résultat |
| --- | --- |
| `flutter analyze` | Aucun problème détecté |
| `flutter test --timeout=60s` | 131 tests réussis |
| Tests des nouveaux modules | 19 tests, dont 12 rendus aux largeurs 320/390/1440 px et 2 parcours complets web/mobile |
| Tests HTTP | Bearer, PATCH 204 avec relecture, 401, rôle de session, effacement du jeton, état après erreur |
| Test messagerie | Ouverture, saisie, clic Envoyer, présence du message et vidage du champ |
| Mode mock | Profil/préférences, notifications, conversation existante, déduplication d’envoi testés |
| Build web release `lib/main_web.dart` en mock | Réussi |
| Build web release adaptatif `lib/main.dart` en mode API | Réussi (URL de démonstration à la compilation) |
| Revue visuelle interne | Profil et conversation à 390 et 1440 px, avec les polices du projet |

Les tests de contrat HTTP utilisent un serveur simulé en mémoire. Aucun serveur backend réel
n’a été fourni ou interrogé. Un build en mode API ne constitue pas un test d’intégration backend.
La déduplication serveur des messages doit être implémentée et validée côté backend.

Les rendus mobiles sont des tests Flutter aux dimensions mobiles, pas une exécution sur
Android/iOS. Aucun APK/IPA ni exécution sur émulateur/appareil n’est revendiqué.
Les permissions Android/macOS ont été ajustées ; la recette native reste à effectuer.

Les captures de revue servent au contrôle interne ; les tests livrés ne dépendent pas de fichiers
image temporaires. Les sorties de build, caches, secrets et dépendances téléchargées ne sont pas
inclus dans la livraison source.

Pour reproduire les contrôles : `bash scripts/verify-recruiter.sh`.
Le lanceur `scripts/run-joyn.py` permet de tester le `.env` sans exécuter son contenu.

L’archive contient un bundle Git et un script d’import contrôlé pour conserver les commits.
Le script refuse un arbre de travail modifié, une branche divergente ou un `origin/main`
contenant des changements absents de la livraison. Il n’utilise ni reset forcé ni suppression.
