#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

if command -v rofi &> /dev/null; then
    info "rofi is already installed. Skipping installation."
else
    info "Installing rofi..."
    "$UTILS_DIR/install-package.sh" rofi-wayland
fi


# Set up the theme and configuration directory.
info "Setting up rofi config..."
SOURCE_CONFIG_DIR="$SCRIPT_DIR/../config/rofi"
TARGET_CONFIG_DIR="$HOME/.config/rofi"

mkdir -p "$TARGET_CONFIG_DIR"

stow -v -R -d "$SCRIPT_DIR/../config" -t "$TARGET_CONFIG_DIR" rofi

success "rofi configuration linked!"
