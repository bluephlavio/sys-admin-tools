# ------------------------------
# Zero-config SSH sync (WSL → Windows)
# ------------------------------

param (
    [string]$WslDistro = "Ubuntu"
)

Write-Host "Using WSL distro: $WslDistro"

# Detect WSL username
$wslUser = (wsl -d $WslDistro whoami).Trim()

# Detect Windows username and SSH dirs
$winUser = $env:USERNAME
$sshWinDir = "C:\Users\$winUser\.ssh"
$sshWslDir = "\\wsl$\$WslDistro\home\$wslUser\.ssh"

Write-Host "WSL distro: $WslDistro"
Write-Host "WSL user:   $wslUser"
Write-Host "Windows user: $winUser"

# Backup existing Windows .ssh dir if it exists
if (Test-Path $sshWinDir) {
    $backupPath = "$sshWinDir.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
    Rename-Item -Path $sshWinDir -NewName $backupPath
    Write-Host "Backed up existing .ssh to $backupPath"
}

# Create fresh Windows .ssh dir
New-Item -ItemType Directory -Path $sshWinDir | Out-Null

# Path to WSL SSH config
$wslConfigPath = "\\wsl$\$WslDistro\home\$wslUser\.ssh\config"

if (-not (Test-Path $wslConfigPath)) {
    throw "No SSH config found in WSL at $wslConfigPath"
}

# Read and convert config paths
$configLines = Get-Content $wslConfigPath
$convertedLines = $configLines | ForEach-Object {
    if ($_ -match '^\s*(IdentityFile|CertificateFile)\s+(.*)$') {
        $key = $matches[1]
        $path = $matches[2].Trim()

        # Normalize slashes to forward for replacement
        $path = $path -replace '\\', '/'

        # Replace WSL ~/.ssh and /home/user/.ssh prefixes with Windows .ssh path (using forward slashes)
        $windowsPath = $sshWinDir -replace '\\', '/'

        $path = $path -replace '^~\/\.ssh\/', "$windowsPath/"
        $path = $path -replace "^/home/$wslUser/\.ssh/", "$windowsPath/"

        # Add 4 spaces indentation for proper ssh config formatting
        "    $key $path"
    }
    else {
        $_
    }
}

# Save converted config to Windows
$convertedConfigPath = "$sshWinDir\config"
$convertedLines | Set-Content -Path $convertedConfigPath -Encoding UTF8
Write-Host "Converted config saved to $convertedConfigPath"

# Extract keys from converted config
$keyPaths = $convertedLines |
    ForEach-Object { if ($_ -match '^\s*IdentityFile\s+(.*)$') { $matches[1] } } |
    Sort-Object -Unique

# Create symlinks for each key from WSL .ssh to Windows .ssh
foreach ($keyPath in $keyPaths) {
    $keyName = Split-Path $keyPath -Leaf
    $src = Join-Path $sshWslDir $keyName
    $dst = Join-Path $sshWinDir $keyName
    if (Test-Path $src) {
        # Use cmd /c mklink to create symbolic link; requires admin or developer mode enabled
        cmd /c mklink "$dst" "$src" | Out-Null
        Write-Host "Linked: $keyName"
    } else {
        Write-Warning "Key not found in WSL: $src"
    }
}

# Add keys to Windows SSH agent
foreach ($keyPath in $keyPaths) {
    & ssh-add $keyPath | Out-Null
}
Write-Host "Keys added to Windows SSH agent."

Write-Host "SSH sync completed successfully."
