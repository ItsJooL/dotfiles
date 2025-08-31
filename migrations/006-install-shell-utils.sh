#!/bin/bash
set -e

# Define script and utility directories relative to the script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source the logging utilities.
source "$UTILS_DIR/log.sh"

# Source the new utility for installing from GitHub repositories.
source "$UTILS_DIR/install-from-repo.sh"

# Function to get the latest release tag for a repo
get_latest_tag() {
    local repo_url="$1"
    local repo_path="${repo_url#https://github.com/}"
    curl -s "https://api.github.com/repos/$repo_path/releases/latest" | grep '"tag_name"' | cut -d'"' -f4
}

# --- Main Script Logic ---

info "Starting installation of core binaries from git repositories..."

# Ripgrep
install_binary "https://github.com/BurntSushi/ripgrep" "rg" "ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz" "ripgrep*/rg -> rg"
success "Ripgrep installed!"

# Fd - get the actual latest version and construct exact filename
info "Getting latest fd release version..."
FD_TAG=$(get_latest_tag "https://github.com/sharkdp/fd")
if [[ -n "$FD_TAG" ]]; then
    install_binary "https://github.com/sharkdp/fd" "fd" "fd-${FD_TAG}-x86_64-unknown-linux-musl.tar.gz"
else
    # Fallback to known working version
    install_binary "https://github.com/sharkdp/fd" "fd" "fd-v10.3.0-x86_64-unknown-linux-musl.tar.gz"
fi
success "fd installed!"

# Eza
install_binary "https://github.com/eza-community/eza" "eza" "eza_x86_64-unknown-linux-musl.tar.gz"
success "Eza installed!"

# FZF
install_binary "https://github.com/junegunn/fzf" "fzf" "fzf-0.55.0-linux_amd64.tar.gz"
success "FZF installed!"

# Zoxide
install_binary "https://github.com/ajeetdsouza/zoxide" "zoxide" "zoxide-0.9.8-x86_64-unknown-linux-musl.tar.gz"
success "Zoxide installed!"

# Mcfly
install_binary "https://github.com/cantino/mcfly" "mcfly" "mcfly-v0.9.3-x86_64-unknown-linux-musl.tar.gz"
success "Mcfly installed!"

# Mcfly-Fzf
install_binary "https://github.com/bnprks/mcfly-fzf" "mcfly-fzf" "mcfly-fzf-1.0.4-x86_64-unknown-linux-musl.tar.gz"
success "Mcfly-fzf installed!"

# Carapace
install_binary "https://github.com/carapace-sh/carapace-bin" "carapace" "carapace-bin_1.4.1_linux_amd64.tar.gz"
success "Carapace installed!"

success "Finished install shell utils."
