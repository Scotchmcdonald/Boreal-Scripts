# Linux Server Management Scripts

Scripts for Linux server administration, maintenance, and monitoring.

## Available Scripts

### system-health.sh
Comprehensive system health check for Linux servers
- CPU, memory, and disk usage
- Service status
- System load
- Failed services

### backup-config.sh
Backs up important system configuration files

### user-audit.sh
Audits user accounts and permissions

### service-monitor.sh
Monitors critical services and restarts them if needed

### security-audit.sh
Performs basic security checks on the system

### log-analyzer.sh
Analyzes system logs for errors and warnings

### package-updates.sh / package-updates.ps1
Checks for and reports available package updates (bash and PowerShell versions)

## Usage

Make scripts executable:
```bash
chmod +x script-name.sh
./script-name.sh
```

Many scripts require root/sudo privileges for full functionality:
```bash
sudo ./script-name.sh
```

## Compatibility

Scripts are tested on:
- Ubuntu 20.04/22.04 LTS
- Debian 10/11
- CentOS/RHEL 7/8
- Amazon Linux 2

## Best Practices

1. Always review scripts before running with sudo
2. Test in non-production environments first
3. Keep backups before making system changes
4. Monitor logs after automated changes
