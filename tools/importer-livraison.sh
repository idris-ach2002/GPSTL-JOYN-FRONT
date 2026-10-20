#!/usr/bin/env bash
set -euo pipefail

# Import idempotent de la branche landing-page depuis le bundle de livraison.
# Le bundle Git est la source de vérité : aucun rsync ne réécrit les fichiers
# suivis après le merge, ce qui évite l'impression d'un import « appliqué » alors
# que l'historique n'a pas bougé.
delivery_dir="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)}"
repo_dir="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$repo_dir" ]]; then
  printf '%s\n' 'Erreur : lance ce script depuis ton dépôt GPSTL-JOYN-FRONT.' >&2
  exit 1
fi

branch="$(git -C "$repo_dir" symbolic-ref --quiet --short HEAD || true)"
if [[ "$branch" != "landing-page" ]]; then
  printf '%s\n' "Erreur : branche courante '$branch'. Place-toi sur landing-page." >&2
  exit 1
fi

bundle="$delivery_dir/joyn-landing.bundle"
if [[ ! -f "$bundle" ]]; then
  printf '%s\n' "Erreur : bundle introuvable : $bundle" >&2
  exit 1
fi

# Vérifier l'intégrité du fichier de livraison avant de toucher au dépôt cible.
git -C "$repo_dir" bundle verify "$bundle" >/dev/null

before="$(git -C "$repo_dir" rev-parse HEAD)"
before_short="$(git -C "$repo_dir" rev-parse --short HEAD)"

# Utiliser une référence distante locale dédiée permet d'inspecter la livraison
# sans déplacer HEAD. --force ne force que cette ref de livraison, jamais la
# branche utilisateur.
git -C "$repo_dir" fetch --quiet "$bundle" \
  +refs/heads/landing-page:refs/remotes/joyn-livraison/landing-page

delivery_ref='refs/remotes/joyn-livraison/landing-page'
delivery_head="$(git -C "$repo_dir" rev-parse "$delivery_ref")"
delivery_short="$(git -C "$repo_dir" rev-parse --short "$delivery_ref")"

printf 'Version locale    : %s\n' "$before_short"
printf 'Version livraison : %s\n' "$delivery_short"

if [[ "$before" == "$delivery_head" ]]; then
  printf '%s\n' 'Cette livraison est déjà installée : aucun fichier à modifier.'
  exit 0
fi

# Refuser toute réécriture d'historique. Si la livraison n'est pas un descendant
# du HEAD local, l'utilisateur doit d'abord examiner la divergence.
if ! git -C "$repo_dir" merge-base --is-ancestor HEAD "$delivery_ref"; then
  printf '%s\n' 'Import arrêté : ton historique local diverge de la livraison.' >&2
  printf '%s\n' 'Commande de diagnostic : git log --oneline --graph --decorate --all -20' >&2
  exit 1
fi

stashed=0
if [[ -n "$(git -C "$repo_dir" status --porcelain)" ]]; then
  git -C "$repo_dir" stash push --include-untracked \
    -m 'Sauvegarde locale avant import JOYN landing-page' >/dev/null
  stashed=1
  printf '%s\n' 'Changements locaux sauvegardés dans git stash.'
fi

# Une avance rapide applique à la fois les commits ET tous les fichiers suivis.
git -C "$repo_dir" merge --ff-only --quiet "$delivery_ref"

after="$(git -C "$repo_dir" rev-parse HEAD)"
if [[ "$after" != "$delivery_head" ]]; then
  printf '%s\n' 'Erreur : le HEAD final ne correspond pas au bundle.' >&2
  exit 1
fi

printf '\n%s\n' 'Import terminé avec succès.'
printf 'HEAD : %s\n\n' "$(git -C "$repo_dir" rev-parse --short HEAD)"
git -C "$repo_dir" log --oneline --decorate -8

if [[ $stashed -eq 1 ]]; then
  printf '\n%s\n' 'Tes anciens changements restent dans git stash list.'
  printf '%s\n' 'Ne fais pas stash pop automatiquement : inspecte-les avant réapplication.'
fi
