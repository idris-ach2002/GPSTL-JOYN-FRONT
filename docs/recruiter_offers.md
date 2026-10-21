# R38 / R39 — Offres recruteur

La feature vit dans `lib/features/recruiter_offers/` et respecte la séparation
JOYN : `presentation/web` et `presentation/mobile` partagent uniquement le
domaine, les repositories, les contrôleurs et les composants `shared`.

## Parcours livrés

- `/recruiter/jobs` : gestion, recherche, filtres, statuts, clôture et menu Options.
- `/recruiter/jobs/new` : création d'une offre.
- `/recruiter/jobs/:id/edit` : modification avec le même éditeur pré-rempli.
- `/recruiter/jobs/:id` : détail natif mobile ; sur web, l'éditeur pré-rempli
  est utilisé.
- Sélection d'une entreprise parmi la base mockée.
- Recherche d'une entreprise par SIRET puis création manuelle si elle n'existe
  pas.
- Brouillon et publication.
- Champs conditionnels d'alternance, compétences et rémunération.

## Frontière API

`RecruiterOffersRepository` isole complètement l'IHM de la source de données.
`MockRecruiterOffersRepository` est injecté aujourd'hui. Le futur repository
HTTP pourra donc remplacer le mock sans modifier les écrans.

`JobOfferApiMapper` prépare le payload de création correspondant au contrat
Spring Boot actuel :

- `POST /api/v1/recruiters/jobs`
- `PATCH /api/v1/jobs/{id}`
- `DELETE /api/v1/jobs/{id}`

Le backend public actuel ne fournit pas encore de route GET dédiée à la liste
des offres du recruteur. Aucune URL fictive n'est donc codée dans le front.

### Point à synchroniser avec le backend

Le besoin produit R38 permet de choisir une entreprise existante dans la base,
puis de créer l'offre pour cette entreprise. Le POST Spring actuel déduit encore
l'entreprise depuis le profil recruteur et n'accepte pas `company_id` dans le
payload. La sélection est donc fonctionnelle avec le mock mais le branchement
HTTP final devra attendre l'évolution correspondante du backend.

### Suppression vs. clôture

La clôture reste mappée au `DELETE /api/v1/jobs/{id}` actuel du backend, qui
réalise un soft-delete métier. L’action **Supprimer** ajoutée dans l’IHM est
volontairement implémentée uniquement par le repository mock : aucune route HTTP
de suppression définitive n’est inventée tant que le backend ne fournit pas un
contrat distinct.
