# Deploy SonarQube on a Linux VM (Option A)

This folder contains a small deployment helper for running the SonarQube Compose stack inside a Linux VM (recommended approach for hosting on the Windows server at mallow-HQ).

Overview
- Target: Ubuntu 22.04 LTS (or similar) running as a VM on the Windows host.
- Approach: Install Docker and the Docker Compose plugin in the VM, copy or clone this repository to the VM, optionally restore backups, then bring the stack up with `docker compose up -d`.

Prerequisites (VM)
- Ubuntu 22.04 LTS (or later) running in the VM
- Sudo access
- Network access between the VM and the clients that will reach SonarQube (port 9000)

Install Docker & Compose (quick)
```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
sudo apt install -y docker-compose-plugin
# Log out and back in (or reboot) to apply group change
```

Copy repo and start
1. On the VM, clone or copy this repository into a working folder, e.g.:

```bash
git clone <your-repo-url> SonarQube-Open-Server
cd SonarQube-Open-Server
```

2. Configure `.env` if required (DB credentials, tokens). There is a `sonar.properties` file in the repo used by the container.

3. (Optional) Restore backups

- If you need to restore the SonarQube or Postgres volumes from the backups created previously, copy the `backups/` folder (or the relevant tar.gz files) into the repo on the VM and run the deploy script with `--restore <backups-dir>` (see below).

4. Start the stack

```bash
./deploy.sh            # from repo root on the VM
```

Commands performed by the script
- sanity checks for Docker
- creates named volumes (if missing)
- optionally restores `sonarqube_data` and `postgresql_data` from backups
- runs `docker compose pull` and `docker compose up -d`

Notes and recommendations
- Use a dedicated VM rather than running containers directly on Windows for production-like behaviour and best Elasticsearch compatibility.
- Provision enough RAM and CPU for SonarQube + Elasticsearch. For small installs: 4-8 GB RAM; for heavier usage increase accordingly.
- Keep backups outside the VM (network share or external storage) and do not commit large binary backups into git.
- If you plan to migrate to a more powerful machine later, keep the `backups/` tarballs available for volume restores.

Troubleshooting
- If Elasticsearch fails during start, check memory and ulimits on the VM. See SonarQube logs in container: `docker logs -f <project>_sonarqube_1`.
- If the web UI doesn't come up, check `docker compose ps` and the container logs for the web server.
