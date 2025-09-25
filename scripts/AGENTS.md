# Agent Signpost — `scripts/`

Automation helpers live here. They are safe to run locally; none should be committed with secrets.

## Key scripts

- `write-env.sh` — prompts for `SONARQUBE_TOKEN` and writes `.env` (adds to `.gitignore`).
- `create-sonarqube-token.sh` — uses admin creds to create a token; optional `--write` persists it to `.env`.
- `create-service-user-token.sh` — creates a dedicated SonarQube service user, generates a password/token, and can append to `.env`.

## Tips

- Run scripts from the repo root so path references work.
- All scripts require `curl`; token scripts optionally use `jq` for JSON parsing.
- After generating a token, recreate the `mcp-server` container: `docker compose up -d --force-recreate --no-build mcp-server`.
- Tokens printed to the terminal are sensitive—rotate them immediately if they ever land in logs or commits.
