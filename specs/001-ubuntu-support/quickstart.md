# Quickstart & Verification Guide: Ubuntu Support

**Feature**: `001-ubuntu-support`
**Date**: 2026-08-20

This guide outlines runnable end-to-end validation scenarios for the Ubuntu installation workflow, dotfiles sync, and fallback subsystems.

---

## Scenario 1: Dry-Run Inspection on Ubuntu

**Goal**: Verify that `./install.sh --dry-run` accurately detects Ubuntu 24.04 and outputs the planned package installations without mutating the host.

### Execution
```bash
./install.sh --dry-run
```

### Expected Outcome
- Console displays: `Detected OS: Ubuntu (ID: ubuntu, ID_LIKE: debian)`
- Lists APT packages to be installed (`kitty`, `alacritty`, `zsh`, `sway-notification-center`, `waybar`, `rofi-wayland`, `batcat`, `fd-find`, etc.)
- Lists fallback actions (Quickshell binary to `~/.local/bin`, fonts to `~/.local/share/fonts`)
- Lists planned configuration sync paths
- Exit code is `0`
- No changes made to `~/.config` or `/etc/`

---

## Scenario 2: Containerized Automated Verification (Docker)

**Goal**: Execute a complete, non-interactive end-to-end installation test inside a clean Ubuntu 24.04 container.

### Execution
```bash
docker run --rm -v "$(pwd):/repo" -w /repo ubuntu:24.04 bash -c "
  apt-get update && apt-get install -y sudo curl git ca-certificates
  ./install.sh --noconfirm --dry-run
"
```

### Expected Outcome
- Container successfully executes `./install.sh` non-interactively
- Passes package mapping checks and exits with code `0`

---

## Scenario 3: Safe Backup & Idempotency Verification

**Goal**: Verify that pre-existing user configurations are safely backed up to `~/.mydotfiles/backups/` and repeated runs produce identical stable states.

### Execution
```bash
# 1. Create a dummy test config
mkdir -p ~/.config/hypr ~/.config/quickshell
echo "# test" > ~/.config/hypr/test.conf

# 2. Run installer
./install.sh --noconfirm

# 3. Verify backup creation
ls -ld ~/.mydotfiles/backups/ml4w-backup-*

# 4. Re-run installer (idempotency check)
./install.sh --noconfirm
```

### Expected Outcome
- Backup directory created under `~/.mydotfiles/backups/ml4w-backup-YYYYMMDD-HHMMSS/` containing pre-existing files
- Second run completes quickly without duplicate configuration entries or errors

---

## Scenario 4: Command Shim & Shell Alias Resolution

**Goal**: Ensure `bat` and `fd` commands work on Ubuntu despite `batcat` and `fdfind` naming differences.

### Execution
```bash
bash -c "source ~/.bashrc && command -v bat && command -v fd"
zsh -c "source ~/.zshrc && alias bat && alias fd"
```

### Expected Outcome
- `bat` resolves to `batcat` or equivalent wrapper
- `fd` resolves to `fdfind` or equivalent wrapper
- No command-not-found errors during dotfile script invocations
