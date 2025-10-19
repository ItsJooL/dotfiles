#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# mise installation directory
MISE_DIR="${MISE_DIR:-${HOME}/.local/share/mise}"
MISE_BIN_DIR="${HOME}/.local/bin"

# Check if mise is already installed
check_mise_installed() {
    if command -v mise >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Install mise
install_mise() {
    info "Installing mise..."
    
    # Create bin directory if it doesn't exist
    mkdir -p "$MISE_BIN_DIR"
    
    # Download and install mise
    info "Downloading mise installer..."
    curl https://mise.run | sh
    
    # Add mise to PATH for this script
    export PATH="$MISE_BIN_DIR:$PATH"
    
    # Verify installation
    if command -v mise >/dev/null 2>&1; then
        success "mise installed successfully"
    elif [[ -f "$MISE_BIN_DIR/mise" ]]; then
        success "mise installed successfully to $MISE_BIN_DIR/mise"
    else
        error "mise installation failed"
        exit 1
    fi
}

# Link mise configuration using stow
link_mise_config() {
    info "Linking mise configuration..."
    
    # Create target directory
    mkdir -p "$HOME"
    
    # Link configuration using stow
    stow -v -R -d "$SCRIPT_DIR/../config" -t "$HOME" mise
    success "mise configuration linked!"
}

# Install tools from .tool-versions
install_tools() {
    info "Installing tools from .tool-versions..."
    
    # Change to home directory where .tool-versions is linked
    cd "$HOME"
    
    # Install all tools
    if mise install; then
        success "All tools installed successfully"
    else
        error "Failed to install some tools"
        exit 1
    fi
}

# Verify installations
verify_installations() {
    info "Verifying installations..."
    
    # Source mise to ensure tools are in PATH
    eval "$(mise activate bash)"
    
    # Check key tools
    local tools_to_check=(
        "java:java -version"
        "maven:mvn --version"
        "gradle:gradle --version"
        "node:node --version"
        "go:go version"
        "rg:rg --version"
        "fd:fd --version"
        "eza:eza --version"
        "fzf:fzf --version"
        "zoxide:zoxide --version"
        "mcfly:mcfly --version"
        "carapace:carapace --version"
        "zellij:zellij --version"
    )
    
    local failed_tools=()
    
    for tool_check in "${tools_to_check[@]}"; do
        local tool_name="${tool_check%%:*}"
        local check_command="${tool_check##*:}"
        
        if eval "$check_command" >/dev/null 2>&1; then
            local version=$(eval "$check_command" 2>&1 | head -n 1)
            success "$tool_name: $version"
        else
            error "$tool_name verification failed"
            failed_tools+=("$tool_name")
        fi
    done
    
    if [[ ${#failed_tools[@]} -gt 0 ]]; then
        warn "Some tools failed verification: ${failed_tools[*]}"
        warn "They may still be installed but not immediately available"
    fi
}

# Main execution
main() {
    info "Setting up mise development environment..."
    
    # Ensure mise bin directory is in PATH
    export PATH="$MISE_BIN_DIR:$PATH"
    
    if check_mise_installed; then
        info "mise is already installed"
    else
        install_mise
    fi
    
    # Link configuration
    link_mise_config
    
    # Install tools
    install_tools
    
    # Verify installations
    verify_installations
    
    success "mise development environment setup completed successfully!"
    info "Installed tools:"
    info "  • Java 21 (Temurin distribution)"
    info "  • Apache Maven (latest)"
    info "  • Gradle (latest)"
    info "  • Node.js 22"
    info "  • Go 1.25.3"
    info "  • Zellij"
    info "  • Shell utilities: ripgrep, fd, eza, fzf, zoxide, mcfly, carapace"
}

main