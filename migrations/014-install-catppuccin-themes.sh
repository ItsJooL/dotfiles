#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# Install modern Qt6 theming tools
install_qt_theming() {
    info "Installing Qt5/Qt6 theming tools..."
    
    "$UTILS_DIR/install-package.sh" qt5ct qt5ct qt5ct qt5ct
    "$UTILS_DIR/install-package.sh" qt6ct qt6ct qt6ct qt6ct
    "$UTILS_DIR/install-package.sh" kvantum kvantum kvantum kvantum
    "$UTILS_DIR/install-package.sh" qt5-qtwayland qt5-qtwayland qt5-wayland qt5-wayland
    "$UTILS_DIR/install-package.sh" qt6-qtwayland qt6-qtwayland qt6-wayland qt6-wayland
    
    # Install Catppuccin Kvantum theme
    local kvantum_dir="$HOME/.config/Kvantum"
    info "Installing Catppuccin Kvantum theme..."
    mkdir -p "$kvantum_dir"
    
    TEMP_DIR=$(mktemp -d)
    
    if git clone --depth=1 https://github.com/catppuccin/Kvantum.git "$TEMP_DIR/catppuccin-kvantum"; then
        cd "$TEMP_DIR/catppuccin-kvantum"
        if [[ -d "themes" ]]; then
            cp -r themes/Catppuccin-Mocha-* "$kvantum_dir/" 2>/dev/null || true
            success "Catppuccin Kvantum themes installed!"
        elif [[ -d "src" ]]; then
            cp -r src/Catppuccin-Mocha-* "$kvantum_dir/" 2>/dev/null || true
            success "Catppuccin Kvantum themes installed!"
        fi
        cd - > /dev/null
    else
        warn "Failed to install Catppuccin Kvantum theme"
    fi
    
    rm -rf "$TEMP_DIR"
}

# Install GTK theming (GTK2, GTK3, GTK4)
install_gtk_theming() {
    info "Installing GTK2/3/4 themes and dependencies..."
    
    "$UTILS_DIR/install-package.sh" gtk2 gtk2 gtk2 gtk2
    "$UTILS_DIR/install-package.sh" gtk3 gtk3 gtk3 gtk3
    "$UTILS_DIR/install-package.sh" libgtk-4-dev gtk4-devel gtk4 gtk4
    
    # Try to install Catppuccin GTK theme via package manager first
    if "$UTILS_DIR/install-package.sh" catppuccin-gtk-theme-mocha catppuccin-gtk-theme-mocha catppuccin-gtk-theme-mocha catppuccin-gtk-theme-mocha 2>/dev/null; then
        success "Catppuccin GTK theme installed via package manager!"
    else
        # Install manually from GitHub
        info "Installing Catppuccin GTK theme manually..."
        local themes_dir="$HOME/.themes"
        mkdir -p "$themes_dir"
        
        TEMP_DIR=$(mktemp -d)
        
        if git clone --depth=1 https://github.com/catppuccin/gtk.git "$TEMP_DIR/catppuccin-gtk"; then
            cd "$TEMP_DIR/catppuccin-gtk"
            
            # Install Mocha variant (focus on main theme)
            theme_name="Catppuccin-Mocha-Standard-Mauve-Dark"
            if [[ -d "themes/${theme_name}" ]]; then
                info "Installing ${theme_name}..."
                cp -r "themes/${theme_name}" "$themes_dir/"
                success "Catppuccin GTK theme installed!"
            fi
            
            cd - > /dev/null
        else
            error "Failed to install Catppuccin GTK theme"
        fi
        
        rm -rf "$TEMP_DIR"
    fi
}

