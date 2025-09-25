# Agent Signpost — `deploy/`

This folder contains provisioning helpers for running the SonarQube stack off-box.

## Subdirectories

- `vm/` — Bash scripts and docs for provisioning on Ubuntu-based VMs.
- `windows/` — PowerShell automation for Hyper-V hosts (supports `-AutoDeploy`).

## Quick guidance

- Review the respective `README.md` before executing any script; they outline prerequisites and safety notes.
- Keep credentials and SSH keys outside the repo. Scripts expect you to provide paths/values interactively.
- Validate Docker is installed on the target host before trying the VM deploy helper.

## Handy follow-ups

- After provisioning, run `deploy/vm/deploy.sh --restore` if you need to restore backups.
- Update docs when you change script flags or defaults so future agents can follow along.
