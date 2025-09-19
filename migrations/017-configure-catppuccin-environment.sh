#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# --- Helper Functions ---

# Update Hyprland environment variables
update_hyprland_env() {
    local hyprland_config="$SCRIPT_DIR/../config/hypr/hyprland.conf"
    
    info "Updating Hyprland environment variables for theming..."
    
    # Check if file exists
    if [[ ! -f "$hyprland_config" ]]; then
        error "Hyprland config file not found: $hyprland_config"
        return 1
    fi
    
    # Backup original config
    cp "$hyprland_config" "$hyprland_config.bak"
    
    # Add GTK and Qt environment variables after existing env lines
    local env_section_found=false
    local temp_file=$(mktemp)
    
    while IFS= read -r line; do
        echo "$line" >> "$temp_file"
        
        # Add our theme env vars after the existing XCURSOR_SIZE line
        if [[ "$line" =~ ^env[[:space:]]*=[[:space:]]*XCURSOR_SIZE ]]; then
            cat >> "$temp_file" << 'EOF'

# GTK Theme environment
env = GTK_THEME,Catppuccin-Mocha-Standard-Mauve-Dark

# Qt Theme environment (qt6ct already configured above)
env = QT_STYLE_OVERRIDE,kvantum

# Cursor theme environment  
env = XCURSOR_THEME,Catppuccin-Mocha-Dark
EOF
            env_section_found=true
        fi
    done < "$hyprland_config"
    
    # If no XCURSOR_SIZE found, add all env vars at the end of env section
    if [[ "$env_section_found" == false ]]; then
        # Find last env line and add after it
        sed -i '/^env = /a\\n# GTK Theme environment\nenv = GTK_THEME,Catppuccin-Mocha-Standard-Mauve-Dark\n\n# Qt Theme environment\nenv = QT_STYLE_OVERRIDE,kvantum\n\n# Cursor theme environment\nenv = XCURSOR_THEME,Catppuccin-Mocha-Dark' "$temp_file"
    fi
    
    # Replace original with updated config
    mv "$temp_file" "$hyprland_config"
    
    success "Hyprland environment variables updated!"
    info "Backup saved as: $hyprland_config.bak"
}

# Create GTK configuration files
create_gtk_configs() {
    local config_dir="$SCRIPT_DIR/../config"
    
    info "Creating GTK configuration files..."
    
    # Create GTK config directories
    mkdir -p "$config_dir/gtk"
    mkdir -p "$config_dir/gtk/gtk-4.0"
    
    # Create GTK3 settings
    cat > "$config_dir/gtk/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Catppuccin-Mocha-Standard-Mauve-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=Catppuccin-Mocha-Dark
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
EOF

    # Create GTK4 settings
    cat > "$config_dir/gtk/gtk-4.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Catppuccin-Mocha-Standard-Mauve-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=Catppuccin-Mocha-Dark
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF

    # Create GTK2 settings
    cat > "$config_dir/gtk/gtkrc-2.0" << 'EOF'
# GTK2 Catppuccin Mocha Configuration
gtk-theme-name="Catppuccin-Mocha-Standard-Mauve-Dark"
gtk-icon-theme-name="Papirus-Dark"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="Catppuccin-Mocha-Dark"
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
gtk-xft-rgba="rgb"
EOF

    success "GTK configuration files created!"
}

# Link configuration files
link_configs() {
    info "Linking Catppuccin configuration files..."
    
    local config_source="$SCRIPT_DIR/../config"
    local configs_to_link=("gtk")
    
    for config in "${configs_to_link[@]}"; do
        if [[ -d "$config_source/$config" ]]; then
            info "Linking $config configuration..."
            stow -v -R -d "$config_source" -t "$HOME/.config" "$config"
            success "$config configuration linked!"
        else
            warn "$config configuration directory not found, skipping..."
        fi
    done
}

# --- Main Execution ---

main() {
    info "Configuring Catppuccin environment and settings..."
    
    update_hyprland_env
    create_gtk_configs
    link_configs
    
    success "Catppuccin environment configuration completed successfully!"
    info "Theme settings:"
    info "  - GTK Theme: Catppuccin-Mocha-Standard-Mauve-Dark"
    info "  - Qt Theme: Kvantum + Catppuccin-Mocha-Blue"
    info "  - Icon Theme: Papirus-Dark"
    info "  - Cursor Theme: Catppuccin-Mocha-Dark"
    info ""
    info "Note: Please restart Hyprland or log out/in for all changes to take effect."
}

main