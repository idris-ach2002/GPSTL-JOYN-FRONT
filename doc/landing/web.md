# Web, assets et référencement

[Sommaire](README.md) · [Métadonnées navigateur](fichiers/page_metadata_web.md)

## Point d’entrée et chargement

`web/index.html` définit les métadonnées statiques, les informations Open Graph et Twitter, le JSON-LD du site et le contenu visible avant le démarrage Flutter. La balise de base utilise la substitution Flutter `$FLUTTER_BASE_HREF`. Le loader gère l’état d’attente, le démarrage et l’échec avec possibilité de réessayer.

`web/flutter_bootstrap.js` utilise les substitutions `{{flutter_js}}` et `{{flutter_build_config}}`. Il appelle le loader Flutter, initialise le moteur et démarre l’application. En cas d’exception, il émet `joyn-load-error` et écrit l’erreur dans la console.

Les titres de route sont mis à jour par `page_metadata_web.dart`, y compris les titres Open Graph et Twitter. La connexion reçoit `noindex,follow`. Ces changements dynamiques ne remplacent pas les pages HTML destinées à être lues sans lancer Flutter.

### États du point d’entrée HTML

`showStartupFailure` rend visible le bloc `failure` et masque `loading` lorsqu’ils existent encore. L’événement `joyn-load-error`, l’erreur de chargement du script et le délai de 30 secondes appellent cette fonction. Si le bloc `startup` existe toujours à l’expiration du délai, l’état d’échec est affiché. Le bouton de reprise recharge la page avec `window.location.reload()`.

Le retrait de `startup` est effectué par la mise à jour des métadonnées après le premier rendu de l’écran Flutter. Les identifiants `startup`, `loading` et `failure` relient donc le HTML aux fonctions du navigateur.

### Styles des pages HTML

`guide.css` déclare les familles de polices et les variables CSS de palette. Les règles couvrent la boîte globale, les liens et leur focus, l’en-tête, les titres, la grille d’article, le sommaire, les exemples, les listes, les notes, les liens de suite et le pied de page. À 1024 pixels et moins, la grille devient une colonne et le sommaire quitte son positionnement sticky. `prefers-reduced-motion` supprime le défilement doux.

`manifest.json` décrit `name`, `short_name`, `start_url`, le mode `display`, les couleurs, la description, l’orientation et les icônes. Les icônes portent leur taille déclarée et, pour les variantes maskable, leur usage dédié. Le manifeste ne réalise pas l’installation ou l’authentification d’un compte.

## Pages de lecture

| Fichier | Contenu |
| --- | --- |
| `web/presentation.html` | Présentation des parcours candidat et recruteur, des recommandations et du suivi |
| `web/guides/profil.html` | Préparation du CV, présentation de l’expérience et des compétences |
| `web/guides/matching.html` | Analyse initiale du CV, profil, lecture des recommandations et suite de la démarche |
| `web/guides/entretien.html` | Lecture de l’offre, préparation d’une réalisation, attentes et prochaine étape |
| `web/guide.css` | Polices, palette, grille éditoriale, focus, responsive et mouvement réduit |
| `web/robots.txt` | Règles d’exploration du site ; sitemap ajouté par la configuration SEO |
| `web/manifest.json` | Nom, démarrage, couleurs et icônes de l’application Web |

Les guides comportent un sommaire interne, des sections liées par identifiants et une navigation vers les autres guides. Ils sont ouverts par une liste de cibles autorisées dans `openResource`. Leurs polices pointent vers les assets produits par le build Flutter ; vérifier les pages à partir de `build/web`, pas uniquement en ouvrant leurs sources avec `file://`.

## URL canonique et sitemap

`tool/configure_seo.py` est l’outil de configuration SEO du projet. Il est conservé car il modifie les ressources Web nécessaires à leur publication, sans gérer Git.

Son argument obligatoire `--origin` reçoit la véritable origine HTTPS du site, avec un éventuel sous-répertoire. Il refuse les identifiants dans l’URL, la query, le fragment, les espaces et caractères interdits. Il traite la page d’accueil, la présentation et tous les guides HTML.

Pour chaque page, il remplace les balises canonical et `og:url`, puis produit `web/sitemap.xml` et `web/robots.txt`. La commande à utiliser, une fois le domaine choisi, est :

```bash
python3 tool/configure_seo.py --origin "$JOYN_PUBLIC_ORIGIN"
flutter build web --release
```

Définir `JOYN_PUBLIC_ORIGIN` avec l’URL réelle avant cette commande. La documentation ne fournit pas de domaine de substitution à publier. Les routes d’application nécessitent un hébergement qui résout les chemins Flutter vers son point d’entrée, tout en servant directement les guides et assets statiques.

### Variables de l’outil SEO

| Nom | Fonction |
| --- | --- |
| `parser`, `args` | Déclaration et lecture de l’argument de ligne de commande |
| `origin`, `parts` | Racine normalisée et éléments d’URL à valider |
| `root` | Répertoire Web résolu à partir de l’emplacement du script |
| `pages` | Paires fichier/URL canonique de l’accueil, de la présentation et des guides |
| `name`, `canonical` | Fichier et URL traités dans la boucle |
| `path`, `content` | Fichier courant et son texte avant écriture |
| `urls` | URL utilisées pour construire le sitemap |

### Variables du bootstrap

`engineInitializer` est fourni par le loader ; `runner` reçoit l’application initialisée. Chaque bloc `catch` reçoit `error`, émet l’événement d’échec et conserve le détail dans la console. Les états de chargement et de reprise sont gérés par le point d’entrée HTML.

## Inventaire des assets

Les fichiers suivants sont conservés dans leur format d’origine. Les licences de polices sont livrées à côté des fontes.

| Fichier | Usage ou format |
| --- | --- |
| `assets/fonts/GreatVibes-OFL.txt` | Licence de la famille de police |
| `assets/fonts/GreatVibes-Regular.ttf` | Police embarquée |
| `assets/fonts/Inter-Bold.ttf` | Police embarquée |
| `assets/fonts/Inter-Medium.ttf` | Police embarquée |
| `assets/fonts/Inter-OFL.txt` | Licence de la famille de police |
| `assets/fonts/Inter-Regular.ttf` | Police embarquée |
| `assets/fonts/Inter-SemiBold.ttf` | Police embarquée |
| `assets/fonts/SpaceGrotesk-Bold.ttf` | Police embarquée |
| `assets/fonts/SpaceGrotesk-OFL.txt` | Licence de la famille de police |
| `assets/fonts/SpaceGrotesk-Regular.ttf` | Police embarquée |
| `web/favicon.png` | Image PNG ; 16 × 16 pixels |
| `web/icons/Icon-192.png` | Image PNG ; 192 × 192 pixels |
| `web/icons/Icon-512.png` | Image PNG ; 512 × 512 pixels |
| `web/icons/Icon-maskable-192.png` | Image PNG ; 192 × 192 pixels |
| `web/icons/Icon-maskable-512.png` | Image PNG ; 512 × 512 pixels |

Les portraits, le signe JOYN et les pictogrammes de menu ne dépendent pas d’images téléchargées : leur géométrie est dessinée en Dart dans les peintres référencés dans [le catalogue du code](reference.md).
