#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"
source "$UTILS_DIR/stow-config.sh"

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
# Link configuration using stow
config_source="$SCRIPT_DIR/../config"
if [[ -d "$config_source/kitty" ]]; then
    for managed_file in kitty.conf current-theme.conf; do
        managed_path="$HOME/.config/kitty/$managed_file"
        if [[ -e "$managed_path" && ! -L "$managed_path" ]]; then
            info "Removing existing Kitty-managed file: $managed_path"
            rm -f "$managed_path"
        fi
    done
    info "Linking Kitty configuration with stow..."
    stow_config -d "$config_source" -t "$HOME/.config/kitty" kitty
    success "Kitty configuration linked!"
else
    error "Kitty config directory not found at $config_source/kitty"
    exit 1
fi

success "Kitty setup completed successfully!"
