# JOYN — livraison du raccordement Flutter / Spring Boot

**Date :** 12 novembre 2026
**Branche de travail :** `feat/connexion-er-back` (archive Git jointe)
**Périmètre :** frontend exclusivement. Aucun fichier du dépôt backend n'a été modifié.

## Principe de conception

L'interface Flutter d'origine est maintenue. Les objets des repositories API convertissent les modèles Spring Boot en modèles de présentation. Les données que le serveur ne connaît pas ne sont pas simulées comme persistées en mode API.

Le mode démonstration `mock` reste disponible ; le mode `api` utilise les endpoints réels. Le JWT est transmis par le `ApiClient` unique. Le token est conservé en mémoire (pas de stockage durable à travers les rechargements).

## Flux branchés

| Écran/fonction | Route Spring Boot `main` | Comportement | Limite |
|---|---|---|---|
| Connexion | `POST /api/v1/auth/login` | JWT, rôle candidat/recruteur/admin | pas de récupération de mot de passe dans `main` |
| Inscription candidat | `POST /api/v1/candidates/register` | `multipart/form-data` puis connexion | les données supplémentaires ne sont pas acceptées par l'inscription |
| Recherche SIRET | `GET /api/v1/companies/lookup?siret=` | infos de l'entreprise | dépend du service public de recherche côté backend |
| Inscription recruteur | `POST /api/v1/recruiters/register` | une seule entreprise via `companyName` | pas de deuxième entreprise à choisir |
| Profil candidat | `GET/PATCH /api/v1/candidates/profile` | champs validés, compétences et liens | projets, recommandations, niveaux de compétences et masquer employeur non stockés |
| Accueil candidat | `GET /api/v1/candidates/profile`, `/recommendations` | infos réelles, score optionnel | pas de score inventé s'il n'y a pas d'offre |
| Recommandations candidat | `GET /api/v1/candidates/recommendations` | objets `content[].offer`, `match_score` | actions sauvegarder/passer uniquement locales |
| Candidature | `POST /api/v1/applications` | écrit une candidature réelle après « Intéressé » local | annulation du swipe n'annule pas une candidature déjà envoyée |
| Historique candidat | `GET /api/v1/candidates/applications` | résultats paginés + intérêts locaux | messagerie non créée par l'API actuelle |
| Recruteur : profil | `GET/PATCH /api/v1/recruiters/profile` | identité et entreprise | entreprise non modifiable depuis l'éditeur d'offre |
| Recruteur : offres | `POST /api/v1/recruiters/jobs` | création réelle liée automatiquement à l'entreprise | lecture intégrale de toutes les offres non exposée |
| Recruteur : offres visibles | `GET /api/v1/recruiters/dashboard` | résumés `topOffers` + créations en mémoire | `topOffers` est une sélection, non un catalogue complet ; édition de résumé désactivée |
| Recruteur : candidats | `GET /api/v1/recruiters/jobs/{id}/recommendations` | candidatures de l'offre classées par match | ce n'est pas un annuaire de tous les candidats |
| Recruteur : statut candidature | `PATCH /api/v1/applications/{id}/status` | VIEWED / IN_REVIEW / REJECTED selon action | vocabulaire affiché adapté aux statuts backend |
| Dashboard recruteur | `GET /api/v1/recruiters/dashboard` | métriques et activités réelles | pas de WebSocket temps réel |
| Admin : entreprises | `GET /api/v1/admin/companies` | pagination, recherche, modération en lecture | PATCH statut seulement ; pas de CRUD entreprise complet |
| Admin : comptes | `GET /api/v1/admin/candidates`, `/recruiters` | regroupement local, filtres UI | pas de liste d'administrateurs ni mutation de compte dans main |
| Admin : vérifications | `GET /api/v1/admin/companies` | projection du statut de vérification | relance de vérification non exposée |
| Notifications recruteur | activités de dashboard | consultation et état « lu » en session | aucune notification serveur persistante |
| Réglages recruteur | données locales | navigation/présentation préservées | ne promet pas de persistance serveur |
| Messagerie | aucune route dans main | écran conservé, conversation vide | envoi non fonctionnel jusqu'à un backend disponible |

