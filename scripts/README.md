Helper scripts for managing secrets and tokens

- write-env.sh

  - Prompts the operator silently for `SONARQUBE_TOKEN` and writes a local `.env` file.
  - Ensures `.env` is added to `.gitignore`.
  - Usage: `./scripts/write-env.sh`

- create-sonarqube-token.sh
  - Uses SonarQube API to create a new user token. Requires admin credentials.
  - Depends on `curl` and optionally `jq` for JSON parsing.
  - Usage: `./scripts/create-sonarqube-token.sh admin admin_password mcp-server-token`

Security notes

- Never commit real tokens or passwords into the repository. Keep `.env` local and secret.
- Consider using a vault/secret manager for production.
