#!/bin/bash
################################################################################
# Freescout Backup Script
# Description: Complete backup of Freescout installation
# Author: Boreal IT Services
# Usage: sudo ./backup-freescout.sh
# Requirements: Root/sudo privileges, MySQL/MariaDB access
################################################################################

# Configuration - Modify these variables for your installation
FREESCOUT_PATH="/var/www/freescout"
BACKUP_BASE_DIR="/var/backups/freescout"
DB_NAME="freescout"
DB_USER="freescout"
DB_PASS=""  # Leave empty to prompt or use .my.cnf
RETENTION_DAYS=30

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Freescout Backup Script"
echo "=========================================="
echo "Started: $(date)"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

# Verify Freescout directory exists
if [ ! -d "$FREESCOUT_PATH" ]; then
    echo -e "${RED}Error: Freescout directory not found: $FREESCOUT_PATH${NC}"
    exit 1
fi

# Create backup directory structure
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE_DIR/$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

echo -e "${GREEN}Creating backup in: $BACKUP_DIR${NC}"
echo ""

# Step 1: Put Freescout in maintenance mode
echo "=== Enabling Maintenance Mode ==="
cd "$FREESCOUT_PATH"
sudo -u www-data php artisan down
echo -e "${GREEN}✓ Maintenance mode enabled${NC}"
echo ""

# Step 2: Backup database
echo "=== Backing Up Database ==="
if [ -z "$DB_PASS" ]; then
    # Use .my.cnf or prompt
    mysqldump --single-transaction --quick "$DB_NAME" > "$BACKUP_DIR/database.sql" 2>/dev/null
else
    mysqldump -u "$DB_USER" -p"$DB_PASS" --single-transaction --quick "$DB_NAME" > "$BACKUP_DIR/database.sql" 2>/dev/null
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database backup completed${NC}"
    gzip "$BACKUP_DIR/database.sql"
    echo -e "${GREEN}✓ Database backup compressed${NC}"
else
    echo -e "${RED}✗ Database backup failed${NC}"
fi
echo ""

# Step 3: Backup Freescout files
echo "=== Backing Up Freescout Files ==="
tar -czf "$BACKUP_DIR/freescout-files.tar.gz" \
    -C "$(dirname $FREESCOUT_PATH)" \
    "$(basename $FREESCOUT_PATH)" \
    --exclude="$(basename $FREESCOUT_PATH)/storage/logs/*" \
    --exclude="$(basename $FREESCOUT_PATH)/storage/framework/cache/*" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Files backup completed${NC}"
else
    echo -e "${RED}✗ Files backup failed${NC}"
fi
echo ""

# Step 4: Backup .env file separately (contains sensitive data)
echo "=== Backing Up Configuration ==="
if [ -f "$FREESCOUT_PATH/.env" ]; then
    cp "$FREESCOUT_PATH/.env" "$BACKUP_DIR/.env"
    chmod 600 "$BACKUP_DIR/.env"
    echo -e "${GREEN}✓ Configuration backed up${NC}"
else
    echo -e "${YELLOW}! .env file not found${NC}"
fi
echo ""

# Step 5: Disable maintenance mode
echo "=== Disabling Maintenance Mode ==="
cd "$FREESCOUT_PATH"
sudo -u www-data php artisan up
echo -e "${GREEN}✓ Maintenance mode disabled${NC}"
echo ""

# Step 6: Create backup info file
cat > "$BACKUP_DIR/backup-info.txt" << EOF
Freescout Backup Information
============================
Backup Date: $(date)
Freescout Path: $FREESCOUT_PATH
Database Name: $DB_NAME
Hostname: $(hostname)

Files:
- database.sql.gz (Database dump)
- freescout-files.tar.gz (Application files)
- .env (Configuration file)

Restore Instructions:
1. Extract freescout-files.tar.gz
2. Restore database from database.sql.gz
3. Copy .env file to Freescout directory
4. Set proper permissions
5. Run: php artisan migrate
6. Run: php artisan freescout:clear-cache
EOF

echo -e "${GREEN}✓ Backup info created${NC}"
echo ""

# Step 7: Calculate backup size
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
echo "=== Backup Summary ==="
echo "Backup Location: $BACKUP_DIR"
echo "Backup Size: $BACKUP_SIZE"
echo ""

# Step 8: Clean up old backups
echo "=== Cleaning Old Backups ==="
find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;
echo -e "${GREEN}✓ Removed backups older than $RETENTION_DAYS days${NC}"
echo ""

echo "=========================================="
echo -e "${GREEN}Backup Complete!${NC}"
echo "=========================================="
echo "Backup saved to: $BACKUP_DIR"
echo "Completed: $(date)"
