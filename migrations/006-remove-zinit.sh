#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

source "$UTILS_DIR/log.sh"

ZINIT_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"

if [[ -d "$ZINIT_DIR" ]]; then
    info "Removing zinit directory: $ZINIT_DIR"
    rm -rf "$ZINIT_DIR"
    success "zinit removed — antidote will bootstrap on next shell start."
else
    info "zinit not found at $ZINIT_DIR — nothing to remove."
fi
