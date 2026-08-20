# Feature Specification: Ubuntu Support for Dotfiles & Installer

**Feature Branch**: `001-ubuntu-support`

**Created**: 2026-08-20

**Status**: Draft

**Input**: User description: "Add Ubuntu support for the dotfiles and environment installer. Feature Goal: Port our installation scripts and dotfiles (currently supporting Arch Linux, Fedora, and openSUSE) to full support for Ubuntu (focusing on Ubuntu 24.04 LTS and newer)."

## Clarifications

### Session 2026-08-20

- Q: Where should fallback binaries (such as pre-built GitHub releases for eza, fastfetch, or custom Wayland utilities) and custom fonts be placed when installed on Ubuntu? → A: Hybrid approach (official APT/PPAs installed system-wide; GitHub release binary fallbacks and fonts deployed to user-level paths `~/.local/bin` and `~/.local/share/fonts`).
- Q: How should the desktop status bar / shell component be provisioned on Ubuntu, given that this dotfiles repository defaults to Quickshell? → A: Quickshell Default with Waybar Fallback (deploy Quickshell and its Qt6/QML runtime by default, while configuring Waybar as a pre-installed/automated fallback if Quickshell encounters runtime issues).
- Q: Where should existing user configuration backups be stored prior to applying dotfile symlinks or copy overrides? → A: Store timestamped configuration backups under `~/.mydotfiles/backups/ml4w-backup-YYYYMMDD-HHMMSS`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ubuntu 24.04+ Environment Installation & Package Resolution (Priority: P1)

As a user running Ubuntu 24.04 LTS (or newer), I want to execute the installer script so that all necessary desktop environment packages, Wayland utilities, terminal tools, fonts, and themes are automatically installed and configured without manual package troubleshooting.

**Why this priority**: Core installer functionality on the new target distribution is the primary goal and foundation of this entire feature.

**Independent Test**: Can be tested on a clean Ubuntu 24.04 installation by executing `./install.sh`; verifies that all required graphical and CLI applications launch and display correctly.

**Acceptance Scenarios**:

1. **Given** a clean installation of Ubuntu 24.04 LTS, **When** the user runs `./install.sh`, **Then** the installer detects Ubuntu via `/etc/os-release`, maps packages to APT repositories, and installs all core environment components (`hyprland`, `quickshell` as default, `waybar` as secondary fallback, `swaync`, `rofi-wayland`, `swww`/`hyprpaper`, `hyprlock`, `hypridle`, `xdg-desktop-portal-hyprland`).
2. **Given** packages that are absent or outdated in official Ubuntu repos, **When** the installer runs on Ubuntu, **Then** it automatically applies deterministic fallbacks (vetted PPAs or GitHub release binary downloads) to ensure functional parity with existing Arch/Fedora/openSUSE setups.
3. **Given** CLI utilities, fonts, and themes, **When** the installer completes, **Then** Starship, Fastfetch, Zsh/Bash profiles, Nerd Fonts, and GTK icon themes are installed and active.

---

### User Story 2 - Debian/Ubuntu Shell & Command Name Compatibility (Priority: P2)

As a user or automated script running on Ubuntu, I want commands and shell configurations to resolve standardized binary names (such as `bat` and `fd`) seamlessly despite Debian-specific package naming discrepancies (`batcat`, `fdfind`).

**Why this priority**: Essential to avoid broken keybindings, broken shell alias workflows, and script execution failures across the dotfiles ecosystem.

**Independent Test**: Can be tested by opening interactive `bash` and `zsh` sessions and invoking `bat`, `fd`, and dependent custom scripts (e.g., fastfetch wrappers, rofi launchers) to ensure expected output without command-not-found errors.

**Acceptance Scenarios**:

1. **Given** Ubuntu has installed `batcat` and `fdfind`, **When** the user starts a shell session or launches custom dotfile scripts, **Then** `bat` and `fd` commands resolve and function identically to their upstream equivalents.
2. **Given** non-Ubuntu distributions (Arch, Fedora, openSUSE), **When** shared dotfile configs are loaded, **Then** existing binary resolutions remain unaffected and introduce no regressions.

---

### User Story 3 - Safe Backup, Idempotency & Multi-Distro Non-Breakage (Priority: P3)

As a user with existing system configurations, I want the installer to safely back up my pre-existing files and support repeated runs cleanly, while maintaining 100% compatibility on Arch, Fedora, and openSUSE.

**Why this priority**: Protects existing user configs against data loss and guarantees that existing multi-distro users experience zero regressions.

**Independent Test**: Can be tested by running the installer multiple times consecutively on Ubuntu, Arch, Fedora, and openSUSE, verifying that timestamped backups are generated and re-runs produce identical valid states without duplicate entries.

**Acceptance Scenarios**:

1. **Given** pre-existing configuration directories (`~/.config`), **When** the installer runs, **Then** a timestamped backup is created before new configurations or symlinks are applied.
2. **Given** an existing installation that has already completed, **When** `./install.sh` is executed again, **Then** the script completes idempotently with no errors and no duplicate configuration blocks.
3. **Given** an Arch Linux, Fedora, or openSUSE system, **When** `./install.sh` is executed, **Then** the script preserves its original package manager routing (`pacman`, `dnf`, `zypper`) and configuration behavior.

---

### User Story 4 - Dry-Run Mode & Automated Containerized Verification (Priority: P4)

