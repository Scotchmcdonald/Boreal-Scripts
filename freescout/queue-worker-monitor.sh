#!/bin/bash
################################################################################
# Freescout Queue Worker Monitor Script
# Description: Monitors and manages Freescout queue workers
# Author: Boreal IT Services
# Usage: ./queue-worker-monitor.sh [start|stop|restart|status]
# Requirements: Freescout installation with supervisor
################################################################################

FREESCOUT_PATH="/var/www/freescout"
QUEUE_WORKER_NAME="freescout-queue-worker"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Freescout Queue Worker Monitor"
echo "=========================================="
echo ""

# Function to check if supervisor is installed
check_supervisor() {
    if ! command -v supervisorctl &> /dev/null; then
        echo -e "${RED}Error: Supervisor is not installed${NC}"
        echo "Install with: sudo apt-get install supervisor"
        exit 1
    fi
}

# Function to check queue worker status
check_status() {
    echo "=== Queue Worker Status ==="
    
    # Check supervisor status
    if command -v supervisorctl &> /dev/null; then
        sudo supervisorctl status | grep -i queue || echo "No queue workers found in supervisor"
    fi
    echo ""
    
    # Check running queue processes
    echo "=== Running Queue Processes ==="
    ps aux | grep -i "queue:work" | grep -v grep || echo "No queue:work processes found"
    echo ""
    
    # Check queue size
    if [ -d "$FREESCOUT_PATH" ]; then
        echo "=== Queue Information ==="
        cd "$FREESCOUT_PATH"
        sudo -u www-data php artisan queue:work --once 2>&1 | head -5 || echo "Unable to check queue"
    fi
}

# Function to start queue worker
start_worker() {
    echo "=== Starting Queue Worker ==="
    check_supervisor
    
    if sudo supervisorctl start "$QUEUE_WORKER_NAME" 2>/dev/null; then
        echo -e "${GREEN}✓ Queue worker started${NC}"
    else
        echo -e "${YELLOW}Starting manually...${NC}"
        cd "$FREESCOUT_PATH"
        sudo -u www-data php artisan queue:work --daemon &
        echo -e "${GREEN}✓ Queue worker started manually${NC}"
    fi
}

# Function to stop queue worker
stop_worker() {
    echo "=== Stopping Queue Worker ==="
    check_supervisor
    
    if sudo supervisorctl stop "$QUEUE_WORKER_NAME" 2>/dev/null; then
        echo -e "${GREEN}✓ Queue worker stopped${NC}"
    else
        echo -e "${YELLOW}Stopping manually...${NC}"
        pkill -f "queue:work" || echo "No queue workers to stop"
        echo -e "${GREEN}✓ Queue workers stopped${NC}"
    fi
}

# Function to restart queue worker
restart_worker() {
    echo "=== Restarting Queue Worker ==="
    check_supervisor
    
    if sudo supervisorctl restart "$QUEUE_WORKER_NAME" 2>/dev/null; then
        echo -e "${GREEN}✓ Queue worker restarted${NC}"
    else
        stop_worker
        sleep 2
        start_worker
    fi
}

# Main logic
case "${1:-status}" in
    start)
        start_worker
        ;;
    stop)
        stop_worker
        ;;
    restart)
        restart_worker
        ;;
    status)
        check_status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the queue worker"
        echo "  stop    - Stop the queue worker"
        echo "  restart - Restart the queue worker"
        echo "  status  - Check queue worker status (default)"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Operation Complete"
echo "=========================================="
