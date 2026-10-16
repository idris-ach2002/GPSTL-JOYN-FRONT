# `app.dart`

Configure l’application Material, son thème et son routeur.

[Code source](../../../lib/app/app.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `routing/app_router.dart`
- `theme/app_theme.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `JoynApp` | `Bibliothèque` | Point d’entrée visuel de JOYN ; relie MaterialApp au thème et au routeur. | `class JoynApp extends StatelessWidget` |
| `JoynApp` | `JoynApp` | Initialise les paramètres de JoynApp ; les valeurs par défaut figurent dans la signature. | `const JoynApp({super.key})` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `build` | `JoynApp` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `JoynApp` | Identité du widget dans l’arbre Flutter. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |

