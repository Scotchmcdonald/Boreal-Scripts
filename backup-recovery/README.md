# Backup and Recovery Scripts

Scripts for automated backups, disaster recovery, and data protection.

## Available Scripts

### automated-backup.sh / automated-backup.ps1
Comprehensive backup script with rotation and verification

### restore-from-backup.sh
Restore data from backup archives

### verify-backup.sh
Verify backup integrity and completeness

### rsync-backup.sh
Incremental backup using rsync

### database-backup.sh
Backup MySQL/PostgreSQL databases

## Backup Strategy

### 3-2-1 Rule
- 3 copies of data
- 2 different media types
- 1 off-site backup

### Retention Policy
- Daily backups: Keep 7 days
- Weekly backups: Keep 4 weeks
- Monthly backups: Keep 12 months

## Common Backup Locations

### Local
- `/var/backups/`
- External drives
- NAS devices

### Remote
- Cloud storage (S3, Azure, etc.)
- Remote servers via SSH/rsync
- Backup services

## Best Practices

1. **Test Restores Regularly** - Backups are only good if they can be restored
2. **Encrypt Sensitive Data** - Protect confidential information
3. **Verify Backups** - Check integrity after completion
4. **Document Procedures** - Keep restore instructions updated
5. **Monitor Backup Jobs** - Alert on failures
6. **Secure Backup Storage** - Limit access to backup files

## Automation

Use cron (Linux) or Task Scheduler (Windows) to automate backups:

```bash
# Daily backup at 2 AM
0 2 * * * /path/to/automated-backup.sh
```

```powershell
# Windows Task Scheduler
schtasks /create /tn "Daily Backup" /tr "C:\Scripts\automated-backup.ps1" /sc daily /st 02:00
```
