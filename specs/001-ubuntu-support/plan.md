# Implementation Plan: Ubuntu Support for Dotfiles & Installer

**Branch**: `001-ubuntu-support` | **Date**: 2026-08-20 | **Spec**: [spec.md](file:///Users/deww/Repos/per/ml4w-ubuntu-dotfiles/specs/001-ubuntu-support/spec.md)

**Input**: Feature specification from `specs/001-ubuntu-support/spec.md`

## Summary

Port our dotfiles installation scripts and configuration management to full, native support for Ubuntu 24.04 LTS+ while preserving 100% backward compatibility with Arch Linux, Fedora, and openSUSE. The implementation introduces modular OS detection, declarative multi-distro package mappings (APT / Pacman / DNF / Zypper), hybrid fallback provisioning (`~/.local/bin` and `~/.local/share/fonts`), Quickshell as default with Waybar fallback, timestamped backups in `~/.mydotfiles/backups/`, shell binary shims (`batcat` → `bat`, `fdfind` → `fd`), and non-interactive `--dry-run` container verification.

## Technical Context

**Language/Version**: POSIX Shell (`bash` 5.x, `zsh` 5.x)
**Primary Dependencies**: `apt-get` / `pacman` / `dnf` / `zypper`, `rsync`, `curl`, `tar`, `git`, Qt6 runtime (`libqt6quick6`, `libqt6qml6`), `quickshell`, `hyprland`, `waybar`, `swaync`, `rofi-wayland`
**Storage**: Filesystem dotfiles in `~/.config`, backups in `~/.mydotfiles/backups/`
**Testing**: Containerized non-interactive runner (`ubuntu:24.04` Docker), dry-run CLI validations, idempotency check passes
**Target Platform**: Linux (Ubuntu 24.04+, Debian 12+, Arch Linux / CachyOS, Fedora 40+, openSUSE Tumbleweed/Leap)
**Project Type**: Shell scripts & Desktop Configuration management (CLI / Dotfiles)
**Performance Goals**: Installer dry-run < 2s; idempotent re-run on configured systems < 30s
**Constraints**: 100% backward compatibility with Arch/Fedora/openSUSE; zero breakage of existing configs without backups; non-root user fallback execution
**Scale/Scope**: 1 unified installer (`install.sh`), modular distro handlers (`install/`), 10+ core packages mapped, 4 desktop shells/tools

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle / Gate | Compliance Status | Rationale |
|---|---|---|
| **I. Multi-Distro Support & Idempotency** | **PASS** | Installer parses `/etc/os-release` (`ID`, `ID_LIKE`); routes to distinct package handlers; repeated executions use safe `rsync` merges without duplication. |
| **II. Native APT & PPA / Fallback Logic** | **PASS** | Official Ubuntu APT packages prioritized; verified GitHub release binaries and fonts deployed locally to `~/.local/bin` and `~/.local/share/fonts`. |
| **III. No Breakage of Existing Distros** | **PASS** | Arch, Fedora, and openSUSE code paths preserved intact; shell shims only activate when Debian-specific binary names (`batcat`, `fdfind`) are present. |
| **IV. Clean Uninstall & Safe Backup** | **PASS** | Pre-existing configs backed up to timestamped directory `~/.mydotfiles/backups/ml4w-backup-YYYYMMDD-HHMMSS` before any files are copied or symlinked. Works on bash & zsh. |

## Project Structure

### Documentation (this feature)

```text
specs/001-ubuntu-support/
├── plan.md              # Implementation Plan (this document)
├── research.md          # Technical research & package matrix findings
├── data-model.md        # Entities, lifecycle state machine, and data types
├── quickstart.md        # Runnable verification scenarios
├── contracts/           # CLI interface & option specifications
│   └── installer-interface.md
└── checklists/          # Quality verification checklists
    └── requirements.md
```

### Source Code (repository root)

```text
ml4w-ubuntu-dotfiles/
├── install.sh                                # Unified multi-distro entry point (with --dry-run, --noconfirm)
├── install/                                  # Modular distro & fallback installers
│   ├── os-detect.sh                          # /etc/os-release parser (Ubuntu, Arch, Fedora, openSUSE)
│   ├── backup.sh                             # Timestamped backup creator (~/.mydotfiles/backups)
│   ├── distros/
│   │   ├── ubuntu.sh                         # Ubuntu/Debian APT package mappings & PPAs
│   │   ├── arch.sh                           # Arch Linux / Pacman installation handler
│   │   ├── fedora.sh                         # Fedora / DNF installation handler
│   │   └── suse.sh                           # openSUSE / Zypper installation handler
│   └── fallbacks/
│       ├── quickshell.sh                     # Quickshell binary & Qt6 runtime installer
│       ├── tools.sh                          # GitHub release binary fallbacks (eza, fastfetch, starship)
│       └── fonts.sh                          # Nerd Fonts downloader & fontcache refresher
├── .config/                                  # Shared dotfiles & configurations
│   ├── bashrc/10-aliases                     # Shell shims for bat/fd/eza
│   ├── zshrc/25-aliases                      # Zsh shims for bat/fd/eza
│   ├── fish/conf.d/10-aliases.fish           # Fish shims for bat/fd/eza
│   ├── quickshell/                           # Quickshell desktop shell configs
│   ├── waybar/                               # Waybar fallback configs
│   └── hypr/                                 # Hyprland window manager configs
└── tests/
    └── test-ubuntu-container.sh              # Non-interactive Docker/LXC validation harness
```

**Structure Decision**: Modular installer structure separating distro-specific logic into `install/distros/` and user-level fallbacks into `install/fallbacks/`, invoked by the top-level `install.sh`.

## Complexity Tracking

> **No Constitution violations. Complexity score: Low-Medium.**
