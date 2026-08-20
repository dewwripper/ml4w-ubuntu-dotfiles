#!/bin/bash
# ==============================================================================
# Automated Container Test Script for Ubuntu 24.04 Environment
# ==============================================================================

set -e

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)
cd "$REPO_ROOT"

echo "🧪 Starting Automated Ubuntu Installer Verification..."

# 1. Test CLI Help & Option Parsing
echo "🧪 [Test 1/4] Verifying CLI --help flag..."
./install.sh --help > /dev/null

# 2. Test Dry-Run Execution
echo "🧪 [Test 2/4] Verifying --dry-run simulation..."
./install.sh --dry-run --noconfirm

# 3. Test Full Package & Dotfile Installation (if running in container)
if [ -f /.dockerenv ] || [ "${RUN_FULL_TEST:-false}" = "true" ]; then
    echo "🧪 [Test 3/4] Running full automated installation in container..."
    ./install.sh --noconfirm

    # 4. Verify Installed Shims & Dotfiles
    echo "🧪 [Test 4/4] Verifying generated paths and shims..."
    test -d "$HOME/.mydotfiles/com.ml4w.dotfiles/.config"
    test -f "$HOME/.local/bin/quickshell" || test -f "$HOME/.local/bin/qs"
fi

echo "✅ All Ubuntu verification tests passed successfully!"
exit 0
