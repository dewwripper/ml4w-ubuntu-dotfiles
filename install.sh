#!/bin/bash
# ==============================================================================
# ML4W Multi-Distro Dotfiles & Environment Installer
# Supports: Ubuntu/Debian, Arch Linux, Fedora, openSUSE
# ==============================================================================

set -e

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
TARGET_STORAGE="${HOME}/.mydotfiles/com.ml4w.dotfiles"
INSTALLER_DIR="${HOME}/ml4w-dotfiles-installer"
PROFILE_URL="https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/hyprland-dotfiles.dotinst"

# Source helper modules
# shellcheck source=install/common.sh
source "${REPO_ROOT}/install/common.sh"
# shellcheck source=install/os-detect.sh
source "${REPO_ROOT}/install/os-detect.sh"
# shellcheck source=install/backup.sh
source "${REPO_ROOT}/install/backup.sh"
# shellcheck source=install/distros/ubuntu.sh
source "${REPO_ROOT}/install/distros/ubuntu.sh"
# shellcheck source=install/distros/arch.sh
source "${REPO_ROOT}/install/distros/arch.sh"
# shellcheck source=install/distros/fedora.sh
source "${REPO_ROOT}/install/distros/fedora.sh"
# shellcheck source=install/distros/suse.sh
source "${REPO_ROOT}/install/distros/suse.sh"
# shellcheck source=install/fallbacks/quickshell.sh
source "${REPO_ROOT}/install/fallbacks/quickshell.sh"
# shellcheck source=install/fallbacks/tools.sh
source "${REPO_ROOT}/install/fallbacks/tools.sh"
# shellcheck source=install/fallbacks/fonts.sh
source "${REPO_ROOT}/install/fallbacks/fonts.sh"

# Default flags
DRY_RUN=false
NON_INTERACTIVE=false
SKIP_BACKUP=false
SKIP_PACKAGES=false
PREFERRED_BAR="quickshell"

show_help() {
    cat << 'EOF'
ML4W Multi-Distro Dotfiles Installer

Usage:
  ./install.sh [OPTIONS]

Options:
  -h, --help           Show this help message and exit
  -d, --dry-run        Simulate installation without modifying files or packages
  -y, --noconfirm      Run non-interactively (accept all prompts)
  -b, --bar <type>     Preferred status bar: 'quickshell' (default) or 'waybar'
      --skip-backup    Skip configuration backup step
      --skip-packages  Skip package installation (dotfiles sync only)

Supported Distributions:
  • Ubuntu 24.04 LTS+ / Debian 12+
  • Arch Linux / CachyOS / EndeavourOS
  • Fedora 40+
  • openSUSE Tumbleweed / Leap
EOF
    exit 0
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -y|--noconfirm|--yes)
            NON_INTERACTIVE=true
            shift
            ;;
        -b|--bar)
            PREFERRED_BAR="$2"
            shift 2
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --skip-packages)
            SKIP_PACKAGES=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            ;;
    esac
done

export DRY_RUN NON_INTERACTIVE

# ==============================================================================
# 1. OS DETECTION
# ==============================================================================
log_header "🔍 Host Environment Detection"
detect_os || {
    log_error "Unsupported host operating system."
    exit 2
}

log_info "Detected OS: ${OS_ID} (Family: ${OS_FAMILY}, ID_LIKE: ${OS_ID_LIKE:-none}, Version: ${OS_VERSION_ID:-unknown})"
log_info "Target Package Manager: ${PKG_MANAGER:-none}"
log_info "Repository Root: ${REPO_ROOT}"
log_info "Target Dotfiles Storage: ${TARGET_STORAGE}"

if [ "$DRY_RUN" = true ]; then
    log_dry "Dry-run mode active. No filesystem or system modifications will be committed."
fi

# ==============================================================================
# 2. CONFIGURATION BACKUP
# ==============================================================================
if [ "$SKIP_BACKUP" = false ]; then
    log_header "💾 Pre-Installation Backup"
    create_backup
else
    log_info "Skipping pre-installation backup as requested."
fi

# ==============================================================================
# 3. DISTRIBUTION PACKAGES INSTALLATION
# ==============================================================================
if [ "$SKIP_PACKAGES" = false ]; then
    case "$OS_FAMILY" in
        DEBIAN)
            install_ubuntu_packages
            ;;
        ARCH)
            install_arch_packages
            ;;
        FEDORA)
            install_fedora_packages
            ;;
        SUSE)
            install_suse_packages
            ;;
        *)
            log_warn "Unknown OS family ($OS_FAMILY). Skipping distro-specific package manager."
            ;;
    esac

    # 4. FALLBACK DEPLOYERS (Tools, Quickshell, Fonts)
    log_header "🚀 Fallback & User-Level Asset Deployment"
    install_tools_fallbacks
    install_fonts_fallback

    if [[ "$PREFERRED_BAR" == "quickshell" ]]; then
        install_quickshell_fallback
    fi
else
    log_info "Skipping package installation and fallbacks as requested."
fi

