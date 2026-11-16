# Security

> "Security is a lifestyle, not a feature" — the Prime module keeps your dev environment hardened.

The ByteBabe security stack lives in the **Prime** module (`prime`, alias `pm`). It bundles vulnerability scanning, malware quarantine, firewall control, data backup, network diagnostics and system vitals under one roof.

## The Prime Security Toolkit

All features below are implemented and reachable through `bytebabe prime <subcommand>` (or `bytebabe pm <subcommand>`).

```bash
bytebabe prime install/upgrade/remove/scan/firewall/clean/backup/network/stats/sysinfo
```

### 🔍 Security Scan (`prime scan`)

Threat assessment scanning for your system:

```bash
prime scan system      # Complete system scan
prime scan security    # Security analysis
prime scan ports       # Port scanning
prime scan malware     # Malware detection
prime scan updates     # Check for updates
prime scan network     # Network security scan
prime scan firewall    # Firewall analysis
prime scan services    # Running services check
```

Options: `--deep` (deep scan), `--quick` (quick mode), `--report` (detailed report), `--monitor` (continuous monitoring), `--verbose`.

Reports are written to the scan report directory next to a per-scan log of findings.

### ☣️ Quarantine (`prime quarantine`)

Isolate, inspect and remove suspicious files:

```bash
prime quarantine list                          # List quarantined items
prime quarantine isolate /path/to/suspicious   # Isolate a suspicious file
prime quarantine analyze --deep threat_123     # Analyze item in quarantine
prime quarantine restore threat_123            # Restore from quarantine
prime quarantine remove threat_123             # Remove threat permanently
```

Options: `--force`, `--deep`, `--verbose`.

### 🛡️ Firewall (`prime firewall`)

Firewall management is exposed through the interactive control panel (`Install/Detect`, `View Status`, `Enable/Disable`, `List/Add/Remove Rules`, `Quick Setup Profiles`). Full details live in the dedicated docs:

- [Firewall Module](firewall-module.md)

Access control today is practical, not dashboard-based: host-level rules (firewall profiles, port policies) are applied by the [DevOps Security Profile](security-best-practices.md#firewall-security-profiles). Planned user/role/2FA management is tracked in [Security Best Practices](security-best-practices.md#access-control-planned).

### 💾 Backup (`prime backup`)

Data archival and restore:

```bash
prime backup create /home/user /mnt/backup
prime backup restore backup_2023.tar.gz /home/user
prime backup list
```

### 🌐 Network Diagnostics (`prime network`)

Interactive menu with:

- Network interfaces
- Connection test
- Port scanner
- DNS diagnostics
- Bandwidth monitor
- VPN status

### 📊 System Vitals (`prime stats`)

CPU, memory, swap and disk usage with model, cores, frequency and load averages — quick sanity check before deep scans.

## Consolidated Reference

Content from the old standalone pages was merged here and into [Security Best Practices](security-best-practices.md):

| Old topic | Where it lives now |
|-----------|-------------------|
| Access Control (planned) | [Security Best Practices → Access Control (Planned)](security-best-practices.md#access-control-planned) |
| Encryption (planned) | [Security Best Practices → Encryption (Planned)](security-best-practices.md#encryption-planned) |
| Security Profiles (firewall) | [Security Best Practices → Firewall Security Profiles](security-best-practices.md#firewall-security-profiles) |

## Vulnerability Scanning Tips

- Run a quick pass before every release: `prime scan security --quick`
- Schedule deep audits monthly: `prime scan system --deep --report`
- Anything flagged by `prime scan malware` should be isolated first (`prime quarantine isolate`) and analyzed (`prime quarantine analyze --deep`) before deletion.

## Getting Help

- [Support](support.md)
- [GitHub Issues](https://github.com/mrpunkdasilva/bytebabe/issues)
- [Troubleshooting](troubleshooting.md)
