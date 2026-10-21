# Architecture JOYN

## Principe

JOYN possède une logique métier partagée mais deux présentations distinctes : **Web** et **Mobile**.

Structure cible d'une feature :

```text
lib/features/<feature>/
├── data/
├── domain/
└── presentation/
    ├── controllers/
    ├── shared/
    ├── web/
    └── mobile/
```

Tout n'a pas besoin de contenir chacun de ces dossiers. On les crée seulement lorsqu'ils sont utiles.

## Partagé

Les éléments suivants peuvent être utilisés par les deux expériences :

```text
data/
domain/
presentation/controllers/
presentation/shared/
```

Ils contiennent la logique et les composants réellement communs.

## Web et Mobile

Les interfaces vivent dans :

```text
presentation/web/
presentation/mobile/
```

Une interface Web ne doit pas importer directement une interface Mobile, et inversement.

Cette règle est vérifiée automatiquement par :

```bash
python3 scripts/ci/check_architecture.py
```

## Points d'entrée

```text
lib/main.dart         sélection adaptative
lib/main_web.dart     force l'expérience Web
lib/main_mobile.dart  force l'expérience Mobile
```

Pour développer :

```bash
flutter run -t lib/main_web.dart -d chrome
flutter run -t lib/main_mobile.dart -d chrome
```

## Routage

Le routage applicatif se trouve sous :

```text
lib/app/routing/
```

Le routeur choisit les écrans correspondant à l'expérience active.

Le parcours mobile démarre sur son startup puis rejoint l'authentification. Il ne passe pas par la landing marketing.

## Hotspots

Les fichiers transverses suivants sont susceptibles de créer des conflits entre branches :

```text
lib/app/routing/app_router.dart
lib/app/bootstrap.dart
lib/app/app.dart
pubspec.yaml
lib/design_system/tokens/
```

Une feature doit éviter de les modifier si ce n'est pas nécessaire.

Si plusieurs features nécessitent régulièrement des changements dans le même hotspot, il faut découper davantage l'architecture plutôt que multiplier les résolutions de conflits.
