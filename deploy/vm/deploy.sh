#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
BACKUP_DIR=""

usage(){
  cat <<EOF
Usage: $0 [--restore <backups-dir>]

Options:
  --restore <backups-dir>   Restore sonarqube and postgres volumes from tar.gz files in <backups-dir>
  -h, --help                Show this help
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --restore)
      BACKUP_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      ;;
  esac
done

cd "$REPO_ROOT"

echo "Checking Docker..."
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed. Please install Docker and try again." >&2
  exit 2
fi

if [[ -n "$BACKUP_DIR" ]]; then
  echo "Restoring volumes from $BACKUP_DIR"
  # Ensure volumes exist
  docker volume create sonarqube-local_sonarqube_data || true
  docker volume create sonarqube-local_postgresql_data || true

  # Restore sonarqube data
  if [[ -f "$BACKUP_DIR/sonarqube_data-backup-*.tar.gz" ]]; then
    echo "Restoring SonarQube data..."
    docker run --rm -v sonarqube-local_sonarqube_data:/data -v "$BACKUP_DIR":/backup alpine sh -c "cd /data && tar xzf /backup/$(basename $(ls -1 $BACKUP_DIR/sonarqube_data-backup-*.tar.gz | tail -n1))"
  fi

  # Restore postgres data
  if [[ -f "$BACKUP_DIR/postgresql_data-backup-*.tar.gz" ]]; then
    echo "Restoring Postgres data..."
    docker run --rm -v sonarqube-local_postgresql_data:/data -v "$BACKUP_DIR":/backup alpine sh -c "cd /data && tar xzf /backup/$(basename $(ls -1 $BACKUP_DIR/postgresql_data-backup-*.tar.gz | tail -n1))"
  fi
fi

echo "Pulling images and starting stack..."
docker compose pull || true
docker compose up -d

echo "Done. Use 'docker compose ps' to check services and 'docker logs -f <service>' to follow logs."
