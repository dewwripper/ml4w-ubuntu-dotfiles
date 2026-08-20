#!/bin/bash
# ==============================================================================
# openSUSE / Zypper Distribution Package Handler
# ==============================================================================

install_suse_packages() {
    log_header "📦 openSUSE Package Installation"

    ensure_sudo

    local suse_pkgs=(
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
        "fd"
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

    for pkg in "${suse_pkgs[@]}"; do
        if rpm -q "$pkg" &>/dev/null || has_cmd "$pkg"; then
            log_info "$pkg is already installed."
        else
            pkgs_to_install+=("$pkg")
        fi
    done

    if [ ${#pkgs_to_install[@]} -gt 0 ]; then
        log_info "Installing openSUSE packages: ${pkgs_to_install[*]}"
        if [ "$DRY_RUN" = true ]; then
            log_dry "sudo zypper --non-interactive install ${pkgs_to_install[*]}"
        else
            sudo zypper --non-interactive install "${pkgs_to_install[@]}" || {
                log_warn "Some packages could not be installed via Zypper. Check OBS repositories."
            }
        fi
    else
        log_success "All core openSUSE packages are already satisfied."
    fi

    return 0
}
