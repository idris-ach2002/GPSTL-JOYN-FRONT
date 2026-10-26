#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

JOYN_DATA_MODE="${JOYN_DATA_MODE:-auto}"
JOYN_API_BASE_URL="${JOYN_API_BASE_URL:-}"
JOYN_API_TIMEOUT_MS="${JOYN_API_TIMEOUT_MS:-12000}"

exec flutter run -d chrome \
  --dart-define="JOYN_DATA_MODE=$JOYN_DATA_MODE" \
  --dart-define="JOYN_API_BASE_URL=$JOYN_API_BASE_URL" \
  --dart-define="JOYN_API_TIMEOUT_MS=$JOYN_API_TIMEOUT_MS"
