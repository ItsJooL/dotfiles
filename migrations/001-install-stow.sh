#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"
# Source logging utilities
source "$UTILS_DIR/log.sh"

info "Installing GNU Stow..."
"$UTILS_DIR/install-package.sh" stow

success "Stow installation completed!"
