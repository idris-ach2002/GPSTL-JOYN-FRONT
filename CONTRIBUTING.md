# Contribuer à JOYN

`main` est la branche d'intégration officielle. Elle doit toujours rester compilable et testable.

## 1. Ne jamais développer directement sur `main`

Créer chaque travail depuis le dernier `main` :

```bash
./scripts/dev/start_branch.sh feat matching
./scripts/dev/start_branch.sh fix login-mobile
```

Nommage accepté :

```text
feat/...
fix/...
hotfix/...
refactor/...
test/...
docs/...
ci/...
chore/...
```

`landing-page` est uniquement tolérée par la CI pour la PR initiale qui installe le socle dans `main`.

## 2. Une branche = un objectif

Éviter les branches longues qui mélangent plusieurs fonctionnalités. Plus une branche vit longtemps, plus le risque de conflit augmente.

Les couches métier restent partagées :

```text
data/
domain/
controllers/
shared/
```

Les présentations restent séparées :

```text
presentation/web/
presentation/mobile/
```

Un écran `web/` ne doit jamais importer directement un écran `mobile/`, et inversement. La CI bloque ce cas automatiquement.

## 3. Se remettre à jour avant une PR

Sur une branche personnelle :

```bash
./scripts/dev/sync_main.sh
```

Le script fait un `git fetch` puis un `git rebase origin/main`. Ne pas utiliser ce script sur une branche partagée avec plusieurs personnes sans vous coordonner.

## 4. Vérifier avant de pousser la PR

```bash
./scripts/dev/check_before_pr.sh
```

Il vérifie :

- architecture Web/Mobile ;
- format Dart ;
- `flutter analyze` ;
- tous les tests ;
- build Web ;
- build Android ;
- erreurs d'espaces Git.

## 5. Pull Request obligatoire

Toute modification de `main` passe par une PR.

La CI GitHub exécute automatiquement :

1. contrôle du nom de branche ;
2. simulation du merge pour détecter les conflits ;
3. contrôle des frontières Web/Mobile ;
4. format et analyse ;
5. tests Flutter ;
6. build Web et Android.

La PR ne doit être mergée que lorsque tous les checks sont verts.

## 6. Hotspots à modifier avec prudence

Ces fichiers créent facilement des conflits si plusieurs personnes les éditent en parallèle :

```text
lib/app/routing/app_router.dart
lib/app/bootstrap.dart
lib/app/app.dart
pubspec.yaml
lib/design_system/tokens/
```

Avant de les modifier, vérifier si quelqu'un travaille déjà dessus. Pour une nouvelle route, préférer à terme des fichiers de routes par feature plutôt que d'empiler toute la logique dans un seul routeur.

## 7. Stratégie de merge

Pour les features classiques : **Squash and merge**.

Avant merge :

- branche à jour avec `main` ;
- CI verte ;
- conversations de review résolues ;
- pas de conflit Git.

Après merge, supprimer la branche de feature.
