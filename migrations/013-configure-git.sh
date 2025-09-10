#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# Set up the theme and configuration directory.
info "Setting up Git config..."
SOURCE_CONFIG_DIR="$SCRIPT_DIR/../config/"
TARGET_CONFIG_DIR="$HOME/"


stow -v -R -d "$SOURCE_CONFIG_DIR/" -t "$TARGET_CONFIG_DIR" git


sed -i "s|__HOME__|$HOME|g" "$HOME/.gitconfig"