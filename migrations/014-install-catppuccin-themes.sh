#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# Detect distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Install theme packages based on distribution
install_theme_packages() {
    local distro="$1"
    
    info "Installing Catppuccin theme packages for $distro..."
    
    case "$distro" in
        arch|manjaro|endeavouros)
            info "Installing packages via yay for Arch-based systems..."
            local packages=(
                "catppuccin-gtk-theme-mocha"
                "papirus-icon-theme"
                "kvantum"
                "qt5ct"
                "qt6ct"
                "catppuccin-kvantum-theme-git"
                "catppuccin-sddm-theme-mocha-git"
            )
            
            # Check if yay is available
            if command -v yay >/dev/null 2>&1; then
                yay -S --noconfirm --needed "${packages[@]}" || warn "Some AUR packages may not be available"
            else
                warn "yay not found, installing available packages via pacman..."
                sudo pacman -S --noconfirm --needed kvantum qt5ct qt6ct papirus-icon-theme || true
            fi
            ;;
            
        fedora|centos|rhel)
            info "Installing packages for Fedora/RHEL..."
            
            # Install basic packages
            "$UTILS_DIR/install-package.sh" "kvantum" "kvantum" "kvantum"
            "$UTILS_DIR/install-package.sh" "qt5ct" "qt5ct" "qt5ct"  
            "$UTILS_DIR/install-package.sh" "qt6ct" "qt6ct" "qt6ct"
            "$UTILS_DIR/install-package.sh" "papirus-icon-theme" "papirus-icon-theme" "papirus-icon-theme"
            
            # Try to install from COPR if available
            if sudo dnf copr enable -y catppuccin/catppuccin 2>/dev/null; then
                sudo dnf install -y catppuccin-gtk || warn "Could not install catppuccin-gtk from COPR"
            else
                warn "Catppuccin COPR repo not available, themes will be downloaded manually"
            fi
            ;;
            
        ubuntu|debian|pop|mint)
            info "Installing packages for Debian/Ubuntu..."
            
            # Update package list
            sudo apt-get update -qq
            
            # Install available packages
            "$UTILS_DIR/install-package.sh" "qt5ct" "qt5ct" "qt5ct"
            "$UTILS_DIR/install-package.sh" "papirus-icon-theme" "papirus-icon-theme" "papirus-icon-theme"
            
            # Kvantum might need to be installed from source or flatpak
            if ! "$UTILS_DIR/install-package.sh" "kvantum" "kvantum" "kvantum" 2>/dev/null; then
                warn "Kvantum not available in repositories, will try alternative installation"
            fi
            ;;
            
        *)
            warn "Unknown distribution: $distro. Manual theme installation may be required."
            ;;
    esac
}

