#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# SDKMAN installation directory
SDKMAN_DIR="${SDKMAN_DIR:-${HOME}/.sdkman}"

# Check if SDKMAN is installed and available
check_sdkman_available() {
    if [[ ! -d "$SDKMAN_DIR" ]] || [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
        error "SDKMAN is not installed. Please run migration 014-install-sdkman.sh first."
        exit 1
    fi
}

# Source SDKMAN for this session
source_sdkman() {
    info "Initializing SDKMAN for this session..."
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
}

# Check if a candidate is already installed
is_candidate_installed() {
    local candidate="$1"
    local version="$2"
    
    if [[ -n "$version" ]]; then
        sdk list "$candidate" | grep -q "* $version" 2>/dev/null
    else
        sdk current "$candidate" >/dev/null 2>&1
    fi
}

# Install Java 21
install_java() {
    info "Installing Java 21..."
    
    if is_candidate_installed "java" "21.*"; then
        info "Java 21 is already installed"
        return 0
    fi
    
    # Install the latest Java 21 version (Temurin distribution)
    sdk install java 21.0.5-tem || {
        warn "Failed to install Java 21.0.5-tem, trying default Java 21..."
        sdk install java 21-tem || {
            error "Failed to install Java 21"
            exit 1
        }
    }
    
    # Set as default
    sdk default java 21.0.5-tem 2>/dev/null || sdk default java 21-tem
    success "Java 21 installed and set as default"
}

# Install Maven
install_maven() {
    info "Installing Maven..."
    
    if is_candidate_installed "maven"; then
        info "Maven is already installed"
        return 0
    fi
    
    # Install latest Maven
    sdk install maven || {
        error "Failed to install Maven"
        exit 1
    }
    
    success "Maven installed successfully"
}

# Install Gradle
install_gradle() {
    info "Installing Gradle..."
    
    if is_candidate_installed "gradle"; then
        info "Gradle is already installed"
        return 0
    fi
    
    # Install latest Gradle
    sdk install gradle || {
        error "Failed to install Gradle"
        exit 1
    }
    
    success "Gradle installed successfully"
}

# Verify installations
verify_installations() {
    info "Verifying installations..."
    
    # Source SDKMAN again to ensure tools are in PATH
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
    
    # Check Java
    if command -v java >/dev/null 2>&1; then
        local java_version=$(java -version 2>&1 | head -n 1)
        success "✓ Java: $java_version"
    else
        error "✗ Java installation verification failed"
        exit 1
    fi
    
    # Check Maven
    if command -v mvn >/dev/null 2>&1; then
        local mvn_version=$(mvn -version 2>/dev/null | head -n 1 | cut -d' ' -f3)
        success "✓ Maven: $mvn_version"
    else
        error "✗ Maven installation verification failed"
        exit 1
    fi
    
    # Check Gradle
    if command -v gradle >/dev/null 2>&1; then
        local gradle_version=$(gradle -version 2>/dev/null | grep "Gradle" | cut -d' ' -f2)
        success "✓ Gradle: $gradle_version"
    else
        error "✗ Gradle installation verification failed"
        exit 1
    fi
}

# Main execution
main() {
    info "Setting up Java development tools via SDKMAN..."
    
    # Check prerequisites
    check_sdkman_available
    
    # Initialize SDKMAN for this session
    source_sdkman
    
    # Install tools
    install_java
    install_maven
    install_gradle
    
    # Verify everything is working
    verify_installations
    
    echo
    success "Java development tools installation completed successfully!"
    info "Installed tools:"
    info "  • Java 21 (Temurin distribution)"
    info "  • Apache Maven (latest)"
    info "  • Gradle (latest)"
    info ""
    info "Tools will be available in new shell sessions automatically."
    info "To use in current session, run: source ~/.sdkman/bin/sdkman-init.sh"
}

main