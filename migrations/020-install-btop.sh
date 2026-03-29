#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

source "$UTILS_DIR/log.sh"
source "$UTILS_DIR/stow-config.sh"

link_btop_config() {
    info "Linking btop configuration..."
    mkdir -p "$HOME/.config/btop/themes"
    stow_config -d "$SCRIPT_DIR/../config" -t "$HOME/.config/btop" btop
    success "btop configuration linked!"
}

main() {
    info "Setting up btop configuration..."
    link_btop_config
    success "btop setup completed successfully!"
}

main
