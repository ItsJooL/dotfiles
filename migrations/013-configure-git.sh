#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"
source "$UTILS_DIR/stow-config.sh"

# Set up the theme and configuration directory.
info "Setting up Git config..."

if [[ -f "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" ]]; then
    info "~/.gitconfig already exists as an unmanaged file — skipping to preserve existing config."
    exit 0
fi

SOURCE_CONFIG_DIR="$SCRIPT_DIR/../config/"
TARGET_CONFIG_DIR="$HOME/"

stow_config -d "$SOURCE_CONFIG_DIR/" -t "$TARGET_CONFIG_DIR" git