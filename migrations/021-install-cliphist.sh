#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

source "$UTILS_DIR/log.sh"

main() {
    info "Installing cliphist and wl-clipboard..."
    "$UTILS_DIR/install-package.sh" cliphist
    "$UTILS_DIR/install-package.sh" wl-clipboard
    success "cliphist and wl-clipboard installed!"
}

main
