#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# --- Helper Functions ---

# Install Catppuccin cursor themes
install_catppuccin_cursors() {
    local cursors_dir="$HOME/.icons"
    
    info "Installing Catppuccin cursor themes..."
    mkdir -p "$cursors_dir"
    
    TEMP_DIR=$(mktemp -d)
    
    # Clone the Catppuccin cursors repository
    if ! git clone --depth=1 https://github.com/catppuccin/cursors.git "$TEMP_DIR/catppuccin-cursors"; then
        error "Failed to clone Catppuccin cursors repository"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    cd "$TEMP_DIR/catppuccin-cursors"
    
    # Install all Mocha variants
    info "Installing Catppuccin Mocha cursor themes..."
    for variant in cursors/Catppuccin-Mocha-*; do
        if [[ -d "$variant" ]]; then
            variant_name=$(basename "$variant")
            info "Installing $variant_name..."
            cp -r "$variant" "$cursors_dir/"
        fi
    done
    
    # Set up default cursor theme (Dark variant)
    if [[ -d "$cursors_dir/Catppuccin-Mocha-Dark" ]]; then
        info "Setting up default cursor theme..."
        ln -sf "Catppuccin-Mocha-Dark" "$cursors_dir/Catppuccin-Mocha-Cursors"
    fi
    
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    success "Catppuccin cursor themes installed successfully!"
}

# Create cursor configuration
create_cursor_config() {
    info "Creating cursor configuration..."
    
    # Create cursor theme configuration
    mkdir -p "$HOME/.config"
    
    # Set cursor theme in various locations for compatibility
    echo "Inherits=Catppuccin-Mocha-Dark" > "$HOME/.icons/default/index.theme"
    mkdir -p "$HOME/.icons/default"
    
    # Create index.theme for the cursor
    cat > "$HOME/.icons/default/index.theme" << 'EOF'
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Catppuccin-Mocha-Dark
EOF

    success "Cursor configuration created!"
}

# Update GTK cursor settings
update_gtk_cursor_config() {
    info "Updating GTK cursor configuration..."
    
    local gtk3_config="$HOME/.config/gtk-3.0/settings.ini"
    local gtk4_config="$HOME/.config/gtk-4.0/settings.ini"
    
    # Ensure GTK config directories exist
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    
    # Update or create GTK3 settings
    if [[ -f "$gtk3_config" ]]; then
        # Update existing cursor theme setting
        if grep -q "gtk-cursor-theme-name" "$gtk3_config"; then
            sed -i 's/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=Catppuccin-Mocha-Dark/' "$gtk3_config"
        else
            echo "gtk-cursor-theme-name=Catppuccin-Mocha-Dark" >> "$gtk3_config"
        fi
        
        if grep -q "gtk-cursor-theme-size" "$gtk3_config"; then
            sed -i 's/gtk-cursor-theme-size=.*/gtk-cursor-theme-size=24/' "$gtk3_config"
        else
            echo "gtk-cursor-theme-size=24" >> "$gtk3_config"
        fi
    else
        cat > "$gtk3_config" << 'EOF'
[Settings]
gtk-cursor-theme-name=Catppuccin-Mocha-Dark
gtk-cursor-theme-size=24
EOF
    fi
    
    # Update or create GTK4 settings
    if [[ -f "$gtk4_config" ]]; then
        # Update existing cursor theme setting
        if grep -q "gtk-cursor-theme-name" "$gtk4_config"; then
            sed -i 's/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=Catppuccin-Mocha-Dark/' "$gtk4_config"
        else
            echo "gtk-cursor-theme-name=Catppuccin-Mocha-Dark" >> "$gtk4_config"
        fi
        
        if grep -q "gtk-cursor-theme-size" "$gtk4_config"; then
            sed -i 's/gtk-cursor-theme-size=.*/gtk-cursor-theme-size=24/' "$gtk4_config"
        else
            echo "gtk-cursor-theme-size=24" >> "$gtk4_config"
        fi
    else
        cat > "$gtk4_config" << 'EOF'
[Settings]
gtk-cursor-theme-name=Catppuccin-Mocha-Dark
gtk-cursor-theme-size=24
EOF
    fi
    
    success "GTK cursor configuration updated!"
}

# Create Xresources configuration for cursor
create_xresources_cursor() {
    info "Creating Xresources cursor configuration..."
    
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
    if [[ -n "$DISPLAY" ]]; then
        if command -v xrdb >/dev/null 2>&1; then
            xrdb -merge "$xresources_file"
            info "Xresources loaded"
        fi
    fi
    
    success "Xresources cursor configuration created!"
}

# --- Main Execution ---

main() {
    install_catppuccin_cursors
    create_cursor_config
    update_gtk_cursor_config
    create_xresources_cursor
    
    success "Catppuccin cursor themes installation completed successfully!"
    info "Note: You may need to restart applications or log out/in for cursor changes to take effect."
    info "Cursor theme: Catppuccin-Mocha-Dark"
}

main