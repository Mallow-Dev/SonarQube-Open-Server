#!/usr/bin/env bash
set -euo pipefail

# create-sonarqube-token.sh
# Creates a SonarQube user token via the admin API.
# Usage examples:
#   ./scripts/create-sonarqube-token.sh admin secret my-token
#   ./scripts/create-sonarqube-token.sh admin secret my-token https://sonar.example.com --write

usage() {
  cat <<'EOF'
Usage: create-sonarqube-token.sh ADMIN PASSWORD TOKEN_NAME [SONAR_URL] [--write]

Creates a SonarQube user token using the admin credentials.

Arguments:
  ADMIN        SonarQube admin username
  PASSWORD     SonarQube admin password
  TOKEN_NAME   Name for the generated token
  SONAR_URL    Optional SonarQube URL (default: http://localhost:9000)
  --write      Write the token into a local .env file as SONARQUBE_TOKEN (backs up existing .env)

Requirements: curl (mandatory), jq (optional for JSON parsing).
EOF
}

if [[ $# -lt 3 ]]; then
  usage
  exit 1
fi

ADMIN="$1"
PASSWORD="$2"
TOKEN_NAME="$3"
shift 3

SONAR_URL="http://localhost:9000"
WRITE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --write)
      WRITE=true
      ;;
    http*://*)
      SONAR_URL="${1%/}"
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required but not installed." >&2
  exit 3
fi

echo "Creating SonarQube token '${TOKEN_NAME}' on ${SONAR_URL} as user '${ADMIN}'..."

HTTP_RESP=$(curl -sS -u "${ADMIN}:${PASSWORD}" -X POST "${SONAR_URL}/api/user_tokens/generate" \
  -H "Content-Type: application/x-www-form-urlencoded" -d "name=${TOKEN_NAME}" || true)

if [[ -z "${HTTP_RESP//[[:space:]]/}" ]]; then
  echo "No response from SonarQube API. Check connectivity and credentials." >&2
  exit 4
fi

TOKEN=""
if command -v jq >/dev/null 2>&1; then
  TOKEN=$(printf '%s' "$HTTP_RESP" | jq -r '.token // .generatedToken // .value // .tokenValue // empty')
fi

if [[ -z "$TOKEN" ]]; then
  TOKEN=$(printf '%s' "$HTTP_RESP" | grep -Po '"token"\s*:\s*"\K[^"]+' || true)
fi

if [[ -z "$TOKEN" ]]; then
  echo "Failed to parse token from SonarQube response." >&2
  echo "Full response:" >&2
  echo "$HTTP_RESP" >&2
  exit 5
fi

echo "Token generated: $TOKEN"

if [[ "$WRITE" == true ]]; then
  ENV_FILE=".env"

  if [[ -f .gitignore && -z $(grep -F "${ENV_FILE}" .gitignore || true) ]]; then
    printf '\n%s\n' "${ENV_FILE}" >> .gitignore
    echo "Added ${ENV_FILE} to .gitignore"
  fi

  if [[ -f ${ENV_FILE} ]]; then
    cp -- "${ENV_FILE}" "${ENV_FILE}.bak.$(date +%s)"
    echo "Existing ${ENV_FILE} backed up."
  fi

  if grep -q '^SONARQUBE_TOKEN=' "${ENV_FILE}" 2>/dev/null; then
    sed -i "s|^SONARQUBE_TOKEN=.*|SONARQUBE_TOKEN=${TOKEN}|" "${ENV_FILE}"
  else
    printf '\nSONARQUBE_TOKEN=%s\n' "${TOKEN}" >> "${ENV_FILE}"
  fi

  echo "Wrote token to ${ENV_FILE}."
fi

exit 0
