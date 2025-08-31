#!/bin/bash
set -e

# Define script and utility directories relative to the script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source the logging utilities from the 'utils' directory.
source "$UTILS_DIR/log.sh"

# --- Main Script Logic ---
# Check if tmux is already installed.
if command -v tmux &> /dev/null; then
    info "tmux is already installed. Skipping installation."
else
    info "Installing tmux..."
    "$UTILS_DIR/install-package.sh" tmux

    success "tmux installation completed!"
fi

# Set up the tmux configuration directory.
info "Setting up tmux config..."
TARGET_DIR="$HOME/.config/tmux"
mkdir -p "$TARGET_DIR"
stow -v -R -d "$SCRIPT_DIR/../config/tmux" -t "$TARGET_DIR"
success "tmux configuration linked!"
