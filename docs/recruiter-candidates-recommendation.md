# Recommandations candidats — contrat front R48

L'écran `/recruiter/candidates` fonctionne dans les mêmes modes de données que le dashboard :

- `JOYN_DATA_MODE=mock` : données et actions simulées localement ;
- `JOYN_DATA_MODE=api` : lecture/écriture via `JOYN_API_BASE_URL` ;
- `JOYN_DATA_MODE=auto` : API si une base URL est fournie, mock sinon.

## Endpoints préparés

```text
GET    /api/v1/recruiters/recommendations
GET    /api/v1/recruiters/recommendations/:candidateId
POST   /api/v1/recruiters/recommendations/:candidateId/interest
POST   /api/v1/recruiters/recommendations/:candidateId/save
POST   /api/v1/recruiters/recommendations/:candidateId/reject
DELETE /api/v1/recruiters/recommendations/:candidateId/save
```

Le endpoint de liste accepte notamment : `offerId`, `status`, `scoreMin`, `page`, `limit`, `sort`, `location`, `availability`, `experienceMin`, `experienceMax`, `skills`, `contractType`.

La réponse liste attendue expose les clés `items`, `offers`, `stats`, `page`, `totalPages`, `totalItems` et `selectedOfferId`. Le mapper accepte également `recommendations` ou `content` pour la liste et un wrapper `data`.

Les écrans ne dépendent jamais directement du mock ou de HTTP : ils utilisent `RecruiterCandidateRepository`, injecté au démarrage selon `AppEnvironment`.
