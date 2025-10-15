#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging
source "$UTILS_DIR/log.sh"


if command -v nvim &> /dev/null; then
    info "Neovim is already installed. Skipping installation."
else
	"$UTILS_DIR/install-package.sh" neovim
	"$UTILS_DIR/install-package.sh" gcc # needed for treesitter
    success "Neovim installation completed!"
fi

# Set up the configuration directory.
info "Setting up Neovim config and themes..."
SOURCE_CONFIG_DIR="$SCRIPT_DIR/../config/nvim"
TARGET_CONFIG_DIR="$HOME/.config/nvim"

mkdir -p "$TARGET_CONFIG_DIR"

stow -v -R -d "$SCRIPT_DIR/../config" -t "$TARGET_CONFIG_DIR" nvim
success "Neovim configuration linked!"

