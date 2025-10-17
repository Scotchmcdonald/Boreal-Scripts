# Freescout Ticketing System Scripts

Scripts for managing and maintaining the Freescout ticketing system.

## Available Scripts

### backup-freescout.sh / backup-freescout.ps1
Complete backup of Freescout installation including database and files

### restore-freescout.sh
Restore Freescout from backup

### database-maintenance.sh
Performs database optimization and cleanup

### queue-worker-monitor.sh
Monitors and manages Freescout queue workers

### clear-cache.sh
Clears Freescout application cache

### update-freescout.sh
Helper script for updating Freescout

## Freescout Structure

Typical Freescout installation:
- Application files: `/var/www/freescout` or `/var/www/html/freescout`
- Database: MySQL/MariaDB
- Configuration: `.env` file
- Storage: `storage/` and `public/storage/` directories

## Prerequisites

- Access to Freescout server (Linux)
- Database credentials
- Sufficient disk space for backups
- PHP and Composer installed
- Artisan command-line tool

## Usage Notes

1. Always test backup/restore procedures
2. Keep backups in secure location
3. Schedule regular automated backups
4. Monitor queue workers for ticket processing
5. Clear cache after configuration changes

## Security

⚠️ **Important**: Never commit database credentials or `.env` files to version control!
