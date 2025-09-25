#!/usr/bin/env bash
set -euo pipefail

# create-service-user-token.sh
# Creates a SonarQube service user (using admin credentials) and generates a token for that user.
# Usage:
#   ./scripts/create-service-user-token.sh ADMIN ADMIN_PASSWORD SERVICE_LOGIN SERVICE_NAME TOKEN_NAME [SERVICE_PASSWORD] [SONAR_URL] [--write]
# Examples:
#   ./scripts/create-service-user-token.sh admin adminpass svc-mcp "MCP Service" mcp-token secretpass http://localhost:9000 --write
#   ./scripts/create-service-user-token.sh admin adminpass svc-mcp "MCP Service" mcp-token --gen http://localhost:9000

usage() {
  cat <<EOF
Usage: $0 ADMIN ADMIN_PASSWORD SERVICE_LOGIN SERVICE_NAME TOKEN_NAME [SERVICE_PASSWORD|--gen] [SONAR_URL] [--write]

Creates a SonarQube service user (admin) and then generates a user token by authenticating as that service user.

Arguments:
  ADMIN            - SonarQube admin username
  ADMIN_PASSWORD   - SonarQube admin password
  SERVICE_LOGIN    - username/login for the service account to create
  SERVICE_NAME     - display name for the service user (wrap in quotes if contains spaces)
  TOKEN_NAME       - name for the token to create
  SERVICE_PASSWORD - (optional) password for the service user. If omitted, use --gen to auto-generate.
  SONAR_URL        - (optional) SonarQube URL, default: http://localhost:9000
  --write          - (optional) write the generated token into a local .env file as SONARQUBE_TOKEN

Examples:
  $0 admin adminpass svc-mcp "MCP Service" mcp-token --gen
  $0 admin adminpass svc-mcp "MCP Service" mcp-token secretpass http://localhost:9000 --write

Security: This script requires admin credentials. Do not share the admin password in public channels.
EOF
}

if [[ ${1:-} == "" || ${2:-} == "" || ${3:-} == "" || ${4:-} == "" || ${5:-} == "" ]]; then
  usage
  exit 1
fi

ADMIN="$1"
ADMIN_PASS="$2"
SERVICE_LOGIN="$3"
SERVICE_NAME="$4"
TOKEN_NAME="$5"

shift 5

SERVICE_PASSWORD=""
SONAR_URL="http://localhost:9000"
WRITE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --gen)
      SERVICE_PASSWORD="__GEN__"
      shift
      ;;
    --write)
      WRITE=true
      shift
      ;;
    http*://* )
      SONAR_URL="$1"
      shift
      ;;
    *)
      # If it's not a flag or URL, treat as password
      if [[ -z "$SERVICE_PASSWORD" || "$SERVICE_PASSWORD" == "__GEN__" ]]; then
        SERVICE_PASSWORD="$1"
      fi
      shift
      ;;
  esac
done

if [[ "$SERVICE_PASSWORD" == "__GEN__" || -z "$SERVICE_PASSWORD" ]]; then
  # Generate a reasonably strong password
  if command -v openssl >/dev/null 2>&1; then
    SERVICE_PASSWORD=$(openssl rand -base64 18)
  else
    SERVICE_PASSWORD=$(head -c 24 /dev/urandom | base64 | tr -d '\n' || true)
  fi
  GENERATED_PASSWORD=true
else
  GENERATED_PASSWORD=false
fi

echo "Creating service user '${SERVICE_LOGIN}' (display name: '${SERVICE_NAME}') on ${SONAR_URL} using admin '${ADMIN}'..."

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required." >&2
  exit 2
fi

# Create the user via admin API. If the user already exists, SonarQube returns 400; handle gracefully.
CREATE_RESP=$(curl -sS -u "${ADMIN}:${ADMIN_PASS}" -X POST "${SONAR_URL%/}/api/users/create" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "login=${SERVICE_LOGIN}&name=${SERVICE_NAME}&password=${SERVICE_PASSWORD}" || true)

if echo "$CREATE_RESP" | grep -qi "already exists"; then
  echo "User '${SERVICE_LOGIN}' already exists. Proceeding to token generation."
elif [[ -n "$CREATE_RESP" && "$CREATE_RESP" != "" ]]; then
  # Some SonarQube versions return empty body on success; on error JSON may be returned
  if echo "$CREATE_RESP" | grep -qiE "error|exception|bad request|unauthorized"; then
    echo "Warning: received response when creating user:" >&2
    echo "$CREATE_RESP" >&2
    # Continue — user may exist or other non-fatal
  else
    echo "User create response: $CREATE_RESP"
  fi
else
  echo "User create API call returned no body; assume success if HTTP code was 200/204." 
fi

echo "Generating token by authenticating as the service user..."

TOKEN_RESP=$(curl -sS -u "${SERVICE_LOGIN}:${SERVICE_PASSWORD}" -X POST "${SONAR_URL%/}/api/user_tokens/generate" \
  -H "Content-Type: application/x-www-form-urlencoded" -d "name=${TOKEN_NAME}" || true)

if [[ -z "${TOKEN_RESP// /}" ]]; then
  echo "No response from SonarQube token API. Check that the service user can authenticate and that the SonarQube URL is reachable." >&2
  exit 3
fi

TOKEN=""
if command -v jq >/dev/null 2>&1; then
  TOKEN=$(printf '%s' "$TOKEN_RESP" | jq -r '.token // .generatedToken // .value // .tokenValue // .token' 2>/dev/null || true)
else
  TOKEN=$(printf '%s' "$TOKEN_RESP" | grep -Po '"token"\s*:\s*"\K[^"]+' || true)
fi

if [[ -z "$TOKEN" ]]; then
  echo "Failed to parse token from response." >&2
  echo "Full response:" >&2
  echo "$TOKEN_RESP" >&2
  exit 4
fi

echo "Generated token: $TOKEN"

if [[ "$GENERATED_PASSWORD" == true ]]; then
  echo "Service user generated password: ${SERVICE_PASSWORD}"
  echo "Store this password somewhere secure if you need to log in as the service user."
fi

if [[ "$WRITE" == true ]]; then
  ENV_FILE=".env"
  if [[ -f .gitignore && $(grep -Fx "${ENV_FILE}" .gitignore || true) == "" ]]; then
    echo "Adding ${ENV_FILE} to .gitignore"
    printf '\n%s\n' "${ENV_FILE}" >> .gitignore
  fi

  if [[ -f ${ENV_FILE} ]]; then
    cp -- "${ENV_FILE}" "${ENV_FILE}.bak.$(date +%s)"
  fi

  if grep -q '^SONARQUBE_TOKEN=' "${ENV_FILE}" 2>/dev/null; then
    sed -i "s|^SONARQUBE_TOKEN=.*|SONARQUBE_TOKEN=${TOKEN}|" "${ENV_FILE}"
  else
    printf '\nSONARQUBE_TOKEN=%s\n' "${TOKEN}" >> "${ENV_FILE}"
  fi

  echo "Wrote token to ${ENV_FILE} (existing file backed up if present)."
fi

echo "Done. The new service user '${SERVICE_LOGIN}' exists (or already existed) and has a token named '${TOKEN_NAME}'."

exit 0
