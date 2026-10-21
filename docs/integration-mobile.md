# Intégration mobile, authentification et CI/CD

## Historique conservé

L'intégration est réalisée avec de vrais commits de merge sur `landing-page` :

- `feature/inscription` est fusionnée sans écraser son historique ;
- `connexion-dashboard` est fusionnée sans écraser son historique ;
- les conflits sont résolus ensuite dans l'architecture commune.

Les commits des collègues restent donc présents dans le graphe Git et gardent
leurs auteurs d'origine.

## Architecture retenue

`main.dart` constitue le point d'injection des dépôts. `JoynApp` fournit ensuite
l'état d'authentification, le dépôt dashboard et le dépôt d'inscription au reste
de l'application.

Le routeur unique distingue la plateforme :

- web : `/` affiche la landing ;
- Android/iOS : `/` affiche l'animation de démarrage JOYN ;
- utilisateur non connecté : l'animation mène à `/login` ;
- session restaurée : l'animation mène directement à `/dashboard` ;
- la connexion mène au dashboard ;
- « Créer un compte » mène au choix étudiant / entreprise ;
- l'inscription étudiant mène à l'onboarding ;
- l'inscription entreprise mène au dashboard.

Les anciennes routes `/connexion` et `/inscription` restent acceptées afin de
ne pas casser les liens de la landing.

## Dépôts fictifs et futur backend

Les écrans dépendent de contrats (`AuthRepository`, `RegistrationRepository`,
`DashboardRepository`). Les implémentations fictives sont assemblées dans
`main.dart`. Le remplacement par l'API doit donc se faire à cet endroit sans
réécrire les écrans.

`AuthRegistrationRepository` permet à l'inscription et à la connexion de
partager la même session : un compte créé par le parcours inscription est
immédiatement visible par `AuthController`.

## CI/CD GitHub

Le workflow `.github/workflows/flutter.yml` s'exécute pour les pull requests et
les pushes vers `landing-page` ou `main`.

Pour une pull request, le workflow reconstruit d'abord localement le merge entre
le SHA de base et le SHA de la branche. Un conflit Git fait donc échouer le job
avant les tests.

Lorsque le merge est possible, la chaîne exécute :

1. `flutter pub get` ;
2. vérification du format Dart ;
3. `flutter analyze` ;
4. `flutter test` ;
5. build web release ;
6. build APK Android debug ;
7. publication des deux builds comme artifacts GitHub pendant sept jours.

Pour empêcher un merge cassé, configurer ensuite la protection de branche
GitHub sur `landing-page` et `main` en rendant le check
« Vérifier le merge, tester et construire » obligatoire. L'option Auto-merge de
GitHub peut alors être utilisée : GitHub effectuera le merge uniquement une fois
les checks obligatoires validés et la branche sans conflit.
