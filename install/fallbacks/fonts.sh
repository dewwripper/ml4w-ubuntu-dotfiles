#!/bin/bash
# ==============================================================================
# Nerd Fonts Fallback Deployer
# ==============================================================================

install_fonts_fallback() {
    local font_dir="${HOME}/.local/share/fonts"

    log_info "Verifying Nerd Fonts in ${font_dir}..."

    if [ "$DRY_RUN" = true ]; then
        log_dry "mkdir -p ${font_dir}"
        log_dry "Check/Download MesloLGS & JetBrainsMono Nerd Fonts to ${font_dir}"
        log_dry "fc-cache -f ${font_dir}"
        return 0
    fi

    mkdir -p "${font_dir}"

    local need_cache=false

    # Check for JetBrainsMono or Meslo
    if ! find "${font_dir}" -iname "*NerdFont*" 2>/dev/null | grep -q .; then
        log_info "Downloading MesloLGS Nerd Font..."
        local font_zip="/tmp/Meslo.zip"
        curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip" -o "$font_zip" 2>/dev/null || true
        if [ -f "$font_zip" ]; then
            unzip -q -o "$font_zip" -d "${font_dir}/Meslo" 2>/dev/null || true
            rm -f "$font_zip"
            need_cache=true
        fi

        log_info "Downloading JetBrainsMono Nerd Font..."
        local jb_zip="/tmp/JetBrainsMono.zip"
        curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -o "$jb_zip" 2>/dev/null || true
        if [ -f "$jb_zip" ]; then
            unzip -q -o "$jb_zip" -d "${font_dir}/JetBrainsMono" 2>/dev/null || true
            rm -f "$jb_zip"
            need_cache=true
        fi
    else
        log_info "Nerd Fonts are already present in ${font_dir}."
    fi

    if [ "$need_cache" = true ] && has_cmd fc-cache; then
        log_info "Refreshing font cache..."
        fc-cache -f "${font_dir}" 2>/dev/null || true
    fi

    log_success "Font configuration check completed."
    return 0
}
