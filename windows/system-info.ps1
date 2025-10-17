################################################################################
# Windows System Information Script
# Description: Collects comprehensive Windows system information
# Author: Boreal IT Services
# Usage: .\system-info.ps1
# Requirements: PowerShell 5.1+, Run as Administrator for complete info
################################################################################

# Script header
Write-Host "=========================================="
Write-Host "Windows System Information Report"
Write-Host "=========================================="
Write-Host "Generated: $(Get-Date)"
Write-Host ""

# Operating System Information
Write-Host "=== Operating System ===" -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
Write-Host "OS Name: $($os.Caption)"
Write-Host "Version: $($os.Version)"
Write-Host "Build: $($os.BuildNumber)"
Write-Host "Architecture: $($os.OSArchitecture)"
Write-Host "Install Date: $($os.InstallDate)"
Write-Host "Last Boot: $($os.LastBootUpTime)"
Write-Host ""

# Computer Information
Write-Host "=== Computer Information ===" -ForegroundColor Cyan
$cs = Get-CimInstance Win32_ComputerSystem
Write-Host "Computer Name: $($cs.Name)"
Write-Host "Domain: $($cs.Domain)"
Write-Host "Manufacturer: $($cs.Manufacturer)"
Write-Host "Model: $($cs.Model)"
Write-Host "Total Physical Memory: $([math]::Round($cs.TotalPhysicalMemory/1GB, 2)) GB"
Write-Host ""

# Processor Information
Write-Host "=== Processor ===" -ForegroundColor Cyan
$cpu = Get-CimInstance Win32_Processor
Write-Host "Name: $($cpu.Name)"
Write-Host "Cores: $($cpu.NumberOfCores)"
Write-Host "Logical Processors: $($cpu.NumberOfLogicalProcessors)"
Write-Host "Max Clock Speed: $($cpu.MaxClockSpeed) MHz"
Write-Host ""

# Disk Information
Write-Host "=== Disk Information ===" -ForegroundColor Cyan
Get-Volume | Where-Object {$_.DriveLetter -ne $null} | ForEach-Object {
    $percentFree = [math]::Round(($_.SizeRemaining / $_.Size) * 100, 2)
    Write-Host "Drive $($_.DriveLetter): $([math]::Round($_.SizeRemaining/1GB, 2)) GB free of $([math]::Round($_.Size/1GB, 2)) GB ($percentFree% free)"
}
Write-Host ""

# Network Adapters
Write-Host "=== Network Adapters ===" -ForegroundColor Cyan
Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | ForEach-Object {
    Write-Host "Adapter: $($_.Name) - $($_.InterfaceDescription)"
    Write-Host "Status: $($_.Status) - Speed: $($_.LinkSpeed)"
}
Write-Host ""

# IP Configuration
Write-Host "=== IP Configuration ===" -ForegroundColor Cyan
Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.InterfaceAlias -notlike "*Loopback*"} | ForEach-Object {
    Write-Host "Interface: $($_.InterfaceAlias)"
    Write-Host "IP Address: $($_.IPAddress)"
    Write-Host "Prefix Length: $($_.PrefixLength)"
    Write-Host ""
}

# Windows Update Status
Write-Host "=== Windows Update Status ===" -ForegroundColor Cyan
try {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $searchResult = $updateSearcher.Search("IsInstalled=0")
    Write-Host "Pending Updates: $($searchResult.Updates.Count)"
} catch {
    Write-Host "Unable to check Windows Update status (may require elevation)"
}
Write-Host ""

# System Uptime
Write-Host "=== System Uptime ===" -ForegroundColor Cyan
$uptime = (Get-Date) - $os.LastBootUpTime
Write-Host "Uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"
Write-Host ""

Write-Host "=========================================="
Write-Host "Report Complete"
Write-Host "=========================================="
