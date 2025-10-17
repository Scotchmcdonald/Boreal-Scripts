# Scripts Index

Complete index of all available scripts in the Boreal Scripts repository.

## ChromeOS Management (chromeos/)

| Script | Type | Description |
|--------|------|-------------|
| system-info.sh | Bash | Gathers comprehensive system information from ChromeOS devices |
| network-diagnostics.sh | Bash | Performs network connectivity tests and diagnostics |

## Windows Management (windows/)

| Script | Type | Description |
|--------|------|-------------|
| system-info.ps1 | PowerShell | Collects comprehensive Windows system information |
| system-info.sh | Bash | System information for WSL/Git Bash |
| cleanup-temp.ps1 | PowerShell | Removes temporary files and clears caches |
| network-info.ps1 | PowerShell | Displays detailed network configuration |

## Linux Server Management (linux-servers/)

| Script | Type | Description |
|--------|------|-------------|
| system-health.sh | Bash | Comprehensive system health monitoring |
| system-health.ps1 | PowerShell | System health check via SSH |
| security-audit.sh | Bash | Performs basic security checks |

## Freescout Ticketing System (freescout/)

| Script | Type | Description |
|--------|------|-------------|
| backup-freescout.sh | Bash | Complete backup of Freescout installation |
| backup-freescout.ps1 | PowerShell | Remote backup via SSH from Windows |
| queue-worker-monitor.sh | Bash | Monitors and manages queue workers |

## Network Management (network/)

| Script | Type | Description |
|--------|------|-------------|
| port-test.sh | Bash | Tests connectivity to specific ports |
| port-test.ps1 | PowerShell | Port connectivity testing |
| dns-check.sh | Bash | Verifies DNS resolution and configuration |

## Backup & Recovery (backup-recovery/)

| Script | Type | Description |
|--------|------|-------------|
| automated-backup.sh | Bash | Comprehensive backup with rotation |
| automated-backup.ps1 | PowerShell | Windows backup with retention |

## Monitoring (monitoring/)

| Script | Type | Description |
|--------|------|-------------|
| service-monitor.sh | Bash | Monitors critical services and restarts if needed |
| disk-monitor.ps1 | PowerShell | Monitors disk space and alerts on thresholds |

## Security (security/)

| Script | Type | Description |
|--------|------|-------------|
| open-ports-scan.sh | Bash | Scans for open ports and listening services |

## Utilities (utilities/)

| Script | Type | Description |
|--------|------|-------------|
| system-report.sh | Bash | Generates comprehensive system report |
| duplicate-finder.ps1 | PowerShell | Finds duplicate files based on content hash |

---

## Quick Start Guide

### Running Bash Scripts
```bash
# Make executable (if needed)
chmod +x script-name.sh

# Run the script
./script-name.sh

# With sudo (if needed)
sudo ./script-name.sh
```

### Running PowerShell Scripts
```powershell
# Set execution policy (first time only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the script
.\script-name.ps1

# As Administrator (if needed)
# Right-click PowerShell > Run as Administrator
```

## Script Categories by Use Case

### Daily Operations
- windows/cleanup-temp.ps1
- monitoring/service-monitor.sh
- monitoring/disk-monitor.ps1

### Troubleshooting
- chromeos/network-diagnostics.sh
- windows/network-info.ps1
- network/port-test.sh
- network/dns-check.sh

### System Administration
- linux-servers/system-health.sh
- windows/system-info.ps1
- utilities/system-report.sh

### Security & Compliance
- linux-servers/security-audit.sh
- security/open-ports-scan.sh

### Backup & Maintenance
- backup-recovery/automated-backup.sh
- freescout/backup-freescout.sh

### Resource Management
- utilities/duplicate-finder.ps1
- windows/cleanup-temp.ps1

## Contributing New Scripts

When adding new scripts to this repository:

1. **Location**: Place in appropriate category directory
2. **Naming**: Use descriptive, lowercase names with hyphens
3. **Dual Versions**: Provide both .sh and .ps1 when practical
4. **Documentation**: 
   - Add header with description, usage, and requirements
   - Update category README.md
   - Update this index file
5. **Testing**: Verify syntax and basic functionality
6. **Permissions**: Ensure .sh files are executable

## Support

For questions or issues:
- Review the README.md in each category folder
- Check script comments for specific usage
- Contact IT team for assistance
