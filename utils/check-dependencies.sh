#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/log.sh"

# Required dependencies for the dotfiles installation
REQUIRED_DEPS=(
    "git"
    "curl"
    "sha256sum"
    "find"
)

# Optional dependencies (will warn but not fail)
OPTIONAL_DEPS=(
    "rsync"
)

missing_deps=()
missing_optional=()

missing_deps=()
missing_optional=()

check_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        return 1
    fi
    return 0
}

info "Checking required dependencies..."

# Check required dependencies
for dep in "${REQUIRED_DEPS[@]}"; do
    if check_command "$dep"; then
        success "✓ $dep"
    else
        error "✗ $dep (required)"
        missing_deps+=("$dep")
    fi
done

# Check optional dependencies
for dep in "${OPTIONAL_DEPS[@]}"; do
    if check_command "$dep"; then
        success "✓ $dep (optional)"
    else
        warn "! $dep (optional)"
        missing_optional+=("$dep")
    fi
done

# Report results
if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo
    error "Missing required dependencies:"
    for dep in "${missing_deps[@]}"; do
        echo "  - $dep"
    done
    echo
    error "Please install missing dependencies and try again."
    exit 1
fi

if [[ ${#missing_optional[@]} -gt 0 ]]; then
    echo
    warn "Missing optional dependencies:"
    for dep in "${missing_optional[@]}"; do
        echo "  - $dep"
    done
    warn "These are optional and won't prevent installation."
fi

echo
success "All required dependencies are available!"
exit 0
