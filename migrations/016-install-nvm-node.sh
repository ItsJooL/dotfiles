#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# NVM installation directory
NVM_DIR="${NVM_DIR:-${HOME}/.nvm}"

# Check if NVM is already installed
check_nvm_installed() {
    if [[ -d "$NVM_DIR" ]] && [[ -s "$NVM_DIR/nvm.sh" ]]; then
        return 0
    fi
    return 1
}

# Install NVM
install_nvm() {
    info "Installing NVM..."
    
    # Create NVM directory if it doesn't exist
    mkdir -p "$NVM_DIR"
    
    # Download and install NVM
    info "Downloading NVM installer..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    
    # Verify installation
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        success "NVM installed successfully to $NVM_DIR"
    else
        error "NVM installation failed"
        exit 1
    fi
}

# Source NVM for this session
source_nvm() {
    info "Initializing NVM for this session..."
    export NVM_DIR="$NVM_DIR"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# Install Node.js 22 LTS
install_node() {
    info "Installing Node.js 22 LTS..."
    
    # Check if Node 22 is already installed
    if nvm ls | grep -q "v22\."; then
        info "Node.js 22 is already installed"
        # Make sure it's set as default
        nvm alias default lts/iron
        return 0
    fi
    
    # Install the latest Node 22 LTS (Iron)
    nvm install --lts=iron || {
        error "Failed to install Node.js 22 LTS"
        exit 1
    }
    
    # Set as default
    nvm alias default lts/iron
    nvm use default
    
    success "Node.js 22 LTS installed and set as default"
}

# Verify installations
verify_installations() {
    info "Verifying installations..."
    
    # Source NVM again to ensure tools are in PATH
    source_nvm
    nvm use default
    
    # Check Node.js
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version)
        success "✓ Node.js: $node_version"
    else
        error "✗ Node.js installation verification failed"
        exit 1
    fi
    
    # Check npm
    if command -v npm >/dev/null 2>&1; then
        local npm_version=$(npm --version)
        success "✓ npm: $npm_version"
    else
        error "✗ npm installation verification failed"
        exit 1
    fi
    
    # Update npm to latest version
    info "Updating npm to latest version..."
    npm install -g npm@latest || warn "Failed to update npm, but continuing..."
    
    local npm_version_updated=$(npm --version)
    success "✓ npm updated to: $npm_version_updated"
}

# Main execution
main() {
    info "Setting up Node.js development environment via NVM..."
    
    if check_nvm_installed; then
        info "NVM is already installed at $NVM_DIR"
    else
        install_nvm
    fi
    
    # Initialize NVM for this session
    source_nvm
    
    # Install Node.js
    install_node
    
    # Verify everything is working
    verify_installations
    
    echo
    success "Node.js development environment setup completed successfully!"
    info "Installed components:"
    info "  • NVM (Node Version Manager)"
    info "  • Node.js 22 LTS (Iron)"
    info "  • npm (latest version)"
    info ""
    info "Tools will be available in new shell sessions automatically."
    info "To use in current session, run: source ~/.nvm/nvm.sh && nvm use default"
}

main