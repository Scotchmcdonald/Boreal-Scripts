#!/bin/bash
################################################################################
# Automated Backup Script
# Description: Comprehensive backup with rotation and verification
# Author: Boreal IT Services
# Usage: ./automated-backup.sh
# Requirements: tar, rsync (optional)
################################################################################

# Configuration
BACKUP_SOURCE="/home /etc /var/www"
BACKUP_DEST="/var/backups/automated"
BACKUP_NAME="system-backup"
RETENTION_DAYS=7
NOTIFICATION_EMAIL=""  # Set email for notifications

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Log file
LOG_FILE="/var/log/automated-backup.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

echo "=========================================="
echo "Automated Backup Script"
echo "=========================================="
log_message "Backup started"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}Warning: Not running as root. Some files may not be accessible.${NC}"
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DEST"

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DEST}/${BACKUP_NAME}_${TIMESTAMP}.tar.gz"

# Calculate space needed (rough estimate)
echo ""
echo "=== Pre-Backup Checks ==="
log_message "Running pre-backup checks"

for source in $BACKUP_SOURCE; do
    if [ -d "$source" ]; then
        size=$(du -sh "$source" 2>/dev/null | cut -f1)
        echo "Source $source: $size"
    else
        echo -e "${YELLOW}Warning: Source $source not found${NC}"
        log_message "Warning: Source $source not found"
    fi
done

# Check available space
avail_space=$(df -h "$BACKUP_DEST" | awk 'NR==2 {print $4}')
echo "Available space at destination: $avail_space"
echo ""

# Create backup
echo "=== Creating Backup ==="
log_message "Creating backup: $BACKUP_FILE"
echo "Backup file: $BACKUP_FILE"
echo "This may take several minutes..."

# Perform backup with exclusions
tar -czf "$BACKUP_FILE" \
    --exclude='*.tmp' \
    --exclude='*.cache' \
    --exclude='*/cache/*' \
    --exclude='*/logs/*' \
    --exclude='*/tmp/*' \
    $BACKUP_SOURCE 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Backup created successfully${NC}"
    log_message "Backup created successfully"
    
    # Get backup size
    backup_size=$(du -sh "$BACKUP_FILE" | cut -f1)
    echo "Backup size: $backup_size"
    log_message "Backup size: $backup_size"
else
    echo -e "${RED}✗ Backup failed${NC}"
    log_message "ERROR: Backup failed"
    exit 1
fi

echo ""

# Verify backup
echo "=== Verifying Backup ==="
log_message "Verifying backup integrity"

if tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Backup verification passed${NC}"
    log_message "Backup verification passed"
else
    echo -e "${RED}✗ Backup verification failed${NC}"
    log_message "ERROR: Backup verification failed"
    exit 1
fi

echo ""

# Create checksum
echo "=== Creating Checksum ==="
sha256sum "$BACKUP_FILE" > "${BACKUP_FILE}.sha256"
echo -e "${GREEN}✓ Checksum created${NC}"
log_message "Checksum created"

echo ""

# Cleanup old backups
echo "=== Cleaning Old Backups ==="
log_message "Cleaning backups older than $RETENTION_DAYS days"

find "$BACKUP_DEST" -name "${BACKUP_NAME}_*.tar.gz" -type f -mtime +$RETENTION_DAYS -exec rm -f {} \;
find "$BACKUP_DEST" -name "${BACKUP_NAME}_*.sha256" -type f -mtime +$RETENTION_DAYS -exec rm -f {} \;

remaining_backups=$(find "$BACKUP_DEST" -name "${BACKUP_NAME}_*.tar.gz" | wc -l)
echo "Remaining backups: $remaining_backups"
log_message "Cleanup complete. Remaining backups: $remaining_backups"

echo ""

# Summary
echo "=========================================="
echo "Backup Summary"
echo "=========================================="
echo "Status: SUCCESS"
echo "Backup File: $BACKUP_FILE"
echo "Backup Size: $backup_size"
echo "Retention: $RETENTION_DAYS days"
echo "Total Backups: $remaining_backups"
echo ""

log_message "Backup completed successfully"

# Send notification if email configured
if [ -n "$NOTIFICATION_EMAIL" ] && command -v mail &> /dev/null; then
    echo "Backup completed successfully at $(date)" | mail -s "Backup Success - $(hostname)" "$NOTIFICATION_EMAIL"
fi

echo "=========================================="
echo "Backup Complete!"
echo "=========================================="