# ==============================================================================
# 5. UPSTREAM ML4W PROFILE (ARCH ONLY)
# ==============================================================================
if [[ "$OS_FAMILY" == "ARCH" && "$SKIP_PACKAGES" = false ]]; then
    log_header "📦 Upstream ML4W Profile Installer"
    if [ ! -d "$INSTALLER_DIR" ]; then
        run_cmd git clone https://github.com/mylinuxforwork/ml4w-dotfiles-installer.git "$INSTALLER_DIR"
    else
        log_info "Updating ML4W Installer..."
        if [ "$DRY_RUN" = false ]; then
            (cd "$INSTALLER_DIR" && git pull) || true
        fi
    fi

    if [ "$DRY_RUN" = false ] && [ -d "$INSTALLER_DIR" ]; then
        (cd "$INSTALLER_DIR" && make install) || true
        if [ -x "$HOME/.local/bin/ml4w-dotfiles-installer" ]; then
            log_info "Running ML4W Profile Installer..."
            "$HOME/.local/bin/ml4w-dotfiles-installer" --install "$PROFILE_URL" || true
        fi
    fi
fi

# ==============================================================================
# 6. OVERRIDE WITH CUSTOM DOTFILES
# ==============================================================================
log_header "🔄 Applying Custom Dotfile Overrides"

run_cmd mkdir -p "$TARGET_STORAGE/.config"

# Also sync base ML4W payload if present
if [ -d "$REPO_ROOT/.mydotfiles/com.ml4w.dotfiles" ]; then
    if has_cmd rsync; then
        run_cmd rsync -a --exclude='.git/' "$REPO_ROOT/.mydotfiles/com.ml4w.dotfiles/" "$TARGET_STORAGE/"
    fi
fi

log_info "Merging custom dotfiles into $TARGET_STORAGE/.config/..."
if has_cmd rsync; then
    run_cmd rsync -aL --exclude='.git/' "$REPO_ROOT/.config/" "$TARGET_STORAGE/.config/"
else
    run_cmd cp -rLf "$REPO_ROOT/.config/"* "$TARGET_STORAGE/.config/"
fi

# Ensure custom scripts remain executable
run_cmd chmod +x "$TARGET_STORAGE/.config/hypr/conf/custom/workspace-wallpapers.sh" 2>/dev/null || true

# Specific failsafes
log_info "Enforcing critical shell and quickshell files..."
run_cmd mkdir -p "$TARGET_STORAGE/.config/quickshell"
run_cmd cp -f "$REPO_ROOT/.config/quickshell/shell.qml" "$TARGET_STORAGE/.config/quickshell/shell.qml" 2>/dev/null || true

run_cmd mkdir -p "$TARGET_STORAGE/.config/bashrc" "$TARGET_STORAGE/.config/zshrc" "$TARGET_STORAGE/.config/fish/conf.d"
run_cmd cp -f "$REPO_ROOT/.mydotfiles/com.ml4w.dotfiles/.config/bashrc/10-aliases" "$TARGET_STORAGE/.config/bashrc/10-aliases" 2>/dev/null || true
run_cmd cp -f "$REPO_ROOT/.mydotfiles/com.ml4w.dotfiles/.config/zshrc/25-aliases" "$TARGET_STORAGE/.config/zshrc/25-aliases" 2>/dev/null || true
run_cmd cp -f "$REPO_ROOT/.config/fish/conf.d/10-aliases.fish" "$TARGET_STORAGE/.config/fish/conf.d/10-aliases.fish" 2>/dev/null || true

# Deploy root .zshrc
log_info "Deploying Zsh configuration (.zshrc)..."
run_cmd cp -f "$REPO_ROOT/.zshrc" "$TARGET_STORAGE/.zshrc" 2>/dev/null || true
run_cmd cp -f "$REPO_ROOT/.zshrc" "$HOME/.zshrc" 2>/dev/null || true

# Link configurations into ~/.config
log_info "Linking configurations into $HOME/.config/..."
run_cmd mkdir -p "$HOME/.config"
if [ "$DRY_RUN" = true ]; then
    log_dry "Symlink configurations from $TARGET_STORAGE/.config/ into $HOME/.config/"
else
    for item in "$TARGET_STORAGE/.config/"*; do
        [ -e "$item" ] || continue
        base=$(basename "$item")
        if [ -d "$HOME/.config/$base" ] && [ ! -L "$HOME/.config/$base" ]; then
            rm -rf "$HOME/.config/$base"
        fi
        ln -sfn "$item" "$HOME/.config/$base" 2>/dev/null || true
    done
fi

# ==============================================================================
# 7. DEFAULT SHELL CONFIGURATION
# ==============================================================================
configure_default_shell

log_header "✅ Installation & Synchronization Summary"
echo "
============================================================
        ✅ ML4W DOTFILES SETUP COMPLETED SUCCESSFULLY
============================================================

Host Operating System: ${OS_ID} (${OS_FAMILY})
Status Bar Mode:       ${PREFERRED_BAR}
Dotfile Storage:       ${TARGET_STORAGE}

🐚 Desktop & User Shell:
   • Default Shell: Zsh (configured via ~/.zshrc with Oh My Zsh)
   • Quickshell Bar (Default) with instant OSD, popups & window frame
   • Waybar (Fallback configuration preserved in ~/.config/waybar)

🎨 Theme & Appearance:
   • MesloLGS & JetBrainsMono Nerd Fonts
   • Papirus / Adwaita icon themes & dark mode integration

⌨️ Command Shims:
   • bat (aliased to batcat on Ubuntu/Debian)
   • fd  (aliased to fdfind on Ubuntu/Debian)
   • eza, fastfetch, starship, zoxide in ~/.local/bin/

============================================================
"