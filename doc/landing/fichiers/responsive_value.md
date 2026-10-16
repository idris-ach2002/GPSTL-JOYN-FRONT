# `responsive_value.dart`

Sélectionne une valeur typée à partir de la largeur fournie par MediaQuery.

[Code source](../../../lib/core/responsive/responsive_value.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `app_breakpoints.dart`

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `responsiveValue` | `Bibliothèque` | Retourne la variante mobile, tablette ou ordinateur du type demandé. | `T responsiveValue<T>( BuildContext context, { required T mobile, required T tablet, required T desktop, })` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `width` | `Bibliothèque` | Largeur disponible ou calculée pour cette composition. | `final width = MediaQuery.sizeOf(context).width;` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `BuildContext context` | `T responsiveValue<T>( BuildContext context, { required T mobile, required T tablet, required T desktop, })` | Contexte Flutter de l’élément en cours de construction. |
| `T mobile` | `T responsiveValue<T>( BuildContext context, { required T mobile, required T tablet, required T desktop, })` | Seuil ou contenu de la variante mobile, selon la déclaration. |
| `T tablet` | `T responsiveValue<T>( BuildContext context, { required T mobile, required T tablet, required T desktop, })` | Seuil ou contenu de la variante tablette, selon la déclaration. |
| `T desktop` | `T responsiveValue<T>( BuildContext context, { required T mobile, required T tablet, required T desktop, })` | Seuil ou contenu de la variante ordinateur, selon la déclaration. |

