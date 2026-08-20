# Technical Research & Findings: Ubuntu 26.04 Compatibility & Refactoring

**Feature**: `002-ubuntu-2604-compatibility`
**Date**: 2026-08-20

## 1. Ubuntu 26.04 Identification & Codename Parsing

### Decision
Enhance `install/os-detect.sh` to extract `VERSION_CODENAME` alongside `VERSION_ID` from `/etc/os-release` and export `OS_CODENAME` and `OS_VERSION_MAJOR` (e.g., `26`).

### Rationale
- Allows conditional package logic where Ubuntu 26.04 packages differ from Ubuntu 24.04 (`noble`).
- Supports pre-release / rolling Ubuntu installations where `VERSION_ID` might be empty or `devel`.

---

## 2. Robust PPA Suite Validation & Safe Fallback

### Decision
In `install/distros/ubuntu.sh`, wrap third-party PPA additions (such as `ppa:hyprland-community/hyprland`) with an automated verification check. If the PPA does not provide packages for the host's Ubuntu release (or if `apt-get update` returns 404 for the PPA), automatically purge the invalid PPA entry and route directly to the user-level binary fallback deployer (`~/.local/bin`).

### Rationale
- Ubuntu 26.04 may not have active builds in older PPAs created for 24.04.
- Prevents breaking APT package updates for the entire user system while ensuring Hyprland/Quickshell still install via GitHub binary fallbacks.

---

## 3. Qt6 / Wayland Runtime Library Stack on Ubuntu 26.04

### Decision
Expand the Qt6 package list to include modular packages present in modern Ubuntu:
- `libqt6quick6`, `libqt6qml6`, `libqt6svg6`, `libqt6waylandclient6`, `qt6-qpa-plugins`
- `qml6-module-qtquick*`, `qml6-module-qtcore`, `qml6-module-qtqml-workerscript`

Use a resilient package probe loop: iterate through candidates, installing what is available in the release repository without failing on single missing transitional package names.

### Rationale
- Ensures Quickshell and Qt6 plugins find all necessary rendering libraries on Ubuntu 26.04 Wayland without segmentation faults or missing plugin errors.

---

## 4. Multi-Release Docker Testing Matrix

### Decision
Introduce `tests/Dockerfile.ubuntu2604` and `tests/test-ubuntu2604-container.sh` to test against `ubuntu:26.04` (and `ubuntu:devel` as a fallback image for pre-release validation).

### Rationale
- Verifies both 24.04 LTS and 26.04 LTS pipelines in CI.
