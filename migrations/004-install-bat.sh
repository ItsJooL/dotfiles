#!/bin/bash
set -e

# Define script and utility directories relative to the script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source the logging utilities from the 'utils' directory.
source "$UTILS_DIR/log.sh"

# --- Main Script Logic ---

# Check if bat is already installed.
if command -v bat &> /dev/null; then
    info "Bat is already installed. Skipping installation."
else
    info "Installing Bat..."
    "$UTILS_DIR/install-package.sh" bat

    #Ubuntu :/
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
            info "Found 'batcat' binary. Creating a symlink to 'bat'..."
            sudo ln -s "$(which batcat)" /usr/local/bin/bat
            success "Symlink created."
    fi
    success "Bat installation completed!"
fi

# Set up the theme and configuration directory.
info "Setting up Bat config and themes..."
SOURCE_CONFIG_DIR="$SCRIPT_DIR/../config/bat"
TARGET_CONFIG_DIR="$HOME/.config/bat"

mkdir -p "$TARGET_CONFIG_DIR"

stow -v -R -d "$SCRIPT_DIR/../config" -t "$TARGET_CONFIG_DIR" bat
info "Building bat cache..."
bat cache --build
success "Bat configuration linked!"
