#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# Check if kitty is already installed
if command -v kitty >/dev/null 2>&1; then
    info "Kitty is already installed. Skipping installation."
else
    info "Installing Kitty..."
    "$UTILS_DIR/install-package.sh" kitty
    success "Kitty installation completed!"
fi

# Setup kitty configuration
info "Setting up Kitty configuration..."
mkdir -p "$HOME/.config/kitty"

info "Applying Catppuccin Mocha theme..."
kitty +kitten themes --reload-in=all Catppuccin-Mocha
rm "$HOME/.config/kitty/kitty.conf" # delete the generated one.
# Link configuration using stow
config_source="$SCRIPT_DIR/../config"
if [[ -d "$config_source/kitty" ]]; then
    info "Linking Kitty configuration with stow..."
    stow -v -R -d "$config_source" -t "$HOME/.config/kitty" kitty
    success "Kitty configuration linked!"
else
    error "Kitty config directory not found at $config_source/kitty"
    exit 1
fi

success "Kitty setup completed successfully!"
