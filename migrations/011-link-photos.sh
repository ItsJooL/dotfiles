#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

info "Stowing wallpapers and profile photo..."

# Define the config source directory
CONFIG_SOURCE_DIR="$SCRIPT_DIR/../config"
BACKGROUNDS_DESTINATION="$HOME/.config/backgrounds"
PROFILE_DESTINATION="$HOME/.config/profile"
mkdir -p $BACKGROUNDS_DESTINATION
mkdir -p $PROFILE_DESTINATION


if [[ -d "$CONFIG_SOURCE_DIR/backgrounds" ]]; then
    info "Linking backgrounds with stow..."
    stow -v -R -d "$CONFIG_SOURCE_DIR" -t "$BACKGROUNDS_DESTINATION" backgrounds
    success "Backgrounds linked!"
else
    warn "Backgrounds directory not found, skipping..."
fi

if [[ -d "$CONFIG_SOURCE_DIR/profile" ]]; then
    info "Linking profile photo with stow..."
    stow -v -R -d "$CONFIG_SOURCE_DIR" -t "$PROFILE_DESTINATION" profile
    success "Profile photo linked!"
else
    warn "Profile directory not found, skipping..."
fi

success "Media stowing completed!"
