## Objectif

<!-- Décris en 2-4 lignes ce que change cette PR. -->

## Surface touchée

- [ ] Web
- [ ] Mobile
- [ ] Data / Domain / Controllers partagés
- [ ] Routing / bootstrap
- [ ] Design system
- [ ] Dépendances (`pubspec.yaml`)

## Risque de conflit

- [ ] Je n'ai pas modifié inutilement `app_router.dart`, `pubspec.yaml` ou les tokens globaux.
- [ ] Si j'ai touché un de ces hotspots, j'explique pourquoi ci-dessous.

<!-- Hotspots concernés / raison : -->

## Validation

- [ ] `./scripts/dev/sync_main.sh` exécuté avant la PR (ou branche déjà à jour avec `origin/main`).
- [ ] `./scripts/dev/check_before_pr.sh` passe localement.
- [ ] Les écrans Web n'importent pas les écrans Mobile, et inversement.
- [ ] J'ai ajouté/ajusté les tests liés à mon changement.
- [ ] J'ai vérifié le rendu concerné.

## Captures / notes de recette

<!-- Ajoute les captures Web/Mobile utiles ou les étapes pour reproduire. -->
