#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# Install Catppuccin GTK themes (optional - only if user wants actual themes)
install_catppuccin_gtk_themes() {
    info "This migration provides Catppuccin GTK theme configurations."
    info "To install actual GTK themes, you can:"
    info "  1. Install via package manager (if available):"
    info "     - Arch: yay -S catppuccin-gtk-theme-mocha"
    info "     - Manual: Clone https://github.com/catppuccin/gtk"
    info "  2. Or install manually from: https://github.com/catppuccin/gtk"
    info ""
    info "The configurations are already set up and will work when themes are installed."
}

# Link GTK configuration files
link_gtk_configs() {
    info "Linking GTK configuration files..."
    
    local config_source="$SCRIPT_DIR/../config"
    local configs_to_link=("gtk")
    
    for config in "${configs_to_link[@]}"; do
        if [[ -d "$config_source/$config" ]]; then
            info "Linking $config configuration..."
            mkdir -p "$HOME/.config"
            stow -v -R -d "$config_source" -t "$HOME/.config" "$config"
            success "$config configuration linked!"
        else
            warn "$config configuration directory not found, skipping..."
        fi
    done
}

# --- Main Execution ---

main() {
    install_catppuccin_gtk_themes
    link_gtk_configs
    
    success "Catppuccin GTK configuration completed successfully!"
    info "GTK applications will use Catppuccin theming when themes are installed."
}

main