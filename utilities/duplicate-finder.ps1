################################################################################
# Duplicate File Finder Script (PowerShell)
# Description: Finds duplicate files based on content hash
# Author: Boreal IT Services
# Usage: .\duplicate-finder.ps1 -Path "C:\Users\Documents"
################################################################################

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [Parameter(Mandatory=$false)]
    [int]$MinSizeMB = 1,
    
    [Parameter(Mandatory=$false)]
    [switch]$DeleteDuplicates
)

Write-Host "=========================================="
Write-Host "Duplicate File Finder"
Write-Host "=========================================="
Write-Host "Scanning Path: $Path"
Write-Host "Minimum Size: $MinSizeMB MB"
Write-Host "Date: $(Get-Date)"
Write-Host ""

if (-not (Test-Path $Path)) {
    Write-Host "Error: Path not found: $Path" -ForegroundColor Red
    exit 1
}

$minSizeBytes = $MinSizeMB * 1MB

Write-Host "=== Scanning for Files ===" -ForegroundColor Cyan
$files = Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue | 
         Where-Object { $_.Length -ge $minSizeBytes }

$totalFiles = $files.Count
Write-Host "Found $totalFiles files to analyze"
Write-Host ""

if ($totalFiles -eq 0) {
    Write-Host "No files found matching criteria"
    exit 0
}

Write-Host "=== Calculating Hashes ===" -ForegroundColor Cyan
Write-Host "This may take a while..."

$hashTable = @{}
$duplicates = @()
$processed = 0

foreach ($file in $files) {
    $processed++
    if ($processed % 100 -eq 0) {
        Write-Host "Processed $processed of $totalFiles files..."
    }
    
    try {
        $hash = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash
        
        if ($hashTable.ContainsKey($hash)) {
            # Duplicate found
            $duplicates += [PSCustomObject]@{
                Hash = $hash
                Original = $hashTable[$hash].FullName
                Duplicate = $file.FullName
                Size = $file.Length
            }
        } else {
            $hashTable[$hash] = $file
        }
    } catch {
        Write-Host "Warning: Could not process $($file.FullName)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Results ===" -ForegroundColor Cyan

if ($duplicates.Count -eq 0) {
    Write-Host "No duplicate files found!" -ForegroundColor Green
    exit 0
}

Write-Host "Found $($duplicates.Count) duplicate files:" -ForegroundColor Yellow
Write-Host ""

$totalDuplicateSize = 0
$groupedDuplicates = $duplicates | Group-Object Hash

foreach ($group in $groupedDuplicates) {
    $firstDup = $group.Group[0]
    $sizeMB = [math]::Round($firstDup.Size / 1MB, 2)
    
    Write-Host "Duplicate Set (Size: $sizeMB MB):" -ForegroundColor Cyan
    Write-Host "  Original: $($firstDup.Original)"
    
    foreach ($dup in $group.Group) {
        Write-Host "  Duplicate: $($dup.Duplicate)" -ForegroundColor Yellow
        $totalDuplicateSize += $dup.Size
    }
    Write-Host ""
}

$totalWastedMB = [math]::Round($totalDuplicateSize / 1MB, 2)
$totalWastedGB = [math]::Round($totalDuplicateSize / 1GB, 2)

Write-Host "=========================================="
Write-Host "Summary"
Write-Host "=========================================="
Write-Host "Total Files Scanned: $totalFiles"
Write-Host "Duplicate Files Found: $($duplicates.Count)"
Write-Host "Wasted Space: $totalWastedMB MB ($totalWastedGB GB)"
Write-Host ""

if ($DeleteDuplicates) {
    Write-Host "=== Deleting Duplicates ===" -ForegroundColor Yellow
    Write-Host "WARNING: This will permanently delete duplicate files!"
    $confirm = Read-Host "Type 'YES' to confirm deletion"
    
    if ($confirm -eq 'YES') {
        $deleted = 0
        foreach ($dup in $duplicates) {
            try {
                Remove-Item -Path $dup.Duplicate -Force
                Write-Host "Deleted: $($dup.Duplicate)" -ForegroundColor Green
                $deleted++
            } catch {
                Write-Host "Error deleting: $($dup.Duplicate)" -ForegroundColor Red
            }
        }
        Write-Host ""
        Write-Host "Deleted $deleted duplicate files" -ForegroundColor Green
    } else {
        Write-Host "Deletion cancelled"
    }
}

Write-Host "=========================================="
Write-Host "Scan Complete"
Write-Host "=========================================="
