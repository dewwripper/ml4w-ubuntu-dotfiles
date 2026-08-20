#!/bin/bash
# ==============================================================================
# CLI Tools Fallback Deployer (eza, fastfetch, starship, zoxide)
# ==============================================================================

install_tools_fallbacks() {
    local target_bin="${HOME}/.local/bin"

    log_info "Verifying CLI tool binaries in ${target_bin}..."

    if [ "$DRY_RUN" = true ]; then
        log_dry "mkdir -p ${target_bin}"
        log_dry "Check/Download eza binary to ${target_bin}/eza"
        log_dry "Check/Download fastfetch binary to ${target_bin}/fastfetch"
        log_dry "Check/Install starship to ${target_bin}/starship"
        log_dry "Check/Install zoxide to ${target_bin}/zoxide"
        return 0
    fi

    mkdir -p "${target_bin}"

    # 1. eza
    if ! has_cmd eza && [ ! -x "${target_bin}/eza" ]; then
        log_info "Installing eza binary..."
        local eza_url
        eza_url=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest 2>/dev/null \
            | grep "browser_download_url.*x86_64.*linux.*tar.gz" \
            | head -n 1 \
            | cut -d '"' -f 4)
        if [ -n "$eza_url" ]; then
            curl -fsSL "$eza_url" | tar -xz -C "${target_bin}" ./eza 2>/dev/null || true
            chmod +x "${target_bin}/eza" 2>/dev/null || true
        fi
    fi

    # 2. fastfetch
    if ! has_cmd fastfetch && [ ! -x "${target_bin}/fastfetch" ]; then
        log_info "Installing fastfetch binary..."
        local ff_url
        ff_url=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest 2>/dev/null \
            | grep "browser_download_url.*linux-amd64.tar.gz" \
            | head -n 1 \
            | cut -d '"' -f 4)
        if [ -n "$ff_url" ]; then
            local tmp_dir
            tmp_dir=$(mktemp -d)
            curl -fsSL "$ff_url" | tar -xz -C "$tmp_dir" 2>/dev/null || true
            find "$tmp_dir" -type f -name fastfetch -exec cp {} "${target_bin}/fastfetch" \; 2>/dev/null || true
            chmod +x "${target_bin}/fastfetch" 2>/dev/null || true
            rm -rf "$tmp_dir"
        fi
    fi

    # 3. starship
    if ! has_cmd starship && [ ! -x "${target_bin}/starship" ]; then
        log_info "Installing starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "${target_bin}" 2>/dev/null || true
    fi

    # 4. zoxide
    if ! has_cmd zoxide && [ ! -x "${target_bin}/zoxide" ]; then
        log_info "Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | BIN_DIR="${target_bin}" sh 2>/dev/null || true
    fi

    log_success "CLI tools fallback check completed."
    return 0
}
