# `app_breakpoints.dart`

Expose les seuils de largeur partagés avec les jetons de la landing.

[Code source](../../../lib/core/responsive/app_breakpoints.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `../../design_system/joyn_tokens.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `AppBreakpoints` | `Bibliothèque` | Seuils de largeur réutilisables dans les helpers responsives. | `abstract final class AppBreakpoints` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `mobile` | `AppBreakpoints` | Seuil ou contenu de la variante mobile, selon la déclaration. | `static const mobile = JoynTokens.mobile` |
| `tablet` | `AppBreakpoints` | Seuil ou contenu de la variante tablette, selon la déclaration. | `static const tablet = JoynTokens.tablet` |
| `desktop` | `AppBreakpoints` | Seuil ou contenu de la variante ordinateur, selon la déclaration. | `static const desktop = JoynTokens.tablet` |
| `wide` | `AppBreakpoints` | Largeur de contenu maximale partagée avec les jetons. | `static const wide = JoynTokens.content` |

