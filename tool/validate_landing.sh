#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build web --release
python3 -m json.tool web/manifest.json >/dev/null
