# JOYN

JOYN met en relation des candidats et des recruteurs autour d’offres correspondant aux profils. L’application réunit la présentation du parcours, les recommandations de postes et le suivi des candidatures.

## Le point de départ

Une recherche d’emploi demande de rapprocher plusieurs informations : ce que le candidat sait faire, ce qu’il recherche, les missions du poste et ses conditions. Une liste d’intitulés ne suffit pas à expliquer cette correspondance. Du côté du recruteur, les profils reçus doivent pouvoir être replacés dans le contexte de chaque offre.

JOYN organise ces informations dans deux parcours : le candidat présente son expérience et suit ses démarches ; le recruteur décrit son besoin et gère les candidatures associées à ses offres.

## Les parcours

| Candidat                                         | Recruteur en entreprise                         |
| ------------------------------------------------ | ----------------------------------------------- |
| Constituer son profil à partir de son CV         | Présenter les missions et conditions d’un poste |
| Consulter les offres correspondant à son profil  | Consulter les profils recommandés               |
| Examiner une offre avant de candidater           | Retrouver les candidatures par offre            |
| Suivre ses candidatures et préparer les échanges | Organiser le suivi et préciser les attentes     |

Lors de la création du profil, l’analyse du CV joint fournit les informations nécessaires à sa constitution. Les recommandations rapprochent ensuite le profil des offres. Une correspondance aide à orienter la recherche ; elle ne constitue pas une décision de recrutement.

## Fonctionnalités

| Fonctionnalité | Description                                                                       | Documentation                             |
| -------------- | --------------------------------------------------------------------------------- | ----------------------------------------- |
| Landing page   | Présentation de JOYN, parcours candidat et recruteur, formules, FAQ et assistance | [Documentation technique](doc/landing.md) |

## Démarrer l’interface Web

Utiliser un SDK Flutter dont Dart satisfait la contrainte de [pubspec.yaml](pubspec.yaml).

```bash
flutter pub get
flutter run -d chrome
```

Les polices sont embarquées dans le projet. La documentation de la landing décrit les interactions locales et les limites d’intégration des pages de service.
