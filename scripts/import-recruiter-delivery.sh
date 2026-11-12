#!/usr/bin/env bash
set -euo pipefail
repo="${1:?Usage: import-recruiter-delivery.sh /chemin/depot /chemin/livraison.bundle}"
bundle="${2:?Fichier bundle manquant}"
repo="$(git -C "$repo" rev-parse --show-toplevel)"
bundle="$(cd "$(dirname "$bundle")" && pwd)/$(basename "$bundle")"
branch='feat/espace-recruteur'
ref='refs/remotes/joyn-delivery/espace-recruteur'
if [[ -n "$(git -C "$repo" status --porcelain)" ]]; then
  echo 'Import arrêté : enregistre ou mets de côté tes modifications locales, puis relance.' >&2
  exit 1
fi
git -C "$repo" bundle verify "$bundle"
git -C "$repo" fetch --no-tags "$bundle" "$branch:$ref"
if git -C "$repo" show-ref --verify --quiet refs/remotes/origin/main; then
  if ! git -C "$repo" merge-base --is-ancestor refs/remotes/origin/main "$ref"; then
    echo 'Import arrêté : origin/main contient des changements absents de cette livraison. Une intégration par rebase est nécessaire.' >&2
    exit 1
  fi
fi
if git -C "$repo" show-ref --verify --quiet "refs/heads/$branch"; then
  if ! git -C "$repo" merge-base --is-ancestor "$branch" "$ref"; then
    echo 'Import arrêté : ta branche feat/espace-recruteur a divergé. Aucun de tes commits n’a été écrasé.' >&2
    exit 1
  fi
  git -C "$repo" switch "$branch"
  git -C "$repo" merge --ff-only "$ref"
else
  git -C "$repo" switch -c "$branch" "$ref"
fi
if [[ "$(git -C "$repo" rev-parse HEAD)" != "$(git -C "$repo" rev-parse "$ref")" ]]; then
  echo 'Vérification de la révision importée impossible.' >&2
  exit 1
fi
echo 'Livraison appliquée sur feat/espace-recruteur. Tu peux lancer python3 scripts/run-joyn.py depuis le dépôt.'
