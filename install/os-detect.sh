#!/bin/bash
# ==============================================================================
# OS Detection Module for ML4W Multi-Distro Installer
# ==============================================================================

detect_os() {
    OS_ID=""
    OS_ID_LIKE=""
    OS_VERSION_ID=""
    OS_FAMILY="UNKNOWN"
    PKG_MANAGER=""

    if [ ! -f /etc/os-release ]; then
        log_error "Cannot find /etc/os-release. Unable to determine host OS."
        return 1
    fi

    # Source os-release in a subshell or parse directly to prevent variable pollution
    eval "$(grep -E '^(ID|ID_LIKE|VERSION_ID)=' /etc/os-release | sed 's/^/DETECTED_/')"

    OS_ID="${DETECTED_ID,,}"
    OS_ID_LIKE="${DETECTED_ID_LIKE,,}"
    OS_VERSION_ID="${DETECTED_VERSION_ID}"

    # Match OS family based on ID and ID_LIKE
    if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" || "$OS_ID_LIKE" =~ (ubuntu|debian) ]]; then
        OS_FAMILY="DEBIAN"
        PKG_MANAGER="apt"
    elif [[ "$OS_ID" =~ (arch|cachyos|endeavouros|manjaro|artix) || "$OS_ID_LIKE" =~ (arch) ]]; then
        OS_FAMILY="ARCH"
        PKG_MANAGER="pacman"
    elif [[ "$OS_ID" =~ (fedora|rhel|centos|nobara|almalinux|rocky) || "$OS_ID_LIKE" =~ (fedora|rhel) ]]; then
        OS_FAMILY="FEDORA"
        PKG_MANAGER="dnf"
    elif [[ "$OS_ID" =~ (opensuse|suse|tumbleweed|leap) || "$OS_ID_LIKE" =~ (suse) ]]; then
        OS_FAMILY="SUSE"
        PKG_MANAGER="zypper"
    else
        OS_FAMILY="UNKNOWN"
        PKG_MANAGER=""
    fi

    export OS_ID OS_ID_LIKE OS_VERSION_ID OS_FAMILY PKG_MANAGER
    return 0
}
