#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <type> <nom>"
  echo "Exemple: $0 feat matching"
  echo "Types: feat, fix, hotfix, refactor, test, docs, ci, chore"
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

type="$1"
name="$2"

if [[ ! "$type" =~ ^(feat|fix|hotfix|refactor|test|docs|ci|chore)$ ]]; then
  echo "❌ Type invalide : $type"
  usage
  exit 1
fi

if [[ ! "$name" =~ ^[a-z0-9][a-z0-9._-]*$ ]]; then
  echo "❌ Nom invalide : $name"
  echo "Utilise uniquement minuscules, chiffres, ., _ et -."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "❌ Le working tree n'est pas propre. Commit ou stash avant de créer une branche."
  exit 1
fi

branch="$type/$name"

echo "==> Synchronisation de main"
git fetch origin main
git checkout main
git pull --ff-only origin main

if git show-ref --verify --quiet "refs/heads/$branch"; then
  echo "❌ La branche locale $branch existe déjà."
  exit 1
fi

if git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
  echo "❌ La branche distante origin/$branch existe déjà."
  exit 1
fi

git checkout -b "$branch"
echo "✅ Branche créée depuis le dernier main : $branch"
