#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# --- Helper Functions ---

# Install Qt5ct and Qt6ct packages
install_qt_tools() {
    info "Installing Qt configuration tools..."
    
    # Use the enhanced install-package.sh utility (supports yay automatically)
    "$UTILS_DIR/install-package.sh" qt5ct qt5ct qt5ct qt5ct
    "$UTILS_DIR/install-package.sh" qt6ct qt6ct qt6ct qt6ct
    "$UTILS_DIR/install-package.sh" kvantum kvantum kvantum kvantum-qt5
    "$UTILS_DIR/install-package.sh" qtwayland5 qt5-qtwayland qt5-wayland qt5-wayland
    "$UTILS_DIR/install-package.sh" qt6-qtwayland qt6-qtwayland qt6-wayland qt6-wayland
    "$UTILS_DIR/install-package.sh" git git git git
}

# Install Catppuccin Kvantum theme
install_catppuccin_kvantum() {
    local kvantum_dir="$HOME/.config/Kvantum"
    
    info "Installing Catppuccin Kvantum theme..."
    mkdir -p "$kvantum_dir"
    
    TEMP_DIR=$(mktemp -d)
    
    # Clone the Catppuccin Kvantum repository
    if ! git clone --depth=1 https://github.com/catppuccin/Kvantum.git "$TEMP_DIR/catppuccin-kvantum"; then
        error "Failed to clone Catppuccin Kvantum repository"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    cd "$TEMP_DIR/catppuccin-kvantum"
    
    # Install Mocha theme
    info "Installing Catppuccin Mocha Kvantum theme..."
    if [[ -d "src/Catppuccin-Mocha-Blue" ]]; then
        cp -r src/Catppuccin-Mocha-* "$kvantum_dir/"
        success "Catppuccin Kvantum themes installed!"
    else
        error "Catppuccin Mocha Kvantum theme not found"
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    # Set default Kvantum theme
    info "Setting Catppuccin-Mocha-Blue as default Kvantum theme..."
    mkdir -p "$kvantum_dir"
    cat > "$kvantum_dir/kvantum.kvconfig" << EOF
[General]
theme=Catppuccin-Mocha-Blue
EOF
    
    success "Catppuccin Kvantum theme configured!"
}

