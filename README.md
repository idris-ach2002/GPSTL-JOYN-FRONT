# JOYN

**JOYN** est une application de mise en relation entre candidats et entreprises pour l'emploi, le stage et surtout l'alternance.

Le projet part d'un constat simple : une candidature ne dépend pas seulement d'un intitulé de poste. Le bon match dépend aussi des compétences, de la localisation, du rythme, des disponibilités, des attentes du candidat et des contraintes de recrutement de l'entreprise.

JOYN cherche donc à **faire le match avant la candidature** : mieux qualifier les profils et les opportunités, réduire les candidatures peu pertinentes et rendre le parcours plus lisible des deux côtés.

## Ce que le produit doit permettre

Pour un **candidat**, JOYN doit permettre de créer son profil, importer ou compléter ses informations, préciser ses préférences et accéder à des opportunités pertinentes.

Pour une **entreprise**, JOYN doit permettre de présenter son besoin, consulter des profils compatibles et concentrer le recrutement sur les candidats les plus pertinents.

Le produit possède deux expériences distinctes :

- **Web** : landing, authentification, inscription, onboarding, dashboard et pages d'information ;
- **Mobile** : expérience native dédiée avec startup animé, authentification, inscription, onboarding et dashboard mobile.

La logique métier reste partagée entre les deux expériences.

## Documentation

Le README reste volontairement une façade. La documentation utile se trouve dans [`docs/`](docs/README.md).

| Document | À lire pour |
| --- | --- |
| [Vision produit](docs/product.md) | comprendre le problème auquel JOYN répond et les principes du produit |
| [Fonctionnalités](docs/features.md) | voir les features existantes et leur responsabilité |
| [Architecture](docs/architecture.md) | comprendre la séparation Web / Mobile et les couches partagées |
| [Workflow & CI/CD](docs/workflow.md) | savoir exactement comment travailler avec Git, les scripts, les PR et la CI |

## Lancer le projet

Installer les dépendances :

```bash
flutter pub get
```

Prévisualiser explicitement le Web :

```bash
flutter run -t lib/main_web.dart -d chrome
```

Prévisualiser explicitement le Mobile dans Chrome :

```bash
flutter run -t lib/main_mobile.dart -d chrome
```

L'entrée standard reste disponible :

```bash
flutter run -d chrome
```

Sur un petit viewport, elle sélectionne l'expérience mobile ; sur un viewport desktop, elle sélectionne l'expérience web.

---

# Règles de travail

`main` est la **seule branche d'intégration** et elle est protégée par un ruleset GitHub.

On ne développe **jamais directement sur `main`**.

Chaque changement suit ce cycle :

```text
main à jour
   ↓
branche courte feat/fix/docs/...
   ↓
développement + commits
   ↓
synchronisation régulière avec main
   ↓
validation locale
   ↓
push
   ↓
Pull Request vers main
   ↓
CI verte + review
   ↓
Squash & Merge
   ↓
main
```

## Toujours utiliser `scripts/`

Les opérations répétitives et sensibles passent par les scripts du dépôt :

```text
scripts/dev/start_branch.sh     créer une branche depuis le dernier main
scripts/dev/sync_main.sh        rebaser la branche sur origin/main
scripts/dev/check_before_pr.sh  lancer toutes les validations locales
scripts/dev/push_branch.sh      pousser la branche de façon sûre, même après un rebase
```

Cela évite que chaque membre applique sa propre procédure Git.

## Exemple concret : une feature du début à la fin

### 1. Commencer une nouvelle feature

Depuis un working tree propre :

```bash
./scripts/dev/start_branch.sh feat notifications
```

Le script récupère le dernier `main`, met `main` à jour puis crée :

```text
feat/notifications
```

### 2. Travailler normalement

Modifier le code puis créer des commits cohérents :

```bash
git add lib/features/notifications test/features/notifications
git commit -m "feat(notifications): ajouter le centre de notifications"
```

Les commits intermédiaires sont autorisés : la PR sera fusionnée avec **Squash & Merge**.

### 3. En plein milieu du travail, récupérer les changements de `main`

Avant la synchronisation, le working tree doit être propre. Committer le travail en cours si nécessaire.

Puis :

```bash
./scripts/dev/sync_main.sh
```

Le script exécute un rebase sur le dernier `origin/main`.

S'il n'y a pas de conflit, continuer à travailler.

S'il y a un conflit :

```bash
git status
```

Corriger les fichiers concernés, puis :

```bash
git add <fichiers-corrigés>
git rebase --continue
```

Répéter jusqu'à la fin du rebase.

Pour abandonner le rebase et revenir à l'état précédent :

```bash
git rebase --abort
```

Après un rebase, pousser uniquement avec le script prévu :

```bash
./scripts/dev/push_branch.sh
```

Il utilise un push normal quand c'est possible et `--force-with-lease` uniquement lorsque le rebase l'impose. Il n'écrase pas silencieusement le travail distant d'un autre développeur.

### 4. Continuer la feature

Faire les modifications restantes et committer :

```bash
git add <fichiers>
git commit -m "test(notifications): couvrir le parcours principal"
```

### 5. Avant la Pull Request

Se resynchroniser une dernière fois :

```bash
./scripts/dev/sync_main.sh
```

Puis lancer la validation complète :

```bash
./scripts/dev/check_before_pr.sh
```

Cette commande vérifie notamment :

- les frontières Web / Mobile ;
- le format Dart ;
- `flutter analyze` ;
- tous les tests ;
- le build Web ;
- le build Android ;
- les erreurs Git détectables localement.

### 6. Pousser la branche

```bash
./scripts/dev/push_branch.sh
```

Puis ouvrir une **Pull Request vers `main`**.

### 7. Pendant la review

Si `main` avance pendant que la PR est ouverte :

```bash
./scripts/dev/sync_main.sh
./scripts/dev/check_before_pr.sh
./scripts/dev/push_branch.sh
```

La CI GitHub repart automatiquement sur le nouvel état de la branche.

### 8. Finir

La PR n'est mergée que lorsque les checks requis sont verts et que les règles du ruleset sont satisfaites.

Le merge se fait avec **Squash & Merge**.

Après le merge, pour démarrer le travail suivant :

```bash
./scripts/dev/start_branch.sh feat prochaine-feature
```

Le script repartira du nouveau `main`.

## Règles d'architecture à ne pas casser

Les présentations Web et Mobile sont séparées :

```text
presentation/web/
presentation/mobile/
```

Elles peuvent partager :

```text
data/
domain/
controllers/
shared/
```

Un écran `web/` ne doit pas importer directement un écran `mobile/`, et inversement. La CI contrôle cette frontière.

Les fichiers transverses suivants sont des zones de conflit fréquentes :

```text
lib/app/routing/app_router.dart
lib/app/bootstrap.dart
lib/app/app.dart
pubspec.yaml
lib/design_system/tokens/
```

Avant de les modifier, vérifier que personne d'autre ne travaille déjà dessus.

Pour le détail, voir [Workflow & CI/CD](docs/workflow.md).
