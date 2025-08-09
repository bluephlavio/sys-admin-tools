# ------------------------------
# Zero-config SSH sync (WSL → Windows)
# ------------------------------

# Detect default WSL distro
$wslDistro = (wsl --list --quiet | Select-Object -First 1).Trim()
if (-not $wslDistro) { throw "No WSL distro found." }

# Detect WSL username
$wslUser = (wsl -d $wslDistro whoami).Trim()

# Detect Windows username and SSH dir
$winUser = $env:USERNAME
$sshWinDir = "C:\Users\$winUser\.ssh"
$sshWslDir = "\\wsl$\$wslDistro\home\$wslUser\.ssh"

Write-Host "WSL distro: $wslDistro"
Write-Host "WSL user:   $wslUser"
Write-Host "Windows user: $winUser"

# Backup existing Windows .ssh
if (Test-Path $sshWinDir) {
    $backupPath = "$sshWinDir.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
    Rename-Item $sshWinDir $backupPath
    Write-Host "Backed up existing .ssh to $backupPath"
}

# Create fresh Windows .ssh dir
New-Item -ItemType Directory -Path $sshWinDir | Out-Null

# Path to WSL SSH config
$wslConfigPath = "\\wsl$\$wslDistro\home\$wslUser\.ssh\config"

if (-not (Test-Path $wslConfigPath)) {
    throw "No SSH config found in WSL at $wslConfigPath"
}

# Read and convert config paths
$configLines = Get-Content $wslConfigPath
$convertedLines = $configLines | ForEach-Object {
    if ($_ -match '^\s*(IdentityFile|CertificateFile)\s+(.*)$') {
        $key = $matches[1]
        $path = $matches[2].Trim()

        # Replace WSL ~/.ssh path with Windows .ssh path
        $path = $path -replace "^~\/\.ssh\/", ($sshWinDir -replace '\\', '/') + '/'
        $path = $path -replace "^/home/$wslUser/\.ssh/", ($sshWinDir -replace '\\', '/') + '/'

        "$key $path"
    }
    else {
        $_
    }
}

# Save converted config to Windows
$convertedConfigPath = "$sshWinDir\config"
$convertedLines | Set-Content $convertedConfigPath -Encoding UTF8
Write-Host "Converted config saved to $convertedConfigPath"

# Extract keys from converted config
$keyPaths = $convertedLines |
    ForEach-Object { if ($_ -match '^\s*IdentityFile\s+(.*)$') { $matches[1] } } |
    Sort-Object -Unique

# Create symlinks for each key
foreach ($keyPath in $keyPaths) {
    $keyName = Split-Path $keyPath -Leaf
    $src = Join-Path $sshWslDir $keyName
    $dst = Join-Path $sshWinDir $keyName
    if (Test-Path $src) {
        cmd /c mklink "$dst" "$src" | Out-Null
        Write-Host "Linked: $keyName"
    } else {
        Write-Warning "Key not found in WSL: $src"
    }
}

# Auto-add keys to Windows SSH agent
foreach ($keyPath in $keyPaths) {
    & ssh-add $keyPath | Out-Null
}
Write-Host "Keys added to Windows SSH agent."

Write-Host "SSH sync completed successfully."
