#!/bin/bash
################################################################################
# Comprehensive System Report Script
# Description: Generates a complete system report
# Author: Boreal IT Services
# Usage: ./system-report.sh [output-file]
################################################################################

OUTPUT_FILE="${1:-system-report-$(date +%Y%m%d_%H%M%S).txt}"

echo "=========================================="
echo "Comprehensive System Report Generator"
echo "=========================================="
echo "Generating report: $OUTPUT_FILE"
echo ""

# Function to add section to report
add_section() {
    local title="$1"
    local command="$2"
    
    echo "" >> "$OUTPUT_FILE"
    echo "========================================" >> "$OUTPUT_FILE"
    echo "$title" >> "$OUTPUT_FILE"
    echo "========================================" >> "$OUTPUT_FILE"
    eval "$command" >> "$OUTPUT_FILE" 2>&1
}

# Start report
cat > "$OUTPUT_FILE" << EOF
================================================================================
                        SYSTEM REPORT
================================================================================
Generated: $(date)
Hostname: $(hostname)
User: $(whoami)
================================================================================

EOF

# System Information
add_section "SYSTEM INFORMATION" "cat /etc/os-release 2>/dev/null || echo 'OS info not available'"
add_section "KERNEL VERSION" "uname -a"
add_section "SYSTEM UPTIME" "uptime"

# Hardware Information
add_section "CPU INFORMATION" "lscpu 2>/dev/null || echo 'lscpu not available'"
add_section "MEMORY INFORMATION" "free -h"
add_section "DISK INFORMATION" "df -h"

# Network Information
add_section "NETWORK INTERFACES" "ip addr show 2>/dev/null || ifconfig"
add_section "ROUTING TABLE" "ip route 2>/dev/null || route -n"
add_section "DNS CONFIGURATION" "cat /etc/resolv.conf"
add_section "LISTENING PORTS" "ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null || echo 'Port info requires sudo'"

# Process Information
add_section "TOP PROCESSES BY CPU" "ps aux --sort=-%cpu | head -11"
add_section "TOP PROCESSES BY MEMORY" "ps aux --sort=-%mem | head -11"

# System Services
add_section "FAILED SERVICES" "systemctl list-units --failed 2>/dev/null || echo 'systemctl not available'"

# User Information
add_section "LOGGED IN USERS" "who"
add_section "LAST LOGINS" "last -n 10"
add_section "USER ACCOUNTS" "cat /etc/passwd | grep -v nologin | grep -v false"

# Security Information
add_section "FIREWALL STATUS" "sudo ufw status 2>/dev/null || sudo firewall-cmd --state 2>/dev/null || echo 'Firewall status requires sudo'"

# Package Information
if command -v dpkg &> /dev/null; then
    add_section "INSTALLED PACKAGES (Debian/Ubuntu)" "dpkg -l | wc -l"
elif command -v rpm &> /dev/null; then
    add_section "INSTALLED PACKAGES (RHEL/CentOS)" "rpm -qa | wc -l"
fi

# Disk Usage Details
add_section "LARGEST DIRECTORIES IN /" "du -h --max-depth=1 / 2>/dev/null | sort -rh | head -10"

# System Logs (last 20 lines)
add_section "RECENT SYSTEM MESSAGES" "tail -20 /var/log/syslog 2>/dev/null || tail -20 /var/log/messages 2>/dev/null || echo 'Log files require sudo'"

# Environment Variables
add_section "ENVIRONMENT VARIABLES" "env | sort"

# End report
cat >> "$OUTPUT_FILE" << EOF

================================================================================
                        END OF REPORT
================================================================================
Generated: $(date)
Report Size: $(du -h "$OUTPUT_FILE" | cut -f1)
================================================================================
EOF

# Display summary
echo "Report generated successfully!"
echo ""
echo "Report Details:"
echo "  File: $OUTPUT_FILE"
echo "  Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo "  Lines: $(wc -l < "$OUTPUT_FILE")"
echo ""
echo "View report with: cat $OUTPUT_FILE"
echo "                  less $OUTPUT_FILE"
echo "                  nano $OUTPUT_FILE"
