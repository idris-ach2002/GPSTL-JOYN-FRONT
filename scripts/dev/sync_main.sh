#!/usr/bin/env bash
set -euo pipefail

branch="$(git branch --show-current)"

if [[ -z "$branch" ]]; then
  echo "❌ HEAD détachée."
  exit 1
fi

if [[ "$branch" == "main" || "$branch" == "landing-page" ]]; then
  echo "❌ Ce script est réservé aux branches de feature/fix. Branche actuelle : $branch"
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "❌ Le working tree n'est pas propre. Commit ou stash avant le rebase."
  exit 1
fi

echo "==> Récupération de main"
git fetch origin main

echo "==> Rebase de $branch sur origin/main"
git rebase origin/main

echo "✅ $branch est à jour avec main"
