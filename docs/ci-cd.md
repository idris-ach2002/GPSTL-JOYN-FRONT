# CI/CD JOYN

## Objectif

Le pipeline protège `main` et automatise la validation des branches Web/Mobile.

```text
feature/fix branch
      ↓
Pull Request vers main
      ↓
Guard Git + architecture
      ↓
Format / Analyze     Tests
        \             /
         \           /
          Build Web + Android
                 ↓
              Merge main
                 ↓
       Artifacts Web + APK
```

## Checks obligatoires recommandés sur `main`

Dans GitHub : **Settings → Rules → Rulesets** (ou Branch protection selon l'interface du dépôt), créer une règle pour `main` avec :

- Require a pull request before merging ;
- Require status checks to pass ;
- Require branches to be up to date before merging ;
- Require conversation resolution before merging ;
- Block force pushes ;
- Block branch deletion.

Checks à rendre obligatoires :

```text
Guard / Architecture & Git
Quality / Format & Analyze
Tests / Flutter
Build / Web + Android
```

Un reviewer obligatoire peut être ajouté si l'équipe le souhaite. Pour une petite équipe, la CI + review ciblée sur les gros changements suffit souvent.

## Merge queue

Le workflow écoute déjà l'événement `merge_group`. Si plusieurs PR arrivent en parallèle, la Merge Queue GitHub peut être activée sans modifier la CI. Elle reteste l'état combiné juste avant le merge.

## Continuous Delivery

Après un push réussi sur `main`, le job Build publie automatiquement pendant 14 jours :

- `joyn-web-<sha>` : build Web release ;
- `joyn-android-<sha>` : APK Android debug.

Ce sont des artifacts de recette, pas encore un déploiement de production. Le déploiement vers un hébergeur Web / Play Store sera ajouté quand la cible d'hébergement et la signature Android seront définies.

## Version Flutter

La CI est épinglée sur la version Flutter détectée sur la machine qui installe ce socle CI/CD. Le but est d'éviter qu'une mise à jour automatique de Flutter casse toutes les PR du jour au lendemain.

Pour changer de version Flutter, modifier volontairement `FLUTTER_VERSION` dans `.github/workflows/ci.yml` dans une PR dédiée, puis valider toute la suite de tests.

## Workflow quotidien

Créer une feature :

```bash
./scripts/dev/start_branch.sh feat matching
```

Se synchroniser avec `main` :

```bash
./scripts/dev/sync_main.sh
```

Valider avant PR :

```bash
./scripts/dev/check_before_pr.sh
```

Puis pousser et ouvrir une Pull Request vers `main`.
