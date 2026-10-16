# `app_routes.dart`

Regroupe des chemins de navigation du projet ; leur présence ne les enregistre pas dans le routeur actif.

[Code source](../../../lib/app/routing/app_routes.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `AppRoutes` | `Bibliothèque` | Catalogue de chemins du projet, distinct de la liste des routes enregistrées. | `class AppRoutes` |
| `AppRoutes` | `AppRoutes` | Initialise les paramètres de AppRoutes ; les valeurs par défaut figurent dans la signature. | `AppRoutes._()` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `landing` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String landing = '/'` |
| `login` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String login = '/login'` |
| `candidateRegister` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String candidateRegister = '/register/candidate'` |
| `recruiterRegister` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String recruiterRegister = '/register/recruiter'` |
| `candidate` | `AppRoutes` | Intérêt exprimé du côté candidat dans la scène interactive. | `static const String candidate = '/candidate'` |
| `candidateDiscover` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String candidateDiscover = '/candidate/discover'` |
| `candidateProfile` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String candidateProfile = '/candidate/profile'` |
| `candidateApplications` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String candidateApplications = '/candidate/applications'` |
| `recruiter` | `AppRoutes` | Sélectionne le rôle recruteur ou son portrait selon le composant. | `static const String recruiter = '/recruiter'` |
| `recruiterJobs` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String recruiterJobs = '/recruiter/jobs'` |
| `recruiterCandidates` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String recruiterCandidates = '/recruiter/candidates'` |
| `recruiterCompany` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String recruiterCompany = '/recruiter/company'` |
| `messages` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String messages = '/messages'` |
| `admin` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String admin = '/admin'` |
| `adminUsers` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String adminUsers = '/admin/users'` |
| `adminCompanies` | `AppRoutes` | Chemin nommé du projet ; vérifier son enregistrement dans appRouter avant navigation. | `static const String adminCompanies = '/admin/companies'` |

