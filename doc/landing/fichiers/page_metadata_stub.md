# `page_metadata_stub.dart`

Fournit les mêmes fonctions sans effets sur les plateformes sans navigateur Web.

[Code source](../../../lib/core/platform/page_metadata_stub.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `configureWeb` | `Bibliothèque` | Configure les URL sans fragment sur Web ; ne produit aucun effet dans le stub. | `void configureWeb()` |
| `updatePageMetadata` | `Bibliothèque` | Actualise le titre et les métadonnées de la page sur Web. | `void updatePageMetadata(String audience)` |
| `openPresentation` | `Bibliothèque` | Ouvre la présentation HTML à partir de l’URL de base. | `void openPresentation()` |
| `openResource` | `Bibliothèque` | Ouvre uniquement une ressource appartenant à la liste de guides autorisée. | `void openResource(String target)` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `String audience` | `void updatePageMetadata(String audience)` | Acteur ou point d’entrée utilisé pour adapter la présentation. |
| `String target` | `void openResource(String target)` | Cible d’ancre ou de route transmise à la navigation. |

