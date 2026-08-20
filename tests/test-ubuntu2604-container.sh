#!/bin/bash
# ==============================================================================
# Automated Container Test Script for Ubuntu 26.04 Environment
# ==============================================================================

set -e

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)
cd "$REPO_ROOT"

echo "🧪 Starting Automated Ubuntu 26.04 Installer Verification..."

# 1. Test CLI Help
echo "🧪 [Test 1/4] Verifying CLI --help flag..."
./install.sh --help > /dev/null

# 2. Test Dry-Run Execution on 26.04
echo "🧪 [Test 2/4] Verifying --dry-run simulation on Ubuntu 26.04..."
./install.sh --dry-run --noconfirm

# 3. Test Full Installation if in container
if [ -f /.dockerenv ] || [ "${RUN_FULL_TEST:-false}" = "true" ]; then
    echo "🧪 [Test 3/4] Running full automated installation in Ubuntu 26.04 container..."
    ./install.sh --noconfirm

    # 4. Verify Installed Shims & Dotfiles
    echo "🧪 [Test 4/4] Verifying generated paths and shims on 26.04..."
    test -d "$HOME/.mydotfiles/com.ml4w.dotfiles/.config"
    test -f "$HOME/.local/bin/quickshell" || test -f "$HOME/.local/bin/qs"
    test -f "$HOME/.zshrc"
    grep -q "oh-my-zsh" "$HOME/.zshrc"
fi

echo "✅ All Ubuntu 26.04 verification tests passed successfully!"
exit 0
