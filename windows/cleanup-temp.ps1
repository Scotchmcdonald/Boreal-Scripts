################################################################################
# Windows Temporary Files Cleanup Script
# Description: Removes temporary files and clears caches to free disk space
# Author: Boreal IT Services
# Usage: .\cleanup-temp.ps1
# Requirements: PowerShell 5.1+, Run as Administrator for best results
################################################################################

# Requires elevation for full cleanup
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "Running without administrator privileges. Some locations cannot be cleaned."
    Write-Host "For complete cleanup, run as Administrator."
    Write-Host ""
}

Write-Host "=========================================="
Write-Host "Windows Temporary Files Cleanup"
Write-Host "=========================================="
Write-Host "Started: $(Get-Date)"
Write-Host ""

# Function to safely remove files
function Remove-TempFiles {
    param (
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path $Path) {
        Write-Host "Cleaning: $Description" -ForegroundColor Cyan
        try {
            $itemsBefore = (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object).Count
            Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | 
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            $itemsAfter = (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object).Count
            $removed = $itemsBefore - $itemsAfter
            Write-Host "  Removed $removed items" -ForegroundColor Green
        } catch {
            Write-Host "  Warning: Could not clean all items - $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Skipping: $Description (path not found)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Get disk space before cleanup
$driveBefore = Get-Volume -DriveLetter C
$freeSpaceBefore = [math]::Round($driveBefore.SizeRemaining/1GB, 2)

# Clean Windows Temp folder
Remove-TempFiles -Path "C:\Windows\Temp" -Description "Windows Temp"

# Clean User Temp folder
Remove-TempFiles -Path "$env:TEMP" -Description "User Temp ($env:USERNAME)"

# Clean Windows Update Cache
if ($isAdmin) {
    Remove-TempFiles -Path "C:\Windows\SoftwareDistribution\Download" -Description "Windows Update Cache"
}

# Clean Recycle Bin (requires elevation)
if ($isAdmin) {
    Write-Host "Cleaning: Recycle Bin" -ForegroundColor Cyan
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "  Recycle Bin emptied" -ForegroundColor Green
    } catch {
        Write-Host "  Warning: Could not empty Recycle Bin" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Clean Prefetch (requires elevation)
if ($isAdmin) {
    Remove-TempFiles -Path "C:\Windows\Prefetch" -Description "Prefetch Cache"
}

# Clean DNS Cache
Write-Host "Cleaning: DNS Cache" -ForegroundColor Cyan
try {
    Clear-DnsClientCache
    Write-Host "  DNS Cache cleared" -ForegroundColor Green
} catch {
    Write-Host "  Warning: Could not clear DNS Cache" -ForegroundColor Yellow
}
Write-Host ""

# Clean Browser Caches (Internet Explorer/Edge)
Remove-TempFiles -Path "$env:LOCALAPPDATA\Microsoft\Windows\INetCache" -Description "IE/Edge Cache"

# Get disk space after cleanup
$driveAfter = Get-Volume -DriveLetter C
$freeSpaceAfter = [math]::Round($driveAfter.SizeRemaining/1GB, 2)
$spaceReclaimed = [math]::Round($freeSpaceAfter - $freeSpaceBefore, 2)

Write-Host "=========================================="
Write-Host "Cleanup Summary"
Write-Host "=========================================="
Write-Host "Free Space Before: $freeSpaceBefore GB"
Write-Host "Free Space After: $freeSpaceAfter GB"
Write-Host "Space Reclaimed: $spaceReclaimed GB" -ForegroundColor Green
Write-Host ""
Write-Host "Cleanup Complete!"
Write-Host "=========================================="
