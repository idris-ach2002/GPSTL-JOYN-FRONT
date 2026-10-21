#!/usr/bin/env bash
set -euo pipefail

branch="${GITHUB_HEAD_REF:-$(git branch --show-current)}"

# Exception unique pour la PR qui installe le socle historique dans main.
if [[ "$branch" == "landing-page" ]]; then
  echo "✓ Branche bootstrap autorisée : $branch"
  exit 0
fi

if [[ "$branch" == dependabot/* ]]; then
  echo "✓ Branche Dependabot autorisée : $branch"
  exit 0
fi

if [[ "$branch" =~ ^(feat|feature|fix|hotfix|refactor|test|docs|ci|chore)/[a-z0-9][a-z0-9._-]*$ ]]; then
  echo "✓ Nom de branche valide : $branch"
  exit 0
fi

echo "❌ Nom de branche invalide : $branch"
echo "Utilise par exemple :"
echo "  feat/matching"
echo "  fix/login-mobile"
echo "  refactor/router"
echo "  test/onboarding"
exit 1