## Fonctionnalités présentes uniquement dans des branches backend

L'API de suppression du compte sur `feat/A67-user-deletion` n'est pas disponible dans le `main` audité. Aucun appel à cette route n'est activé ici. Les autres branches listées dans l'audit antérieur ont leurs changements intégrés à `main` au moment de la comparaison Git (11–12/11/2026).

## Test local recommandé

```bash
cd GPSTL-JOYN-FRONT
flutter pub get
flutter analyze
flutter test
```

Pour travailler en mode API en local, créer `.env` à la racine :

```env
JOYN_DATA_MODE=api
JOYN_API_BASE_URL=https://gpstl-joyn-back.onrender.com
JOYN_API_TIMEOUT_MS=30000
```

Puis :

```bash
python3 scripts/run-joyn.py run -d chrome -t lib/main.dart
```

En mode simulé remplacer `JOYN_DATA_MODE=api` par `mock` ; l'interface conserve ses données de démonstration.

## Déploiement Cloudflare

Les `--dart-define` sont injectés **à la compilation Flutter**, pas en modifiant les variables d'environnement du navigateur après compilation. Le Worker `deploy/api-worker.mjs` conserve le proxy `/api/v1/*` vers le backend configuré côté Worker avec `JOYN_BACKEND_URL`. Le build Flutter peut utiliser :

```bash
flutter build web --release \
  --dart-define=JOYN_DATA_MODE=api \
  --dart-define=JOYN_API_BASE_URL=same-origin
```

Configurer dans Cloudflare Worker `JOYN_BACKEND_URL=https://gpstl-joyn-back.onrender.com` ; compiler puis redéployer les assets. **Ne pas mettre de token utilisateur dans les variables de build.** Vérifier les sessions et CORS/redirect dans le navigateur.

## Génération de données fictives

```bash
node scripts/seed-joyn.js       # simulation, aucun appel HTTP
node scripts/seed-joyn.js --help
```

Le scénario par défaut prévoit 30 entreprises, 60 recruteurs, 250 candidats, 300 offres (publiées ou brouillons) et 400 candidatures uniques. Il privilégie des données francophones plausibles et des profils cohérents avec les métiers ; les e-mails fictifs utilisent `example.test`.

**Exécution :** uniquement sur une base de test autorisée et avec `JOYN_SEED_PASSWORD` (mot de passe de test, longueur ≥ 12). Ajouter `--execute --base-url https://hote-staging --confirm-host hote-staging` et éventuellement `--resume` pour reprendre le fichier d'état. Le script refuse les domaines déployés connus sans autorisation supplémentaire explicite. Il limite le débit et la concurrence et vérifie les erreurs HTTP. **Aucun administrateur n'est créé**, car aucune route n'est prévue dans le backend `main`.

## Validation effectuée dans l'environnement de livraison

- ✅ `node --check scripts/seed-joyn.js`
- ✅ simulation de 30/60/250/300/400 sans requête HTTP
- ✅ exécution du script sur serveur local factice : 2 recruteurs, 2 entreprises, 3 candidats, 5 offres, 4 candidatures — 22 requêtes réussies
- ✅ `git diff --check`
- ⏳ `flutter analyze` / `flutter test` : **non exécutés**, Flutter et Dart absents de cet environnement
- ⏳ Intégration de bout en bout sur Render/Cloudflare : **non exécutée** ; aucun compte réel créé, aucune écriture en production

Il faut donc encore valider la compilation Flutter et les parcours utilisateurs réels avant la soutenance. Les fonctionnalités non supportées par le backend restent visuellement présentes mais ne sont pas présentées comme des écritures persistantes.
