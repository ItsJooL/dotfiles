#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

source "$UTILS_DIR/log.sh"

remove_hyprpanel_config() {
    local target="$HOME/.config/hyprpanel"

    if [[ -L "$target" ]]; then
        info "Removing stale hyprpanel symlink..."
        rm "$target"
        success "Removed $target"
    elif [[ -d "$target" ]]; then
        info "Removing hyprpanel config directory..."
        rm -rf "$target"
        success "Removed $target"
    else
        info "No hyprpanel config found, nothing to remove."
    fi
}

main() {
    remove_hyprpanel_config
    success "HyprPanel cleanup complete."
}

main