# Generate Qt5ct configuration
generate_qt5ct_config() {
    local qt5ct_dir="$HOME/.config/qt5ct"
    mkdir -p "$qt5ct_dir/colors"
    
    info "Generating Qt5ct configuration..."
    
    # Create Qt5ct color scheme
    cat > "$qt5ct_dir/colors/Catppuccin-Mocha.conf" << 'EOF'
[ColorScheme]
active_colors=#ffcdd6f4, #ff313244, #ff585b70, #ff45475a, #ff1e1e2e, #ff313244, #ffcdd6f4, #ffcdd6f4, #ffcdd6f4, #ff1e1e2e, #ff1e1e2e, #ff11111b, #ff89b4fa, #ff1e1e2e, #ff89b4fa, #fff38ba8, #ff313244, #ffcdd6f4, #ff11111b, #ffcdd6f4, #ff45475a
disabled_colors=#ff6c7086, #ff313244, #ff585b70, #ff45475a, #ff1e1e2e, #ff313244, #ff6c7086, #ff6c7086, #ff6c7086, #ff1e1e2e, #ff1e1e2e, #ff11111b, #ff45475a, #ff6c7086, #ff89b4fa, #fff38ba8, #ff313244, #ff6c7086, #ff11111b, #ff6c7086, #ff45475a
inactive_colors=#ffcdd6f4, #ff313244, #ff585b70, #ff45475a, #ff1e1e2e, #ff313244, #ffcdd6f4, #ffcdd6f4, #ffcdd6f4, #ff1e1e2e, #ff1e1e2e, #ff11111b, #ff89b4fa, #ff1e1e2e, #ff89b4fa, #fff38ba8, #ff313244, #ffcdd6f4, #ff11111b, #ffcdd6f4, #ff45475a
EOF

    # Create Qt5ct main configuration
    cat > "$qt5ct_dir/qt5ct.conf" << 'EOF'
[Appearance]
color_scheme_path=/home/user/.config/qt5ct/colors/Catppuccin-Mocha.conf
custom_palette=true
icon_theme=Papirus-Dark
standard_dialogs=default
style=kvantum

[Fonts]
fixed=@Variant(\0\0\0@\0\0\0\x12\0M\0o\0n\0o\0s\0p\0\x61\0\x63\0\x65@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
general=@Variant(\0\0\0@\0\0\0\x12\0S\0\x61\0n\0s\0 \0S\0\x65\0r\0i\0\x66@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[SettingsWindow]
geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\x2\x9f\0\0\x1\xdf\0\0\0\0\0\0\0\0\0\0\x2\x9f\0\0\x1\xdf\0\0\0\0\x2\0\0\0\a\x80\0\0\0\0\0\0\0\0\0\0\x2\x9f\0\0\x1\xdf)

[Troubleshooting]
force_raster_widgets=1
ignored_applications=@Invalid()
EOF
    
    # Fix path in config file
    sed -i "s|/home/user|$HOME|g" "$qt5ct_dir/qt5ct.conf"
    
    success "Qt5ct configuration generated!"
}

# Generate Qt6ct configuration  
generate_qt6ct_config() {
    local qt6ct_dir="$HOME/.config/qt6ct"
    mkdir -p "$qt6ct_dir/colors"
    
    info "Generating Qt6ct configuration..."
    
    # Create Qt6ct color scheme (same as Qt5ct)
    cat > "$qt6ct_dir/colors/Catppuccin-Mocha.conf" << 'EOF'
[ColorScheme]
active_colors=#ffcdd6f4, #ff313244, #ff585b70, #ff45475a, #ff1e1e2e, #ff313244, #ffcdd6f4, #ffcdd6f4, #ffcdd6f4, #ff1e1e2e, #ff1e1e2e, #ff11111b, #ff89b4fa, #ff1e1e2e, #ff89b4fa, #fff38ba8, #ff313244, #ffcdd6f4, #ff11111b, #ffcdd6f4, #ff45475a
disabled_colors=#ff6c7086, #ff313244, #ff585b70, #ff45475a, #ff1e1e2e, #ff313244, #ff6c7086, #ff6c7086, #ff6c7086, #ff1e1e2e, #ff1e1e2e, #ff11111b, #ff45475a, #ff6c7086, #ff89b4fa, #fff38ba8, #ff313244, #ff6c7086, #ff11111b, #ff6c7086, #ff45475a
inactive_colors=#ffcdd6f4, #ff313244, #ff585b70, #ff45475a, #ff1e1e2e, #ff313244, #ffcdd6f4, #ffcdd6f4, #ffcdd6f4, #ff1e1e2e, #ff1e1e2e, #ff11111b, #ff89b4fa, #ff1e1e2e, #ff89b4fa, #fff38ba8, #ff313244, #ffcdd6f4, #ff11111b, #ffcdd6f4, #ff45475a
EOF

    # Create Qt6ct main configuration
    cat > "$qt6ct_dir/qt6ct.conf" << 'EOF'
[Appearance]
color_scheme_path=/home/user/.config/qt6ct/colors/Catppuccin-Mocha.conf
custom_palette=true
icon_theme=Papirus-Dark
standard_dialogs=default
style=kvantum

[Fonts]
fixed=@Variant(\0\0\0@\0\0\0\x12\0M\0o\0n\0o\0s\0p\0\x61\0\x63\0\x65@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
general=@Variant(\0\0\0@\0\0\0\x12\0S\0\x61\0n\0s\0 \0S\0\x65\0r\0i\0\x66@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[SettingsWindow]
geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\x2\x9f\0\0\x1\xdf\0\0\0\0\0\0\0\0\0\0\x2\x9f\0\0\x1\xdf\0\0\0\0\x2\0\0\0\a\x80\0\0\0\0\0\0\0\0\0\0\x2\x9f\0\0\x1\xdf)

[Troubleshooting]
force_raster_widgets=1
ignored_applications=@Invalid()
EOF
    
    # Fix path in config file
    sed -i "s|/home/user|$HOME|g" "$qt6ct_dir/qt6ct.conf"
    
    success "Qt6ct configuration generated!"
}

# Link Qt configuration files
link_qt_configs() {
    info "Linking Qt configuration files..."
    
    local config_source="$SCRIPT_DIR/../config"
    local configs_to_link=("qt5ct" "qt6ct" "Kvantum")
    
    for config in "${configs_to_link[@]}"; do
        if [[ -d "$config_source/$config" ]]; then
            info "Linking $config configuration..."
            mkdir -p "$HOME/.config"
            stow -v -R -d "$config_source" -t "$HOME/.config" "$config"
            success "$config configuration linked!"
        else
            info "$config configuration directory not found, using generated config..."
        fi
    done
}

# --- Main Execution ---

main() {
    install_qt_tools
    install_catppuccin_kvantum
    generate_qt5ct_config
    generate_qt6ct_config
    link_qt_configs
    
    success "Catppuccin Qt themes installation completed successfully!"
    info "Note: Qt applications will use the new theme after restart."
}

main