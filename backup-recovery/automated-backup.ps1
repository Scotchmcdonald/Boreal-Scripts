################################################################################
# Automated Backup Script (PowerShell)
# Description: Comprehensive Windows backup with rotation
# Author: Boreal IT Services
# Usage: .\automated-backup.ps1
# Requirements: PowerShell 5.1+, Run as Administrator
################################################################################

param(
    [Parameter(Mandatory=$false)]
    [string[]]$SourcePaths = @("C:\Users", "C:\Important"),
    
    [Parameter(Mandatory=$false)]
    [string]$BackupDestination = "D:\Backups",
    
    [Parameter(Mandatory=$false)]
    [int]$RetentionDays = 7
)

$ErrorActionPreference = "Continue"
$BackupName = "system-backup"
$LogFile = "$BackupDestination\backup.log"

# Function to log messages
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogFile -Value $logMessage
}

Write-Host "=========================================="
Write-Host "Automated Backup Script (PowerShell)"
Write-Host "=========================================="
Write-Log "Backup started"

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Not running as Administrator. Some files may not be accessible."
}

# Create backup destination
if (-not (Test-Path $BackupDestination)) {
    New-Item -ItemType Directory -Path $BackupDestination | Out-Null
    Write-Log "Created backup destination: $BackupDestination"
}

# Generate timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFolder = "$BackupDestination\$BackupName`_$timestamp"
New-Item -ItemType Directory -Path $backupFolder | Out-Null

Write-Host ""
Write-Host "=== Pre-Backup Checks ===" -ForegroundColor Cyan
Write-Log "Running pre-backup checks"

# Check source paths and calculate size
$totalSize = 0
foreach ($source in $SourcePaths) {
    if (Test-Path $source) {
        $size = (Get-ChildItem -Path $source -Recurse -ErrorAction SilentlyContinue | 
                Measure-Object -Property Length -Sum).Sum / 1GB
        $totalSize += $size
        Write-Host "Source ${source}: $([math]::Round($size, 2)) GB"
    } else {
        Write-Warning "Source $source not found"
        Write-Log "Warning: Source $source not found"
    }
}

# Check available space
$drive = (Get-Item $BackupDestination).PSDrive
$freeSpace = [math]::Round($drive.Free / 1GB, 2)
Write-Host "Available space at destination: $freeSpace GB"
Write-Host "Estimated backup size: $([math]::Round($totalSize, 2)) GB"
Write-Host ""

if ($freeSpace -lt ($totalSize * 1.1)) {
    Write-Warning "Low disk space! Backup may fail."
}

# Perform backup
Write-Host "=== Creating Backup ===" -ForegroundColor Cyan
Write-Log "Creating backup: $backupFolder"
Write-Host "This may take several minutes..."

$filesCopied = 0
$errorCount = 0

foreach ($source in $SourcePaths) {
    if (Test-Path $source) {
        $sourceName = (Get-Item $source).Name
        $destPath = Join-Path $backupFolder $sourceName
        
        Write-Host "Copying $source..."
        try {
            Copy-Item -Path $source -Destination $destPath -Recurse -Force -ErrorAction SilentlyContinue
            $filesCopied++
            Write-Host "  ✓ Copied successfully" -ForegroundColor Green
        } catch {
            $errorCount++
            Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Log "Error copying $source : $($_.Exception.Message)"
        }
    }
}

Write-Host ""

# Compress backup
Write-Host "=== Compressing Backup ===" -ForegroundColor Cyan
$zipFile = "$BackupDestination\$BackupName`_$timestamp.zip"

try {
    Compress-Archive -Path $backupFolder -DestinationPath $zipFile -CompressionLevel Optimal
    Write-Host "✓ Backup compressed successfully" -ForegroundColor Green
    Write-Log "Backup compressed: $zipFile"
    
    # Remove uncompressed folder
    Remove-Item -Path $backupFolder -Recurse -Force
    
    # Get final size
    $backupSize = [math]::Round((Get-Item $zipFile).Length / 1GB, 2)
    Write-Host "Backup size: $backupSize GB"
    Write-Log "Backup size: $backupSize GB"
} catch {
    Write-Host "✗ Compression failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Log "ERROR: Compression failed - $($_.Exception.Message)"
}

Write-Host ""

# Cleanup old backups
Write-Host "=== Cleaning Old Backups ===" -ForegroundColor Cyan
Write-Log "Cleaning backups older than $RetentionDays days"

$cutoffDate = (Get-Date).AddDays(-$RetentionDays)
Get-ChildItem -Path $BackupDestination -Filter "$BackupName`_*.zip" | 
    Where-Object { $_.LastWriteTime -lt $cutoffDate } | 
    ForEach-Object {
        Remove-Item $_.FullName -Force
        Write-Log "Removed old backup: $($_.Name)"
    }

$remainingBackups = (Get-ChildItem -Path $BackupDestination -Filter "$BackupName`_*.zip").Count
Write-Host "Remaining backups: $remainingBackups"
Write-Log "Cleanup complete. Remaining backups: $remainingBackups"

Write-Host ""

# Summary
Write-Host "=========================================="
Write-Host "Backup Summary"
Write-Host "=========================================="
Write-Host "Status: SUCCESS"
Write-Host "Backup File: $zipFile"
Write-Host "Files Copied: $filesCopied"
Write-Host "Errors: $errorCount"
Write-Host "Retention: $RetentionDays days"
Write-Host "Total Backups: $remainingBackups"
Write-Host ""

Write-Log "Backup completed successfully"

Write-Host "=========================================="
Write-Host "Backup Complete!" -ForegroundColor Green
Write-Host "=========================================="
