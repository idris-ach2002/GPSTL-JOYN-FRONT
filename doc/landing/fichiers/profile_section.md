# `profile_section.dart`

Permet de saisir une présentation et de mettre à jour un aperçu local du profil.

[Code source](../../../lib/features/landing/presentation/sections/profile_section.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `../../../../design_system/joyn_tokens.dart`
- `../widgets/editorial_layout.dart`
- `../widgets/person_portrait.dart`
- `../widgets/product_atmosphere.dart`

## Types et constructeurs

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `ProfileSection` | `Bibliothèque` | Formulaire de présentation avec validation et aperçu indépendant des champs. | `class ProfileSection extends StatefulWidget` |
| `ProfileSection` | `ProfileSection` | Initialise les paramètres de ProfileSection ; les valeurs par défaut figurent dans la signature. | `const ProfileSection({super.key})` |
| `_ProfileSectionState` | `Bibliothèque` | État de ProfileSection ; définit ses données mutables et son rendu. | `class _ProfileSectionState extends State<ProfileSection>` |

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `createState` | `ProfileSection` | Crée l’état local associé au widget. | `State<ProfileSection> createState()` |
| `dispose` | `_ProfileSectionState` | Libère les ressources détenues par cet état avant sa destruction. | `void dispose()` |
| `requiredText` | `_ProfileSectionState` | Refuse une chaîne vide ou ne contenant que des espaces. | `String? requiredText(String? value)` |
| `fillExample` | `_ProfileSectionState` | Renseigne les trois champs et actualise l’aperçu du profil. | `void fillExample()` |
| `build` | `_ProfileSectionState` | Construit la présentation à partir de la configuration et de l’état courant. | `Widget build(BuildContext context)` |

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `form` | `_ProfileSectionState` | Clé du formulaire utilisée pour déclencher la validation de ses champs. | `final form = GlobalKey<FormState>()` |
| `name` | `_ProfileSectionState` | Contrôleur du prénom ou nom de la personne représentée, selon la portée. | `final name = TextEditingController(text: 'Camille')` |
| `skill` | `_ProfileSectionState` | Contrôleur de la compétence saisie dans l’aperçu du profil. | `final skill = TextEditingController(text: 'Dart et interfaces web')` |
| `project` | `_ProfileSectionState` | Contrôleur de la réalisation saisie dans l’aperçu du profil. | `final project = TextEditingController(text: 'J’ai construit un outil de suivi de tâches et travaillé sa navigation.')` |
| `snapshot` | `_ProfileSectionState` | Copie validée des trois champs affichée dans l’aperçu ; null représente un aperçu vide. | `(String, String, String)? snapshot = ('Camille', 'Dart et interfaces web', 'J’ai construit un outil de suivi de tâches et travaillé sa navigation.')` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `super.key` | `ProfileSection` | Identité du widget dans l’arbre Flutter. |
| `String? value` | `String? requiredText(String? value)` | Valeur reçue par le paramètre ou affichée dans la ligne, selon la portée. |
| `BuildContext context` | `Widget build(BuildContext context)` | Contexte Flutter de l’élément en cours de construction. |

