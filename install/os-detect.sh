#!/bin/bash
# ==============================================================================
# OS Detection Module for ML4W Multi-Distro Installer
# ==============================================================================

detect_os() {
    OS_ID=""
    OS_ID_LIKE=""
    OS_VERSION_ID=""
    OS_CODENAME=""
    OS_VERSION_MAJOR=""
    OS_FAMILY="UNKNOWN"
    PKG_MANAGER=""

    local os_file="${OS_RELEASE_FILE:-/etc/os-release}"

    if [ ! -f "$os_file" ]; then
        log_error "Cannot find ${os_file}. Unable to determine host OS."
        return 1
    fi

    # Source os-release variables safely
    eval "$(grep -E '^(ID|ID_LIKE|VERSION_ID|VERSION_CODENAME)=' "$os_file" | sed 's/^/DETECTED_/')"

    OS_ID="$(echo "${DETECTED_ID}" | tr '[:upper:]' '[:lower:]')"
    OS_ID_LIKE="$(echo "${DETECTED_ID_LIKE}" | tr '[:upper:]' '[:lower:]')"
    OS_VERSION_ID="${DETECTED_VERSION_ID}"
    OS_CODENAME="$(echo "${DETECTED_VERSION_CODENAME}" | tr '[:upper:]' '[:lower:]')"

    # Extract major version number (e.g. 26 from 26.04)
    if [[ "$OS_VERSION_ID" =~ ^([0-9]+) ]]; then
        OS_VERSION_MAJOR="${BASH_REMATCH[1]}"
    fi

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

    export OS_ID OS_ID_LIKE OS_VERSION_ID OS_CODENAME OS_VERSION_MAJOR OS_FAMILY PKG_MANAGER
    return 0
}
