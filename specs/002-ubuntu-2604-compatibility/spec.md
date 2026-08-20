# Feature Specification: Ubuntu 26.04 Compatibility & Refactoring

**Feature Branch**: `002-ubuntu-2604-compatibility`

**Created**: 2026-08-20

**Status**: Draft

**Input**: User description: "I'm using Ubuntu 26.04. Please refactor to compatible to use that OS."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ubuntu 26.04 LTS Installation & Package Resolution (Priority: P1)

As a user running Ubuntu 26.04 LTS, I want to execute `./install.sh` so that the installer correctly detects Ubuntu 26.04, resolves all desktop environment packages, Wayland utilities, and CLI dependencies tailored for the 26.04 release, and installs them cleanly.

**Why this priority**: Directly satisfies the user's primary requirement to support Ubuntu 26.04 as a first-class host platform.

**Independent Test**: Execute `./install.sh` on an Ubuntu 26.04 system/container and verify that all core graphical and CLI tools install without package lookup errors or unmet dependency failures.

**Acceptance Scenarios**:

1. **Given** a host running Ubuntu 26.04 LTS (`VERSION_ID="26.04"`), **When** `./install.sh` is executed, **Then** the OS detector identifies `OS_ID=ubuntu` and `OS_VERSION_ID=26.04` and applies 26.04-compatible package mapping.
2. **Given** Ubuntu 26.04 APT repositories, **When** package installation runs, **Then** core Wayland tools (`hyprland`, `waybar`, `sway-notification-center`, `rofi-wayland`, `hyprpaper`, `hyprlock`, `hypridle`, `xdg-desktop-portal-hyprland`) and Qt6 libraries are resolved without missing package errors.
3. **Given** upstream PPAs that may lack a dedicated 26.04 suite, **When** installing tools with missing PPA builds, **Then** the installer automatically and gracefully routes to deterministic GitHub binary releases or user-local fallback shims in `~/.local/bin`.

---

### User Story 2 - Modern Qt6 & Desktop Shell Parity on Ubuntu 26.04 (Priority: P2)

As an Ubuntu 26.04 desktop user, I want the Quickshell bar and custom widgets to launch with all required Qt6/QML runtime modules available in 26.04, falling back to Waybar if needed.

**Why this priority**: Prevents graphical crashes or missing QML plugin errors on Ubuntu 26.04's updated Qt6 ecosystem.

**Independent Test**: Launch Quickshell (`qs`) or test QML engine initialization under Ubuntu 26.04, verifying all components (top bar, system tray, popups) render without missing QML import errors.

**Acceptance Scenarios**:

1. **Given** Ubuntu 26.04, **When** Quickshell runtime libraries are installed, **Then** all necessary Qt6/QML modules (`qml6-module-qtquick`, `qml6-module-qtquick-controls`, `qml6-module-qtquick-layouts`, `qml6-module-qtquick-shapes`, `qml6-module-qtcore`) are present.
2. **Given** a failure or incompatibility during Quickshell runtime execution, **When** the desktop session starts, **Then** Waybar is available as a functional fallback.

---

### User Story 3 - Multi-Distro & Cross-Release Non-Breakage (Priority: P3)

As a maintainer or user on other distributions (Ubuntu 24.04, Arch, Fedora, openSUSE), I want the refactoring for Ubuntu 26.04 to maintain 100% backward compatibility with all previously supported versions and distros.

**Why this priority**: Enforces Constitution Principle III (No Breakage of Existing Distros).

**Independent Test**: Run `./install.sh --dry-run` across Ubuntu 24.04, Arch, Fedora, and openSUSE environments, verifying all existing logic remains intact.

**Acceptance Scenarios**:

1. **Given** an Ubuntu 24.04 host, **When** `./install.sh` runs, **Then** 24.04-specific package rules and fallbacks continue to operate as expected.
2. **Given** Arch, Fedora, or openSUSE hosts, **When** `./install.sh` runs, **Then** `pacman`, `dnf`, and `zypper` package management is unaffected.

