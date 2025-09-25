#!/usr/bin/env bash
# Safely write a .env file prompting for SONARQUBE_TOKEN without echoing input.
set -euo pipefail

ENV_FILE=.env
BACKUP_FILE=.env.bak

if [ -f "$ENV_FILE" ]; then
  echo "Backing up existing $ENV_FILE to $BACKUP_FILE"
  cp "$ENV_FILE" "$BACKUP_FILE"
fi

read -r -p "Write/overwrite local $ENV_FILE? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborted."
  exit 1
fi

# Prompt silently for token
read -r -s -p "Enter SONARQUBE_TOKEN: " token
echo
if [ -z "$token" ]; then
  echo "No token entered; aborting"
  exit 1
fi

# Write safe .env
cat > "$ENV_FILE" <<EOF
# Local environment (do NOT commit)
SONARQUBE_TOKEN=$token
EOF

# Ensure .env is in .gitignore
if ! grep -qxF ".env" .gitignore 2>/dev/null; then
  echo ".env" >> .gitignore
  echo "Added .env to .gitignore"
fi

echo "Wrote $ENV_FILE (not committed). Keep this file secret."
