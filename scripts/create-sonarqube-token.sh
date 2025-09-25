#!/usr/bin/env bash
# Create/rotate a SonarQube user token via the SonarQube API.
# Requires SonarQube admin username/password (or admin token) and jq installed.
# Usage: ./scripts/create-sonarqube-token.sh <admin-user> <admin-password> <new-token-name>
# This will print the generated token to stdout. Use it to update your local .env.
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <admin-user> <admin-password> <token-name>"
  exit 2
fi

ADMIN_USER=$1
ADMIN_PASS=$2
TOKEN_NAME=$3
SONAR_URL=${SONARQUBE_URL:-http://localhost:9000}

# Create token
resp=$(curl -sS -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$SONAR_URL/api/user_tokens/generate" -d "name=$TOKEN_NAME")

# Parse result (jq optional)
if command -v jq >/dev/null 2>&1; then
  echo "$resp" | jq -r '.token'
else
  # Fallback: crude extraction
  echo "$resp" | sed -n 's/.*"token"\s*:\s*"\([^"]*\)".*/\1/p'
fi
