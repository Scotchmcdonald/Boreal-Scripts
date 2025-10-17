################################################################################
# Disk Space Monitor Script (PowerShell)
# Description: Monitors disk space and alerts on thresholds
# Author: Boreal IT Services
# Usage: .\disk-monitor.ps1
################################################################################

param(
    [Parameter(Mandatory=$false)]
    [int]$WarningThreshold = 80,
    
    [Parameter(Mandatory=$false)]
    [int]$CriticalThreshold = 90,
    
    [Parameter(Mandatory=$false)]
    [string]$LogFile = "$env:ProgramData\disk-monitor.log"
)

# Function to log messages
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Add-Content -Path $LogFile -Value $logMessage
}

Write-Host "=========================================="
Write-Host "Disk Space Monitor"
Write-Host "=========================================="
Write-Host "Date: $(Get-Date)"
Write-Host "Warning Threshold: $WarningThreshold%"
Write-Host "Critical Threshold: $CriticalThreshold%"
Write-Host ""

Write-Log "Disk monitor check started"

# Get all fixed drives
$drives = Get-Volume | Where-Object {$_.DriveLetter -ne $null -and $_.DriveType -eq 'Fixed'}

$alertCount = 0
$criticalCount = 0

Write-Host "=== Disk Space Status ===" -ForegroundColor Cyan

foreach ($drive in $drives) {
    $percentUsed = [math]::Round(($drive.Size - $drive.SizeRemaining) / $drive.Size * 100, 2)
    $percentFree = [math]::Round($drive.SizeRemaining / $drive.Size * 100, 2)
    $freeGB = [math]::Round($drive.SizeRemaining / 1GB, 2)
    $totalGB = [math]::Round($drive.Size / 1GB, 2)
    
    Write-Host "Drive $($drive.DriveLetter):" -NoNewline
    
    if ($percentUsed -ge $CriticalThreshold) {
        Write-Host " CRITICAL" -ForegroundColor Red
        Write-Host "  Used: $percentUsed% | Free: $freeGB GB of $totalGB GB" -ForegroundColor Red
        Write-Log "CRITICAL: Drive $($drive.DriveLetter): is $percentUsed% full"
        $criticalCount++
    }
    elseif ($percentUsed -ge $WarningThreshold) {
        Write-Host " WARNING" -ForegroundColor Yellow
        Write-Host "  Used: $percentUsed% | Free: $freeGB GB of $totalGB GB" -ForegroundColor Yellow
        Write-Log "WARNING: Drive $($drive.DriveLetter): is $percentUsed% full"
        $alertCount++
    }
    else {
        Write-Host " OK" -ForegroundColor Green
        Write-Host "  Used: $percentUsed% | Free: $freeGB GB of $totalGB GB"
        Write-Log "OK: Drive $($drive.DriveLetter): is $percentUsed% full"
    }
    
    # Show file system info
    Write-Host "  FileSystem: $($drive.FileSystemType) | Label: $($drive.FileSystemLabel)"
    Write-Host ""
}

# Summary
Write-Host "=========================================="
Write-Host "Monitor Summary"
Write-Host "=========================================="
Write-Host "Total Drives Checked: $($drives.Count)"
Write-Host "Warnings: $alertCount" -ForegroundColor $(if ($alertCount -gt 0) { "Yellow" } else { "Green" })
Write-Host "Critical: $criticalCount" -ForegroundColor $(if ($criticalCount -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($criticalCount -gt 0) {
    Write-Host "ACTION REQUIRED: $criticalCount drive(s) in critical state!" -ForegroundColor Red
    Write-Log "ACTION REQUIRED: $criticalCount drive(s) in critical state"
}
elseif ($alertCount -gt 0) {
    Write-Host "ATTENTION: $alertCount drive(s) need attention" -ForegroundColor Yellow
    Write-Log "ATTENTION: $alertCount drive(s) need attention"
}
else {
    Write-Host "All drives are healthy" -ForegroundColor Green
    Write-Log "All drives are healthy"
}

Write-Host "=========================================="
Write-Log "Disk monitor check completed"

# Exit with appropriate code
if ($criticalCount -gt 0) {
    exit 2
}
elseif ($alertCount -gt 0) {
    exit 1
}
else {
    exit 0
}
