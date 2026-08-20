# CLI Interface Contract: ML4W Multi-Distro Installer

**Contract ID**: `installer-cli-v1`
**Feature**: `001-ubuntu-support`

## Command-Line Synopsis

```bash
./install.sh [OPTIONS]
```

## Options & Arguments

| Flag | Long Flag | Description | Default |
|---|---|---|---|
| `-h` | `--help` | Display usage instructions and exit | `false` |
| `-d` | `--dry-run` | Print planned operations without modifying filesystem or installing packages | `false` |
| `-y` | `--noconfirm` / `--yes` | Automatic yes to prompts; run non-interactively for CI / Docker tests | `false` |
| `-b` | `--bar <type>` | Preferred desktop status bar: `quickshell` (default) or `waybar` | `quickshell` |
| | `--skip-backup` | Skip configuration backup step (NOT recommended for normal use) | `false` |
| | `--skip-packages` | Skip OS package installation and only sync dotfile configs | `false` |

## Exit Codes

| Exit Code | Meaning |
|---|---|
| `0` | Success: All requested operations completed cleanly |
| `1` | General Error: Missing required system dependencies or unexpected failure |
| `2` | Unsupported OS: Host OS could not be identified or is unsupported |
| `3` | Permission Error: Sudo required but unavailable in non-interactive environment |
| `4` | Download/Network Failure: Critical binary or fallback asset failed to download |

## Output Protocol & Logging

- Standard output: Formatted log messages prefixed with unicode indicators (`📂`, `📦`, `🚀`, `✅`, `⚠️`, `❌`).
- Standard error: Detailed error messages sent to `stderr`.
- Color codes: ANSI colors enabled when attached to a TTY; auto-disabled in non-TTY pipe/redirection unless forced.