---

### User Story 4 - Ubuntu 26.04 Containerized CI & Test Harness (Priority: P4)

As a developer, I want an automated container verification test for Ubuntu 26.04 so that the installation workflow can be continuously tested without requiring a dedicated physical 26.04 installation.

**Why this priority**: Ensures rapid regression testing and long-term maintainability for the 26.04 release.

**Independent Test**: Run `tests/test-ubuntu2604-container.sh` or execute `./install.sh --dry-run` in an Ubuntu 26.04 Docker environment.

**Acceptance Scenarios**:

1. **Given** a Dockerfile configured for `ubuntu:26.04` (or rolling development release), **When** the test script is executed, **Then** it completes the installation sequence non-interactively with exit code `0`.

---

### Edge Cases

- **PPA Release Missing for 26.04**: If a third-party PPA (such as `ppa:hyprland-community/hyprland`) does not have a 26.04 suite release file, APT repository addition must not hard-fail the entire installer; it must cleanly fall back to user-local binaries.
- **APT Package Renaming**: Any package name alterations between 24.04 and 26.04 (e.g. Qt6 module names or font package naming) must be handled through alias/fallback detection arrays.
- **Development/Rolling Release Identification**: Ubuntu development releases where `VERSION_ID` might be empty or formatted as codename (e.g. `devel`) must still be recognized as `OS_FAMILY=DEBIAN` and `OS_ID=ubuntu`.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST recognize Ubuntu 26.04 in `install/os-detect.sh` across both finalized version strings (`VERSION_ID="26.04"`) and development strings.
- **FR-002**: System MUST adapt package installation in `install/distros/ubuntu.sh` to support Ubuntu 26.04 package names and repositories.
- **FR-003**: System MUST check PPA availability before adding repositories to prevent `404 Not Found` APT update errors on Ubuntu 26.04, gracefully falling back to pre-built GitHub release binaries in `~/.local/bin`.
- **FR-004**: System MUST ensure all Qt6 runtime dependencies required by Quickshell are compatible with Ubuntu 26.04's Qt6 stack.
- **FR-005**: System MUST preserve Debian binary name shims (`batcat` → `bat`, `fdfind` → `fd`) and path exports across shell configurations in Ubuntu 26.04.
- **FR-006**: System MUST maintain 100% backward compatibility with Ubuntu 24.04 LTS, Arch Linux, Fedora, and openSUSE.
- **FR-007**: System MUST preserve safe backup functionality (`~/.mydotfiles/backups/`) prior to dotfile sync on Ubuntu 26.04.
- **FR-008**: System MUST provide an automated container verification harness (`tests/Dockerfile.ubuntu2604` and test runner) targeting Ubuntu 26.04.

### Key Entities

- **OS Profile (Version Extended)**: Contains `os_id`, `os_version_id` (e.g., `26.04`), and `os_family` used to switch distro package matrices.
- **PPA Fallback Handler**: Logic that validates PPA suite compatibility before adding APT source lists.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Running `./install.sh` on an Ubuntu 26.04 LTS installation successfully provisions all graphical and CLI components without manual intervention.
- **SC-002**: 100% of CLI tools (`bat`, `fd`, `eza`, `fastfetch`, `starship`) and Quickshell/Waybar function properly on Ubuntu 26.04.
- **SC-003**: Zero errors caused by missing PPA release suites on Ubuntu 26.04 due to automated fallback routing.
- **SC-004**: Automated container testing on Ubuntu 26.04 completes end-to-end with exit code 0.
- **SC-005**: Zero regressions on Ubuntu 24.04, Arch Linux, Fedora, or openSUSE.

## Assumptions

- Target system runs Ubuntu 26.04 LTS (or compatible 26.04+ release).
- Standard internet access is available to download APT packages and GitHub binary releases.
- Executing user has standard `sudo` privileges.
