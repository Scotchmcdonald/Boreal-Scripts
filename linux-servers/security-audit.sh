#!/bin/bash
################################################################################
# Linux Security Audit Script
# Description: Performs basic security checks on Linux systems
# Author: Boreal IT Services
# Usage: sudo ./security-audit.sh
# Requirements: Root/sudo privileges for complete audit
################################################################################

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "WARNING: Not running as root. Some checks will be limited."
    echo "Run with sudo for complete audit."
    echo ""
fi

echo "=========================================="
echo "Linux Security Audit"
echo "=========================================="
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo ""

# Check for users with UID 0 (root privileges)
echo "=== Users with UID 0 (Root Privileges) ==="
awk -F: '($3 == 0) {print $1}' /etc/passwd
echo ""

# Check for users with empty passwords
echo "=== Users with Empty Passwords ==="
if [ "$EUID" -eq 0 ]; then
    awk -F: '($2 == "" ) {print $1 " has empty password!"}' /etc/shadow 2>/dev/null || echo "No users with empty passwords found"
else
    echo "Requires root privileges"
fi
echo ""

# Check for users with login shells
echo "=== Users with Login Shells ==="
grep -v '/nologin\|/false' /etc/passwd | grep -v '^#' | awk -F: '{print $1 " - " $7}'
echo ""

# SSH Configuration Checks
echo "=== SSH Security Configuration ==="
if [ -f /etc/ssh/sshd_config ]; then
    echo "Checking SSH configuration..."
    
    # Check PermitRootLogin
    root_login=$(grep "^PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}')
    if [ "$root_login" = "no" ]; then
        echo "✓ Root login: Disabled"
    else
        echo "✗ Root login: Enabled or default (consider disabling)"
    fi
    
    # Check PasswordAuthentication
    pass_auth=$(grep "^PasswordAuthentication" /etc/ssh/sshd_config | awk '{print $2}')
    if [ "$pass_auth" = "no" ]; then
        echo "✓ Password authentication: Disabled (key-based only)"
    else
        echo "! Password authentication: Enabled"
    fi
    
    # Check Port
    ssh_port=$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}')
    if [ -n "$ssh_port" ] && [ "$ssh_port" != "22" ]; then
        echo "✓ SSH Port: Changed from default ($ssh_port)"
    else
        echo "! SSH Port: Using default (22)"
    fi
else
    echo "SSH configuration file not found"
fi
echo ""

# Firewall Status
echo "=== Firewall Status ==="
if command -v ufw &> /dev/null; then
    echo "UFW Status:"
    sudo ufw status 2>/dev/null || ufw status 2>/dev/null || echo "Cannot check UFW status"
elif command -v firewall-cmd &> /dev/null; then
    echo "Firewalld Status:"
    sudo firewall-cmd --state 2>/dev/null || firewall-cmd --state 2>/dev/null || echo "Cannot check firewalld status"
else
    echo "No common firewall tool found (ufw/firewalld)"
fi
echo ""

# Failed login attempts
echo "=== Recent Failed Login Attempts ==="
if [ "$EUID" -eq 0 ]; then
    grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || \
    grep "Failed password" /var/log/secure 2>/dev/null | tail -5 || \
    echo "No recent failed attempts found or log not accessible"
else
    echo "Requires root privileges to check auth logs"
fi
echo ""

# Check for listening ports
echo "=== Listening Network Services ==="
if command -v ss &> /dev/null; then
    ss -tlnp | grep LISTEN | head -10
elif command -v netstat &> /dev/null; then
    netstat -tlnp | grep LISTEN | head -10
else
    echo "Neither ss nor netstat available"
fi
echo ""

# Check last system logins
echo "=== Recent System Logins ==="
last -n 10
echo ""

# Check for world-writable files (sample check in common directories)
echo "=== World-Writable Files Check (sample) ==="
if [ "$EUID" -eq 0 ]; then
    echo "Checking /etc for world-writable files..."
    find /etc -type f -perm -002 2>/dev/null | head -10 || echo "None found in /etc"
else
    echo "Requires root privileges for complete check"
fi
echo ""

# Check automatic updates status
echo "=== Automatic Updates ==="
if [ -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
    echo "Ubuntu/Debian unattended-upgrades configuration:"
    cat /etc/apt/apt.conf.d/20auto-upgrades 2>/dev/null | grep -E 'Update|Upgrade'
elif [ -f /etc/dnf/automatic.conf ]; then
    echo "DNF automatic updates configured"
else
    echo "Automatic updates status unknown"
fi
echo ""

echo "=========================================="
echo "Security Audit Complete"
echo "=========================================="
echo ""
echo "Recommendations:"
echo "1. Disable root SSH login if not needed"
echo "2. Use SSH key authentication instead of passwords"
echo "3. Keep system updated with security patches"
echo "4. Enable and configure firewall"
echo "5. Monitor failed login attempts"
echo "6. Regular security audits"
