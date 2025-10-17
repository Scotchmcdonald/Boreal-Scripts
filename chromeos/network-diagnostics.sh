#!/bin/bash
################################################################################
# ChromeOS Network Diagnostics Script
# Description: Performs comprehensive network diagnostics
# Author: Boreal IT Services
# Usage: ./network-diagnostics.sh
################################################################################

set -e

echo "=========================================="
echo "Network Diagnostics for ChromeOS"
echo "=========================================="
echo "Date: $(date)"
echo ""

# Check internet connectivity
echo "=== Internet Connectivity ==="
if ping -c 4 8.8.8.8 &> /dev/null; then
    echo "✓ Internet connectivity: OK"
else
    echo "✗ Internet connectivity: FAILED"
fi
echo ""

# DNS Resolution Test
echo "=== DNS Resolution ==="
if nslookup google.com &> /dev/null; then
    echo "✓ DNS resolution: OK"
    nslookup google.com | grep -A 2 "Name:"
else
    echo "✗ DNS resolution: FAILED"
fi
echo ""

# Gateway Test
echo "=== Default Gateway ==="
gateway=$(ip route | grep default | awk '{print $3}' | head -1)
if [ -n "$gateway" ]; then
    echo "Default Gateway: $gateway"
    if ping -c 3 "$gateway" &> /dev/null; then
        echo "✓ Gateway reachable: OK"
    else
        echo "✗ Gateway unreachable: FAILED"
    fi
else
    echo "✗ No default gateway found"
fi
echo ""

# Network Interface Status
echo "=== Network Interfaces ==="
ip link show | grep -E '^[0-9]|state'
echo ""

# Active DNS Servers
echo "=== DNS Servers ==="
if [ -f /etc/resolv.conf ]; then
    grep nameserver /etc/resolv.conf
else
    echo "Cannot read DNS configuration"
fi
echo ""

# Latency Test
echo "=== Latency Tests ==="
echo "Testing latency to common servers..."
for host in google.com cloudflare.com 1.1.1.1; do
    echo -n "$host: "
    ping -c 3 -q "$host" 2>/dev/null | grep 'rtt' | awk -F'/' '{print "avg " $5 "ms"}' || echo "Failed"
done
echo ""

echo "=========================================="
echo "Diagnostics Complete"
echo "=========================================="
