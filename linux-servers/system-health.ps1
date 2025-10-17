################################################################################
# Linux System Health Check Script (PowerShell version)
# Description: Check Linux system health via PowerShell SSH
# Author: Boreal IT Services
# Usage: .\system-health.ps1 -HostName "server.example.com" -UserName "admin"
# Requirements: PowerShell 7+ with SSH configured
################################################################################

param(
    [Parameter(Mandatory=$false)]
    [string]$HostName = "localhost",
    
    [Parameter(Mandatory=$false)]
    [string]$UserName = $env:USER
)

Write-Host "=========================================="
Write-Host "Linux System Health Check (via PowerShell)"
Write-Host "=========================================="
Write-Host "Target Host: $HostName"
Write-Host "Date: $(Get-Date)"
Write-Host ""

# Function to execute SSH command
function Invoke-SSHCommand {
    param([string]$Command)
    
    if ($HostName -eq "localhost") {
        # Running on local Linux system with PowerShell
        bash -c $Command
    } else {
        # Remote SSH execution
        ssh "${UserName}@${HostName}" $Command
    }
}

# System Information
Write-Host "=== System Information ===" -ForegroundColor Cyan
Invoke-SSHCommand "uname -a"
Write-Host ""

# Uptime
Write-Host "=== System Uptime ===" -ForegroundColor Cyan
Invoke-SSHCommand "uptime"
Write-Host ""

# Memory Usage
Write-Host "=== Memory Usage ===" -ForegroundColor Cyan
Invoke-SSHCommand "free -h"
Write-Host ""

# Disk Usage
Write-Host "=== Disk Usage ===" -ForegroundColor Cyan
Invoke-SSHCommand "df -h | grep -vE 'tmpfs|devtmpfs'"
Write-Host ""

# Top Processes
Write-Host "=== Top 5 Processes by Memory ===" -ForegroundColor Cyan
Invoke-SSHCommand "ps aux --sort=-%mem | head -6"
Write-Host ""

# Service Status
Write-Host "=== Failed Services ===" -ForegroundColor Cyan
Invoke-SSHCommand "systemctl list-units --failed --no-pager"
Write-Host ""

Write-Host "=========================================="
Write-Host "Health Check Complete"
Write-Host "=========================================="
