#!/usr/bin/env bash
set -euo pipefail

branch="$(git branch --show-current)"

if [[ -z "$branch" ]]; then
  echo "❌ HEAD détachée."
  exit 1
fi

if [[ "$branch" == "main" ]]; then
  echo "❌ Push direct de main interdit. Travaille depuis une branche."
  exit 1
fi

if [[ ! "$branch" =~ ^(feat|fix|hotfix|refactor|test|docs|ci|chore)/[a-z0-9][a-z0-9._-]*$ ]]; then
  echo "❌ Nom de branche non conforme : $branch"
  echo "Format attendu : feat/..., fix/..., hotfix/..., refactor/..., test/..., docs/..., ci/... ou chore/..."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "❌ Le working tree n'est pas propre."
  echo "Committe le travail avant de pousser pour que ce qui part sur GitHub soit explicite."
  exit 1
fi

if git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
  echo "==> Récupération de origin/$branch"
  git fetch origin "$branch"

  remote_sha="$(git rev-parse "origin/$branch")"

  if git merge-base --is-ancestor "origin/$branch" HEAD; then
    echo "==> Push fast-forward de $branch"
    git push origin "HEAD:refs/heads/$branch"
  else
    echo "==> Historique réécrit détecté (ex: rebase)"
    echo "==> Push sécurisé avec --force-with-lease"
    git push \
      --force-with-lease="refs/heads/$branch:$remote_sha" \
      origin "HEAD:refs/heads/$branch"
  fi
else
  echo "==> Premier push de $branch"
  git push -u origin "$branch"
fi

echo "✅ Branche publiée : $branch"
