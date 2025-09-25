# Agent Signpost

Welcome! This repository contains a SonarQube + PostgreSQL stack managed via Docker Compose, plus a custom MCP server.

## High-priority context

- **Never commit secrets**: `.env` is intentionally untracked. Use the helpers in `scripts/` to roll tokens.
- **MCP server** lives in the `mcp-server/` submodule (Gradle project). Build with `./gradlew build` inside that directory.
- **Backups**: volume tarballs belong in `backups/` but should not be committed.

## Key entry points

- `docker-compose.yml` — main runtime definition.
- `deploy/` — provisioning helpers for VMs and Hyper-V hosts.
- `scripts/` — token automation and local environment writers.
- `memory-bank/` — operational history, progress, and design decisions.

## Operational tips

- Generate service tokens with `./scripts/create-service-user-token.sh`.
- Update local secrets using `./scripts/write-env.sh` (prompts securely).
- When touching `mcp-server/`, remember to commit inside the submodule and update the parent repo reference.

## Next actions when arriving mid-task

1. Check `memory-bank/progress.md` for the latest status.
2. Run `docker compose ps` to verify container health.
3. Review `.specstory/history/` entries for detailed session transcripts.
