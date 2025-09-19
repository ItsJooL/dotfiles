#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# Configure Firefox theme
configure_firefox() {
    info "Configuring Firefox theme..."
    
    # Find Firefox profile directories
    local firefox_dir="$HOME/.mozilla/firefox"
    if [[ -d "$firefox_dir" ]]; then
        local profiles=($(find "$firefox_dir" -name "*.default*" -type d 2>/dev/null))
        
        for profile in "${profiles[@]}"; do
            local userjs_file="$profile/user.js"
            info "Configuring Firefox profile: $(basename "$profile")"
            
            # Create or update user.js with dark theme preferences
            cat >> "$userjs_file" << 'EOF'

// Catppuccin Mocha theme preferences
user_pref("ui.systemUsesDarkTheme", true);
user_pref("devtools.theme", "dark");
user_pref("browser.theme.content-theme", 0);
user_pref("browser.theme.toolbar-theme", 0);
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
EOF
            success "Firefox profile configured: $(basename "$profile")"
        done
        
        if [[ ${#profiles[@]} -eq 0 ]]; then
            info "No Firefox profiles found, configuration will apply to new profiles"
        fi
    else
        info "Firefox not installed or no profiles found"
    fi
}

# Configure Chrome/Chromium theme
configure_chrome() {
    info "Configuring Chrome/Chromium theme..."
    
    local chrome_dirs=(
        "$HOME/.config/google-chrome"
        "$HOME/.config/chromium"
        "$HOME/.config/google-chrome-beta"
        "$HOME/.config/google-chrome-unstable"
    )
    
    for chrome_dir in "${chrome_dirs[@]}"; do
        if [[ -d "$chrome_dir" ]]; then
            local prefs_file="$chrome_dir/Default/Preferences"
            local local_state="$chrome_dir/Local State"
            
            info "Configuring $(basename "$chrome_dir")..."
            
            # Create Default profile directory if it doesn't exist
            mkdir -p "$chrome_dir/Default"
            
            # Configure dark theme preference
            if [[ -f "$prefs_file" ]]; then
                # Use jq if available to modify JSON, otherwise append
                if command -v jq >/dev/null 2>&1; then
                    local temp_file=$(mktemp)
                    jq '.browser.theme.kind = 2' "$prefs_file" > "$temp_file" && mv "$temp_file" "$prefs_file"
                    success "Updated theme preference for $(basename "$chrome_dir")"
                else
                    warn "jq not available, theme preference may need manual configuration"
                fi
            else
                # Create basic preferences file with dark theme
                cat > "$prefs_file" << 'EOF'
{
   "browser": {
      "theme": {
         "kind": 2
      }
   }
}
EOF
                success "Created theme preference for $(basename "$chrome_dir")"
            fi
        fi
    done
}

# Configure application-specific themes
configure_application_themes() {
    info "Configuring application-specific themes..."
    
    # Configure VSCode/Codium theme
    local vscode_dirs=(
        "$HOME/.config/Code/User"
        "$HOME/.config/VSCodium/User"
        "$HOME/.config/code-oss/User"
    )
    
    for vscode_dir in "${vscode_dirs[@]}"; do
        if [[ -d "$(dirname "$vscode_dir")" ]]; then
            mkdir -p "$vscode_dir"
            local settings_file="$vscode_dir/settings.json"
            
            info "Configuring $(basename "$(dirname "$vscode_dir")")..."
            
            # Create or update settings.json
            if [[ -f "$settings_file" ]]; then
                # Backup existing settings
                cp "$settings_file" "$settings_file.backup"
            fi
            
            # Add Catppuccin theme preferences
            cat > "$settings_file" << 'EOF'
{
    "workbench.colorTheme": "Catppuccin Mocha",
    "workbench.iconTheme": "catppuccin-mocha",
    "workbench.preferredDarkColorTheme": "Catppuccin Mocha",
    "workbench.preferredLightColorTheme": "Catppuccin Latte",
    "terminal.integrated.colorScheme": "Catppuccin Mocha"
}
EOF
            success "Configured $(basename "$(dirname "$vscode_dir")")"
        fi
    done
    
    # Configure Zed theme
    local zed_config="$HOME/.config/zed/settings.json"
    if [[ -d "$(dirname "$zed_config")" ]]; then
        mkdir -p "$(dirname "$zed_config")"
        cat > "$zed_config" << 'EOF'
{
    "theme": "Catppuccin Mocha",
    "ui_font_family": "Inter",
    "buffer_font_family": "FiraCode Nerd Font"
}
EOF
        success "Configured Zed editor theme"
    fi
}

# Configure desktop environment specific themes
configure_desktop_themes() {
    info "Configuring desktop environment themes..."
    
    # Configure GNOME/GTK themes using gsettings if available
    if command -v gsettings >/dev/null 2>&1; then
        info "Configuring GNOME theme preferences..."
        
        # Set GTK theme
        gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Standard-Mauve-Dark' 2>/dev/null || warn "Could not set GTK theme via gsettings"
        
        # Set icon theme
        gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || warn "Could not set icon theme via gsettings"
        
        # Set cursor theme
        gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' 2>/dev/null || warn "Could not set cursor theme via gsettings"
        
        # Set font
        gsettings set org.gnome.desktop.interface font-name 'Inter 11' 2>/dev/null || warn "Could not set font via gsettings"
        
        # Prefer dark theme
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || warn "Could not set color scheme via gsettings"
        
        success "GNOME theme preferences configured"
    fi
    
    # Configure KDE/Plasma themes using kwriteconfig5 if available
    if command -v kwriteconfig5 >/dev/null 2>&1; then
        info "Configuring KDE theme preferences..."
        
        # Set widget style
        kwriteconfig5 --file kdeglobals --group General --key widgetStyle kvantum-dark
        
        # Set color scheme
        kwriteconfig5 --file kdeglobals --group General --key ColorScheme CatppuccinMocha
        
        # Set icon theme
        kwriteconfig5 --file kdeglobals --group Icons --key Theme Papirus-Dark
        
        success "KDE theme preferences configured"
    fi
}

# Set up additional theme directories and symlinks
setup_theme_directories() {
    info "Setting up additional theme directories..."
    
    # Ensure theme directories exist
    mkdir -p "$HOME/.themes"
    mkdir -p "$HOME/.icons"
    mkdir -p "$HOME/.local/share/themes"
    mkdir -p "$HOME/.local/share/icons"
    
    # Create symlinks for system-wide themes if they exist
    local system_theme_dirs=(
        "/usr/share/themes"
        "/usr/local/share/themes"
    )
    
    for theme_dir in "${system_theme_dirs[@]}"; do
        if [[ -d "$theme_dir" ]]; then
            for theme in "$theme_dir"/Catppuccin-*; do
                if [[ -d "$theme" ]]; then
                    local theme_name=$(basename "$theme")
                    if [[ ! -e "$HOME/.themes/$theme_name" ]]; then
                        ln -s "$theme" "$HOME/.themes/$theme_name"
                        success "Linked theme: $theme_name"
                    fi
                fi
            done
        fi
    done
    
    # Link icon themes
    local system_icon_dirs=(
        "/usr/share/icons"
        "/usr/local/share/icons"
    )
    
    for icon_dir in "${system_icon_dirs[@]}"; do
        if [[ -d "$icon_dir/Papirus-Dark" ]] && [[ ! -e "$HOME/.icons/Papirus-Dark" ]]; then
            ln -s "$icon_dir/Papirus-Dark" "$HOME/.icons/Papirus-Dark"
            success "Linked Papirus-Dark icons"
        fi
    done
}

# Main execution
main() {
    info "Configuring application-specific themes..."
    
    # Configure various applications
    configure_firefox
    configure_chrome
    configure_application_themes
    configure_desktop_themes
    setup_theme_directories
    
    success "Application theme configuration completed!"
    info "Some applications may need to be restarted to apply new themes."
    info "For Chrome/Chromium: Navigate to chrome://settings/appearance to verify theme."
    info "For Firefox: The theme will be applied on next restart."
}

main