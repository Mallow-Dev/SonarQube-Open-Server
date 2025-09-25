# Provision a Linux VM on Windows (Hyper-V) and deploy SonarQube

This folder contains a PowerShell helper that automates creating an Ubuntu VM under Hyper-V on the Windows host and performs basic provisioning (install Docker, Docker Compose plugin, clone the repo).

Important notes
- Run the PowerShell script from an elevated PowerShell prompt (Run as Administrator) on the Windows server that hosts Hyper-V.
- The script is intended as a starting point and may require adjustments for your environment (network, storage paths, proxy, credentials).
- The VM will be created with an attached virtual disk and default settings; adapt CPU/RAM/disk sizes as needed.

Files
- `provision-hyperv.ps1` — creates the VM, configures networking, attaches an Ubuntu cloud-init ISO, powers on the VM, and performs a basic cloud-init based provisioning step (or uses SSH for post-provisioning). See inline comments.

High-level flow
1. Provide an SSH public key and your desired VM parameters (name, CPU, memory, disk path).
2. The script downloads an Ubuntu server cloud image, creates a VM with a custom cloud-init ISO containing a user-data file that installs Docker and Docker Compose plugin, and sets up SSH access.
3. After the VM starts and obtains an IP, the script can SSH into it, clone this repository, and run the `deploy/vm/deploy.sh` script (optionally with `--restore`).

Security and production considerations
- The script is a convenience helper. For production usage, consider hardened images, dedicated networks, a separate storage location for Docker volumes, and automated configuration tools (Ansible, Packer + Terraform, or an image-based approach).
