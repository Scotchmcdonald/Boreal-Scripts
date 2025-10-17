# Network Management Scripts

Scripts for network diagnostics, monitoring, and management.

## Available Scripts

### network-scan.sh / network-scan.ps1
Scans local network for active hosts and open ports

### port-test.sh / port-test.ps1
Tests connectivity to specific ports on remote hosts

### bandwidth-test.sh
Tests network bandwidth and latency

### dns-check.sh / dns-check.ps1
Verifies DNS resolution and configuration

### connection-monitor.sh / connection-monitor.ps1
Continuously monitors network connectivity

## Common Use Cases

### Troubleshooting
- Test connectivity to services
- Verify DNS resolution
- Check for network latency
- Identify network bottlenecks

### Monitoring
- Track uptime of critical services
- Monitor bandwidth usage
- Alert on connection failures

### Discovery
- Find active hosts on network
- Identify open ports
- Map network topology

## Requirements

### Bash Scripts
- Standard Unix utilities (ping, nslookup, etc.)
- nmap (optional, for advanced scanning)
- iperf3 (optional, for bandwidth testing)

### PowerShell Scripts
- PowerShell 5.1+
- Test-NetConnection cmdlet
- Administrative privileges for some operations

## Safety Notes

- Obtain proper authorization before scanning networks
- Be aware of security policies
- Some scans may trigger security alerts
- Use responsibly and ethically
