# Workflow & CI/CD JOYN

## Branche d'intégration

`main` est la branche d'intégration officielle.

Elle est protégée par un ruleset GitHub : le travail passe par une branche puis une Pull Request. Les pushes forcés directs et les modifications directes de `main` ne font pas partie du workflow normal.

## Branches

Types acceptés :

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

Une branche doit correspondre à un objectif clair et rester courte.

## Scripts de développement

### Créer une branche

```bash
./scripts/dev/start_branch.sh feat matching
```

Le script :

1. vérifie que le working tree est propre ;
2. récupère `origin/main` ;
3. met `main` à jour en fast-forward ;
4. crée la nouvelle branche depuis ce `main`.

### Synchroniser une branche avec main

```bash
./scripts/dev/sync_main.sh
```

Le script fait :

```text
fetch origin/main
↓
rebase de la branche courante sur origin/main
```

Le working tree doit être propre.

Après un rebase d'une branche déjà poussée, utiliser `push_branch.sh`.

### Pousser une branche

```bash
./scripts/dev/push_branch.sh
```

Le script :

- refuse `main` ;
- vérifie le nom de la branche ;
- exige un working tree propre ;
- fait un push normal si la branche distante est un ancêtre de la branche locale ;
- utilise `--force-with-lease` après un rebase si nécessaire.

`--force-with-lease` protège le travail distant connu : si quelqu'un a poussé entre-temps sans que la branche locale l'ait vu, le push est refusé.

### Vérifier avant PR

```bash
./scripts/dev/check_before_pr.sh
```

Validation locale :

```text
architecture
↓
format
↓
flutter analyze
↓
flutter test
↓
build Web
↓
build Android
↓
git diff --check
```

## CI GitHub

Une Pull Request vers `main` déclenche notamment :

```text
Guard / Architecture & Git
Quality / Format & Analyze
Tests / Flutter
Build / Web + Android
```

Le job Guard vérifie aussi la possibilité de merger la branche et les frontières Web / Mobile.

Après un push réussi sur `main`, les builds Web et Android sont publiés comme artifacts de recette.

## Cycle recommandé

```text
./scripts/dev/start_branch.sh
        ↓
développement
        ↓
commits
        ↓
./scripts/dev/sync_main.sh
        ↓
développement
        ↓
commits
        ↓
./scripts/dev/sync_main.sh
        ↓
./scripts/dev/check_before_pr.sh
        ↓
./scripts/dev/push_branch.sh
        ↓
Pull Request
        ↓
CI + review
        ↓
Squash & Merge
        ↓
main
```

## Si un conflit apparaît pendant sync_main

Le rebase s'arrête.

1. Lire les conflits :

```bash
git status
```

2. Corriger les fichiers.
3. Marquer les fichiers résolus :

```bash
git add <fichiers>
```

4. Continuer :

```bash
git rebase --continue
```

Pour abandonner :

```bash
git rebase --abort
```

Ne jamais utiliser `git reset --hard` pour résoudre ce workflow.

## Si main avance pendant une PR

Mettre la branche à jour puis republier :

```bash
./scripts/dev/sync_main.sh
./scripts/dev/check_before_pr.sh
./scripts/dev/push_branch.sh
```

La CI repart automatiquement.

## Merge

Les features sont fusionnées avec **Squash & Merge**.

Cela permet d'avoir plusieurs petits commits de travail sur une branche sans polluer l'historique de `main`.
