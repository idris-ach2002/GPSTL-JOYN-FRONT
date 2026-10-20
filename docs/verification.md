# Vérifications exécutées — 20 octobre 2026

Environnement : Flutter **3.47.7**, Dart **3.13.5**, Linux.
Les commandes de validation ont été exécutées avec télémétrie désactivée et
mode CI explicite. La résolution des dépendances a utilisé le cache local.

| Contrôle | Résultat |
| --- | --- |
| Formatage Dart | 36 fichiers formatés ; contrôle final sans changement |
| Analyse Flutter | No issues found — aucune erreur, aucun avertissement |
| Tests Flutter | **16 tests réussis**, aucun échec |
| Compilation web release | **Réussie**, y compris le contrôle Wasm préalable |
| Palette AppColors | Noms et valeurs des constantes identiques à la source |
| Script d'import | Syntaxe Bash vérifiée ; scénarios Git exécutés |
| Intégrité Git | git diff --check et git fsck --no-dangling réussis |

## Tests couverts

- Héritage des droits JOYN+ et Membre premium.
- Bascule des fonctionnalités et des tarifs candidat/entreprise.
- Carrousel : boutons, flèches clavier, position courante et borne de début.
- Démonstrations : score calculé à partir des critères, import et réinitialisation.
- Catalogue des liens du footer ; ouverture d'une page puis retour au même scroll.
- Absence d'animation perpétuelle une fois les interactions terminées.
- Tarifs avec texte agrandi à 1,6, fenêtre de 390 px.
- Parcours natif existant, annulation du timer et réduction des mouvements.
- Landing web et navigation aux largeurs de 320, 768 et 1440 px.

## Contrôle visuel réel

La compilation release a été servie localement puis ouverte dans Chromium
134.0.6998.35, en fenêtre de 1440 × 1080 px. Des captures internes du hero,
des fonctionnalités, de la transition orange, des tarifs, du footer et du guide
ont été examinées. Le guide a été ouvert depuis le footer puis le retour à la
landing a été activé. Aucune erreur JavaScript ni ressource échouée n'a été
signalée pendant ce dernier parcours.

La première inspection avait révélé des chargements de polices de repli externes.
Roboto est désormais embarquée (regular, medium, bold, black), avec sa licence.
Les symboles textuels concernés ont été remplacés par des libellés lisibles.
Le contrôle navigateur final utilise ces ressources locales.

L'inspection vérifie la composition et le rendu ; elle ne constitue pas une
comparaison automatisée au pixel près avec Figma. Firefox, Safari et les appareils
natifs physiques restent à contrôler dans l'environnement de l'équipe.
Aucune nouvelle conception mobile n'est incluse dans cette passe.

## Recette de récupération des commits

Une copie du dépôt a été placée sur `landing-page` au commit `f719022`, avec :

- une modification locale du README ;
- un fichier de police non suivi à l'emplacement de l'ancienne copie ;
- un fichier local non suivi dans lib/app.

Le script a sauvegardé ces fichiers dans un stash, importé les commits, réalisé
l'avance rapide puis le rsync. Le HEAD correspondait à la livraison et l'état
Git était propre. Le contenu du stash et la conservation de `.git/config` ont
été vérifiés.

Un second scénario a créé un commit divergent : l'import s'est arrêté avant
toute modification des fichiers ou création d'un stash, sans déplacer le HEAD.

## Limites métier

Les démonstrations sont locales et fictives. L'authentification et la facturation
ne sont pas connectées. Les pages juridiques et coordonnées de contact restent
explicitement à compléter avec les documents officiels. Les avantages et tarifs
proposés ne constituent pas des droits appliqués par le backend.
