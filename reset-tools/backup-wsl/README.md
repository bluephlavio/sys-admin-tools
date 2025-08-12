# WSL Backup Tool

## Overview

This tool helps you efficiently **prepare and export your WSL distro backup** with a clean separation between:

* **Preparation inside WSL** (cache cleaning, zero-filling free space)
* **Export on Windows side** (timestamped folder creation, full distro export)

---

## Folder Structure Assumption

Backups are saved under:
`D:\backup\YYYYMMDD-HHMMSS\full-backup.tar`

---

## Usage Workflow

### Step 1: Run cleanup inside WSL manually or automated

Run inside your WSL distro (once in a while before backups):

```bash
./backup_prepare.sh
```

This script will:

* Clear package caches (apt, npm, pip, etc.)
* Remove temporary files, Docker cache, VSCode servers
* Zero-fill free space to shrink the virtual disk size

---

### Step 2: Run export from PowerShell

From PowerShell on Windows, run:

```powershell
.\backup_export.ps1 -Distro Ubuntu -BackupBase D:\backup
```

This script will:

* Create a timestamped folder inside `D:\backup`
* Export the entire WSL distro to `full-backup.tar` inside that folder

---

## Useful Disk Space Commands (WSL)

To check how much space your WSL distro is using and find the largest folders, run these commands inside your WSL terminal:

```bash
# Show total used space in root filesystem
df -h /

# Show disk usage for all folders in root, sorted by size
sudo du -hxd1 / | sort -hr | head -20

# Find the largest folders under your home directory
sudo du -hxd1 ~ | sort -hr | head -20
```

---

## Notes

* Make sure you have **enough free space** on your D: drive for the export.
* You can customize cleanup steps in `backup_prepare.sh` independently without modifying the PowerShell script.
* Use `wsl --import` with the exported `.tar` file to restore your distro if needed.
* Optionally compress the exported `.tar` using 7-Zip or other Windows tools to save space.
