#!/bin/bash
################################################################################
# DNS Check Script
# Description: Verifies DNS resolution and configuration
# Author: Boreal IT Services
# Usage: ./dns-check.sh [domain1] [domain2] ...
################################################################################

# Default domains to test if none provided
if [ $# -eq 0 ]; then
    DOMAINS=("google.com" "github.com" "microsoft.com")
else
    DOMAINS=("$@")
fi

echo "=========================================="
echo "DNS Configuration and Resolution Check"
echo "=========================================="
echo "Date: $(date)"
echo ""

# Display DNS configuration
echo "=== DNS Configuration ==="
if [ -f /etc/resolv.conf ]; then
    echo "DNS Servers:"
    grep nameserver /etc/resolv.conf | awk '{print "  " $2}'
    
    if grep -q "search\|domain" /etc/resolv.conf; then
        echo ""
        echo "Search Domains:"
        grep -E "^search|^domain" /etc/resolv.conf | awk '{$1=""; print "  " $0}'
    fi
else
    echo "Cannot read /etc/resolv.conf"
fi
echo ""

# Test DNS resolution for each domain
echo "=== DNS Resolution Tests ==="
for domain in "${DOMAINS[@]}"; do
    echo "Testing: $domain"
    
    # Using nslookup
    if command -v nslookup &> /dev/null; then
        result=$(nslookup "$domain" 2>&1)
        if echo "$result" | grep -q "NXDOMAIN\|server can't find"; then
            echo "  ✗ Resolution FAILED"
        else
            ip=$(echo "$result" | grep -A 1 "Name:" | grep "Address:" | awk '{print $2}' | head -1)
            if [ -n "$ip" ]; then
                echo "  ✓ Resolves to: $ip"
            else
                echo "  ! Resolution unclear"
            fi
        fi
    fi
    
    # Using dig if available
    if command -v dig &> /dev/null; then
        query_time=$(dig +noall +stats "$domain" | grep "Query time:" | awk '{print $4}')
        if [ -n "$query_time" ]; then
            echo "  Query time: ${query_time}ms"
        fi
    fi
    
    echo ""
done

# Test different DNS servers
echo "=== Testing Against Public DNS Servers ==="
test_domain="${DOMAINS[0]}"

public_dns=(
    "8.8.8.8 (Google)"
    "1.1.1.1 (Cloudflare)"
    "208.67.222.222 (OpenDNS)"
)

for dns_entry in "${public_dns[@]}"; do
    dns_ip=$(echo "$dns_entry" | awk '{print $1}')
    dns_name=$(echo "$dns_entry" | awk '{print $2}')
    
    echo -n "Testing $dns_name: "
    
    if command -v nslookup &> /dev/null; then
        result=$(nslookup "$test_domain" "$dns_ip" 2>&1)
        if echo "$result" | grep -q "NXDOMAIN\|server can't find"; then
            echo "✗ FAILED"
        else
            echo "✓ OK"
        fi
    else
        echo "! nslookup not available"
    fi
done

echo ""

# Check for DNS cache
echo "=== DNS Cache Status ==="
if command -v systemctl &> /dev/null; then
    if systemctl is-active --quiet systemd-resolved; then
        echo "systemd-resolved is running"
        if command -v resolvectl &> /dev/null; then
            echo ""
            echo "Statistics:"
            resolvectl statistics 2>/dev/null | head -10
        fi
    else
        echo "systemd-resolved is not running"
    fi
else
    echo "Cannot determine DNS cache status"
fi

echo ""
echo "=========================================="
echo "DNS Check Complete"
echo "=========================================="
