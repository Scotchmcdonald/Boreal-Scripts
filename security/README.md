# Security Scripts

Scripts for security audits, compliance checks, and system hardening.

## Available Scripts

### security-audit.sh
Comprehensive security audit for Linux systems (see also linux-servers/)

### password-policy-check.sh / password-policy-check.ps1
Verifies password policy compliance

### open-ports-scan.sh / open-ports-scan.ps1
Scans for open ports and listening services

### user-access-audit.sh / user-access-audit.ps1
Audits user accounts and permissions

### ssl-cert-check.sh
Checks SSL certificate expiration dates

## Security Domains

### Access Control
- User account audits
- Permission reviews
- Authentication verification
- SSH configuration

### Network Security
- Open port scanning
- Firewall status
- Service exposure
- SSL/TLS configuration

### System Hardening
- Security patches
- Unnecessary services
- File permissions
- Configuration compliance

### Monitoring
- Failed login attempts
- Sudo usage
- File integrity
- Log analysis

## Compliance Standards

Scripts help verify compliance with:
- CIS Benchmarks
- NIST Guidelines
- PCI DSS
- SOC 2
- Custom security policies

## Best Practices

1. **Regular Audits** - Schedule weekly or monthly
2. **Prompt Remediation** - Address findings quickly
3. **Document Changes** - Track security improvements
4. **Least Privilege** - Minimize access rights
5. **Defense in Depth** - Multiple security layers

## Important Notes

⚠️ **Security scripts should be:**
- Run with appropriate privileges
- Reviewed before execution
- Used as part of comprehensive security program
- Supplemented with professional security tools

These scripts are starting points and do NOT replace:
- Professional security assessments
- Vulnerability scanners
- IDS/IPS systems
- SIEM solutions
