# Contrat API du front recruteur

Contrat proposé au backend, établi à partir du code front livré. Ce document n’atteste pas
l’existence de ces endpoints sur un serveur. Les routes préexistantes sont signalées.
Origine dans `JOYN_API_BASE_URL`, sans suffixe `/api/v1`. Toutes les routes privées utilisent
`Authorization: Bearer <accessToken>`. Les écritures envoient du JSON.

## Routes

| Méthode | Route | Corps / réponse |
| --- | --- | --- |
| POST | `/api/v1/auth/login` | `{email,password}` → session ci-dessous |
| POST | `/api/v1/auth/register` | champs du compte, `role`, consentements → session |
| POST | `/api/v1/auth/forgot-password` | `{email}` → 204 ou JSON ; réponse neutre |
| POST | `/api/v1/auth/logout` | pas de corps → 204 |
| GET | `/api/v1/companies/lookup?siret=...` | entreprise d’inscription ; 404 si absente |
| GET/PATCH | `/api/v1/recruiters/profile` | objet profil ci-dessous |
| GET/PATCH | `/api/v1/recruiters/settings` | objet préférences ci-dessous |
| GET | `/api/v1/recruiters/notifications` | liste notifications |
| PATCH | `/api/v1/recruiters/notifications/{id}` | `{read:true}` → 200/204 |
| DELETE | `/api/v1/recruiters/notifications/{id}` | → 200/204 |
| GET/POST | `/api/v1/conversations` | liste / `{candidateId}` → conversation existante ou créée |
| GET/POST | `/api/v1/conversations/{id}/messages` | liste / `{text,clientId}` → message confirmé |
| PATCH | `/api/v1/conversations/{id}/read` | `{read:true}` → 200/204 |
| GET/POST | `/api/v1/recruiters/companies` | liste / données entreprise → entreprise |
| GET | `/api/v1/recruiters/companies?siret=...` | liste filtrée |
| GET/POST | `/api/v1/recruiters/jobs` | liste / payload JobOfferApiMapper → offre |
| GET/PUT/PATCH/DELETE | `/api/v1/jobs/{id}` | détail / modification / `{status:"CLOSED",reason?}` / suppression |
| GET | `/api/v1/recruiters/jobs/{jobId}/applications` | liste candidatures |
| PATCH | `/api/v1/recruiters/jobs/{jobId}/applications/{id}` | `{stage:"IN_PROGRESS"|"INTERVIEW"|"REJECTED"}` |

Le mapper POST et le chemin `/api/v1/jobs/{id}` existaient dans le dépôt ; les implémentations
réseau de gestion des offres ont été ajoutées. Les réponses GET et les mutations autres que
le POST ne sont pas vérifiées contre le backend.
Les anciennes routes de dashboard et recommandations restent dans :
`api_recruiter_dashboard_repository.dart` et `api_recruiter_candidate_repository.dart`.

## Objets JSON attendus

Session (ou enveloppe `{data: <session>}`) :

```json
{"accessToken":"jeton","user":{"id":"42","email":"recruteur@example.org","role":"COMPANY"}}
```

`access_token` est aussi accepté. Rôles reconnus : COMPANY/RECRUITER et STUDENT/CANDIDATE.
Le rôle et les autorisations doivent être vérifiés par le serveur. Le filtre GoRouter constitue
uniquement une protection de navigation côté client.

Profil (GET retourne tous les champs, PATCH peut être partiel) :

```json
{"firstName":"Camille","lastName":"Martin","jobTitle":"Responsable recrutement","phone":"","companyName":"Joyn","city":"Paris","website":"https://example.org","description":"Notre équipe…"}
```

Préférences :

```json
{"emailNotifications":true,"messageNotifications":true,"matchNotifications":true,"profileVisible":true}
```

Notification :

```json
{"id":"n1","title":"Nouveau message","body":"Un candidat vous a répondu","kind":"message","read":false,"target":"/recruiter/messages","createdAt":"2026-10-29T15:10:00Z"}
```

Les destinations autorisées par l’écran sont les routes recruteur messages, candidates, jobs,
profile et dashboard. Un lien externe arbitraire n’est pas ouvert.

Conversation :

```json
{"id":"c1","candidateId":"42","name":"Alex Dupont","offerTitle":"Développeur Full-Stack","unread":1,"lastMessage":"Bonjour"}
```

Message (le serveur calcule `fromMe` par rapport à l’utilisateur connecté) :

```json
{"id":"m1","clientId":"web-123","text":"Bonjour Alex","fromMe":true,"createdAt":"2026-10-29T15:10:00Z"}
```

Le serveur doit vérifier l’appartenance à la conversation et l’éligibilité du contact.
Ne pas faire confiance au candidat sélectionné par le client. Dédupliquer `clientId` pour éviter
un double envoi après un timeout ambigu. Le serveur retourne le message créé avec un ID stable.
Les messages et toutes les listes doivent être ordonnés de façon stable ; les messages sont
attendus du plus ancien au plus récent. Le front ne prétend pas qu’un message est lu par le candidat.

Candidature :

```json
{"id":"application-1","candidateId":"42","name":"Alex Dupont","education":"Master informatique","stage":"NEW"}
```

Entreprise d’inscription : `siret, legalName, displayName, city, activity, emailDomain, sector?, sizeRange?`.
Entreprise d’offre : `id, name, siret, activity, sector, sizeRange, city, website?, description`.

Offre : champs du mapper existant en snake_case, plus `id`, `company_id` (ou `companyId`),
`updated_at` au format ISO ; `published_at`, `candidate_count` optionnels.
`contract_type`: CDI/CDD/INTERNSHIP/APPRENTICESHIP/PROFESSIONALIZATION/FREELANCE/TEMPORARY.
`remote_policy`: ONSITE/HYBRID/REMOTE. `experience_level`: JUNIOR/MID/SENIOR.
`status`: DRAFT/PUBLISHED/CLOSED/ARCHIVED. `salary_period`: HOUR/MONTH/YEAR.
Les valeurs inconnues sont rejetées plutôt que transformées en faux défauts métier.

## Réponses et erreurs

- Objets nus ou `{data: objet}`. Listes nues, `{items:[...]}`, `{content:[...]}` ou enveloppe `data`.
- PATCH profil/préférences : objet complet ou 204 ; après 204, le front recharge via GET.
- PUT offre : objet complet ou 204 ; après 204, GET de confirmation.
- POST compte/conversation/message/offre/entreprise : retourner l’objet créé, pas un 204 vide.
- 401 : session locale invalidée. 403 : refus sans changement de rôle. 404 offre : introuvable.
- 409 auth : compte existant. 429 auth : trop de tentatives. Timeout : erreur, aucune mutation inventée.
- Le front n’affiche pas le corps brut des erreurs serveur à l’utilisateur.
- Pas de retry automatique des POST. La reprise manuelle d’un message réutilise son `clientId`.

## Emplacements à adapter si le backend diffère

`lib/features/auth/data/api_auth_repository.dart`,
`lib/features/registration/data/api_registration_repository.dart`,
`lib/features/recruiter_workspace/data/recruiter_workspace_repository.dart`,
`lib/features/recruiter_offers/data/api_recruiter_offers_repository.dart`,
`lib/features/recruiter_offers/data/job_offer_api_mapper.dart`.
Le choix mock/API est centralisé dans `lib/app/bootstrap.dart`.
