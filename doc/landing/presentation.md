# Présentation et périmètre

[Sommaire](README.md) · [Assemblage](fichiers/landing_screen.md)

## Intention

La page publique présente le lien entre le parcours du candidat et le besoin de recrutement. Elle explique la constitution du profil à partir du CV, les recommandations, les candidatures et les échanges. Les deux acteurs présentés sont le candidat et le recruteur en entreprise.

La partie explicative décrit le fonctionnement de JOYN. Les commandes de la landing permettent d’examiner des exemples ; elles ne réalisent pas elles-mêmes une analyse de CV ni un envoi de candidature.

## Composition de la page

L’ordre est défini dans la table `parts` de `LandingScreen`. Les clés de cette table servent également de cibles de défilement.

| Cible | Section | Rôle |
| --- | --- | --- |
| `hero` | `FuturistHero` | Présenter JOYN et rejoindre les recommandations |
| `difficultes` | `SearchDifficultiesSection` | Examiner quatre situations de recherche |
| `comparaison` | `BeforeAfterSection` | Comparer les informations disponibles avant et après contextualisation |
| `parcours` | `ScrollJourneySection` | Parcourir les étapes du profil à l’échange |
| `matching` | `MatchingWorkbench` | Expliquer l’analyse du CV, le profil et les recommandations |
| `profil` | `ProfileSection` | Prévisualiser une présentation de compétence et de réalisation |
| `opportunites` | `OpportunitiesSection` | Rechercher et enregistrer des offres illustrées |
| `reciprocite` | `ReciprocitySection` | Distinguer les intérêts des deux acteurs |
| `suivi` | `ApplicationTrackingSection` | Examiner les étapes d’une démarche |
| `entreprises` | `OrganisationSection` | Sélectionner les fonctions candidat ou recruteur |
| `mobile` | `PocketSection` | Présenter le parcours sur téléphone |
| `offres` | `PlanComparisonSection` | Présenter les services selon l’acteur |
| `ressources` | `ResourcesSection` | Ouvrir les guides du profil, des recommandations et de l’entretien |
| `questions` | `QuestionsSection` | Rechercher une réponse et rejoindre l’assistance |

Le menu est placé avant la zone défilable. Le pied de page suit les sections. Sous 600 pixels, la page regroupe les sections après le hero dans six chapitres : comprendre, profil, opportunités, recruteurs, mobile/services et guides/questions. Un chapitre est ouvert à la fois.

## Données de présentation

Les offres, portraits et scènes sont des exemples d’interface. Les favoris et champs ne sont pas persistés dans un compte. Les textes ne promettent ni embauche, ni tarif, ni partenariat d’entreprise. La rubrique des services distingue les usages ; elle ne présente pas de conditions commerciales.

Les pages de connexion et d’assistance ont leur propre route. Leur disponibilité et les traitements réellement exécutés sont décrits dans [l’intégration des services](integration.md).
