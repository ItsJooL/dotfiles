#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# Font installation directory
FONTS_DIR="$HOME/.local/share/fonts"

# Create fonts directory if it doesn't exist
mkdir -p "$FONTS_DIR"

# Function to download and install a Nerd Font
install_nerd_font() {
    local font_name="$1"
    local font_display_name="$2"

    info "Installing $font_display_name Nerd Font..."

    # Check if font is already installed
    if fc-list | grep -qi "$font_display_name"; then
        info "$font_display_name is already installed, skipping..."
        return 0
    fi

    local temp_dir=$(mktemp -d)
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.tar.xz"

    info "Downloading $font_display_name from GitHub releases..."
    if curl -L --progress-bar -o "$temp_dir/${font_name}.tar.xz" "$font_url"; then
        info "Extracting $font_display_name..."
        tar -xf "$temp_dir/${font_name}.tar.xz" -C "$temp_dir"

        # Copy font files to fonts directory
        find "$temp_dir" -name "*.ttf" -o -name "*.otf" | while read -r font_file; do
            cp "$font_file" "$FONTS_DIR/"
        done

        success "$font_display_name installed successfully!"
    else
        error "Failed to download $font_display_name"
        return 1
    fi

    # Cleanup
    rm -rf "$temp_dir"
}

# Main installation
info "Starting Nerd Fonts installation..."

# Ensure fontconfig is available
if ! command -v fc-cache >/dev/null 2>&1; then
    info "Installing fontconfig..."
    "$UTILS_DIR/install-package.sh" fontconfig
fi

# Install essential Nerd Fonts
install_nerd_font "JetBrainsMono" "JetBrainsMono"

# Install a few other popular ones
install_nerd_font "FiraCode" "FiraCode"
install_nerd_font "Hack" "Hack"
install_nerd_font "SourceCodePro" "SauceCodePro"

# Refresh font cache
info "Refreshing font cache..."
fc-cache -fv "$FONTS_DIR" >/dev/null 2>&1

success "All Nerd Fonts installed successfully!"
