#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

flutter pub get
dart format lib test
flutter analyze
flutter test test/core/network/api_client_test.dart
flutter test test/features/recruiter_dashboard
flutter test

echo "R47 dashboard checks passed."
