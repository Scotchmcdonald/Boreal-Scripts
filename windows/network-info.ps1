################################################################################
# Windows Network Information Script
# Description: Displays detailed network configuration and connectivity
# Author: Boreal IT Services
# Usage: .\network-info.ps1
################################################################################

Write-Host "=========================================="
Write-Host "Windows Network Information"
Write-Host "=========================================="
Write-Host "Generated: $(Get-Date)"
Write-Host ""

# Network Adapters
Write-Host "=== Network Adapters ===" -ForegroundColor Cyan
Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress | Format-Table -AutoSize
Write-Host ""

# IP Configuration
Write-Host "=== IPv4 Configuration ===" -ForegroundColor Cyan
Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} |
    Select-Object InterfaceAlias, IPAddress, PrefixLength | 
    Format-Table -AutoSize
Write-Host ""

# Default Gateway
Write-Host "=== Default Gateway ===" -ForegroundColor Cyan
Get-NetRoute -AddressFamily IPv4 | 
    Where-Object {$_.DestinationPrefix -eq "0.0.0.0/0"} |
    Select-Object InterfaceAlias, NextHop, RouteMetric |
    Format-Table -AutoSize
Write-Host ""

# DNS Servers
Write-Host "=== DNS Servers ===" -ForegroundColor Cyan
Get-DnsClientServerAddress -AddressFamily IPv4 | 
    Where-Object {$_.ServerAddresses.Count -gt 0} |
    Select-Object InterfaceAlias, ServerAddresses |
    Format-Table -AutoSize
Write-Host ""

# Connectivity Tests
Write-Host "=== Connectivity Tests ===" -ForegroundColor Cyan
$targets = @(
    @{Name="Internet (Google DNS)"; Address="8.8.8.8"},
    @{Name="Cloudflare DNS"; Address="1.1.1.1"},
    @{Name="Google.com"; Address="google.com"}
)

foreach ($target in $targets) {
    Write-Host "Testing: $($target.Name)" -NoNewline
    $result = Test-Connection -ComputerName $target.Address -Count 2 -Quiet
    if ($result) {
        Write-Host " - OK" -ForegroundColor Green
    } else {
        Write-Host " - FAILED" -ForegroundColor Red
    }
}
Write-Host ""

# DNS Resolution Test
Write-Host "=== DNS Resolution ===" -ForegroundColor Cyan
$dnsTest = @("google.com", "microsoft.com", "github.com")
foreach ($domain in $dnsTest) {
    Write-Host "Resolving: $domain" -NoNewline
    try {
        $result = Resolve-DnsName -Name $domain -Type A -ErrorAction Stop
        Write-Host " - $($result[0].IPAddress)" -ForegroundColor Green
    } catch {
        Write-Host " - FAILED" -ForegroundColor Red
    }
}
Write-Host ""

# Active Connections
Write-Host "=== Active TCP Connections (Top 10) ===" -ForegroundColor Cyan
Get-NetTCPConnection -State Established | 
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State -First 10 |
    Format-Table -AutoSize
Write-Host ""

# Firewall Status
Write-Host "=== Windows Firewall Status ===" -ForegroundColor Cyan
try {
    Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize
} catch {
    Write-Host "Unable to retrieve firewall status"
}
Write-Host ""

Write-Host "=========================================="
Write-Host "Report Complete"
Write-Host "=========================================="