As a maintainer or cautious user, I want to execute a dry-run or containerized test run so that I can inspect the planned actions and verify installation integrity without modifying my active desktop environment.

**Why this priority**: Accelerates continuous integration testing and allows non-destructive verification of package mappings across distributions.

**Independent Test**: Can be tested by running `./install.sh --dry-run` or running an automated containerized test against an Ubuntu Docker container.

**Acceptance Scenarios**:

1. **Given** the `--dry-run` flag passed to `./install.sh`, **When** executed, **Then** the script outputs all planned package installations, repository additions, and file modifications without mutating system state.
2. **Given** an Ubuntu container environment, **When** the test verification script runs, **Then** it validates package installation completeness non-interactively.

---

### Edge Cases

- **Missing Sudo/Root Privileges**: System must gracefully notify the user if required elevated permissions are unavailable before starting package operations.
- **Ubuntu Derivatives / Variations**: Systems with `ID=pop`, `ID=linuxmint`, or custom `ID_LIKE="ubuntu debian"` must be properly recognized and routed to Ubuntu/Debian logic.
- **Network Outage / GitHub Rate Limiting**: Binary fallback downloads must verify transfer status and report clear error messages if a download fails.
- **Pre-existing PPAs or Conflicting Repos**: Installer must check for existing repository entries before attempting additions to avoid duplicate source warnings.
- **Non-Interactive Execution**: Installer must support non-interactive execution flags (e.g. `--noconfirm` or `DEBIAN_FRONTEND=noninteractive`) for container and CI runs.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST parse `/etc/os-release` for `ID` and `ID_LIKE` fields to determine whether the host is Ubuntu, Debian, Arch Linux, Fedora, or openSUSE.
- **FR-002**: System MUST route package installation requests to the appropriate package manager (`apt-get`/`apt` for Ubuntu/Debian, `pacman` for Arch, `dnf` for Fedora, `zypper` for openSUSE).
- **FR-003**: System MUST provide a comprehensive package and binary mapping list for Ubuntu covering desktop essentials (`hyprland`, `quickshell` as default with required Qt6/QML runtime libraries, `waybar` as secondary fallback, `swaync`, `rofi-wayland`, `swww`/`hyprpaper`, `hyprlock`, `hypridle`, `xdg-desktop-portal-hyprland`).
- **FR-004**: System MUST provide package mappings for terminal tools (`kitty`, `alacritty`, `starship`, `fastfetch`, `zsh`, `batcat`, `fdfind`, `eza`, `fzf`, `ripgrep`, `jq`, `brightnessctl`, `pamixer`, `playerctl`).
- **FR-005**: System MUST install and configure required typography and appearance assets including Nerd Fonts, Papirus/Adwaita icon themes, and GTK theme dependencies on Ubuntu.
- **FR-006**: System MUST provide deterministic fallback mechanisms (vetted PPAs or GitHub release binary installations deployed to `~/.local/bin` and custom fonts to `~/.local/share/fonts`) for tools unavailable or outdated in default Ubuntu repositories.
- **FR-007**: System MUST provide alias and binary resolution shims in shared shell configurations (`.bashrc`, `.zshrc`) so `bat` and `fd` map to `batcat` and `fdfind` on Ubuntu while retaining native names on other distributions.
- **FR-008**: System MUST preserve 100% backward compatibility with Arch Linux, Fedora, and openSUSE installations without breaking existing dotfiles or installer workflows.
- **FR-009**: System MUST create a timestamped backup of existing user configurations under `~/.mydotfiles/backups/ml4w-backup-YYYYMMDD-HHMMSS` before copying or linking new dotfiles.
- **FR-010**: System MUST support idempotent execution, ensuring repeated executions do not result in duplicated settings or broken links.
- **FR-011**: System MUST provide a `--dry-run` flag to display all intended commands and operations without applying changes.
- **FR-012**: System MUST support non-interactive execution for automated testing inside containerized environments (Docker/LXC).

### Key Entities

- **OS Profile**: Representation of host system metadata derived from `/etc/os-release` (Distribution Family, Release Version, Package Manager command set).
- **Package Manifest**: Declarative mapping of logical capabilities (e.g. `terminal-emulator`, `status-bar`, `fuzzy-finder`) to distribution-specific package names and fallback sources.
- **Backup Manifest**: Record of backed-up configuration paths and timestamped destination archives.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user on Ubuntu 24.04 LTS can run `./install.sh` and achieve a fully functional desktop environment with zero manual package intervention.
- **SC-002**: 100% of defined CLI tools and keybindings execute successfully across both Ubuntu and Arch Linux test environments.
- **SC-003**: Repeated execution of the installer on an already-configured system completes in under 30 seconds with 0 state regressions or duplicated configuration lines.
- **SC-004**: Automated containerized test harness executes end-to-end on Ubuntu 24.04 without interactive prompts and completes with exit code 0.
- **SC-005**: Zero regressions introduced to existing Arch Linux, Fedora, and openSUSE installation workflows.

## Assumptions

- Target Ubuntu version is Ubuntu 24.04 LTS or newer.
- Host system has network connectivity to standard Ubuntu package mirrors and GitHub.
- Executing user has standard `sudo` privileges.
- Quickshell / Hyprland Wayland sessions run on Wayland-compatible graphics drivers.
