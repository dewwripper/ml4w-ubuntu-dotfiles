# Technical Research & Findings: Ubuntu Support for Dotfiles & Installer

**Feature**: `001-ubuntu-support`
**Date**: 2026-08-20

## 1. Distribution Detection & Package Manager Routing

### Decision
Implement a centralized POSIX-compliant OS detection module (`lib/os_detect.sh` or inline in installer) that parses `/etc/os-release` evaluating both `ID` and `ID_LIKE`.

### Rationale
- Parsing `/etc/os-release` is the standard Linux specification (systemd/Freedesktop).
- Matching `ID` handles `ubuntu`, `debian`, `arch`, `cachyos`, `fedora`, `opensuse-tumbleweed`, `opensuse-leap`.
- Checking `ID_LIKE` enables derivative support (e.g. `linuxmint`, `pop`, `zorin`, `endeavouros`, `manjaro`).

### Alternatives Considered
- `lsb_release`: Not always pre-installed on minimal server, container, or slim cloud images.
- Checking for package manager binary presence (`command -v pacman`): Can give false positives in mixed or chroot container environments.

---

## 2. Ubuntu 24.04 LTS Package Mapping & Fallback Strategy

### Decision
Define a tiered package resolution matrix:
1. **Tier 1 (Official APT Repositories)**: Packages available directly in Ubuntu 24.04 (Noble) main/universe:
   - CLI tools: `zsh`, `ripgrep`, `fzf`, `jq`, `brightnessctl`, `pamixer`, `playerctl`, `socat`, `rsync`, `cava`, `bat` (`batcat`), `fd-find` (`fdfind`), `kitty`, `alacritty`.
   - Desktop & Wayland: `waybar`, `sway-notification-center` (or `swaync`), `rofi` / `rofi-wayland`, `xdg-desktop-portal-hyprland`, `hyprpaper`, `hypridle`, `hyprlock`.
   - Fonts & Themes: `fonts-font-awesome`, `papirus-icon-theme`, `adwaita-icon-theme`.
2. **Tier 2 (Canonical / Vetted PPAs)**:
   - For updated Hyprland stack where base universe packages are outdated: `ppa:hyprland-community/hyprland` or universe backports.
3. **Tier 3 (User-Local Binary Releases to `~/.local/bin`)**:
   - `eza`: Official GitHub release binary (`eza-community/eza`).
   - `fastfetch`: Official GitHub release deb/binary (`fastfetch-cli/fastfetch`).
   - `starship`: Official install script / GitHub binary (`starship.rs`).
   - `zoxide`: Official install script / GitHub binary.
   - `quickshell`: GitHub pre-built binary (`outfoxxed/quickshell`) or custom AppImage/build, with Qt6 runtime libraries (`libqt6quick6`, `libqt6qml6`, `qml6-module-qtquick-*`) installed via APT.
4. **Tier 4 (Custom Fonts to `~/.local/share/fonts`)**:
   - MesloLGS Nerd Font, JetBrainsMono Nerd Font downloaded directly into `~/.local/share/fonts` followed by `fc-cache -f`.

### Rationale
- Adheres strictly to Constitution Principle II (Native APT & PPA / Fallback Logic) and Clarification Session: standard packages installed system-wide via APT, direct binaries and fonts scoped to `~/.local/bin` and `~/.local/share/fonts`.
- Avoids root requirement during binary fallback extraction and prevents collision with future APT upgrades.

### Alternatives Considered
- Compiling all missing tools from source with `cargo`/`cmake`: Slows down installation significantly and requires massive compiler toolchains (`rustc`, `gcc`, `llvm`, `qt6-base-dev`).
- Installing everything via Homebrew on Linux: Adds huge overhead, disk footprint, and pathing inconsistencies.

---

## 3. Quickshell and Waybar Configuration Strategy

### Decision
- **Quickshell as Primary**: Ensure Quickshell binary is installed in `~/.local/bin/quickshell` (with symlink/command `qs`), and runtime Qt6 libraries installed via `apt-get install -y libqt6quick6 libqt6qml6 qml6-module-qtquick-*`.
- **Waybar as Secondary Fallback**: Pre-install `waybar` via APT and maintain ML4W Waybar configuration folders in `~/.config/waybar`. Include an easy toggle or autostart fallback check (`command -v qs &>/dev/null && qs ... || waybar`).

### Rationale
- Matches user preference ("quickshell as default, waybar as fallback").
- Prevents desktop breakage if a user's GPU driver lacks Vulkan/Qt6 hardware acceleration needed by Quickshell.

---

## 4. Shell Shims & Command Normalization

### Decision
In `~/.config/bashrc/10-aliases`, `~/.config/zshrc/25-aliases`, and `~/.config/fish/conf.d/10-aliases.fish`:
- Check if `batcat` exists and `bat` is not present, add `alias bat='batcat'`.
- Check if `fdfind` exists and `fd` is not present, add `alias fd='fdfind'`.
- Ensure `~/.local/bin` is exported in `$PATH` across `.bashrc`, `.zshrc`, and `.config/fish/config.fish`.

### Rationale
- Completely preserves cross-distro compatibility on Arch/Fedora (where binary names are `bat` and `fd`) while transparently fixing Debian/Ubuntu naming divergence.

---

## 5. Safe Backup & Idempotency Design

### Decision
1. **Backup Routine**:
   - Before any directory or file copy/symlink, execute `create_backup()`.
   - Backup destination: `~/.mydotfiles/backups/ml4w-backup-$(date +%Y%m%d-%H%M%S)`.
   - Copies existing `~/.config` targets (e.g. `hypr`, `quickshell`, `waybar`, `swaync`, `rofi`, `kitty`, `alacritty`, `fastfetch`, `bashrc`, `zshrc`).
2. **Idempotent Copy/Link**:
   - Use `rsync -aL --exclude='.git/'` for clean sync without recursive symlink loop traps.
   - Guard shell config additions so duplicate lines are never appended if marker blocks already exist.

### Rationale
- Enforces Constitution Principles I & IV. Prevents user data loss and allows safe multiple runs.

---

## 6. Dry Run & Automated Container Verification

### Decision
- Add `--dry-run` flag parsing at script start. When set, all mutation functions (`apt-get`, `rsync`, `mkdir`, `cp`, `chmod`) print planned commands in yellow without executing.
- Create a test verification script (`tests/verify-ubuntu-install.sh` and `Dockerfile.ubuntu2404`) that runs non-interactively (`--dry-run` and full mock run) in an Ubuntu 24.04 container.

### Rationale
- Guarantees automated testability (Functional Requirement FR-011 and FR-012, Success Criteria SC-004).
