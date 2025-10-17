#!/bin/bash
################################################################################
# Service Monitor Script
# Description: Monitors critical services and restarts if needed
# Author: Boreal IT Services
# Usage: ./service-monitor.sh
# Requirements: systemctl, service management permissions
################################################################################

# Configuration
SERVICES=("sshd" "nginx" "mysql" "cron")
LOG_FILE="/var/log/service-monitor.log"
RESTART_ATTEMPTS=3
NOTIFICATION_EMAIL=""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to send notification
send_notification() {
    local subject="$1"
    local message="$2"
    
    if [ -n "$NOTIFICATION_EMAIL" ] && command -v mail &> /dev/null; then
        echo "$message" | mail -s "$subject" "$NOTIFICATION_EMAIL"
    fi
}

echo "=========================================="
echo "Service Monitor"
echo "=========================================="
echo "Date: $(date)"
echo ""

log_message "Service monitor check started"

# Check each service
for service in "${SERVICES[@]}"; do
    echo "Checking service: $service"
    
    # Check if service exists
    if ! systemctl list-unit-files | grep -q "^${service}.service"; then
        echo -e "${YELLOW}  ! Service $service not found on system${NC}"
        log_message "Service $service not found on system"
        continue
    fi
    
    # Check service status
    if systemctl is-active --quiet "$service"; then
        echo -e "${GREEN}  ✓ $service is running${NC}"
        log_message "$service is running - OK"
    else
        echo -e "${RED}  ✗ $service is NOT running${NC}"
        log_message "WARNING: $service is NOT running"
        
        # Attempt to restart
        echo "  Attempting to restart $service..."
        
        for attempt in $(seq 1 $RESTART_ATTEMPTS); do
            sudo systemctl restart "$service"
            sleep 2
            
            if systemctl is-active --quiet "$service"; then
                echo -e "${GREEN}  ✓ $service restarted successfully (attempt $attempt)${NC}"
                log_message "$service restarted successfully (attempt $attempt)"
                
                send_notification \
                    "Service Restart: $service on $(hostname)" \
                    "Service $service was down and has been restarted successfully on attempt $attempt"
                
                break
            else
                echo -e "${RED}  ✗ Restart attempt $attempt failed${NC}"
                log_message "Restart attempt $attempt failed for $service"
                
                if [ $attempt -eq $RESTART_ATTEMPTS ]; then
                    echo -e "${RED}  ✗ Failed to restart $service after $RESTART_ATTEMPTS attempts${NC}"
                    log_message "CRITICAL: Failed to restart $service after $RESTART_ATTEMPTS attempts"
                    
                    send_notification \
                        "CRITICAL: Service Failed - $service on $(hostname)" \
                        "Service $service is down and could not be restarted after $RESTART_ATTEMPTS attempts. Manual intervention required."
                fi
            fi
        done
    fi
    
    echo ""
done

# Summary
echo "=========================================="
echo "Monitor Check Complete"
echo "=========================================="
log_message "Service monitor check completed"
