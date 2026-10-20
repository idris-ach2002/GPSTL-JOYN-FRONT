# Importer la livraison sans écraser le dépôt

La livraison transporte la branche `landing-page` dans un **Git bundle**. C'est
ce bundle qui applique les commits et les fichiers ; il n'y a plus de second
`rsync` susceptible de masquer l'état réel de Git.

Depuis `GPSTL-JOYN-FRONT`, sur la branche `landing-page` :

```sh
joyn_import_dir="$(mktemp -d)"
unzip -q ~/Downloads/JOYN-landing-material-v2.zip -d "$joyn_import_dir"
bash "$joyn_import_dir/importer-joyn.sh"
```

Le script affiche systématiquement :

- le commit actuellement installé ;
- le commit contenu dans la livraison ;
- les huit derniers commits après import.

S'ils sont identiques, le script écrit explicitement que la livraison est déjà
installée et quitte sans prétendre avoir modifié le projet.

## Sécurité

1. la branche courante doit être `landing-page` ;
2. le bundle est vérifié avant modification ;
3. toute divergence d'historique bloque l'import ;
4. les changements locaux sont sauvegardés dans un stash ;
5. seul un `merge --ff-only` est accepté ;
6. le HEAD final est comparé au commit du bundle.

Aucun `reset --hard`, `checkout -f` ou écrasement du dossier `.git` n'est utilisé.

Après import :

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter run -d chrome
```