# Download and install themes manually if packages aren't available
install_themes_manually() {
    local themes_dir="$HOME/.local/share"
    
    info "Installing themes manually..."
    
    # Create directories
    mkdir -p "$HOME/.themes"
    mkdir -p "$HOME/.local/share/Kvantum"
    mkdir -p "$HOME/.local/share/sddm/themes"
    
    # Download Catppuccin GTK theme
    if [[ ! -d "$HOME/.themes/Catppuccin-Mocha-Standard-Mauve-Dark" ]]; then
        info "Downloading Catppuccin GTK theme..."
        local gtk_theme_url="https://github.com/catppuccin/gtk/releases/latest/download/Catppuccin-Mocha-Standard-Mauve-Dark.zip"
        local temp_file="/tmp/catppuccin-gtk.zip"
        
        if curl -L -o "$temp_file" "$gtk_theme_url" 2>/dev/null; then
            unzip -q "$temp_file" -d "$HOME/.themes/" || warn "Failed to extract GTK theme"
            rm -f "$temp_file"
            success "GTK theme installed"
        else
            warn "Failed to download GTK theme"
        fi
    fi
    
    # Download Catppuccin Kvantum theme
    if [[ ! -d "$HOME/.local/share/Kvantum/Catppuccin-Mocha" ]]; then
        info "Downloading Catppuccin Kvantum theme..."
        local kvantum_theme_url="https://github.com/catppuccin/Kvantum/archive/main.zip"
        local temp_file="/tmp/catppuccin-kvantum.zip"
        
        if curl -L -o "$temp_file" "$kvantum_theme_url" 2>/dev/null; then
            local temp_dir="/tmp/catppuccin-kvantum"
            unzip -q "$temp_file" -d "$temp_dir" || warn "Failed to extract Kvantum theme"
            
            if [[ -d "$temp_dir/Kvantum-main/src" ]]; then
                cp -r "$temp_dir/Kvantum-main/src/"* "$HOME/.local/share/Kvantum/"
                success "Kvantum theme installed"
            fi
            
            rm -rf "$temp_file" "$temp_dir"
        else
            warn "Failed to download Kvantum theme"
        fi
    fi
    
    # Download Catppuccin SDDM theme
    if [[ ! -d "$HOME/.local/share/sddm/themes/catppuccin-mocha" ]]; then
        info "Downloading Catppuccin SDDM theme..."
        local sddm_theme_url="https://github.com/catppuccin/sddm/archive/main.zip"
        local temp_file="/tmp/catppuccin-sddm.zip"
        
        if curl -L -o "$temp_file" "$sddm_theme_url" 2>/dev/null; then
            local temp_dir="/tmp/catppuccin-sddm"
            unzip -q "$temp_file" -d "$temp_dir" || warn "Failed to extract SDDM theme"
            
            if [[ -d "$temp_dir/sddm-main/src/catppuccin-mocha" ]]; then
                cp -r "$temp_dir/sddm-main/src/catppuccin-mocha" "$HOME/.local/share/sddm/themes/"
                success "SDDM theme installed"
            fi
            
            rm -rf "$temp_file" "$temp_dir"
        else
            warn "Failed to download SDDM theme"
        fi
    fi
}

# Link configuration files using stow
link_configurations() {
    info "Linking theme configuration files..."
    
    # Create target directories
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/gtk-4.0"
    mkdir -p "$HOME/.config/qt5ct/colors"
    mkdir -p "$HOME/.config/qt6ct/colors"
    mkdir -p "$HOME/.config/Kvantum"
    
    # Link GTK configurations
    if [[ -f "$CONFIG_DIR/gtk/.gtkrc-2.0" ]]; then
        ln -sf "$CONFIG_DIR/gtk/.gtkrc-2.0" "$HOME/.gtkrc-2.0"
        success "Linked GTK2 configuration"
    fi
    
    if [[ -f "$CONFIG_DIR/gtk/gtk-3.0/settings.ini" ]]; then
        ln -sf "$CONFIG_DIR/gtk/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
        success "Linked GTK3 configuration"
    fi
    
    if [[ -f "$CONFIG_DIR/gtk/gtk-4.0/settings.ini" ]]; then
        ln -sf "$CONFIG_DIR/gtk/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
        success "Linked GTK4 configuration"
    fi
    
    # Link Qt configurations
    if [[ -f "$CONFIG_DIR/qt5ct/qt5ct.conf" ]]; then
        ln -sf "$CONFIG_DIR/qt5ct/qt5ct.conf" "$HOME/.config/qt5ct/qt5ct.conf"
        success "Linked Qt5 configuration"
    fi
    
    if [[ -f "$CONFIG_DIR/qt5ct/colors/Catppuccin-Mocha.conf" ]]; then
        ln -sf "$CONFIG_DIR/qt5ct/colors/Catppuccin-Mocha.conf" "$HOME/.config/qt5ct/colors/Catppuccin-Mocha.conf"
        success "Linked Qt5 color scheme"
    fi
    
    if [[ -f "$CONFIG_DIR/qt6ct/qt6ct.conf" ]]; then
        ln -sf "$CONFIG_DIR/qt6ct/qt6ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"
        success "Linked Qt6 configuration"
    fi
    
    if [[ -f "$CONFIG_DIR/qt6ct/colors/Catppuccin-Mocha.conf" ]]; then
        ln -sf "$CONFIG_DIR/qt6ct/colors/Catppuccin-Mocha.conf" "$HOME/.config/qt6ct/colors/Catppuccin-Mocha.conf"
        success "Linked Qt6 color scheme"
    fi
    
    # Link Kvantum configuration
    if [[ -f "$CONFIG_DIR/Kvantum/kvantum.kvconfig" ]]; then
        ln -sf "$CONFIG_DIR/Kvantum/kvantum.kvconfig" "$HOME/.config/Kvantum/kvantum.kvconfig"
        success "Linked Kvantum configuration"
    fi
}

