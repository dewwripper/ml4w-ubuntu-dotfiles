# CLI Interface Contract: Ubuntu 26.04 Enhanced Installer

**Contract ID**: `installer-cli-v1.1`
**Feature**: `002-ubuntu-2604-compatibility`

## Synopsis
```bash
./install.sh [OPTIONS]
```

## Options
| Flag | Long Flag | Description | Default |
|---|---|---|---|
| `-h` | `--help` | Display usage instructions and exit | `false` |
| `-d` | `--dry-run` | Print planned operations without modifying filesystem or installing packages | `false` |
| `-y` | `--noconfirm` / `--yes` | Automatic yes to prompts; run non-interactively for CI / Docker tests | `false` |
| `-b` | `--bar <type>` | Preferred desktop status bar: `quickshell` (default) or `waybar` | `quickshell` |
| | `--skip-backup` | Skip configuration backup step | `false` |
| | `--skip-packages` | Skip OS package installation and only sync dotfile configs | `false` |

## Exit Codes
| Exit Code | Meaning |
|---|---|
| `0` | Success |
| `1` | General error |
| `2` | Unsupported OS |
| `3` | Permission error |
| `4` | Network/Download error |
