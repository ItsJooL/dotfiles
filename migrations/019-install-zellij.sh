#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# Check if zellij is already available
check_zellij_available() {
    if command -v zellij >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Link zellij configuration using stow
link_zellij_config() {
    info "Linking zellij configuration..."
    
    # Create target directory
    TARGET_CONFIG_DIR="$HOME/.config/zellij"
    mkdir -p "$TARGET_CONFIG_DIR"
    
    # Link configuration using stow
    stow -v -R -d "$SCRIPT_DIR/../config" -t "$TARGET_CONFIG_DIR" zellij
    success "zellij configuration linked!"
}

# Verify zellij installation and configuration
verify_zellij() {
    info "Verifying zellij installation..."
    
    # Ensure mise is activated for this verification
    if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate bash)"
    fi
    
    if command -v zellij >/dev/null 2>&1; then
        local version=$(zellij --version 2>&1 | head -n 1)
        success "zellij: $version"
        
        # Check if config file exists
        if [[ -f "$HOME/.config/zellij/config.kdl" ]]; then
            success "zellij configuration file found"
        else
            warn "! zellij configuration file not found"
            return 1
        fi
        
        # Test config syntax (zellij will validate on startup)
        info "Testing zellij configuration syntax..."
        if zellij list-sessions >/dev/null 2>&1; then
            success "zellij configuration is valid"
        else
            warn "zellij configuration may have issues"
        fi
        
    else
        error "zellij not found in PATH"
        error "Make sure zellij is installed via mise (migration 018-install-mise.sh)"
        return 1
    fi
}

# Main execution
main() {
    info "Setting up zellij terminal multiplexer..."
    
    # Check if zellij is available (should be installed via mise)
    if ! check_zellij_available; then
        # Try to activate mise first
        if command -v mise >/dev/null 2>&1; then
            eval "$(mise activate bash)"
            if ! check_zellij_available; then
                error "zellij is not available. Please run migration 018-install-mise.sh first."
                exit 1
            fi
        else
            error "zellij is not available and mise is not found."
            error "Please run migration 018-install-mise.sh first."
            exit 1
        fi
    fi
    
    # Link configuration
    link_zellij_config
    
    # Verify installation
    verify_zellij
    
    success "zellij setup completed successfully!"
}

main