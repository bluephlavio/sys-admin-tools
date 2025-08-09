# `sync-windows-wsl`

Synchronizes SSH keys and configuration between **WSL** and **Windows**, so SSH works identically from both environments.

## 📌 Overview

This tool:

* Reads the `.ssh` folder and `config` file from your **WSL** environment
* Creates symlinks in your **Windows** `.ssh` directory pointing to the WSL keys
* Converts WSL-specific paths in `config` to Windows-compatible paths, with proper indentation
* Backs up your Windows `.ssh` before making changes
* Supports **Dry Run** mode to preview actions without making changes

This is useful for developers who:

* Work in both **WSL** and **Windows**
* Want to maintain **one set** of SSH keys and config files
* Avoid duplication and manual syncing

---

## ⚙ Requirements

* **Windows 10/11** with WSL installed
* **WSL** with a functional `.ssh` setup
* **PowerShell 5.1+** or **PowerShell 7+**
* Windows user with symlink creation permissions (developer mode or admin rights)
* Access to both environments’ user profiles

---

## 🚀 Usage

**From Windows PowerShell, in the script’s folder:**

```powershell
powershell -ExecutionPolicy Bypass -File .\sync-windows-wsl.ps1
```

**Dry Run (no changes made, previews actions):**

```powershell
powershell -ExecutionPolicy Bypass -File .\sync-windows-wsl.ps1 -DryRun
```

---

## 📝 Arguments

| Argument     | Type   | Default    | Description                                     |
| ------------ | ------ | ---------- | ----------------------------------------------- |
| `-WslDistro` | String | `"Ubuntu"` | Specify the WSL distro name (default: Ubuntu)   |
| `-DryRun`    | Switch | Off        | Shows what would happen without modifying files |

---

## 🔒 How It Works

1. Detects:

   * WSL distro name (or uses provided `-WslDistro`)
   * WSL username
   * Windows username
2. Backs up `C:\Users\<winuser>\.ssh`
3. Creates symlinks for each SSH key found in WSL’s `.ssh` folder inside Windows `.ssh`
4. Reads `~/.ssh/config` from WSL and rewrites key paths to Windows style with proper indentation
5. Saves the converted config to Windows’ `.ssh` folder
6. Adds keys to Windows SSH agent (if available)

---

## ⚠ Notes

* Private keys remain **only** in WSL, Windows uses symlinks
* Windows SSH client accesses keys through symlinks transparently
* Requires Windows permissions for symbolic link creation (enable developer mode or run as admin)
* If `-DryRun` is specified, no files or links are created; only outputs planned actions

---

## 📂 Example

```
Before:
Windows .ssh/ → separate keys and config
WSL .ssh/ → contains all active keys and config with WSL paths

After:
Windows .ssh/ → symlinks to WSL keys
Windows config → same hosts, updated key paths with correct indentation
```
