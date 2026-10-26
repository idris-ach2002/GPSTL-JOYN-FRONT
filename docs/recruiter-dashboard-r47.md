# R47 — Dashboard recruteur

## Routes frontend

- `/recruiter/dashboard` : vue synthèse.
- `/recruiter/dashboard/insights` : outil analytique multi-séries / heatmap / funnel / surface 3D.
- `/recruiter/dashboard/offers/:id` : performance détaillée d'une offre.

La navbar recruteur existante est réutilisée. L'onglet **Candidats** reste hors du périmètre R47 ; le deck de recommandations sera traité par R45.

## Modes de données

Le front utilise `AppEnvironment` et choisit le repository au démarrage :

- `JOYN_DATA_MODE=mock` : données et comportements simulés.
- `JOYN_DATA_MODE=api` : appels réels, aucune retombée silencieuse vers les mocks.
- `JOYN_DATA_MODE=auto` : API si `JOYN_API_BASE_URL` est renseignée, sinon mock.

Exemple local :

```bash
cp .env.example .env
# puis ajuster JOYN_DATA_MODE / JOYN_API_BASE_URL
./scripts/dev/run_web.sh
```

## Contrat backend R47 préparé

Le backend Spring fourni ne contient pas encore ces endpoints. Le repository API est néanmoins prêt pour le contrat suivant :

### `GET /api/v1/recruiters/dashboard?period=30d`

Réponse attendue :

```json
{
  "kpis": [
    {"id":"applications","label":"Candidatures reçues","value":"248","deltaPercent":12,"deltaLabel":"vs période précédente"}
  ],
  "trend": [
    {"date":"2026-10-01","applications":28,"matches":8,"interviews":3,"previousApplications":22}
  ],
  "profileDistribution": [{"label":"Très compatibles","value":38}],
  "topOffers": [
    {"id":1,"title":"Développeur Full-Stack","location":"Paris","contract":"Alternance","status":"Publiée","applications":128,"matches":32,"interviews":12,"views":1240,"conversionRate":25,"lastActivity":"il y a 2 h"}
  ],
  "activities": [
    {"kind":"application","title":"Nouvelle candidature","subtitle":"Développeur Full-Stack","whenLabel":"il y a 2 h"}
  ],
  "priorityActions": [
    {"title":"5 profils à évaluer","subtitle":"…","actionLabel":"Examiner"}
  ]
}
```

### `GET /api/v1/recruiters/dashboard/insights?period=30d`

Contient `trend`, `funnel`, `channels`, `heatmap`, `surface`.

### `GET /api/v1/recruiters/dashboard/offers/{id}?period=30d`

Contient `offer`, `kpis`, `trend`, `sources`, `pipeline`, `skills`, `actions`.

## Cache

`CachedRecruiterDashboardRepository` garde les agrégats deux minutes par clé `(vue, période, offre)` pour éviter de recalculer les métriques lourdes à chaque navigation.

## Authentification et secrets

`ApiClient` accepte un `AuthTokenProvider`; le bearer token utilisateur doit à terme provenir du flux de connexion et du stockage de session.

**Important pour Flutter Web :** `JOYN_API_BASE_URL` est une configuration publique. Un token statique fourni au build (`.env`, `--dart-define`, variables Docker) se retrouverait dans le bundle JavaScript et ne doit pas être considéré comme un secret. Les secrets d'infrastructure doivent rester côté backend/proxy.

## Backend Spring fourni : état constaté

Les contrôleurs actuels exposent notamment :

- `POST /api/v1/recruiters/jobs`
- `PATCH /api/v1/jobs/{jobId}`
- `DELETE /api/v1/jobs/{jobId}`
- `POST /api/v1/applications`
- `PATCH /api/v1/applications/{applicationId}/status`
- `POST /api/v1/auth/login`

Le point d'agrégation R47 reste donc à implémenter côté backend.

## Docker

Build local :

```bash
docker compose --env-file .env up --build
```

Le front est servi par Nginx sur `http://localhost:8081`.

Pour un hébergeur, passer les valeurs publiques au build :

```bash
docker build \
  --build-arg JOYN_DATA_MODE=api \
  --build-arg JOYN_API_BASE_URL=https://api.example.com \
  -t joyn-front .
```
