Helper scripts for managing secrets and tokens

- write-env.sh

  - Prompts the operator silently for `SONARQUBE_TOKEN` and writes a local `.env` file.
  - Ensures `.env` is added to `.gitignore`.
  - Usage: `./scripts/write-env.sh`

- create-sonarqube-token.sh

  - Uses the SonarQube API (admin credentials) to create a user token.
  - Optional `--write` flag writes the token into `.env` (backs up the existing file).
  - Depends on `curl` and optionally `jq` for JSON parsing.
  - Usage: `./scripts/create-sonarqube-token.sh admin admin_password mcp-token --write`

- create-service-user-token.sh
  - Creates a dedicated service user, optionally generates a strong password, and issues a token for that account.
  - Accepts `--gen` to auto-generate the service password and `--write` to store the token in `.env`.
  - Usage: `./scripts/create-service-user-token.sh admin admin_password svc-mcp "MCP Service" mcp-token --gen --write`

Security notes

- Never commit real tokens or passwords into the repository. Keep `.env` local and secret (the file is now git-ignored).
- Consider using a vault/secret manager for production.
- Rotate any tokens that were previously committed and regenerate them with the helpers above.
