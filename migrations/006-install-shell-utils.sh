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

install_binary "https://github.com/BurntSushi/ripgrep" "rg" "aarch64-unknown-linux-gnu"
success "Ripgrep installed!"

info "Getting latest fd release version..."
install_binary "https://github.com/sharkdp/fd" "fd" "fd-{{TAG}}-x86_64-unknown-linux-musl.tar.gz"
success "fd installed!"

install_binary "https://github.com/eza-community/eza" "eza" "x86_64-unknown-linux-musl"
success "Eza installed!"

install_binary "https://github.com/junegunn/fzf" "fzf" "fzf-{{VERSION}}-linux_amd64.tar.gz"
success "FZF installed!"

install_binary "https://github.com/ajeetdsouza/zoxide" "zoxide" "zoxide-{{VERSION}}-x86_64-unknown-linux-musl.tar.gz"
success "Zoxide installed!"

install_binary "https://github.com/cantino/mcfly" "mcfly" "mcfly-{{TAG}}-x86_64-unknown-linux-musl.tar.gz"
success "Mcfly installed!"

install_binary "https://github.com/bnprks/mcfly-fzf" "mcfly-fzf" "mcfly-fzf-{{VERSION}}-x86_64-unknown-linux-musl.tar.gz"
success "Mcfly-fzf installed!"

install_binary "https://github.com/carapace-sh/carapace-bin" "carapace" "carapace-bin_{{VERSION}}_linux_amd64.tar.gz"
success "Carapace installed!"

success "Finished install shell utils."
