<#
Provision an Ubuntu VM on Hyper-V and perform basic provisioning.

Usage (Run as Administrator):
  ./provision-hyperv.ps1 -VMName "sonarqube-vm" -MemoryGB 4 -VhdxPath "C:\HyperV\sonarqube-vm.vhdx" -SshPublicKeyPath "C:\Users\you\\.ssh\\id_rsa.pub"

Notes:
- Requires Hyper-V role enabled.
- The script downloads an Ubuntu cloud image and generates a cloud-init ISO that will create a user with your SSH public key and install Docker.
- Adjust CPU/memory/disk settings as needed.
#>

param(
  [string]$VMName = "sonarqube-vm",
  [int]$MemoryGB = 4,
  [int]$Processors = 2,
  [string]$VhdxPath = "C:\HyperV\$VMName.vhdx",
  [string]$SwitchName = "Default Switch",
  [string]$SshPublicKeyPath = "$env:USERPROFILE\.ssh\id_rsa.pub",
  [string]$SshPrivateKeyPath = "$env:USERPROFILE\.ssh\id_rsa",
  [string]$RepoUrl = "",
  [string]$RestoreBackupsPath = "",
  [string]$VmUser = "ubuntu",
  [string]$UbuntuRelease = "22.04",
  [switch]$AutoDeploy
)

function Ensure-HyperVRole {
  if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V).State -ne 'Enabled') {
    Write-Host "Hyper-V role not enabled. Enable it and reboot, then re-run this script." -ForegroundColor Yellow
    exit 1
  }
}

Ensure-HyperVRole

if (-not (Test-Path -Path $SshPublicKeyPath)) {
  Write-Error "SSH public key not found at $SshPublicKeyPath"
  exit 2
}

$cloudImgUrl = "https://cloud-images.ubuntu.com/releases/$UbuntuRelease/release/ubuntu-$UbuntuRelease-server-cloudimg-amd64.img"
$tmp = Join-Path $env:TEMP "$VMName-cloud"
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

$cloudImg = Join-Path $tmp "ubuntu-cloud.img"
Write-Host "Downloading Ubuntu cloud image..."
Invoke-WebRequest -Uri $cloudImgUrl -OutFile $cloudImg -UseBasicParsing

# Convert qcow2 to vhdx using qemu-img if available; otherwise create differencing VHDX.
if (Get-Command qemu-img -ErrorAction SilentlyContinue) {
  Write-Host "Converting to VHDX using qemu-img..."
  qemu-img convert -f qcow2 -O vhdx $cloudImg $VhdxPath
} else {
  Write-Host "qemu-img not found. Creating differencing VHDX and attaching cloud image via differencing disk."
  New-VHD -Path $VhdxPath -SizeBytes 60GB -Dynamic | Out-Null
}

# Generate cloud-init user-data and meta-data
$sshKey = Get-Content -Path $SshPublicKeyPath -Raw
$userData = @"
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: docker
    shell: /bin/bash
    ssh_authorized_keys:
      - $sshKey
package_update: true
package_upgrade: true
packages:
  - docker.io
  - cloud-init
runcmd:
  - [ sh, -c, 'usermod -aG docker ubuntu' ]
  - [ sh, -c, 'systemctl enable --now docker' ]
  - [ sh, -c, 'mkdir -p /home/ubuntu/SonarQube-Open-Server' ]
  - [ sh, -c, 'chown -R ubuntu:ubuntu /home/ubuntu' ]
"@

$metaData = @"instance-id: $VMName
local-hostname: $VMName
"@

$userDataPath = Join-Path $tmp "user-data"
$metaDataPath = Join-Path $tmp "meta-data"
Set-Content -Path $userDataPath -Value $userData -NoNewline
Set-Content -Path $metaDataPath -Value $metaData -NoNewline

# Create ISO
$isoPath = Join-Path $tmp "cloud-init.iso"
if (Get-Command mkisofs -ErrorAction SilentlyContinue) {
  mkisofs -o $isoPath -V cidata -J -r $userDataPath $metaDataPath
} else {
  Write-Host "mkisofs not available. Attempting to use New-IsoFile (PowerShell 7+ / Windows 10+)."
  if (Get-Command New-IsoFile -ErrorAction SilentlyContinue) {
    New-IsoFile -Path $isoPath -InputPath $userDataPath,$metaDataPath
  } else {
    Write-Error "No iso creation tool found. Install mkisofs or use an alternative to create a cloud-init ISO at $isoPath"
    exit 3
  }
}

