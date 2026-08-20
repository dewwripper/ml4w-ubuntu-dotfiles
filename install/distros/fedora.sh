#!/bin/bash
# ==============================================================================
# Fedora / DNF Distribution Package Handler
# ==============================================================================

install_fedora_packages() {
    log_header "📦 Fedora Package Installation"

    ensure_sudo

    local fedora_pkgs=(
        "cava"
        "zoxide"
        "rsync"
        "socat"
        "curl"
        "wget"
        "git"
        "jq"
        "ripgrep"
        "fzf"
        "bat"
        "fd-find"
        "zsh"
        "fastfetch"
        "eza"
        "starship"
        "brightnessctl"
        "pamixer"
        "playerctl"
        "wl-clipboard"
        "cliphist"
        "papirus-icon-theme"
        "kitty"
        "alacritty"
        "pavucontrol"
        "waybar"
    )

    local pkgs_to_install=()

    for pkg in "${fedora_pkgs[@]}"; do
        if rpm -q "$pkg" &>/dev/null || has_cmd "$pkg"; then
            log_info "$pkg is already installed."
        else
            pkgs_to_install+=("$pkg")
        fi
    done

    if [ ${#pkgs_to_install[@]} -gt 0 ]; then
        log_info "Installing Fedora packages: ${pkgs_to_install[*]}"
        if [ "$DRY_RUN" = true ]; then
            log_dry "sudo dnf install -y ${pkgs_to_install[*]}"
        else
            sudo dnf install -y "${pkgs_to_install[@]}" || {
                log_warn "Some packages could not be installed via DNF. Check Copr repositories."
            }
        fi
    else
        log_success "All core Fedora packages are already satisfied."
    fi

    return 0
}
