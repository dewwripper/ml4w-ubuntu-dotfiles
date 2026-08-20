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
        # Qt6 Runtime for Quickshell & Modern Desktop
        "libqt6quick6"
        "libqt6qml6"
        "libqt6svg6"
        "libqt6waylandclient6"
        "qt6-qpa-plugins"
        "qml6-module-qtquick"
        "qml6-module-qtquick-controls"
        "qml6-module-qtquick-layouts"
        "qml6-module-qtquick-window"
        "qml6-module-qtquick-shapes"
        "qml6-module-qtqml-workerscript"
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
            # Install packages with graceful individual fallback
            for pkg in "${pkgs_to_install[@]}"; do
                if apt-cache show "$pkg" &>/dev/null; then
                    log_info "Installing $pkg..."
                    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$pkg" || {
                        log_warn "Package '$pkg' installation failed. Continuing with fallbacks..."
                    }
                else
                    log_warn "Package '$pkg' not found in active APT repositories for ${OS_ID} ${OS_VERSION_ID:-26.04}. Will use fallbacks."
                fi
            done
        fi
    else
        log_success "All core APT packages are already satisfied."
    fi

    # Check for Hyprland package on Ubuntu
    if ! has_cmd hyprland; then
        log_info "Checking Hyprland availability on Ubuntu (${OS_VERSION_ID:-26.04})..."
        if [ "$DRY_RUN" = true ]; then
            log_dry "Check/Add ppa:hyprland-community/hyprland if hyprland is missing, with automatic 404 rollback"
        else
            if apt-cache show hyprland &>/dev/null; then
                sudo DEBIAN_FRONTEND=noninteractive apt-get install -y hyprland || true
            else
                log_info "Attempting Hyprland Community PPA configuration..."
                local ppa_added=false
                if sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:hyprland-community/hyprland 2>/dev/null; then
                    ppa_added=true
                    if ! sudo DEBIAN_FRONTEND=noninteractive apt-get update -y 2>/dev/null; then
                        log_warn "Hyprland PPA lacks suite for ${OS_CODENAME:-$OS_VERSION_ID}. Removing invalid PPA to preserve APT health..."
                        sudo DEBIAN_FRONTEND=noninteractive add-apt-repository --remove -y ppa:hyprland-community/hyprland 2>/dev/null || true
                        sudo DEBIAN_FRONTEND=noninteractive apt-get update -y 2>/dev/null || true
                        ppa_added=false
                    fi
                fi

                if [ "$ppa_added" = true ]; then
                    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y hyprland 2>/dev/null || {
                        log_warn "Hyprland could not be installed from PPA."
                    }
                fi
            fi
        fi
    fi

    log_success "Ubuntu package installation phase completed."
    return 0
}
