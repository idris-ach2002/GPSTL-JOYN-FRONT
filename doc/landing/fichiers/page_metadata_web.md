# `page_metadata_web.dart`

Met à jour les métadonnées et ouvre les guides dans le navigateur.

[Code source](../../../lib/core/platform/page_metadata_web.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter_web_plugins/url_strategy.dart`
- `package:web/web.dart`

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `configureWeb` | `Bibliothèque` | Configure les URL sans fragment sur Web ; ne produit aucun effet dans le stub. | `void configureWeb()` |
| `updatePageMetadata` | `Bibliothèque` | Actualise le titre et les métadonnées de la page sur Web. | `void updatePageMetadata(String audience)` |
| `openPresentation` | `Bibliothèque` | Ouvre la présentation HTML à partir de l’URL de base. | `void openPresentation()` |
| `openResource` | `Bibliothèque` | Ouvre uniquement une ressource appartenant à la liste de guides autorisée. | `void openResource(String target)` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `title` | `Bibliothèque` | Titre affiché dans cette composition. | `final title = switch (audience) { 'connexion' => 'JOYN — Connexion', 'assistance' => 'JOYN — Assistance', 'entreprises' => 'JOYN — Des attentes de recrutement explicites', _ => 'JOYN — Le match avant la candidature', };` |
| `base` | `Bibliothèque` | URL de base du document, utilisée pour résoudre les pages statiques. | `final base = web.document.baseURI;` |
| `pages` | `Bibliothèque` | Nombre de pages de résultats, calculé par arrondi supérieur. | `const pages = { 'presentation': 'presentation.html', 'guide-profil': 'guides/profil.html', 'guide-matching': 'guides/matching.html', 'guide-entretien': 'guides/entretien.html', };` |
| `page` | `Bibliothèque` | Indice de la page de résultats FAQ, à partir de zéro. | `final page = pages[target];` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `String audience` | `void updatePageMetadata(String audience)` | Acteur ou point d’entrée utilisé pour adapter la présentation. |
| `String target` | `void openResource(String target)` | Cible d’ancre ou de route transmise à la navigation. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `selector` | `(final selector in ['meta[property="og:title"]', 'meta[name="twitter:title"]'])` |
