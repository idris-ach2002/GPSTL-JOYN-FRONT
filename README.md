## Correction des signalements et lots Git

Les `if` utilisent désormais des blocs explicites. Le menu utilise `SizeTransition(alignment: Alignment.topCenter)` et conserve son ouverture depuis le haut. La balise viewport du point d’entrée Flutter a été retirée pour laisser Flutter gérer sa configuration.

Depuis le checkout Git :

```bash
bash tool/validate_landing.sh
bash tool/commit_landing.sh --plan
bash tool/commit_landing.sh --apply
```

Le plan ne modifie pas Git. Le mode apply relance la validation complète avant le premier commit et s’arrête si elle échoue. Il refuse un index déjà rempli et les conflits, conserve la branche et les commits existants, puis crée jusqu’à dix lots selon les fichiers modifiés. Les anciens composants présents dans le checkout sont inclus dans leur lot fonctionnel lorsqu’ils existent. Aucun push n’est effectué. Les fichiers hors liste restent dans le working tree et sont affichés à la fin. Les anciens fichiers non suivis des sections supprimées (Skill Gap, écoles, Remplace-moi) ne sont pas ajoutés par le script.

Les commits regroupent l’état final par fonctionnalité ; la compilation de chaque commit intermédiaire n’est pas garantie. La validation complète porte sur l’état final avant les commits.

---

## Mise à jour de la landing — 16 octobre 2026

- Pictogrammes sémantiques distincts pour les entrées et sous-entrées du menu ; animation du tracé et agrandissement de 12 %, désactivés si les mouvements sont réduits.
- Assistance et Connexion alignées ; retrait des accès Essayer et Ressources dans la navbar.
- Texte public centré sur les usages : analyse du CV à la création du profil et recommandations, sans détails de stack ni calcul inventé.
- Deux acteurs : candidat et recruteur. Retrait des anciennes sections Skill Gap, Remplace-moi et écoles. Le bloc des usages est sélectionnable et accepte un balayage horizontal.
- Recherche FAQ avec normalisation des accents, catégories, pagination et transmission de la question vers l’assistance.
- Présentation des services sans prix ni conditions commerciales inventés. Les tarifs ne sont pas fournis dans ce livrable.
- Connexion et contact indisponibles : aucun faux envoi, paiement ou compte authentifié. L’aperçu du profil et les favoris restent locaux.

Validation de cette mise à jour : contrôle syntaxique Dart et des imports, correspondance des pictogrammes et destinations, intégrité du ZIP. Les tests Flutter sont actualisés mais non exécutés ici : Flutter et Dart ne sont pas installés dans cet environnement. Exécuter `bash tool/validate_landing.sh` sur la machine de développement avant livraison. Le contrôle visuel et la compilation restent nécessaires.

---

## Documentation de la version précédente

Les passages décrivant les écoles, le Skill Gap ou le calcul trois critères sont remplacés par la mise à jour ci-dessus.

# JOYN — Landing Flutter Web étendue

Une landing front avec l’identité futuriste et humaine validée : bleu nuit, éclairages bleus, signature manuscrite orange, personnages vectoriels et démonstrations manipulables. Aucun backend n’est utilisé.

## Lancer et vérifier

