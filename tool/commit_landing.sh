#!/usr/bin/env bash
# Run from the actual Git checkout after synchronizing this delivery.
set -euo pipefail
cd "$(dirname "$0")/.."
mode="${1:---plan}"
if [[ "$mode" != --plan && "$mode" != --apply ]]; then
  echo 'Usage: bash tool/commit_landing.sh [--plan|--apply]' >&2
  exit 2
fi
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo 'Ce dossier doit être le checkout Git du projet.' >&2
  exit 1
fi
root="$(git rev-parse --show-toplevel)"
if [[ "$PWD" != "$root" ]]; then
  echo 'Lancer ce script depuis le projet situé à la racine de son dépôt.' >&2
  exit 1
fi
if [[ "$mode" == --apply ]]; then
  if ! git diff --cached --quiet; then
    echo 'Des fichiers sont déjà indexés. Les désindexer ou les valider séparément avant ce lot.' >&2
    exit 1
  fi
  if [[ -n "$(git ls-files --unmerged)" ]]; then
    echo 'Résoudre les conflits avant de créer les commits.' >&2
    exit 1
  fi
  git var GIT_AUTHOR_IDENT >/dev/null
  # A failure here stops before any commit is created.
  bash tool/validate_landing.sh
fi

batch() {
  local title="$1"
  shift
  local paths=() path
  for path in "$@"; do
    if [[ -e "$path" ]] || git ls-files --error-unmatch -- "$path" >/dev/null 2>&1; then
      paths+=("$path")
    fi
  done
  [[ ${#paths[@]} -gt 0 ]] || return 0
  printf '\n%s\n' "$title"
  if [[ "$mode" == --plan ]]; then
    git status --short -- "${paths[@]}"
    return 0
  fi
  git add -A -- "${paths[@]}"
  if git diff --cached --quiet; then
    echo 'Aucun changement pour ce lot.'
    return 0
  fi
  git commit -m "$title"
}

batch 'feat(landing): centraliser le thème, la palette et les polices' \
  pubspec.yaml pubspec.lock assets/fonts lib/design_system/joyn_tokens.dart \
  lib/design_system/tokens/app_colors.dart lib/app/theme/app_theme_data.dart \
  lib/core/responsive/app_breakpoints.dart \
  lib/features/landing/presentation/widgets/editorial_layout.dart

batch 'feat(landing): ajouter les illustrations et les effets de mouvement' \
  lib/features/landing/presentation/widgets/joyn_mark.dart \
  lib/features/landing/presentation/widgets/person_portrait.dart \
  lib/features/landing/presentation/widgets/product_atmosphere.dart \
  lib/features/landing/presentation/widgets/gentle_depth.dart \
  lib/features/landing/presentation/widgets/landing_motion.dart

batch 'feat(navigation): structurer les menus et leurs pictogrammes animés' \
  lib/features/landing/domain \
  lib/features/landing/presentation/widgets/navigation_symbol.dart \
  lib/features/landing/presentation/widgets/landing_mega_navigation.dart \
  lib/features/landing/presentation/widgets/landing_navbar.dart

batch 'feat(landing): présenter le parcours candidat et les recommandations' \
  lib/features/landing/presentation/sections/futurist_hero.dart \
  lib/features/landing/presentation/sections/context_sections.dart \
  lib/features/landing/presentation/sections/matching_workbench.dart \
  lib/features/landing/presentation/sections/journey_carousel.dart \
  lib/features/landing/presentation/sections/scroll_journey_section.dart \
  lib/features/landing/presentation/widgets/journey_preview.dart \
  lib/features/landing/presentation/widgets/match_signature.dart \
  lib/features/landing/presentation/sections/hero_section.dart \
  lib/features/landing/presentation/sections/problem_section.dart \
  lib/features/landing/presentation/sections/how_it_works_section.dart \
  lib/features/landing/presentation/sections/matching_demo_section.dart

batch 'feat(candidatures): présenter le profil, les offres et leur suivi' \
  lib/features/landing/presentation/sections/profile_section.dart \
  lib/features/landing/presentation/sections/opportunities_section.dart \
  lib/features/landing/presentation/sections/reciprocity_section.dart \
  lib/features/landing/presentation/sections/application_tracking_section.dart

batch 'feat(landing): distinguer les usages candidat et recruteur' \
  lib/features/landing/presentation/sections/organisation_section.dart \
  lib/features/landing/presentation/sections/plan_comparison_section.dart \
  lib/features/landing/presentation/sections/pocket_section.dart \
  lib/features/landing/presentation/widgets/mobile_chapter.dart \
  lib/features/landing/presentation/sections/features_section.dart \
  lib/features/landing/presentation/sections/companies_section.dart \
  lib/features/landing/presentation/sections/mobile_section.dart \
  lib/features/landing/presentation/sections/pricing_section.dart \
  lib/features/landing/presentation/sections/final_cta_section.dart \
  lib/features/landing/presentation/sections/testimonials_section.dart

batch 'feat(assistance): ajouter la FAQ filtrable et les pages de service' \
  lib/features/landing/presentation/sections/questions_section.dart \
  lib/features/landing/presentation/screens/service_screen.dart \
  lib/features/landing/presentation/sections/resources_section.dart \
  lib/features/landing/presentation/widgets/landing_footer.dart \
  lib/features/landing/presentation/sections/footer_section.dart

batch 'feat(web): ajouter les guides et les métadonnées de la landing' \
  lib/core/platform web/index.html web/manifest.json web/flutter_bootstrap.js \
  web/guide.css web/guides web/presentation.html web/robots.txt tool/configure_seo.py

batch 'feat(landing): assembler les sections et les routes responsives' \
  lib/main.dart lib/app/routing/app_router.dart \
  lib/features/landing/presentation/screens/landing_screen.dart

batch 'test(landing): vérifier les parcours et documenter la validation' \
  test/widget_test.dart tool/validate_landing.sh tool/commit_landing.sh README.md

printf '\nÉtat restant du dépôt :\n'
git status --short
if [[ "$mode" == --plan ]]; then
  echo 'Aucun commit créé. Pour valider puis créer les lots : bash tool/commit_landing.sh --apply'
else
  echo 'Lots terminés. Aucun push effectué.'
fi
