#!/usr/bin/env bash
set -euo pipefail

# Dans l'archive, une copie de ce script est placée à côté du bundle.
# Une destination explicite peut aussi être fournie pour la recette automatisée.
delivery_dir="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)}"
repo_dir="$(git rev-parse --show-toplevel)"
branch="$(git -C "$repo_dir" symbolic-ref --quiet --short HEAD)"

if [[ "$branch" != "landing-page" ]]; then
  printf '%s\n' 'Place-toi sur ta branche landing-page avant de lancer cet import.' >&2
  exit 1
fi
if [[ ! -f "$delivery_dir/joyn-landing.bundle" || ! -d "$delivery_dir/GPSTL-JOYN-FRONT" ]]; then
  printf '%s\n' 'Livraison incomplète : bundle ou dossier source absent.' >&2
  exit 1
fi

# Le bundle transporte les objets et les commits ; rsync ne remplace jamais .git.
git -C "$repo_dir" fetch "$delivery_dir/joyn-landing.bundle" \
  refs/heads/landing-page:refs/remotes/joyn-livraison/landing-page

if ! git -C "$repo_dir" merge-base --is-ancestor HEAD refs/remotes/joyn-livraison/landing-page; then
  printf '%s\n' 'Les historiques divergent : import arrêté sans écraser ton travail.' >&2
  printf '%s\n' 'Examine git log --oneline --graph --all avant toute intégration.' >&2
  exit 1
fi

# Le journal utilisateur montre des fichiers non suivis de l'ancien rsync.
# Les préserver localement évite le refus Git « would be overwritten by merge ».
if [[ -n "$(git -C "$repo_dir" status --porcelain)" ]]; then
  git -C "$repo_dir" stash push --include-untracked \
    -m 'Sauvegarde locale avant import de la livraison JOYN'
  printf '%s\n' 'Les changements précédents sont conservés dans git stash list.'
fi

git -C "$repo_dir" merge --ff-only refs/remotes/joyn-livraison/landing-page
rsync -av --no-perms --exclude='.git/' --exclude='.DS_Store' \
  --exclude='build/' --exclude='.dart_tool/' \
  "$delivery_dir/GPSTL-JOYN-FRONT/" "$repo_dir/"

git -C "$repo_dir" status --short
git -C "$repo_dir" log -8 --oneline
printf '%s\n' 'Import terminé. Les anciens fichiers sauvegardés ne sont pas réappliqués automatiquement.'
