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
