################################################################################
# Freescout Backup Script (PowerShell version)
# Description: Complete backup of Freescout via SSH from Windows
# Author: Boreal IT Services
# Usage: .\backup-freescout.ps1 -Server "freescout.example.com" -User "admin"
# Requirements: PowerShell 7+, SSH access to Freescout server
################################################################################

param(
    [Parameter(Mandatory=$true)]
    [string]$Server,
    
    [Parameter(Mandatory=$true)]
    [string]$User,
    
    [Parameter(Mandatory=$false)]
    [string]$FreescoutPath = "/var/www/freescout",
    
    [Parameter(Mandatory=$false)]
    [string]$LocalBackupPath = "$env:USERPROFILE\freescout-backups"
)

Write-Host "=========================================="
Write-Host "Freescout Backup Script (PowerShell)"
Write-Host "=========================================="
Write-Host "Server: $Server"
Write-Host "User: $User"
Write-Host "Date: $(Get-Date)"
Write-Host ""

# Create local backup directory
if (-not (Test-Path $LocalBackupPath)) {
    New-Item -ItemType Directory -Path $LocalBackupPath | Out-Null
    Write-Host "Created local backup directory: $LocalBackupPath" -ForegroundColor Green
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupName = "freescout-backup-$timestamp"

# Execute backup script on remote server
Write-Host "=== Executing Backup on Server ===" -ForegroundColor Cyan
$remoteScript = @"
cd $FreescoutPath
sudo php artisan down
sudo mysqldump freescout > /tmp/$backupName.sql
sudo tar -czf /tmp/$backupName.tar.gz -C $(dirname $FreescoutPath) $(basename $FreescoutPath)
sudo php artisan up
echo 'Backup created on server'
"@

ssh "${User}@${Server}" $remoteScript

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Remote backup completed" -ForegroundColor Green
} else {
    Write-Host "✗ Remote backup failed" -ForegroundColor Red
    exit 1
}

# Download backup from server
Write-Host ""
Write-Host "=== Downloading Backup ===" -ForegroundColor Cyan
scp "${User}@${Server}:/tmp/$backupName.tar.gz" "$LocalBackupPath\"
scp "${User}@${Server}:/tmp/$backupName.sql" "$LocalBackupPath\"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Backup downloaded to $LocalBackupPath" -ForegroundColor Green
} else {
    Write-Host "✗ Download failed" -ForegroundColor Red
}

# Clean up remote temporary files
Write-Host ""
Write-Host "=== Cleaning Up Remote Files ===" -ForegroundColor Cyan
ssh "${User}@${Server}" "sudo rm /tmp/$backupName.tar.gz /tmp/$backupName.sql"

Write-Host ""
Write-Host "=========================================="
Write-Host "Backup Complete!" -ForegroundColor Green
Write-Host "=========================================="
Write-Host "Backup saved to: $LocalBackupPath"
