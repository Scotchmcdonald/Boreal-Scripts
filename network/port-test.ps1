################################################################################
# Port Connectivity Test Script (PowerShell)
# Description: Tests connectivity to specific ports on remote hosts
# Author: Boreal IT Services
# Usage: .\port-test.ps1 -HostName "example.com" -Ports 80,443,22
################################################################################

param(
    [Parameter(Mandatory=$true)]
    [string]$HostName,
    
    [Parameter(Mandatory=$true)]
    [int[]]$Ports,
    
    [Parameter(Mandatory=$false)]
    [int]$Timeout = 3000
)

Write-Host "=========================================="
Write-Host "Port Connectivity Test"
Write-Host "=========================================="
Write-Host "Target Host: $HostName"
Write-Host "Date: $(Get-Date)"
Write-Host ""

# DNS Resolution
Write-Host "=== DNS Resolution ===" -ForegroundColor Cyan
try {
    $ipAddress = [System.Net.Dns]::GetHostAddresses($HostName) | Select-Object -First 1
    Write-Host "✓ $HostName resolves to $($ipAddress.IPAddressToString)" -ForegroundColor Green
} catch {
    Write-Host "! Could not resolve $HostName" -ForegroundColor Yellow
    Write-Host "Continuing with hostname..."
}
Write-Host ""

# Test each port
Write-Host "=== Port Tests ===" -ForegroundColor Cyan
foreach ($port in $Ports) {
    Write-Host "Testing ${HostName}:${port} ... " -NoNewline
    
    try {
        $connection = Test-NetConnection -ComputerName $HostName -Port $port -WarningAction SilentlyContinue
        
        if ($connection.TcpTestSucceeded) {
            Write-Host "✓ OPEN" -ForegroundColor Green
        } else {
            Write-Host "✗ CLOSED or FILTERED" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# Additional information
Write-Host "=== Common Port Reference ===" -ForegroundColor Cyan
$commonPorts = @{
    20 = "FTP Data"
    21 = "FTP Control"
    22 = "SSH"
    25 = "SMTP"
    53 = "DNS"
    80 = "HTTP"
    110 = "POP3"
    143 = "IMAP"
    443 = "HTTPS"
    587 = "SMTP Submission"
    993 = "IMAPS"
    995 = "POP3S"
    3306 = "MySQL"
    3389 = "RDP"
    5432 = "PostgreSQL"
    8080 = "HTTP Alternate"
}

foreach ($port in $Ports) {
    if ($commonPorts.ContainsKey($port)) {
        Write-Host "$port - $($commonPorts[$port])"
    }
}

Write-Host ""
Write-Host "=========================================="
Write-Host "Test Complete"
Write-Host "=========================================="
