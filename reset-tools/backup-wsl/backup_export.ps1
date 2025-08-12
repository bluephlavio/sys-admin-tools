param(
    [string]$Distro = "Ubuntu",
    [string]$BackupBase = "D:\backup"
)

function Get-Timestamp {
    return (Get-Date).ToString("yyyyMMdd")
}

try {
    # Create timestamped backup folder
    $timestamp = Get-Timestamp
    $backupFolder = Join-Path -Path $BackupBase -ChildPath $timestamp

    Write-Host "Creating backup folder: $backupFolder"
    New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null

    # Define export file path
    $exportFile = Join-Path -Path $backupFolder -ChildPath "$Distro-full-backup.tar"

    # Export the WSL distro
    Write-Host "Exporting WSL distro '$Distro' to '$exportFile' ..."
    wsl --export $Distro $exportFile

    if (Test-Path $exportFile) {
        Write-Host "Export completed successfully!"
        Write-Host "Backup saved at: $exportFile"
    } else {
        Write-Error "Export failed: backup file not found."
    }

} catch {
    Write-Error "An error occurred during backup: $_"
}
