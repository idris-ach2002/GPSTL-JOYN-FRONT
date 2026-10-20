# Importer les fichiers ET les commits

Le premier rsync copiait seulement les fichiers : c'est normal que ton Git
n'affichait pas les sept commits. `git restore .` a ensuite rétabli les fichiers
suivis, mais a laissé les nouveaux dossiers non suivis.

Cette livraison contient un **bundle Git** de la branche `landing-page`, en plus
du code source. Le bundle transporte les nouveaux commits et ceux de la première
livraison, avec leurs auteurs et messages français. Il attend le commit de base
`f719022`, déjà présent dans le dépôt fourni.

Depuis `GPSTL-JOYN-FRONT` sur ta branche `landing-page`, après téléchargement :

```sh
joyn_import_dir="$(mktemp -d)"
unzip -q ~/Downloads/JOYN-landing-material.zip -d "$joyn_import_dir"
bash "$joyn_import_dir/importer-joyn.sh"
```

Ne colle pas les commentaires commençant par `#` dans ton terminal Zsh interactif,
qui les a interprétés comme des commandes dans le journal fourni.

Le script :

1. Vérifie que tu es sur `landing-page` et que la livraison est complète.
2. Importe la branche dans une référence locale `joyn-livraison/landing-page`.
3. Vérifie que ton HEAD permet une avance rapide ; sinon il s'arrête sans écraser.
4. Sauvegarde les changements et fichiers non suivis dans un stash local.
5. Avance `landing-page` avec `git merge --ff-only`.
6. Synchronise les fichiers avec rsync, sans toucher au dossier `.git`, en conservant les permissions établies par Git.
7. Affiche l'état et les derniers commits.

Aucune suppression de tes fichiers n'est demandée. Les caches ignorés restent
sur ta machine. L'ancien travail est accessible via `git stash list` ; ne fais
pas un `stash pop` automatique, car les anciens fichiers de l'import initial
recouvriraient la nouvelle version. Inspecte d'abord ce que tu souhaites récupérer.

Puis vérifie et lance :

```sh
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Si l'import signale une divergence, conserve le stash et fournis le résultat de
`git log --oneline --graph --all -15`. Ne force pas un reset ou un écrasement de `.git`.
