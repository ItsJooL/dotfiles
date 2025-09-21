#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# SDKMAN installation directory
SDKMAN_DIR="${SDKMAN_DIR:-${HOME}/.sdkman}"

# Check if SDKMAN is already installed
check_sdkman_installed() {
    if [[ -d "$SDKMAN_DIR" ]] && [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
        return 0
    fi
    return 1
}

# Install SDKMAN
install_sdkman() {
    info "Installing SDKMAN..."
    # Download and install SDKMAN
    info "Downloading SDKMAN installer..."
    curl -s "https://get.sdkman.io" | bash
    
    # Verify installation
    if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
        success "SDKMAN installed successfully to $SDKMAN_DIR"
    else
        error "SDKMAN installation failed"
        exit 1
    fi
}

# Main execution
main() {
    info "Setting up SDKMAN..."
    
    if check_sdkman_installed; then
        info "SDKMAN is already installed at $SDKMAN_DIR"
        success "SDKMAN setup completed (already installed)"
    else
        install_sdkman
        info "SDKMAN is now available. The zshrc is already configured to load it automatically."
        success "SDKMAN installation completed successfully!"
    fi
}

main
