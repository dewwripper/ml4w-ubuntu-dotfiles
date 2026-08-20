<!--
Sync Impact Report:
- Version Change: Template [CONSTITUTION_VERSION] → 1.0.0 (Initial Ratification)
- Modified Principles:
  - Template Placeholders → I. Multi-Distro Support & Idempotency
  - Template Placeholders → II. Native APT & PPA / Fallback Logic
  - Template Placeholders → III. No Breakage of Existing Distros
  - Template Placeholders → IV. Clean Uninstall & Safe Backup
- Added Sections:
  - Core Principles (I - IV)
  - Portability & Packaging Standards
  - Compatibility & Distribution Matrix
  - Governance
- Removed Sections:
  - Unused template placeholder slots
- Follow-up TODOs: None. All template placeholders resolved.
-->

# ML4W Multi-Distro Dotfiles Constitution

## Core Principles

### I. Multi-Distro Support & Idempotency
System installation scripts MUST detect the host OS via standard `/etc/os-release` parsing (evaluating fields such as `ID` and `ID_LIKE`) and route package installations cleanly across supported distributions (Arch Linux, Fedora, openSUSE, and Ubuntu/Debian). All installation and configuration scripts MUST be idempotent: executing scripts multiple times on an existing installation MUST NOT result in duplicate configurations, broken symlinks, unhandled errors, or unintended system state mutations.

### II. Native APT & PPA / Fallback Logic
Package resolution on Ubuntu and Debian-based systems MUST prioritize official APT repositories and modern Canonical PPAs where necessary. When required Wayland ecosystem utilities (such as specific releases of Hyprland, Waybar, SwayNC, or Rofi-Wayland) are absent or outdated in the primary distribution repositories, installation workflows MUST cleanly execute deterministic fallback strategies—such as reputable PPAs, verified pre-built GitHub release binaries, or Cargo/Go source builds—with clear logging and error handling.

### III. No Breakage of Existing Distros
All modifications to shared dotfiles (including configurations for Hyprland, Quickshell, Waybar, SwayNC, Alacritty, Kitty, and Rofi) MUST maintain 100% backward compatibility with Arch Linux, Fedora, and openSUSE environments. Distro-specific adaptations MUST be handled through modular configuration includes, runtime environment checks, or installer-level routing rather than disruptive global configuration changes that degrade non-Ubuntu experiences.

### IV. Clean Uninstall & Safe Backup
Any script that replaces, symlinks, or copies configuration files MUST preserve existing user configurations by creating timestamped, safe backups before writing changes. Uninstall and backup/restore mechanisms MUST be strictly maintained and function uniformly across standard POSIX-compliant interactive shells (`bash` and `zsh`).

## Portability & Packaging Standards

1. **POSIX & Shell Compatibility**: Core installer and utility helper scripts MUST avoid non-portable shell idioms unless explicitly executed under designated shells with valid shebangs (`#!/bin/bash` or `#!/bin/zsh`).
2. **Deterministic State Handling**: Dotfile deployment mechanisms (e.g., `rsync`, symlink managers) MUST handle nested structures gracefully without circular links or destructive overwrites of untracked files.
3. **Transparent Execution**: Package installation, repository addition (PPAs), and binary fallback steps MUST provide user-facing terminal feedback explaining each operation.

## Compatibility & Distribution Matrix

- **Arch Linux / CachyOS**: First-class support via `pacman` and AUR helpers (`yay` / `paru`).
- **Ubuntu / Debian**: First-class support via `apt`, vetted PPAs, and binary fallback strategies.
- **Fedora**: Supported via `dnf` and Copr repositories where applicable.
- **openSUSE**: Supported via `zypper` and OBS repositories where applicable.

## Governance

This Constitution supersedes all informal configuration practices and guides ongoing repository development. 

- **Amendment Procedure**: Any change to these principles requires updating `.specify/memory/constitution.md`, generating a Sync Impact Report, and securing maintainer approval.
- **Versioning Policy**:
  - **MAJOR** version increments indicate breaking governance changes, principle removals, or major architectural shifts in multi-distro governance.
  - **MINOR** version increments indicate newly added principles, extended distro support tiers, or material expansions of existing principles.
  - **PATCH** version increments indicate non-semantic clarifications, typographical corrections, or formatting updates.
- **Compliance Review**: All proposed dotfile updates, pull requests, and installation script modifications MUST be audited against these four core principles prior to integration.

**Version**: 1.0.0 | **Ratified**: 2026-08-20 | **Last Amended**: 2026-08-20
