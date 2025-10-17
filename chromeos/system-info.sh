#!/bin/bash
################################################################################
# ChromeOS System Information Script
# Description: Gathers comprehensive system information from ChromeOS devices
# Author: Boreal IT Services
# Usage: ./system-info.sh
################################################################################

set -e

echo "=========================================="
echo "ChromeOS System Information Report"
echo "=========================================="
echo "Date: $(date)"
echo ""

# System Information
echo "=== System Information ==="
if [ -f /etc/lsb-release ]; then
    cat /etc/lsb-release
fi
echo ""

# Hardware Information
echo "=== Hardware Information ==="
echo "CPU: $(lscpu | grep 'Model name' | cut -d ':' -f 2 | xargs)"
echo "CPU Cores: $(nproc)"
echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo ""

# Disk Usage
echo "=== Disk Usage ==="
df -h | grep -E '^/dev/|Filesystem'
echo ""

# Network Configuration
echo "=== Network Configuration ==="
ip addr show | grep -E 'inet |^[0-9]'
echo ""

# Active Network Connections
echo "=== Active Connections ==="
ss -tuln | head -10
echo ""

# Chrome Version (if accessible)
echo "=== Chrome Browser ==="
if command -v google-chrome &> /dev/null; then
    google-chrome --version 2>/dev/null || echo "Chrome version not accessible"
else
    echo "Chrome not found in PATH"
fi
echo ""

# Uptime
echo "=== System Uptime ==="
uptime
echo ""

echo "=========================================="
echo "Report Complete"
echo "=========================================="
