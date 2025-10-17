# Boreal Scripts

A comprehensive collection of IT management and automation scripts for Boreal IT Services and Development.

## Repository Structure

This repository is organized by service area to make it easy to find and manage scripts:

### 📱 [chromeos/](chromeos/)
Scripts for managing and troubleshooting ChromeOS devices
- System diagnostics
- Policy management
- User administration

### 🪟 [windows/](windows/)
Scripts for Windows system administration and management
- System maintenance
- Active Directory tasks
- User management
- Performance monitoring

### 🐧 [linux-servers/](linux-servers/)
Scripts for Linux server administration
- System maintenance
- Service management
- Package management
- Performance tuning

### 🎫 [freescout/](freescout/)
Scripts for managing the Freescout ticketing system
- Backup and restore
- Database maintenance
- Queue management

### 🌐 [network/](network/)
Network management and diagnostic scripts
- Network scanning
- Connection testing
- Configuration management

### 💾 [backup-recovery/](backup-recovery/)
Backup and disaster recovery scripts
- Automated backups
- Restore procedures
- Verification scripts

### 📊 [monitoring/](monitoring/)
System and service monitoring scripts
- Health checks
- Resource monitoring
- Alert generation

### 🔒 [security/](security/)
Security and compliance scripts
- Security audits
- Vulnerability scanning
- Access reviews

### 🛠️ [utilities/](utilities/)
General utility scripts and tools
- File management
- Data processing
- Common helper functions

## Usage

Most scripts are available in both PowerShell (.ps1) and Bash (.sh) versions where applicable.

### PowerShell Scripts
```powershell
# Run with appropriate execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\script-name.ps1
```

### Bash Scripts
```bash
# Make executable and run
chmod +x script-name.sh
./script-name.sh
```

## Best Practices

1. **Always test scripts in a non-production environment first**
2. **Review scripts before running them**
3. **Keep credentials secure** - Never commit sensitive data
4. **Document any modifications** you make
5. **Follow the principle of least privilege**

## Contributing

When adding new scripts:
1. Place them in the appropriate category directory
2. Include both PowerShell and Bash versions when possible
3. Add clear comments and documentation
4. Update the relevant README in the category directory

## License

Internal use only - Boreal IT Services and Development

## Support

For questions or issues, please contact the IT team or open a ticket in Freescout.