Le projet fourni exige un SDK Flutter contenant Dart >= 3.13.5 et < 4.0.0.

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test test/widget_test.dart
flutter run -d chrome
```

Validation complète incluant la compilation Web :

```bash
bash tool/validate_landing.sh
```

Les polices Inter, Space Grotesk et GreatVibes sont embarquées ; le téléchargement de polices à l’exécution est désactivé. Le premier `pub get` met à jour le lockfile pour les dépendances ajoutées.

## Navigation et footer corrigés

La navigation desktop utilise cinq entrées principales et des accès utilitaires Ressources, Assistance et Connexion. Le panneau blanc descend sous la barre : vignettes vectorielles, intitulés courts et colonne de contexte séparée. Les liens de navigation restent sur fond clair dans tous leurs états.

- Ouverture au survol ou au clic ; transition de 250 ms et tolérance de sortie de 180 ms.
- Passage entre rubriques sans fermer le panneau ; Échap ferme le menu et rend le focus au déclencheur.
- Les symboles sont dessinés dans le code. Leur tracé orange s’anime au survol/focus ; le symbole JOYN pivote légèrement sur interaction. Aucune animation ne boucle.
- Sous 1280 px : menu plein panneau sous la barre, recherche, six catégories, puis sous-rubriques avec retour à la liste. Les accès Assistance et Connexion sont explicites ; l’accès compte est aussi présent dans la barre par un bouton avec libellé accessible.
- Sur téléphone (< 600 px), la landing est organisée en six chapitres repliés. Un lien ouvre le chapitre correspondant avant de défiler vers la section. Le profil et les favoris restent en mémoire lorsque les chapitres sont repliés ; les contrôles masqués sont exclus du parcours clavier.
- La grande scène du hero est elle aussi dépliable sur téléphone.
- Footer blanc à quatre colonnes : Candidats, Entreprises & écoles, Assistance, JOYN & compte. Sur mobile, chaque colonne devient un accordéon. Les liens Données et Accessibilité renvoient à l’aide correspondante.

`LandingMegaNavigation`, `MobileChapter`, `LandingFooter` et `NavigationSymbol` assurent ces comportements. La hauteur réelle de la barre est transmise à la scène au défilement pour aligner son affichage.

## Connexion et assistance

Routes supplémentaires : `/connexion` et `/assistance`. Le formulaire de connexion est une interface front, avec sélection du parcours, validation locale et affichage/masquage du texte fictif. **Aucun compte n’est authentifié et aucune donnée n’est transmise.** L’interface invite à utiliser des valeurs d’exemple. La page Connexion porte une consigne `noindex`.

Le centre d’aide propose les trois guides et des informations sur les données de démonstration et la navigation. `/assistance?theme=donnees` et `/assistance?theme=accessibilite` ouvrent la partie concernée. Aucun faux chat, numéro ou service humain n’est annoncé.

## Correction des titres masqués

Le thème précédent appliquait un fond bleu nuit au survol des boutons texte. Certains titres conservaient une couleur bleu nuit explicite et disparaissaient. Les boutons texte ont désormais des fonds clairs ou transparents et un premier plan bleu nuit dans tous les états. Un test de régression vérifie le contraste des titres explicites pour les états normal, hover, focus, pressed et disabled.

## Contenu : 15 séquences, 17 zones navigables

Les séquences Mobile + formules et Ressources + FAQ sont subdivisées en zones pour permettre les liens précis du menu.

| Zone | Contenu / interaction |
| --- | --- |
| Introduction | Rencontre Camille–Alex, motivations et conversation fictive simulable |
| Difficultés | Quatre situations à inspecter : rythme, compétence, trajet, prochaine étape |
| Avant / après | Une annonce seule comparée au contexte du candidat |
| Parcours | Quatre scènes au défilement sur grand écran ; carrousel manuel de trois étapes sur les autres configurations |
| Matching | Paris, rythme et Flutter : trois critères de même poids, de 0 à 3 correspondances |
| Profil | Trois champs modifiables, validation, aperçu, exemple et remise à zéro ; aucun fichier chargé |
| Skill Gap | Trois exemples pédagogiques : Flutter, Docker et communication |
| Opportunités | Quatre offres fictives, recherche, filtre Paris, favoris, état vide et alerte simulée |
| Réciprocité | Quatre combinaisons des deux intérêts et aperçu de conversation |
| Suivi | Quatre étapes et les actions à préparer |
| Remplace-moi | Trois étapes d’un scénario de transmission à confirmer avec l’entreprise |
| Entreprises | Cinq sujets dépliables et aperçu d’un profil contextualisé |
| Écoles | Cinq sujets dépliables sur calendrier, missions et progression |
| Mobile | Aperçu illustratif sur téléphone |
| Formules | Périmètres de travail pour candidats et recruteurs, sans prix ni achat |
| Ressources | Trois guides HTML et leurs liens |
| FAQ | Quatorze questions filtrables par public |

Routes Flutter : `/`, `/candidats`, `/entreprises`, `/ecoles`. Les routes par public présentent la même landing avec arrivée sur la partie correspondante.

## Animations

1. **Connexion lumineuse** : un tracé courbe rejoint les profils et devient orange lors de l’intérêt partagé dans l’introduction.
2. **Scène au défilement** : sur une largeur d’au moins 1024 px et une hauteur utile d’au moins 812 px sous la barre, l’aperçu du parcours reste dans une scène qui accompagne le défilement. Les quatre étapes restent sélectionnables par boutons. Le document continue de défiler normalement.
3. **Profondeur légère** : la scène d’introduction se déplace au maximum de huit pixels en réponse à la souris, sur grand écran uniquement.
4. **Navigation** : ouverture et fermeture verticales du panneau, avec transition courte.

La réduction des mouvements désactive le déplacement à la souris, remplace la scène au défilement par le carrousel manuel et rend les déplacements de navigation immédiats. Un agrandissement du texte supérieur à 110 % utilise aussi le carrousel. Les faibles hauteurs d’écran évitent la scène fixe. Les vues restent défilables si le contenu agrandi dépasse l’espace disponible.

## Palette et design

Les couleurs proviennent du `app_colors.dart` de l’archive d’origine ; les éclairages utilisent leurs opacités.

| Usage | Valeur |
| --- | --- |
| Bleu nuit / variante | `#001E3B` / `#00254A` |
| Texte sombre | `#102A43` |
| Bleu lumineux / cyan | `#60A0FF` / `#489EC9` |
| Orange / orange clair | `#FF6731` / `#FF8559` |
| Blanc / fond clair | `#FFFFFF` / `#F5F8FB` |
| Gris / gris clair | `#9DA5AC` / `#D9D9D9` |
| Succès / avertissement / erreur | `#68B266` / `#F5A623` / `#E24B4B` |

