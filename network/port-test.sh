#!/bin/bash
################################################################################
# Port Connectivity Test Script
# Description: Tests connectivity to specific ports on remote hosts
# Author: Boreal IT Services
# Usage: ./port-test.sh <hostname> <port1> [port2] [port3] ...
################################################################################

# Check if at least hostname and one port provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <hostname> <port1> [port2] [port3] ..."
    echo ""
    echo "Examples:"
    echo "  $0 google.com 80 443"
    echo "  $0 192.168.1.1 22 3389 80"
    echo "  $0 mail.example.com 25 587 993"
    exit 1
fi

HOST=$1
shift
PORTS=("$@")

echo "=========================================="
echo "Port Connectivity Test"
echo "=========================================="
echo "Target Host: $HOST"
echo "Date: $(date)"
echo ""

# Resolve hostname
echo "=== DNS Resolution ==="
IP=$(dig +short "$HOST" 2>/dev/null | head -1)
if [ -n "$IP" ]; then
    echo "✓ $HOST resolves to $IP"
else
    echo "! Could not resolve $HOST (testing anyway)"
fi
echo ""

# Test each port
echo "=== Port Tests ==="
for PORT in "${PORTS[@]}"; do
    echo -n "Testing $HOST:$PORT ... "
    
    # Try multiple methods
    if command -v nc &> /dev/null; then
        # Using netcat
        if timeout 3 nc -z "$HOST" "$PORT" 2>/dev/null; then
            echo "✓ OPEN"
        else
            echo "✗ CLOSED or FILTERED"
        fi
    elif command -v timeout &> /dev/null; then
        # Using bash TCP connection
        if timeout 3 bash -c "cat < /dev/null > /dev/tcp/$HOST/$PORT" 2>/dev/null; then
            echo "✓ OPEN"
        else
            echo "✗ CLOSED or FILTERED"
        fi
    else
        # Fallback to basic test
        if (echo > /dev/tcp/"$HOST"/"$PORT") 2>/dev/null; then
            echo "✓ OPEN"
        else
            echo "✗ CLOSED or FILTERED"
        fi
    fi
done

echo ""

# Additional information
echo "=== Common Port Reference ==="
echo "20/21   - FTP"
echo "22      - SSH"
echo "25      - SMTP"
echo "53      - DNS"
echo "80      - HTTP"
echo "110     - POP3"
echo "143     - IMAP"
echo "443     - HTTPS"
echo "587     - SMTP (submission)"
echo "993     - IMAPS"
echo "995     - POP3S"
echo "3306    - MySQL"
echo "3389    - RDP"
echo "5432    - PostgreSQL"
echo "8080    - HTTP Alternate"

echo ""
echo "=========================================="
echo "Test Complete"
echo "=========================================="
