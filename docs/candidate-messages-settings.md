# Espace candidat : messagerie, notifications, paramètres

## Messagerie (`/candidate/messages`)

Liste à gauche, fil à droite (Web) ; liste puis fil en plein écran (Mobile).
Conforme à la maquette `assets/figma_demo/candidate_messages.png`.

La liste fusionne trois sortes de fils :

| Fil | Origine | Ce que le candidat peut faire |
|---|---|---|
| Conversation ouverte | `GET /api/v1/conversations` | Lire, écrire |
| Entretien proposé | candidature au statut entretien, sans conversation | « Démarrer la conversation » (`POST /api/v1/conversations`) |
| En attente de réponse | candidature envoyée | Rien : le chat se débloque à l'entretien |

C'est la règle du back : un candidat ne peut ouvrir une conversation qu'à partir
du statut `INTERVIEW` ou `ACCEPTED` (403 sinon).

Le recruteur utilise les mêmes routes : `ApiRecruiterWorkspaceRepository` les
appelle via `ApiMessagingRepository` (`lib/features/messaging/`).

### Routes du back utilisées

- `GET    /api/v1/conversations`
- `POST   /api/v1/conversations` `{application_id}` (candidat) ou `{candidateId}` (recruteur)
- `GET    /api/v1/conversations/{id}/messages?before&limit&order`
- `POST   /api/v1/conversations/{id}/messages` `{text, clientId}`
- `PATCH  /api/v1/conversations/{id}/read`

## Notifications (cloche de la barre du haut)

Panneau à droite (Web) ou feuille (Mobile). Pastille de non-lues sur la cloche,
pastille de messages non lus sur l'icône Messages. Cliquer une notification la
marque lue et mène à la page concernée (message → Messages, entretien →
Candidatures, match → Matchs).

- `GET    /api/v1/notifications?page&limit`
- `PATCH  /api/v1/notifications/{id}/read`, `PATCH /api/v1/notifications/read-all`
- `DELETE /api/v1/notifications/{id}`, `DELETE /api/v1/notifications/read`

## Paramètres (`/candidate/settings`)

Uniquement ce que le profil ne gère pas déjà (le rythme, la date de début et la
durée se modifient depuis le profil) :

- **Ce que je recherche** : types de contrat, télétravail, rémunération minimum
  → `PATCH /api/v1/candidates/profile` `{preferences: …}` ;
- **Visibilité du profil** : visible des recruteurs / des autres membres, nom de
  famille, liens → `PATCH /api/v1/candidates/profile` `{visibility: …}` ;
- **Notifications** : tout marquer comme lu, supprimer les lues ;
- **Compte** : adresse de connexion, déconnexion.

## En attente du back

| Besoin | État |
|---|---|
| Changer / réinitialiser le mot de passe | Aucune route |
| Supprimer son compte | Aucune route |
| Préférences de notification (e-mail, types) | Aucune route |
| Pièce jointe (CV) dans le chat | Messages texte uniquement |
| Temps réel | `GET /conversations/stream` existe, mais exige l'en-tête `Authorization`, qu'un `EventSource` de navigateur ne peut pas envoyer. Le front rafraîchit toutes les 15 s. Il faudrait accepter le jeton en paramètre (ou un cookie). |
| Démarrer une conversation côté recruteur sans `jobId` | À confirmer : le back documente `{candidateId, jobId}` |
| Unité de `min_salary` | Le front l'affiche en € brut / mois : à confirmer |
| « Sauvegarder » une offre (Matchs) | Aucune route, reste local |
