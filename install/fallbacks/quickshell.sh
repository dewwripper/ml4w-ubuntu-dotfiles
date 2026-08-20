#!/bin/bash
# ==============================================================================
# Quickshell Desktop Shell Fallback Deployer
# ==============================================================================

install_quickshell_fallback() {
    local target_bin="${HOME}/.local/bin"
    local qs_bin="${target_bin}/quickshell"
    local qs_symlink="${target_bin}/qs"

    log_info "Verifying Quickshell desktop shell installation..."

    if [ "$DRY_RUN" = true ]; then
        log_dry "mkdir -p ${target_bin}"
        log_dry "Check/Download Quickshell binary to ${qs_bin}"
        log_dry "ln -sf ${qs_bin} ${qs_symlink}"
        return 0
    fi

    mkdir -p "${target_bin}"

    if has_cmd quickshell || [ -x "${qs_bin}" ]; then
        log_success "Quickshell is already available."
        [ ! -e "${qs_symlink}" ] && ln -sf "$(command -v quickshell || echo "${qs_bin}")" "${qs_symlink}"
        return 0
    fi

    log_info "Fetching Quickshell prebuilt binary from GitHub release..."
    local arch
    arch="$(uname -m)"
    local release_url=""

    if [[ "$arch" == "x86_64" ]]; then
        # Fetch latest release asset URL from GitHub API or fallback URL
        release_url=$(curl -s https://api.github.com/repos/outfoxxed/quickshell/releases/latest 2>/dev/null \
            | grep "browser_download_url.*quickshell.*x86_64" \
            | head -n 1 \
            | cut -d '"' -f 4)
    fi

    if [ -n "$release_url" ]; then
        log_info "Downloading Quickshell from $release_url..."
        curl -fsSL "$release_url" -o "${qs_bin}" && chmod +x "${qs_bin}"
    fi

    if [ ! -x "${qs_bin}" ]; then
        log_warn "Direct binary download unavailable. Creating Quickshell wrapper shim..."
        cat << 'EOF' > "${qs_bin}"
#!/bin/bash
# Quickshell starter wrapper
if command -v /usr/bin/quickshell &>/dev/null; then
    exec /usr/bin/quickshell "$@"
elif command -v flatpak &>/dev/null && flatpak list | grep -q outfoxxed.quickshell; then
    exec flatpak run outfoxxed.quickshell "$@"
else
    echo "⚠️ Quickshell is not yet installed in system PATH." >&2
    echo "ℹ️ Falling back to Waybar..." >&2
    exec waybar "$@"
fi
EOF
        chmod +x "${qs_bin}"
    fi

    ln -sf "${qs_bin}" "${qs_symlink}"
    log_success "Quickshell configured at ${qs_bin} and ${qs_symlink}."
    return 0
}
