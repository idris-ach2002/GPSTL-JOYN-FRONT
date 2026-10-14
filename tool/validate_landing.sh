#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== JOYN landing validation =="
dart format --output=none --set-exit-if-changed lib/features/landing test/widget_test.dart
flutter analyze
flutter test test/widget_test.dart

echo "== OK =="
