#!/bin/bash
################################################################################
# Windows System Information Script (Bash version for WSL/Git Bash)
# Description: Collects system information from Windows via bash
# Author: Boreal IT Services
# Usage: ./system-info.sh
# Requirements: WSL or Git Bash on Windows
################################################################################

echo "=========================================="
echo "Windows System Information (via Bash)"
echo "=========================================="
echo "Generated: $(date)"
echo ""

# Check if running in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Environment: WSL (Windows Subsystem for Linux)"
    echo ""
    
    # System Information via PowerShell from WSL
    echo "=== Operating System ==="
    powershell.exe -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture | Format-List" 2>/dev/null | grep -v '^$'
    echo ""
    
    echo "=== Computer Information ==="
    powershell.exe -Command "Get-CimInstance Win32_ComputerSystem | Select-Object Name, Domain, Manufacturer, Model | Format-List" 2>/dev/null | grep -v '^$'
    echo ""
    
    echo "=== Processor ==="
    powershell.exe -Command "Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors | Format-List" 2>/dev/null | grep -v '^$'
    echo ""
    
    echo "=== Disk Usage ==="
    powershell.exe -Command "Get-Volume | Where-Object {$_.DriveLetter -ne $null} | Format-Table DriveLetter, FileSystemLabel, Size, SizeRemaining -AutoSize" 2>/dev/null
    echo ""
else
    echo "Environment: Git Bash or other Unix-like shell on Windows"
    echo ""
    
    # Basic system info available in Git Bash
    echo "=== System Information ==="
    echo "Computer Name: $COMPUTERNAME"
    echo "Username: $USERNAME"
    echo "User Domain: $USERDOMAIN"
    echo ""
    
    echo "=== Processor ==="
    echo "Processor: $PROCESSOR_IDENTIFIER"
    echo "Architecture: $PROCESSOR_ARCHITECTURE"
    echo "Processor Count: $NUMBER_OF_PROCESSORS"
    echo ""
    
    echo "=== Environment ==="
    echo "OS: $OS"
    echo "Path: $PATH" | head -c 200
    echo "..."
    echo ""
fi

echo "=========================================="
echo "Report Complete"
echo "=========================================="