Tokens : `lib/design_system/joyn_tokens.dart`. Thème : `lib/app/theme/app_theme_data.dart`. Un seul rayon d’interface : 16 px. La géométrie du symbole JOYN et des dessins ne définit pas de nouveaux rayons d’interface.

Cibles de 48 px minimum, focus de 3 px, textes foncés sur les actions orange, titres sémantiques et annonces des résultats. Les erreurs de formulaire sont expliquées par du texte bleu nuit et une bordure dédiée. Le contraste calculé bleu nuit/blanc est de 16,82:1 et bleu nuit/orange de 5,79:1. Le rendu final et le parcours au lecteur d’écran restent à contrôler sur la version compilée.

## Guides et SEO

Pages permanentes lisibles sans JavaScript :

- `web/presentation.html`
- `web/guides/profil.html` : compétences, preuves, contexte, apprentissages et relecture
- `web/guides/matching.html` : calcul de démonstration, écarts, limites et réciprocité
- `web/guides/entretien.html` : projet, récit, progression, questions et suite

Les guides sont reliés entre eux et à la landing. Ils disposent de titres, descriptions, Open Graph, JSON-LD WebPage, sommaires et liens sémantiques. Leur feuille de style et leurs polices sont locales après le build Flutter.

`web/index.html` conserve la langue, les métadonnées et les états de préparation/erreur de démarrage. Les titres des routes sont mis à jour côté navigateur.

Flutter ne produit pas automatiquement un document textuel adapté à l’indexation. Les pages HTML et les métadonnées ne garantissent ni indexation ni classement. Source : équipe Flutter, « Web FAQ », section SEO, mise à jour le 21 septembre 2026 : https://docs.flutter.dev/platform-integration/web/faq

Lorsque la vraie URL publique est connue, avant de compiler :

```bash
python3 tool/configure_seo.py --origin "$JOYN_PUBLIC_URL"
flutter build web --release
```

Le script configure les canoniques, Open Graph URL et un sitemap de cinq URL : racine, présentation et trois guides. Il accepte un sous-répertoire, rejette les URL non HTTPS et évite les doublons lors d’exécutions successives. Aucun domaine inventé n’est ajouté à la livraison.

L’hébergement doit servir les fichiers existants en priorité, puis réécrire les routes d’application vers `index.html`. Ne pas réécrire les guides, CSS, assets ni JS/Wasm. Sous un sous-répertoire, utiliser également `--base-href`.

## Données et statut de produit

Les personnages, offres, messages et réalisations illustrés sont fictifs. Le profil, les favoris, filtres, intérêts et statuts sont conservés uniquement en mémoire et sont effacés au rechargement. Aucun compte, candidature, message, notification ou paiement n’est créé. Aucun outil de mesure d’audience ni stockage persistant n’a été ajouté.

Le formulaire Profil ne charge pas de CV. Le matching compare trois critères de même poids ; ce n’est pas un score d’IA. Les exemples Skill Gap ne certifient aucun niveau. Remplace-moi illustre une transmission à vérifier avec l’entreprise. Les formules restent des périmètres de travail : les prix et engagements de la maquette n’ont pas été présentés comme confirmés.

## Validation : portée exacte

Dans l’environnement de préparation, les contrôles suivants ont été exécutés : syntaxe des sources Dart par parseur, imports locaux, références de tokens, palette, cibles du menu, polices, YAML/JSON, structure et liens HTML. Le script SEO a été exécuté dans une copie temporaire pour cinq pages, avec sous-répertoire, répétition de l’opération et rejet d’origines invalides.

**Flutter et Dart ne sont pas installés dans cet environnement : cette version étendue n’a pas été compilée ni rendue ici.** Les tests Flutter inclus ne sont donc pas déclarés réussis. La validation d’une ancienne version par l’utilisateur ne vaut pas validation de cette version.

Les tests couvrent le contraste des titres au survol, le menu desktop, le menu mobile par niveaux et sa recherche, Échap et le focus, les chapitres repliables et la conservation du profil, les favoris, l’état vide, la validation locale de connexion, le matching, la réciprocité, le carrousel et les largeurs 320/390/768/1024/1440. À exécuter avec les commandes au début de ce document.

## Auto-critique

Risque : transformer une landing riche en une succession de cartes identiques. Les compositions alternent comparaisons, listes éditoriales, scènes sombres, formulaire, guides et démonstrations. Les détails sont ouverts par intention, avec onglets et accordéons. Les scènes au défilement sont limitées à une seule séquence et disposent d’une alternative manuelle. La navbar associe des liens textuels à un panneau de vignettes vectorielles ; le footer utilise une hiérarchie de liens plutôt qu’une rangée de boutons d’action. Les profils expriment une motivation ; aucune statistique de résultat ni aucun témoignage non confirmé n’a été ajouté.
