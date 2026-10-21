#!/usr/bin/env bash
set -euo pipefail

echo "==> 1/6 Architecture"
python3 scripts/ci/check_architecture.py

echo "==> 2/6 Format"
dart format --output=none --set-exit-if-changed lib test

echo "==> 3/6 Analyse"
flutter analyze

echo "==> 4/6 Tests"
flutter test

echo "==> 5/6 Build Web"
flutter build web --release -t lib/main_web.dart

echo "==> 6/6 Build Android"
flutter build apk --debug -t lib/main_mobile.dart

git diff --check

echo "✅ Branche prête pour une Pull Request"
