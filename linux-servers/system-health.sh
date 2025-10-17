#!/bin/bash
################################################################################
# Linux System Health Check Script
# Description: Comprehensive system health monitoring for Linux servers
# Author: Boreal IT Services
# Usage: ./system-health.sh
# Requirements: Standard Linux utilities
################################################################################

set -e

echo "=========================================="
echo "Linux System Health Check"
echo "=========================================="
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo ""

# System Information
echo "=== System Information ===" 
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Uptime: $(uptime -p)"
echo ""

# CPU Usage
echo "=== CPU Usage ==="
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "CPU Usage: " 100 - $1 "%"}'
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo "CPU Cores: $(nproc)"
echo ""

# Memory Usage
echo "=== Memory Usage ==="
free -h | awk 'NR==2{printf "Total: %s\nUsed: %s (%.2f%%)\nFree: %s\n", $2, $3, $3*100/$2, $4}'
echo ""

# Disk Usage
echo "=== Disk Usage ==="
df -h | grep -vE '^tmpfs|^devtmpfs|^udev' | awk 'NR==1 || /^\/dev\// {print $0}'
echo ""

# Check for disks over 80% full
echo "=== Disk Space Warnings ==="
df -h | grep -vE '^tmpfs|^devtmpfs|^udev|^Filesystem' | awk '{if($5+0 > 80) print "WARNING: " $1 " is " $5 " full"}'
df -h | grep -vE '^tmpfs|^devtmpfs|^udev|^Filesystem' | awk '{if($5+0 <= 80) count++} END {if(count > 0 || NR == 0) print "All disks below 80% threshold"}'
echo ""

# Network Information
echo "=== Network Interfaces ==="
ip -brief addr show | grep -v '^lo'
echo ""

# Service Status
echo "=== Critical Services Status ==="
services=("sshd" "ssh" "cron" "rsyslog" "systemd-journald")
for service in "${services[@]}"; do
    if systemctl list-unit-files | grep -q "^${service}.service"; then
        status=$(systemctl is-active "$service" 2>/dev/null || echo "not-found")
        if [ "$status" = "active" ]; then
            echo "✓ $service: running"
        else
            echo "✗ $service: $status"
        fi
    fi
done
echo ""

# Failed Services
echo "=== Failed Services ==="
failed_services=$(systemctl list-units --failed --no-pager --no-legend | wc -l)
if [ "$failed_services" -eq 0 ]; then
    echo "No failed services"
else
    echo "WARNING: $failed_services failed service(s) detected:"
    systemctl list-units --failed --no-pager --no-legend
fi
echo ""

# Last Logins
echo "=== Recent Logins ==="
last -n 5 | head -n 5
echo ""

# Top Processes by CPU
echo "=== Top 5 Processes by CPU ==="
ps aux --sort=-%cpu | head -6
echo ""

# Top Processes by Memory
echo "=== Top 5 Processes by Memory ==="
ps aux --sort=-%mem | head -6
echo ""

# Security - Check for available updates
echo "=== System Updates ==="
if command -v apt &> /dev/null; then
    echo "Checking for updates (Debian/Ubuntu)..."
    apt list --upgradable 2>/dev/null | grep -c upgradable || echo "Update check requires sudo"
elif command -v yum &> /dev/null; then
    echo "Checking for updates (RHEL/CentOS)..."
    yum check-update --quiet 2>/dev/null | wc -l || echo "Update check requires sudo"
fi
echo ""

echo "=========================================="
echo "Health Check Complete"
echo "=========================================="
