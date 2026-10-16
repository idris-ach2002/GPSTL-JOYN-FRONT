# FAQ et assistance

[Sommaire](README.md) · [QuestionsSection](fichiers/questions_section.md) · [ServiceScreen](fichiers/service_screen.md)

## Modèle de contenu

La constante `questions` contient des triplets : catégorie, question et réponse. La FAQ contient douze entrées. Les catégories disponibles sont `PROFIL ET CV`, `RECOMMANDATIONS`, `CANDIDATURES`, `RECRUTEURS`, `FORMULES` et `ASSISTANCE`. Le filtre `TOUT` ne restreint pas la catégorie.

`search` détient la saisie. `category` sélectionne le groupe. `page` commence à zéro. `open` est l’indice global de la réponse ouverte, et vaut null lorsque toutes les réponses sont fermées.

## Recherche

`normalize` met le texte en minuscules et remplace les lettres accentuées ainsi que `œ`. La saisie est découpée en mots par les espaces. Une entrée est retenue si elle appartient à la catégorie active et si chacun des mots figure dans la question ou sa réponse normalisée.

Les mots n’ont pas à être consécutifs et leur ordre dans la saisie n’impose pas leur ordre dans la réponse. Une saisie vide accepte toutes les entrées de la catégorie. La recherche est locale et ne réalise aucun appel distant.

## Pagination

`pageSize` vaut 5. Le nombre de pages est l’arrondi supérieur du nombre de résultats divisé par cinq. `skip(page * pageSize).take(pageSize)` fournit la tranche affichée.

Une modification de recherche ou de catégorie ramène `page` à zéro et ferme la réponse ouverte. Changer de page ferme également la réponse. Les boutons précédent et suivant sont désactivés aux limites. La pagination n’est pas affichée lorsqu’il y a au plus une page.

## Absence de résultat et assistance

Un résultat vide affiche une explication et conserve l’accès à l’assistance. La saisie est transmise au paramètre `question` d’une URI construite avec `Uri`, puis à `ServiceScreen`. Elle préremplit un champ visible sur la page d’assistance.

Ce transfert ne constitue pas un envoi de demande. Le champ ne contacte pas un service de support ; la page présente sa disponibilité. Aucun message de succès d’envoi n’est émis.

## Ajouter ou modifier une réponse

1. Ajouter le triplet dans `questions` avec une catégorie disponible.
2. Si la catégorie est nouvelle, l’ajouter aussi à la liste des boutons de catégorie.
3. Décrire le comportement réel sans inventer de délai, de tarif ou de règle de recommandation.
4. Vérifier une recherche avec et sans accents, le filtre de catégorie et le passage entre pages.
5. Vérifier qu’un résultat absent laisse l’assistance accessible et conserve le sujet dans l’URL.
