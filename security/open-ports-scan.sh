#!/bin/bash
################################################################################
# Open Ports Scan Script
# Description: Scans for open ports and listening services
# Author: Boreal IT Services
# Usage: ./open-ports-scan.sh
# Requirements: ss or netstat
################################################################################

echo "=========================================="
echo "Open Ports and Listening Services Scan"
echo "=========================================="
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo ""

# Check for required tools
if command -v ss &> /dev/null; then
    TOOL="ss"
elif command -v netstat &> /dev/null; then
    TOOL="netstat"
else
    echo "Error: Neither 'ss' nor 'netstat' found"
    exit 1
fi

# TCP Listening Ports
echo "=== TCP Listening Ports ==="
echo "Proto | Local Address          | Process"
echo "------|------------------------|----------"

if [ "$TOOL" = "ss" ]; then
    sudo ss -tlnp | grep LISTEN | awk '{print $1 " | " $4 " | " $6}' | column -t
else
    sudo netstat -tlnp | grep LISTEN | awk '{print $1 " | " $4 " | " $7}' | column -t
fi
echo ""

# UDP Listening Ports
echo "=== UDP Listening Ports ==="
echo "Proto | Local Address          | Process"
echo "------|------------------------|----------"

if [ "$TOOL" = "ss" ]; then
    sudo ss -ulnp | awk 'NR>1 {print $1 " | " $4 " | " $6}' | column -t | head -20
else
    sudo netstat -ulnp | awk 'NR>2 {print $1 " | " $4 " | " $6}' | column -t | head -20
fi
echo ""

# Summary by port number
echo "=== Common Port Identification ==="
if [ "$TOOL" = "ss" ]; then
    ports=$(sudo ss -tlnp | grep LISTEN | awk '{print $4}' | awk -F: '{print $NF}' | sort -n | uniq)
else
    ports=$(sudo netstat -tlnp | grep LISTEN | awk '{print $4}' | awk -F: '{print $NF}' | sort -n | uniq)
fi

for port in $ports; do
    case $port in
        20|21) service="FTP" ;;
        22) service="SSH" ;;
        23) service="Telnet" ;;
        25) service="SMTP" ;;
        53) service="DNS" ;;
        80) service="HTTP" ;;
        110) service="POP3" ;;
        143) service="IMAP" ;;
        443) service="HTTPS" ;;
        465) service="SMTPS" ;;
        587) service="SMTP (submission)" ;;
        993) service="IMAPS" ;;
        995) service="POP3S" ;;
        3306) service="MySQL" ;;
        3389) service="RDP" ;;
        5432) service="PostgreSQL" ;;
        6379) service="Redis" ;;
        8080) service="HTTP Alt" ;;
        9000) service="PHP-FPM" ;;
        *) service="Unknown" ;;
    esac
    
    printf "Port %-6s - %s\n" "$port" "$service"
done

echo ""

# Security Recommendations
echo "=== Security Recommendations ==="
echo "1. Close unnecessary ports"
echo "2. Use firewall to restrict access"
echo "3. Disable unused services"
echo "4. Use secure protocols (SSH instead of Telnet, HTTPS instead of HTTP)"
echo "5. Restrict services to localhost when possible"
echo "6. Keep services updated"
echo ""

# Check for potentially risky open ports
echo "=== Security Alerts ==="
risky_found=0

if echo "$ports" | grep -q "^23$"; then
    echo "⚠️  WARNING: Telnet (port 23) is open - USE SSH INSTEAD"
    risky_found=1
fi

if echo "$ports" | grep -q "^21$"; then
    echo "⚠️  WARNING: FTP (port 21) is open - Consider SFTP/FTPS instead"
    risky_found=1
fi

if echo "$ports" | grep -qE "^3306$|^5432$|^6379$"; then
    echo "⚠️  WARNING: Database port exposed - Should be firewalled"
    risky_found=1
fi

if [ $risky_found -eq 0 ]; then
    echo "No immediate security concerns detected"
fi

echo ""
echo "=========================================="
echo "Scan Complete"
echo "=========================================="
