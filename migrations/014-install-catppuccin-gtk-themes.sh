#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# --- Helper Functions ---

# Install GTK themes from GitHub
install_catppuccin_gtk() {
    local themes_dir="$HOME/.themes"
    local icons_dir="$HOME/.icons"
    
    info "Creating theme directories..."
    mkdir -p "$themes_dir" "$icons_dir"
    
    # Download and install Catppuccin GTK theme
    info "Installing Catppuccin GTK themes..."
    TEMP_DIR=$(mktemp -d)
    
    # Clone the Catppuccin GTK repository
    if ! git clone --depth=1 https://github.com/catppuccin/gtk.git "$TEMP_DIR/catppuccin-gtk"; then
        error "Failed to clone Catppuccin GTK repository"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    cd "$TEMP_DIR/catppuccin-gtk"
    
    # Install all Mocha variants
    info "Installing Catppuccin Mocha themes..."
    for accent in Rosewater Flamingo Pink Mauve Red Maroon Peach Yellow Green Teal Sky Sapphire Blue Lavender; do
        theme_name="Catppuccin-Mocha-Standard-${accent}-Dark"
        if [[ -d "themes/${theme_name}" ]]; then
            info "Installing ${theme_name}..."
            cp -r "themes/${theme_name}" "$themes_dir/"
        fi
    done
    
    # Set default theme (Mauve accent)
    if [[ -d "themes/Catppuccin-Mocha-Standard-Mauve-Dark" ]]; then
        info "Setting up default Catppuccin-Mocha theme..."
        ln -sf "Catppuccin-Mocha-Standard-Mauve-Dark" "$themes_dir/Catppuccin-Mocha"
    fi
    
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    success "Catppuccin GTK themes installed successfully!"
}

# Install Catppuccin folders icon theme
install_catppuccin_folders() {
    local icons_dir="$HOME/.icons"
    
    info "Installing Catppuccin folder icons..."
    TEMP_DIR=$(mktemp -d)
    
    # Clone the Catppuccin folders repository
    if ! git clone --depth=1 https://github.com/catppuccin/papirus-folders.git "$TEMP_DIR/catppuccin-folders"; then
        warn "Failed to clone Catppuccin folders repository, skipping folder icons"
        rm -rf "$TEMP_DIR"
        return 0
    fi
    
    cd "$TEMP_DIR/catppuccin-folders"
    
    # Install Papirus icon theme if not present
    if [[ ! -d "$icons_dir/Papirus" ]] && [[ ! -d "/usr/share/icons/Papirus" ]]; then
        info "Installing Papirus icon theme..."
        if ! git clone --depth=1 https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git papirus; then
            warn "Failed to install Papirus icons, skipping"
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
            return 0
        fi
        cp -r papirus/Papirus* "$icons_dir/"
    fi
    
    # Apply Catppuccin Mocha coloring to folders
    if command -v papirus-folders >/dev/null 2>&1; then
        info "Applying Catppuccin Mocha folder colors..."
        papirus-folders -C cat-mocha-mauve --theme Papirus-Dark
    else
        info "papirus-folders command not found, applying manual coloring..."
        # Manual application would go here if needed
    fi
    
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    success "Catppuccin folder icons installed!"
}

# Install dependencies for GTK theming
install_dependencies() {
    info "Installing GTK theming dependencies..."
    
    # Use the enhanced install-package.sh utility (supports yay automatically)
    "$UTILS_DIR/install-package.sh" libgtk-3-dev gtk3-devel gtk3 gtk3
    "$UTILS_DIR/install-package.sh" libgtk-4-dev gtk4-devel gtk4 gtk4
    "$UTILS_DIR/install-package.sh" git git git git
    "$UTILS_DIR/install-package.sh" unzip unzip unzip unzip
    
    # Try to install papirus-folders if available (optional)
    "$UTILS_DIR/install-package.sh" papirus-folders papirus-folders papirus-folders papirus-folders || warn "papirus-folders not available, will install manually if needed"
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
    install_dependencies
    install_catppuccin_gtk
    install_catppuccin_folders
    link_gtk_configs
    
    success "Catppuccin GTK themes installation completed successfully!"
    info "Note: You may need to restart applications or log out/in for themes to take effect."
}

main