#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env.api_keys"
BACKEND_ENV_FILE="$ROOT_DIR/Back-end/.env"

if [[ ! -f "$ENV_FILE" && ! -f "$BACKEND_ENV_FILE" ]]; then
  cp "$ROOT_DIR/scripts/api_keys.env.example" "$ENV_FILE"
  cat <<MSG
Created .env.api_keys.
Fill in the API keys, then run this script again:

  $ENV_FILE
MSG
  exit 1
fi

set -a
if [[ -f "$BACKEND_ENV_FILE" ]]; then
  source "$BACKEND_ENV_FILE"
fi
if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
fi
set +a

MOEF_API_KEY="${MOEF_API_KEY:-${DATA_GO_KR_API_KEY:-}}"

status() {
  if [[ -n "${!1:-}" ]]; then
    printf "%s=SET\n" "$1"
  else
    printf "%s=EMPTY\n" "$1"
  fi
}

echo "Using API key status:"
status API_BASE_URL
status MOEF_API_KEY
status NAVER_SEARCH_CLIENT_ID
status NAVER_SEARCH_CLIENT_SECRET
echo

DEVICE_ARGS=()
if [[ $# -gt 0 ]]; then
  DEVICE_ARGS=("-d" "$1")
  shift
fi

flutter run \
  "${DEVICE_ARGS[@]}" \
  --dart-define=API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:8000}" \
  --dart-define=MOEF_API_KEY="${MOEF_API_KEY:-}" \
  --dart-define=NAVER_SEARCH_CLIENT_ID="${NAVER_SEARCH_CLIENT_ID:-}" \
  --dart-define=NAVER_SEARCH_CLIENT_SECRET="${NAVER_SEARCH_CLIENT_SECRET:-}" \
  "$@"
