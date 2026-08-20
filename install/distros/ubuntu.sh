#!/bin/bash
# ==============================================================================
# Ubuntu / Debian Distribution Package Handler
# ==============================================================================

install_ubuntu_packages() {
    log_header "📦 Ubuntu / Debian Package Installation"

    ensure_sudo

    # Update APT repository index
    log_info "Updating APT package lists..."
    if [ "$DRY_RUN" = true ]; then
        log_dry "sudo apt-get update"
    else
        sudo DEBIAN_FRONTEND=noninteractive apt-get update -y || {
            log_warn "APT update encountered warnings. Continuing..."
        }
    fi

    # Standard APT packages
    local core_pkgs=(
        # Core & CLI Tools
        "curl"
        "wget"
        "git"
        "tar"
        "unzip"
        "rsync"
        "socat"
        "jq"
        "ripgrep"
        "fzf"
        "bat"
        "fd-find"
        "zsh"
        "cava"
        "brightnessctl"
        "pamixer"
        "playerctl"
        "wl-clipboard"
        "cliphist"
        # Appearance & Themes
        "papirus-icon-theme"
        "adwaita-icon-theme"
        "fonts-font-awesome"
        # Qt6 Runtime for Quickshell
        "libqt6quick6"
        "libqt6qml6"
        "libqt6svg6"
        "qml6-module-qtquick"
        "qml6-module-qtquick-controls"
        "qml6-module-qtquick-layouts"
        "qml6-module-qtquick-window"
        "qml6-module-qtquick-shapes"
        "qml6-module-qtcore"
        # Desktop & Wayland
        "waybar"
        "sway-notification-center"
        "rofi-wayland"
        "hyprpaper"
        "hyprlock"
        "hypridle"
        "xdg-desktop-portal-hyprland"
        "kitty"
        "alacritty"
        "pavucontrol"
    )

    local pkgs_to_install=()

    for pkg in "${core_pkgs[@]}"; do
        if dpkg -s "$pkg" &>/dev/null; then
            log_info "$pkg is already installed."
        else
            pkgs_to_install+=("$pkg")
        fi
    done

    if [ ${#pkgs_to_install[@]} -gt 0 ]; then
        log_info "Installing ${#pkgs_to_install[@]} APT packages: ${pkgs_to_install[*]}"
        if [ "$DRY_RUN" = true ]; then
            log_dry "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${pkgs_to_install[*]}"
        else
            # Install packages individually or collectively with fallback handling
            for pkg in "${pkgs_to_install[@]}"; do
                log_info "Installing $pkg..."
                sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$pkg" || {
                    log_warn "Package '$pkg' could not be installed via standard APT. Will rely on fallbacks if available."
                }
            done
        fi
    else
        log_success "All core APT packages are already satisfied."
    fi

    # Check for Hyprland package on Ubuntu
    if ! has_cmd hyprland; then
        log_info "Checking Hyprland availability on Ubuntu..."
        if [ "$DRY_RUN" = true ]; then
            log_dry "Check/Add ppa:hyprland-community/hyprland if hyprland is missing"
        else
            if apt-cache show hyprland &>/dev/null; then
                sudo DEBIAN_FRONTEND=noninteractive apt-get install -y hyprland || true
            else
                log_info "Adding Hyprland Community PPA..."
                sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:hyprland-community/hyprland 2>/dev/null || true
                sudo DEBIAN_FRONTEND=noninteractive apt-get update -y 2>/dev/null || true
                sudo DEBIAN_FRONTEND=noninteractive apt-get install -y hyprland 2>/dev/null || {
                    log_warn "Hyprland could not be installed via PPA. Please verify Wayland desktop compositor manually."
                }
            fi
        fi
    fi

    log_success "Ubuntu package installation phase completed."
    return 0
}
