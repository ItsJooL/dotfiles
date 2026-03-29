#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

source "$UTILS_DIR/log.sh"
source "$UTILS_DIR/stow-config.sh"

link_k9s_config() {
    info "Linking k9s configuration..."

    local target="$HOME/.config/k9s"
    mkdir -p "$target/skins"

    stow_config -d "$SCRIPT_DIR/../config" -t "$target" k9s
    success "k9s configuration linked!"
}

verify_k9s() {
    if command -v k9s >/dev/null 2>&1; then
        local version
        version=$(k9s version --short 2>&1 | head -n 1)
        success "k9s: $version"
    else
        warn "k9s not found in PATH — install via mise"
    fi
}

main() {
    info "Configuring k9s..."
    link_k9s_config
    verify_k9s
    success "k9s configuration complete!"
}

main
