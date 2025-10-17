# Windows Management Scripts

Scripts for Windows system administration, maintenance, and troubleshooting.

## Available Scripts

### system-info.ps1
Collects comprehensive Windows system information
- Hardware details
- OS version and build
- Installed software
- System health status

### cleanup-temp.ps1
Removes temporary files and clears system caches to free up disk space

### user-audit.ps1
Generates a report of local users and their properties

### network-info.ps1
Displays detailed network configuration and connectivity status

### windows-update-check.ps1
Checks for and reports available Windows updates

### disk-health.ps1
Monitors disk health and reports SMART status

## Bash Alternatives

Some scripts include bash versions for use with WSL (Windows Subsystem for Linux) or Git Bash.

## Usage

Run PowerShell scripts with appropriate privileges:

```powershell
# As Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\script-name.ps1
```

## Requirements

- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1 or later
- Administrator rights for some operations
