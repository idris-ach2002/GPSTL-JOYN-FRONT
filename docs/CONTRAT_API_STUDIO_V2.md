# Contrat API — Studio recruteur V2

Ce document décrit ce que le front envoie et attend. Aucun backend réel n’a été fourni ni testé.
Le contrat V1 reste dans `CONTRAT_API_RECRUTEUR.md`.

## Données de travail

Routes privées supplémentaires :

| Méthode | Route | Réponse |
| --- | --- | --- |
| GET | `/api/v1/recruiters/workspace` | Objet de travail complet |
| PATCH | `/api/v1/recruiters/workspace` | Objet complet après fusion, ou 204 suivi d’un GET |

Le serveur identifie le recruteur par le Bearer, vérifie le rôle et les droits, puis n’accède qu’à
ses données. L’identifiant de compte local n’est pas envoyé pour choisir un propriétaire serveur.
Ne pas autoriser une personne à écrire dans l’espace d’un autre compte.

Le PATCH remplace **uniquement les sections présentes dans le corps**. Par exemple :

```json
{"tasks":[{"id":"t1","title":"Relancer Alex","done":false,"priority":"high","due":"2026-10-30T00:00:00.000","candidateId":"cand-001","candidateName":"Alex Dupont"}]}
```

Les autres sections restent inchangées. Les tableaux contenus dans une section sont des snapshots,
pas une liste d’opérations JSON Patch. Le front séquence ses écritures ; une stratégie de concurrence
serveur reste nécessaire pour des modifications simultanées depuis plusieurs appareils.

Objet d’exemple (les sections absentes sont considérées comme vides par le front) :

```json
{
  "offerDefaults":{"contract":"CDI","remote":"HYBRID","location":"Paris"},
  "signature":"Camille · Joyn",
  "templates":[{"id":"r1","title":"Premier contact","text":"Bonjour {prenom}, votre profil nous intéresse."}],
  "drafts":{"c1":"Bonjour Alex, voici nos disponibilités."},
  "tasks":[{"id":"t1","title":"Lire le CV","done":false,"priority":"normal","due":null,"candidateId":"cand-001","candidateName":"Alex Dupont"}],
  "interviews":[{"id":"i1","candidateId":"cand-001","name":"Alex Dupont","title":"Premier échange","location":"Visio","start":"2026-10-30T10:00:00Z","duration":30,"status":"planned"}],
  "pipeline":[{"id":"cand-001","name":"Alex Dupont","title":"Développeur","stage":"contact"}],
  "notes":[{"id":"n1","candidateId":"cand-001","candidateName":"Alex Dupont","text":"Approfondir le projet React.","createdAt":"2026-10-29T16:00:00Z"}],
  "comparison":[],
  "candidateViews":[],
  "offerTemplates":[],
  "pinnedNotifications":["notification-1"],
  "archivedNotifications":[],
  "snoozedNotifications":{"notification-2":"2026-10-30T16:00:00Z"},
  "pinnedConversations":["c1"],
  "archivedConversations":[]
}
```

- `comparison` contient au plus trois snapshots de talents : id, name, title, location, education,
  experienceYears, availability, contract, remote, skills, score, strengths, warnings.
- `pipeline` peut reprendre les mêmes champs, plus `stage` : review/contact/interview/decision/closed.
- `candidateViews` contient `{id,name,query}` ; `query` reprend les paramètres du dépôt de recommandations V1.
- `offerTemplates` contient `{id,name,offer}` ; `offer` utilise les clés du helper `studioOfferTemplate` :
  title, contract, location, remote, experience, description, salaryMin, salaryMax, currency,
  salaryPeriod, skills, rhythmType, durationMonths, degreeLevelRequired.
- Les échéances de tâches sont des dates locales ; les heures d’entretiens sont envoyées en UTC.
- `interviews.status` est planned ou cancelled ; un créneau n’est pas une invitation envoyée.
- Les IDs de notes, tâches, modèles et entretiens sont produits côté client et doivent être uniques
  dans le contexte du compte. Le serveur doit valider les types, longueurs, enums et relations candidat/offre.
- Le front ne parcourt pas automatiquement une pagination de cet objet complet. Si le volume exige
  des sous-ressources paginées, adapter `StudioRepository` et l’état de présentation avant de l’exposer.

Une erreur de lecture/écriture affiche une erreur et permet de réessayer. Elle ne remplace pas
les données serveur par un scénario fictif. Aucun token n’est inclus dans les exports de cet objet.

## Routes V1 enrichies

### Profil

`GET/PATCH /api/v1/recruiters/profile` accepte les champs existants, plus :

`sector`, `sizeRange`, `tagline`, `benefits`, `values`, `recruitmentProcess`, `cover`.

`cover` vaut ocean/forest/sunset et désigne une ambiance de rendu de l’application.
Il ne s’agit pas d’une image téléversée. Les avantages sont actuellement saisis dans une chaîne,
avec une virgule comme séparateur dans l’aperçu.

### Préférences de notification

`GET/PATCH /api/v1/recruiters/settings` conserve emailNotifications, messageNotifications,
matchNotifications, profileVisible et accepte aussi :

```json
{"applicationNotifications":true,"offerNotifications":true,"digest":"daily","quietHours":true,"quietStart":"20:00","quietEnd":"08:00"}
```

`digest` : daily/weekly/off. Horaires au format HH:mm, interprétés par le service serveur
selon le fuseau de son utilisateur ; le front ne déclare pas de fuseau de distribution e-mail.
La distribution effective des e-mails/push et leur programmation ne sont pas implémentées par le front.

### Lecture / non-lecture d’une notification

`PATCH /api/v1/recruiters/notifications/{id}` accepte `{read:true}` et `{read:false}`.
La lecture est mise à jour après confirmation du serveur. Épingles, archives et reports sont
stockés dans l’objet de travail décrit plus haut. La suppression définitive utilise toujours DELETE.

### Offres, duplication et traitements groupés

La duplication appelle le POST existant avec `status:DRAFT` et un titre suffixé « (copie) ».
Le modèle ou les valeurs par défaut préremplissent le formulaire avant sa soumission habituelle.
Les actions groupées appellent les routes de clôture/suppression V1 une par une et réaffichent
les éléments en échec, sans prétendre qu’un lot partiellement refusé a entièrement réussi.

## Préférences propres à l’appareil

Thème, accent, densité, taille de texte, réduction des animations, contraste, aperçu de notification,
ajout de signature, placement du chat et modules masqués du dashboard restent dans le stockage
local des préférences. Ils ne sont pas envoyés au nouveau point d’accès workspace.

Le jeton reste en mémoire. Aucun stockage de secret, refresh token, gestion de sessions distantes,
WebSocket, accusé de lecture du candidat, pièce jointe ni notifications système natives n’est ajouté.

## Fichiers d’intégration

- `lib/features/recruiter_studio/data/studio_repository.dart` : GET/PATCH workspace.
- `lib/features/recruiter_studio/presentation/studio_controller.dart` : état, séquencement, séparation des comptes.
- `lib/features/recruiter_workspace/data/recruiter_workspace_repository.dart` : profil, messages et notifications.
- `lib/app/bootstrap.dart` : sélection mock/API et stockage de préférences.

Côté serveur, ajouter des tests de propriété des données, 401/403, validation, concurrence,
déduplication des messages et contrôle des relations candidat/offre avant mise en production.