# Configure environment variables
setup_environment() {
    info "Setting up environment variables..."
    
    local env_file="$HOME/.config/environment.d/theme.conf"
    mkdir -p "$(dirname "$env_file")"
    
    cat > "$env_file" << 'EOF'
# Qt Theme Configuration
QT_QPA_PLATFORMTHEME=qt5ct
QT_STYLE_OVERRIDE=kvantum

# GTK Theme Configuration  
GTK_THEME=Catppuccin-Mocha-Standard-Mauve-Dark

# XDG Configuration
XDG_CURRENT_DESKTOP=GNOME
EOF
    
    success "Environment variables configured"
    
    # Also add to shell profile if it exists
    if [[ -f "$HOME/.profile" ]]; then
        if ! grep -q "QT_QPA_PLATFORMTHEME" "$HOME/.profile"; then
            cat >> "$HOME/.profile" << 'EOF'

# Theme environment variables
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=kvantum
export GTK_THEME=Catppuccin-Mocha-Standard-Mauve-Dark
EOF
            success "Added theme variables to .profile"
        fi
    fi
}

# Configure display managers (requires root)
configure_display_managers() {
    info "Configuring display managers..."
    
    # Configure SDDM if present
    if command -v sddm >/dev/null 2>&1 || [[ -d /etc/sddm.conf.d ]] || [[ -f /etc/sddm.conf ]]; then
        info "SDDM detected, configuring theme..."
        
        if [[ -f "$CONFIG_DIR/sddm/sddm.conf" ]] && [[ -w /etc ]] || sudo -n true 2>/dev/null; then
            sudo cp "$CONFIG_DIR/sddm/sddm.conf" "/etc/sddm.conf" 2>/dev/null && success "SDDM configuration installed" || warn "Could not install SDDM configuration (requires root)"
        else
            warn "SDDM configuration available but requires manual installation as root"
            info "To install: sudo cp $CONFIG_DIR/sddm/sddm.conf /etc/sddm.conf"
        fi
    fi
    
    # Configure GDM if present  
    if command -v gdm >/dev/null 2>&1 || [[ -d /etc/gdm ]] || [[ -d /etc/gdm3 ]]; then
        info "GDM detected, configuring theme..."
        
        local gdm_config_dir=""
        [[ -d /etc/gdm3 ]] && gdm_config_dir="/etc/gdm3"
        [[ -d /etc/gdm ]] && gdm_config_dir="/etc/gdm"
        
        if [[ -n "$gdm_config_dir" ]] && [[ -f "$CONFIG_DIR/gdm/custom.conf" ]]; then
            if [[ -w "$gdm_config_dir" ]] || sudo -n true 2>/dev/null; then
                sudo cp "$CONFIG_DIR/gdm/custom.conf" "$gdm_config_dir/custom.conf" 2>/dev/null && success "GDM configuration installed" || warn "Could not install GDM configuration (requires root)"
            else
                warn "GDM configuration available but requires manual installation as root"
                info "To install: sudo cp $CONFIG_DIR/gdm/custom.conf $gdm_config_dir/custom.conf"
            fi
        fi
    fi
    
    if ! command -v sddm >/dev/null 2>&1 && ! command -v gdm >/dev/null 2>&1 && [[ ! -d /etc/sddm.conf.d ]] && [[ ! -d /etc/gdm ]] && [[ ! -d /etc/gdm3 ]]; then
        info "No supported display managers detected, skipping display manager configuration"
    fi
}

# Main execution
main() {
    local distro
    distro=$(detect_distro)
    info "Detected distribution: $distro"
    
    info "Installing Catppuccin Mocha themes and configurations..."
    
    # Install theme packages
    install_theme_packages "$distro"
    
    # Install themes manually as fallback
    install_themes_manually
    
    # Link configuration files
    link_configurations
    
    # Setup environment variables
    setup_environment
    
    # Configure display managers
    configure_display_managers
    
    success "Catppuccin theme installation completed!"
    info "Please log out and log back in for all changes to take effect."
    info "Applications may need to be restarted to pick up the new themes."
}

main