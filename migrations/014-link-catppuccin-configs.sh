#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# Link configuration files using stow
link_configs() {
    info "Linking Catppuccin theme configurations..."
    
    local config_source="$SCRIPT_DIR/../config"
    local configs_to_link=("gtk" "qt5ct" "qt6ct" "Kvantum")
    
    for config in "${configs_to_link[@]}"; do
        if [[ -d "$config_source/$config" ]]; then
            info "Linking $config configuration..."
            mkdir -p "$HOME/.config"
            stow -v -R -d "$config_source" -t "$HOME/.config" "$config"
            success "$config configuration linked!"
        else
            info "$config configuration directory not found, skipping..."
        fi
    done
}

# Create additional cursor configuration files
setup_cursor_config() {
    info "Setting up cursor configuration..."
    
    # Create default cursor theme configuration
    mkdir -p "$HOME/.icons/default"
    cat > "$HOME/.icons/default/index.theme" << 'EOF'
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Catppuccin-Mocha-Dark
EOF

    # Create/update Xresources for cursor theme
    local xresources_file="$HOME/.Xresources"
    local cursor_config="Xcursor.theme: Catppuccin-Mocha-Dark
Xcursor.size: 24"
    
    if [[ -f "$xresources_file" ]]; then
        # Update existing or add new cursor settings
        if grep -q "Xcursor.theme" "$xresources_file"; then
            sed -i 's/Xcursor.theme:.*/Xcursor.theme: Catppuccin-Mocha-Dark/' "$xresources_file"
        else
            echo "Xcursor.theme: Catppuccin-Mocha-Dark" >> "$xresources_file"
        fi
        
        if grep -q "Xcursor.size" "$xresources_file"; then
            sed -i 's/Xcursor.size:.*/Xcursor.size: 24/' "$xresources_file"
        else
            echo "Xcursor.size: 24" >> "$xresources_file"
        fi
    else
        echo "$cursor_config" > "$xresources_file"
    fi
    
    # Load Xresources if in X11 session
    if [[ -n "$DISPLAY" ]] && command -v xrdb >/dev/null 2>&1; then
        xrdb -merge "$xresources_file"
        info "Xresources loaded"
    fi
    
    success "Cursor configuration setup complete!"
}

# --- Main Execution ---

main() {
    info "Setting up Catppuccin theme configurations..."
    
    link_configs
    setup_cursor_config
    
    success "Catppuccin theme configuration completed successfully!"
    info ""
    info "Theme settings configured:"
    info "  - GTK Theme: Catppuccin-Mocha-Standard-Mauve-Dark"
    info "  - Qt Theme: Kvantum + Catppuccin-Mocha-Blue"
    info "  - Icon Theme: Papirus-Dark"
    info "  - Cursor Theme: Catppuccin-Mocha-Dark"
    info ""
    info "Notes:"
    info "  - Themes will automatically apply when relevant packages are installed"
    info "  - Qt themes require: qt5ct, qt6ct, kvantum packages"
    info "  - GTK themes require: gtk3, gtk4 and Catppuccin GTK theme installation"
    info "  - Cursor themes require: Catppuccin cursor theme installation"
    info "  - Icon themes work best with: papirus-icon-theme package"
    info ""
    info "Restart applications or log out/in for all changes to take effect."
}

main