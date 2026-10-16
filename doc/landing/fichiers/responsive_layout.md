# `responsive_layout.dart`

Choisit un contenu mobile, tablette ou ordinateur selon la largeur disponible.

[Code source](../../../lib/core/responsive/responsive_layout.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `app_breakpoints.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `ResponsiveLayout` | `Bibliothèque` | Composition de trois variantes de contenu selon les contraintes de largeur. | `class ResponsiveLayout extends StatelessWidget` |
| `ResponsiveLayout` | `ResponsiveLayout` | Initialise les paramètres de ResponsiveLayout ; les valeurs par défaut figurent dans la signature. | `const ResponsiveLayout({ required this.mobile, required this.tablet, required this.desktop, super.key, })` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `build` | `ResponsiveLayout` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `mobile` | `ResponsiveLayout` | Seuil ou contenu de la variante mobile, selon la déclaration. | `final Widget mobile` |
| `tablet` | `ResponsiveLayout` | Seuil ou contenu de la variante tablette, selon la déclaration. | `final Widget tablet` |
| `desktop` | `ResponsiveLayout` | Seuil ou contenu de la variante ordinateur, selon la déclaration. | `final Widget desktop` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `this.mobile` | `ResponsiveLayout` | Seuil ou contenu de la variante mobile, selon la déclaration. |
| `this.tablet` | `ResponsiveLayout` | Seuil ou contenu de la variante tablette, selon la déclaration. |
| `this.desktop` | `ResponsiveLayout` | Seuil ou contenu de la variante ordinateur, selon la déclaration. |
| `super.key` | `ResponsiveLayout` | Identité du widget dans l’arbre Flutter. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |
| `context` | `ResponsiveLayout` | Contexte Flutter de l’élément en cours de construction. |
| `constraints` | `ResponsiveLayout` | Contraintes de largeur et de hauteur reçues du parent. |

