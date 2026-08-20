#!/bin/bash
# ==============================================================================
# Configuration Backup Module for ML4W Multi-Distro Installer
# ==============================================================================

create_backup() {
    local backup_timestamp
    backup_timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_root="${HOME}/.mydotfiles/backups/ml4w-backup-${backup_timestamp}"
    local backed_up_count=0

    log_info "Checking for existing configurations to back up..."

    # List of directories/files to back up if present
    local targets=(
        "${HOME}/.config/hypr"
        "${HOME}/.config/quickshell"
        "${HOME}/.config/waybar"
        "${HOME}/.config/swaync"
        "${HOME}/.config/rofi"
        "${HOME}/.config/kitty"
        "${HOME}/.config/alacritty"
        "${HOME}/.config/fastfetch"
        "${HOME}/.config/bashrc"
        "${HOME}/.config/zshrc"
        "${HOME}/.config/fish"
        "${HOME}/.config/ml4w"
        "${HOME}/.config/ml4w-dotfiles-settings"
        "${HOME}/.config/ml4w-dotfiles-installer"
        "${HOME}/.bashrc"
        "${HOME}/.zshrc"
    )

    for target in "${targets[@]}"; do
        if [ -e "$target" ]; then
            if [ "$backed_up_count" -eq 0 ]; then
                if [ "$DRY_RUN" = true ]; then
                    log_dry "mkdir -p ${backup_root}"
                else
                    mkdir -p "${backup_root}"
                fi
            fi

            local rel_path
            rel_path="${target#$HOME/}"
            local dest_dir
            dest_dir="${backup_root}/$(dirname "$rel_path")"

            if [ "$DRY_RUN" = true ]; then
                log_dry "Backing up ${target} -> ${backup_root}/${rel_path}"
            else
                mkdir -p "$dest_dir"
                cp -a "$target" "$dest_dir/" 2>/dev/null || true
            fi
            backed_up_count=$((backed_up_count + 1))
        fi
    done

    if [ "$backed_up_count" -gt 0 ]; then
        if [ "$DRY_RUN" = true ]; then
            log_dry "Backup would be created at: ${backup_root} (${backed_up_count} items)"
        else
            log_success "Backup created at: ${backup_root} (${backed_up_count} items backed up)"
        fi
    else
        log_info "No pre-existing ML4W configurations found to back up."
    fi

    export LAST_BACKUP_DIR="${backup_root}"
    return 0
}
