# Page « Matchs » candidat (CA82)

> En tant que candidat connecté, je veux parcourir des offres ciblées sous forme
> de cartes interactives et les faire glisser à droite ou à gauche, afin de
> postuler en un geste aux offres pertinentes ou ignorer celles qui ne
> m'intéressent pas.

Route : `/candidate/discover` (onglet « Offres » de l'espace candidat).

## Gestes

| Geste                         | Bouton | Clavier (Web)   | Effet                              |
|-------------------------------|--------|-----------------|------------------------------------|
| Glisser à droite              | ♥      | →               | Ajoute l'offre à « Intéressé »      |
| Glisser à gauche              | ✕      | ←               | Ignore l'offre                     |
| Glisser vers le haut          | 🔖     | ↑               | Sauvegarde l'offre                 |
| —                             | ↶      | Retour arrière  | Annule le dernier geste            |

Les gestes sont **optimistes** : la carte part tout de suite, puis revient en
tête de pile si le backend refuse (message d'erreur dans un SnackBar).

## Code

```text
lib/features/candidate_discover/
  domain/recommended_offer.dart          RecommendedOffer, SwipeDecision, DiscoverFeed…
  data/recommended_offers_repository.dart     interface
  data/mock_recommended_offers_repository.dart données de démo (6 offres)
  data/api_recommended_offers_repository.dart  backend (contrat ci-dessous)
  presentation/controllers/discover_controller.dart  pile, gestes, annulation
  presentation/shared/   pile glissable, carte, « Pourquoi 92 % ? », boutons
  presentation/web/      écran Web (panneau du score à droite)
  presentation/mobile/   écran Mobile (score dans une bottom sheet)
```

Le dépôt est choisi dans `lib/app/bootstrap.dart` : Mock par défaut, API si
`JOYN_DATA_MODE=api` ou si `JOYN_API_BASE_URL` est fourni.

## Contrat API attendu

Toutes les routes exigent le jeton du candidat (`Authorization: Bearer …`).

### `GET /api/v1/candidates/me/recommendations`

Paramètres optionnels : `rhythm`, `location`. Les offres déjà traitées
(postulées, ignorées, sauvegardées) ne doivent **pas** être renvoyées.

```json
{
  "items": [
    {
      "id": "off-7",
      "title": "Développeur·euse Full-Stack en alternance",
      "company": { "name": "Entreprise Beta", "sector": "Fintech",
                   "headcount": 120, "city": "Paris 9e", "logoUrl": null },
      "compatibility": 92,
      "location": "Paris 9e",
      "commuteMinutes": 35,
      "rhythm": "3 sem / 1 sem",
      "remoteDays": 2,
      "monthlySalary": 1450,
      "contractType": "Alternance",
      "description": "…",
      "skills": [ { "name": "React", "matched": true },
                  { "name": "Docker", "matched": false } ],
      "criteria": [ { "label": "Technos", "score": 90 },
                    { "label": "Formation & niveau", "score": 100 },
                    { "label": "Rythme", "score": 100 },
                    { "label": "Trajet", "score": 75 } ],
      "alumniCount": 2
    }
  ],
  "filters": { "rhythm": "3 sem / 1 sem", "location": "Paris" },
  "totalCompatible": 10
}
```

Tolérances du mapping : enveloppe `data`, `offers`/`content` à la place de
`items`, `score`/`compatibilityScore`, `criteria` sous forme d'objet
(`{"skills": 90, "education": 100, "rhythm": 100, "commute": 75}`).

### `POST /api/v1/candidates/me/recommendations/{offerId}/decision`

Corps : `{ "decision": "interested" | "skip" | "save" }`. `interested` crée une
candidature au statut `INTERESTED` (non envoyée). Réponse attendue : `204` (ou `200` avec un corps ignoré).

### `DELETE /api/v1/candidates/me/recommendations/{offerId}/decision`

Annule le dernier geste sur l'offre (retire la candidature « intéressé »
si elle avait été créée). Réponse attendue : `204`.

## Hors périmètre / à venir

- Bouton « Filtres » et lien « Voir mon Skill Gap » : messages « bientôt ».
- L'envoi se fait depuis « Mes candidatures » (`/candidate/applications`),
  colonne « Intéressé » : `POST /api/v1/candidates/applications/{id}/send`.
