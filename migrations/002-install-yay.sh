#!/bin/bash
set -e

# Define script and utility directories relative to the script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source the logging utilities from the 'utils' directory.
source "$UTILS_DIR/log.sh"

# --- System check for Arch Linux ---
if [ ! -f "/etc/arch-release" ]; then
    info "yay is only installed on Arch, it will not be installed."
    exit 0
fi

# --- Check if yay is present ---
if command -v yay &> /dev/null; then
    info "yay is already found, it will not be installed."
    exit 0
fi

# --- Main Script Logic ---
info "Checking for 'git' installation..."
"$UTILS_DIR/install-package.sh" git
info "Cloning yay from the official repository..."
TEMP_DIR=$(mktemp -d)
git clone https://aur.archlinux.org/yay.git "$TEMP_DIR"

info "Building and installing yay..."
cd "$TEMP_DIR"
makepkg -si --noconfirm
cd - > /dev/null
info "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

success "yay is now installed."
