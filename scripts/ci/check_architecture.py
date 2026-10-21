#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LIB = ROOT / "lib"

REQUIRED_PRESENTATION_DIRS = {
    "auth": ("web", "mobile"),
    "dashboard": ("web", "mobile"),
    "information": ("web", "mobile"),
    "landing": ("web", "mobile"),
    "onboarding": ("web", "mobile"),
    "registration": ("web", "mobile"),
    "startup": ("web", "mobile"),
}

DIRECTIVE = re.compile(r"^\s*(?:import|export)\s+['\"]([^'\"]+)['\"]", re.MULTILINE)

# Ponts historiques encore utilisés par deux wrappers Web. Ils sont tolérés
# temporairement pour ne pas casser les routes existantes, mais aucune nouvelle
# dépendance croisée n'est acceptée.
LEGACY_BRIDGES = {
    (
        "lib/features/auth/presentation/web/login_page.dart",
        "lib/features/auth/presentation/mobile/mobile_login_screen.dart",
    ),
    (
        "lib/features/registration/presentation/web/register_choice_screen.dart",
        "lib/features/registration/presentation/mobile/mobile_register_choice_screen.dart",
    ),
}


def resolve_directive(source: Path, target: str) -> Path | None:
    if target.startswith("dart:") or target.startswith("package:flutter"):
        return None
    if target.startswith("package:joyn_front/"):
        rel = target.removeprefix("package:joyn_front/")
        return (LIB / rel).resolve()
    if target.startswith("package:"):
        return None
    return (source.parent / target).resolve()


def is_under(path: Path, directory: Path) -> bool:
    try:
        path.relative_to(directory.resolve())
        return True
    except ValueError:
        return False


def check_boundaries() -> list[str]:
    violations: list[str] = []
    for source in LIB.glob("features/*/presentation/**/*.dart"):
        parts = source.parts
        try:
            p_index = parts.index("presentation")
        except ValueError:
            continue
        if p_index + 1 >= len(parts):
            continue
        side = parts[p_index + 1]
        if side not in {"web", "mobile"}:
            continue

        text = source.read_text(encoding="utf-8")
        for target in DIRECTIVE.findall(text):
            resolved = resolve_directive(source, target)
            if resolved is None:
                continue

            marker = (Path("presentation") / ("mobile" if side == "web" else "web")).as_posix()
            if marker in resolved.as_posix():
                rel_source = source.relative_to(ROOT)
                rel_target = resolved.relative_to(ROOT) if is_under(resolved, ROOT) else resolved
                bridge = (rel_source.as_posix(), Path(rel_target).as_posix())
                if bridge in LEGACY_BRIDGES:
                    continue
                violations.append(
                    f"{rel_source}: {side} ne doit pas importer/exporter {rel_target}"
                )
    return violations


def check_required_structure() -> list[str]:
    violations: list[str] = []
    for feature, sides in REQUIRED_PRESENTATION_DIRS.items():
        base = LIB / "features" / feature / "presentation"
        for side in sides:
            expected = base / side
            if not expected.is_dir():
                violations.append(f"Dossier obligatoire absent : {expected.relative_to(ROOT)}")

    required_files = [
        LIB / "main.dart",
        LIB / "main_web.dart",
        LIB / "main_mobile.dart",
        LIB / "app" / "experience" / "experience_target.dart",
    ]
    for path in required_files:
        if not path.is_file():
            violations.append(f"Fichier obligatoire absent : {path.relative_to(ROOT)}")
    return violations


def main() -> int:
    violations = check_required_structure() + check_boundaries()
    if violations:
        print("❌ Architecture JOYN invalide :")
        for violation in violations:
            print(f"  - {violation}")
        print("\nRègle : web et mobile partagent data/domain/controllers/shared, pas leurs écrans.")
        return 1

    print("✓ Frontières web/mobile respectées")
    print("✓ Structure de présentation JOYN présente")
    print("ℹ 2 ponts historiques Web → Mobile restent tolérés et sont explicitement figés")
    return 0


if __name__ == "__main__":
    sys.exit(main())