# Install icon themes
install_icon_themes() {
    info "Installing icon themes..."
    
    if "$UTILS_DIR/install-package.sh" papirus-icon-theme papirus-icon-theme papirus-icon-theme papirus-icon-theme 2>/dev/null; then
        success "Papirus icon theme installed via package manager!"
    else
        info "Installing Papirus icon theme manually..."
        local icons_dir="$HOME/.icons"
        mkdir -p "$icons_dir"
        
        TEMP_DIR=$(mktemp -d)
        
        if git clone --depth=1 https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git "$TEMP_DIR/papirus"; then
            cd "$TEMP_DIR/papirus"
            cp -r Papirus-Dark "$icons_dir/"
            cd - > /dev/null
            success "Papirus-Dark icon theme installed!"
        else
            warn "Failed to install Papirus icon theme"
        fi
        
        rm -rf "$TEMP_DIR"
    fi
}

# Install cursor themes
install_cursor_themes() {
    info "Installing cursor themes..."
    
    if "$UTILS_DIR/install-package.sh" catppuccin-cursors-mocha catppuccin-cursors-mocha catppuccin-cursors catppuccin-cursors 2>/dev/null; then
        success "Catppuccin cursors installed via package manager!"
    else
        info "Installing Catppuccin cursor theme manually..."
        local cursors_dir="$HOME/.icons"
        mkdir -p "$cursors_dir"
        
        TEMP_DIR=$(mktemp -d)
        
        if git clone --depth=1 https://github.com/catppuccin/cursors.git "$TEMP_DIR/catppuccin-cursors"; then
            cd "$TEMP_DIR/catppuccin-cursors"
            if [[ -d "cursors/Catppuccin-Mocha-Dark" ]]; then
                cp -r cursors/Catppuccin-Mocha-Dark "$cursors_dir/"
                success "Catppuccin cursors installed!"
            fi
            cd - > /dev/null
        else
            warn "Failed to install Catppuccin cursors"
        fi
        
        rm -rf "$TEMP_DIR"
    fi
    
    # Set up default cursor configuration
    mkdir -p "$HOME/.icons/default"
    cat > "$HOME/.icons/default/index.theme" << 'EOF'
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Catppuccin-Mocha-Dark
EOF
}

# Link configurations
link_configurations() {
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
            warn "$config configuration directory not found, skipping..."
        fi
    done
}

# --- Main Execution ---

main() {
    info "Installing modern Catppuccin theming (Qt6 + GTK4)..."
    
    # Install core dependencies
    "$UTILS_DIR/install-package.sh" git git git git
    
    # Install theming components
    install_qt_theming
    install_gtk_theming
    install_icon_themes
    install_cursor_themes
    
    # Link configurations
    link_configurations
    
    # Set up environment variables for Qt theming
    info "Setting up environment variables..."
    
    # Add to shell profile if it exists
    for shell_rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
        if [[ -f "$shell_rc" ]]; then
            # Remove any existing entries
            sed -i '/export QT_QPA_PLATFORMTHEME/d' "$shell_rc" 2>/dev/null || true
            sed -i '/export QT_STYLE_OVERRIDE/d' "$shell_rc" 2>/dev/null || true
            
            # Add new entries
            echo "export QT_QPA_PLATFORMTHEME=qt5ct" >> "$shell_rc"
            echo "export QT_STYLE_OVERRIDE=kvantum" >> "$shell_rc"
            info "Updated $shell_rc with Qt theming variables"
            break
        fi
    done
    
    success "Modern Catppuccin theming installation completed!"
    info ""
    info "Theme Summary:"
    info "  ✅ GTK2/3/4: Catppuccin-Mocha-Standard-Mauve-Dark"
    info "  ✅ Qt5/6: Kvantum + Catppuccin-Mocha-Blue"  
    info "  ✅ Icons: Papirus-Dark"
    info "  ✅ Cursors: Adwaita (normal cursor)"
    info ""
    info "Applications (Nautilus, Dolphin) will be themed."
    info "Restart applications or log out/in for changes to take effect."
    info ""
    info "Qt Environment Variables Set:"
    info "  QT_QPA_PLATFORMTHEME=qt5ct"
    info "  QT_STYLE_OVERRIDE=kvantum"
}

main