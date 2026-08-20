#!/bin/bash
# ==============================================================================
# Arch Linux / Pacman / AUR Distribution Package Handler
# ==============================================================================

install_arch_packages() {
    log_header "📦 Arch Linux Package Installation"

    ensure_sudo

    local arch_pkgs=(
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
        "ttf-jetbrains-mono-nerd"
        "ttf-meslo-nerd"
        "kitty"
        "alacritty"
        "pavucontrol"
    )

    local pkgs_to_install=()

    for pkg in "${arch_pkgs[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null || has_cmd "$pkg"; then
            log_info "$pkg is already installed."
        else
            pkgs_to_install+=("$pkg")
        fi
    done

    if [ ${#pkgs_to_install[@]} -gt 0 ]; then
        log_info "Installing Arch packages: ${pkgs_to_install[*]}"
        if [ "$DRY_RUN" = true ]; then
            log_dry "sudo pacman -Sy --noconfirm ${pkgs_to_install[*]}"
        else
            sudo pacman -Sy --noconfirm "${pkgs_to_install[@]}" || {
                log_warn "Some packages failed to install via pacman. Check AUR availability."
            }
        fi
    else
        log_success "All core Arch packages are already installed."
    fi

    return 0
}
