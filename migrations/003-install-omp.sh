#!/bin/bash
set -e

# Define script and utility directories relative to the script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source the logging utilities from the 'utils' directory.
source "$UTILS_DIR/log.sh"

# --- Main Script Logic ---

# Check if Oh My Posh is already installed.
if command -v oh-my-posh &> /dev/null; then
    info "Oh My Posh is already installed. Skipping installation."
else
    info "Installing Oh My Posh..."
    info "Checking for 'curl' installation..."
    "$UTILS_DIR/install-package.sh" curl

    TEMP_DIR=$(mktemp -d)
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$TEMP_DIR"

    info "Installing Oh My Posh to /usr/local/bin..."
    sudo install -Dm755 "$TEMP_DIR/oh-my-posh" /usr/local/bin/oh-my-posh
    info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    success "Oh My Posh installation completed!"
fi

# Set up the theme directory.
info "Setting up Oh My Posh config..."
SOURCE_CONFIG_DIR="$SCRIPT_DIR/../config/prompt/omp"
TARGET_CONFIG_DIR="$HOME/.config"
mkdir -p "$TARGET_CONFIG_DIR/oh-my-posh"
stow -v -R -d "$SOURCE_CONFIG_DIR/.." -t "$TARGET_CONFIG_DIR" omp
success "Oh My Posh configuration linked!"
