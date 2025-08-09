# `sync-windows-wsl`

Synchronizes SSH keys and configuration between **WSL** and **Windows**, so SSH works identically from both environments.

## 📌 Overview

This tool:

* Reads the `.ssh` folder and `config` file from your **WSL** environment
* Creates symlinks in your **Windows** `.ssh` directory pointing to the WSL keys
* Converts WSL-specific paths in `config` to Windows-compatible paths
* Backs up your Windows `.ssh` before making changes
* Can run in **Dry Run** mode to preview actions without making changes

This is useful for developers who:

* Work in both **WSL** and **Windows**
* Want to maintain **one set** of SSH keys and config files
* Avoid duplication and manual syncing

---

## ⚙ Requirements

* **Windows 10/11** with WSL installed
* **WSL** with a functional `.ssh` setup
* **PowerShell 5.1+** or **PowerShell 7+**
* Access to both environments’ user profiles

---

## 🚀 Usage

**From Windows PowerShell, in the script’s folder:**

```powershell
# Run the script normally
.\sync-windows-wsl.ps1
```

**Dry Run (no changes made):**

```powershell
.\sync-windows-wsl.ps1 -DryRun
```

---

## 📝 Arguments

| Argument  | Type   | Default | Description                                     |
| --------- | ------ | ------- | ----------------------------------------------- |
| `-DryRun` | Switch | Off     | Shows what would happen without modifying files |

---

## 🔒 How It Works

1. Detects:
   * WSL distro name
   * WSL username
   * Windows username
2. Backs up `C:\Users\<winuser>\.ssh`
3. Creates symlinks for each key found in WSL’s `.ssh`
4. Reads `~/.ssh/config` from WSL and rewrites paths for Windows
5. Saves the modified config to Windows’ `.ssh`

---

## ⚠ Notes

* Private keys are **not** copied — they remain in WSL.
* The Windows SSH client accesses them via symlink.
* Requires Windows symlink permissions (developer mode or admin rights).

---

## 📂 Example

```
Before:
Windows .ssh/ → separate files
WSL .ssh/ → contains all active keys

After:
Windows .ssh/ → symlinks to WSL keys
Windows config → same hosts, updated paths
```
