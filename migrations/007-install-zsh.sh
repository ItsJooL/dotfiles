#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging and installation utilities
source "$UTILS_DIR/log.sh"
source "$UTILS_DIR/install-package.sh"

SOURCE_CONFIG_DIR="$SCRIPT_DIR/../config/zsh"
TARGET_CONFIG_DIR="$HOME"

info "Installing Zsh..."
install_package zsh
success "Zsh installed successfully!"

info "Linking Zsh configuration with Stow..."
mkdir -p "$TARGET_CONFIG_DIR"
stow -v -R -d "$SOURCE_CONFIG_DIR/.." -t "$TARGET_CONFIG_DIR" zsh
success "Zsh configuration linked successfully!"

# Set Zsh as default shell if possible
ZSH_PATH="$(command -v zsh)"
if ! grep -q "$ZSH_PATH" /etc/shells; then
  info "Adding $ZSH_PATH to /etc/shells..."
  echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$ZSH_PATH" ]; then
  info "Changing default shell to Zsh for user $USER..."
  chsh -s "$ZSH_PATH"
  success "Default shell changed to Zsh. Log out and back in to apply."
else
  info "Zsh is already the default shell."
fi