# Create VM
if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
  Write-Host "VM $VMName already exists, skipping VM creation."
} else {
  New-VM -Name $VMName -MemoryStartupBytes ($MemoryGB * 1GB) -Generation 2 -SwitchName $SwitchName | Out-Null
  Set-VMProcessor -VMName $VMName -Count $Processors
  # Attach VHDX
  Add-VMHardDiskDrive -VMName $VMName -Path $VhdxPath
  # Add cloud-init ISO as DVD
  Add-VMDvdDrive -VMName $VMName -Path $isoPath
}

Start-VM -Name $VMName

Write-Host "VM started. Wait a minute for cloud-init to run and for the VM to obtain an IP via DHCP."
Write-Host "Use 'Get-VMNetworkAdapter -VMName $VMName | Select -ExpandProperty IPAddresses' to locate the VM IP (requires Hyper-V host support for IP integration)."

Write-Host "Once the VM is reachable, SSH in as 'ubuntu' and clone the repo and run deploy/vm/deploy.sh"

if ($AutoDeploy) {
  Write-Host "AutoDeploy requested — attempting to locate VM IP and SSH in..."

  # Try to get the VM IP address via Hyper-V integration
  $vmIp = $null
  $attempts = 0
  while (($null -eq $vmIp -or $vmIp -eq "") -and $attempts -lt 40) {
    Start-Sleep -Seconds 5
    $attempts++
    try {
      $ips = (Get-VMNetworkAdapter -VMName $VMName -ErrorAction Stop).IPAddresses
      if ($ips) {
        # Prefer an IPv4 address
        $vmIp = $ips | Where-Object { $_ -match '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' } | Select-Object -First 1
      }
    } catch {
      # ignore and retry
    }
    Write-Host -NoNewline "."
  }
  Write-Host ""

  if (-not $vmIp) {
    Write-Error "Could not determine VM IP automatically. You can retry and provide -VmIp manually in a future script update. Exiting AutoDeploy."
    exit 4
  }

  Write-Host "VM IP detected: $vmIp"

  # Ensure ssh client exists on host
  if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Error "SSH client not found on this Windows host. Install the OpenSSH client or run AutoDeploy from a machine with ssh available." 
    exit 5
  }

  if (-not (Test-Path -Path $SshPrivateKeyPath)) {
    Write-Error "SSH private key not found at $SshPrivateKeyPath. Provide a path matching the public key used in -SshPublicKeyPath.";
    exit 6
  }

  # Wait for SSH to accept connections
  $sshReady = $false
  for ($i=0; $i -lt 30; $i++) {
    try {
      & ssh -i $SshPrivateKeyPath -o StrictHostKeyChecking=no -o ConnectTimeout=3 "$VmUser@$vmIp" echo ready > $null 2>&1
      if ($LASTEXITCODE -eq 0) { $sshReady = $true; break }
    } catch {
      Start-Sleep -Seconds 3
    }
  }

  if (-not $sshReady) {
    Write-Error "SSH not reachable on $vmIp after waiting — aborting AutoDeploy.";
    exit 7
  }

  if (-not $RepoUrl) {
    Write-Error "No RepoUrl provided. Supply -RepoUrl '<git clone url>' to AutoDeploy the repository.";
    exit 8
  }

  Write-Host "Cloning repository on VM and running deploy script..."

  # Compose commands for remote execution
  $remoteCommands = @()
  $remoteCommands += "set -euo pipefail"
  $remoteCommands += "cd /home/$VmUser || mkdir -p /home/$VmUser; cd /home/$VmUser"
  $remoteCommands += "if [ -d SonarQube-Open-Server ]; then cd SonarQube-Open-Server && git pull || true; else git clone '$RepoUrl' SonarQube-Open-Server; cd SonarQube-Open-Server; fi"
  if ($RestoreBackupsPath) {
    $remoteCommands += "if [ -d ~/backups ] || true; then mkdir -p ~/backups; fi"
    # Note: scp path quoting: we will scp local RestoreBackupsPath content to remote ~/backups
    Write-Host "Copying backups to VM..."
    & scp -i $SshPrivateKeyPath -o StrictHostKeyChecking=no -r "$RestoreBackupsPath"/* "$VmUser@$vmIp:~/backups/"
    $remoteCommands += "./deploy/vm/deploy.sh --restore ~/backups"
  } else {
    $remoteCommands += "./deploy/vm/deploy.sh"
  }

  $cmd = $remoteCommands -join " && "
  Write-Host "Executing remote commands over SSH (this may take several minutes)..."
  & ssh -i $SshPrivateKeyPath -o StrictHostKeyChecking=no "$VmUser@$vmIp" $cmd

  Write-Host "AutoDeploy finished. Check the VM and containers (docker compose ps) for status."
}
