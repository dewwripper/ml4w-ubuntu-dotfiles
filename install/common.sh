#!/bin/bash
# ==============================================================================
# Common Helper Functions for ML4W Multi-Distro Installer
# ==============================================================================

# Colors
if [ -t 1 ]; then
    COLOR_RESET="\033[0m"
    COLOR_INFO="\033[38;5;39m"
    COLOR_SUCCESS="\033[38;5;48m"
    COLOR_WARN="\033[38;5;214m"
    COLOR_ERROR="\033[38;5;196m"
    COLOR_DRY="\033[38;5;226m"
    COLOR_BOLD="\033[1m"
else
    COLOR_RESET=""
    COLOR_INFO=""
    COLOR_SUCCESS=""
    COLOR_WARN=""
    COLOR_ERROR=""
    COLOR_DRY=""
    COLOR_BOLD=""
fi

DRY_RUN=${DRY_RUN:-false}
NON_INTERACTIVE=${NON_INTERACTIVE:-false}

log_info() {
    echo -e "${COLOR_INFO}ℹ️  $*${COLOR_RESET}"
}

log_success() {
    echo -e "${COLOR_SUCCESS}✅ $*${COLOR_RESET}"
}

log_warn() {
    echo -e "${COLOR_WARN}⚠️  $*${COLOR_RESET}" >&2
}

log_error() {
    echo -e "${COLOR_ERROR}❌ $*${COLOR_RESET}" >&2
}

log_dry() {
    echo -e "${COLOR_DRY}🔍 [DRY-RUN] $*${COLOR_RESET}"
}

log_header() {
    echo -e "\n${COLOR_BOLD}============================================================${COLOR_RESET}"
    echo -e "${COLOR_BOLD}  $*${COLOR_RESET}"
    echo -e "${COLOR_BOLD}============================================================${COLOR_RESET}"
}

# Run a command or print it in dry-run mode
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        log_dry "$*"
        return 0
    else
        "$@"
    fi
}

# Check if a command is available
has_cmd() {
    command -v "$1" &>/dev/null
}

# Check and verify sudo privileges
ensure_sudo() {
    if [ "$EUID" -eq 0 ]; then
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        log_dry "sudo validation check (simulated)"
        return 0
    fi

    if ! has_cmd sudo; then
        log_error "sudo is not installed and script is not running as root."
        exit 3
    fi

    if [ "$NON_INTERACTIVE" = true ]; then
        if ! sudo -n true 2>/dev/null; then
            log_error "Non-interactive mode requires passwordless sudo permissions or root execution."
            exit 3
        fi
    else
        log_info "Acquiring sudo privileges..."
        sudo -v || {
            log_error "Failed to acquire sudo credentials."
            exit 3
        }
    fi
}

# Change default shell to zsh
configure_default_shell() {
    log_header "🐚 Default Shell Configuration"
    local zsh_bin
    zsh_bin=$(command -v zsh 2>/dev/null || which zsh 2>/dev/null || echo "/usr/bin/zsh")

    if ! has_cmd zsh && [ ! -x "$zsh_bin" ]; then
        log_warn "zsh is not installed. Skipping default shell configuration."
        return 0
    fi

    local current_user="${USER:-$(id -un 2>/dev/null || whoami)}"
    local current_shell
    if has_cmd getent; then
        current_shell=$(getent passwd "$current_user" 2>/dev/null | cut -d: -f7 || echo "$SHELL")
    else
        current_shell="$SHELL"
    fi

    if [[ "$current_shell" == *"/zsh" ]]; then
        log_info "Default shell is already zsh ($current_shell)."
        return 0
    fi

    log_info "Changing default shell to zsh ($zsh_bin) for user $current_user..."
    if [ "$DRY_RUN" = true ]; then
        log_dry "chsh -s $zsh_bin $current_user"
        return 0
    fi

    # Attempt changing shell with chsh or usermod or sudo
    local changed=false
    if chsh -s "$zsh_bin" "$current_user" 2>/dev/null; then
        changed=true
    elif chsh -s "$zsh_bin" 2>/dev/null; then
        changed=true
    elif has_cmd sudo && sudo -n true 2>/dev/null; then
        if sudo chsh -s "$zsh_bin" "$current_user" 2>/dev/null; then
            changed=true
        elif sudo usermod -s "$zsh_bin" "$current_user" 2>/dev/null; then
            changed=true
        fi
    fi

    if [ "$changed" = true ]; then
        log_success "Default shell changed to zsh ($zsh_bin)."
    elif [ "$NON_INTERACTIVE" = false ]; then
        log_info "Please enter your password if prompted by chsh:"
        chsh -s "$zsh_bin" || log_warn "Could not change default shell automatically. Run 'chsh -s $zsh_bin' manually."
    else
        log_warn "Could not change default shell non-interactively without sudo. Please run 'chsh -s $zsh_bin' manually."
    fi

    return 0
}

