#!/bin/bash
set -e

# Define script and utility directories relative to the script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source the logging utilities.
source "$UTILS_DIR/log.sh"

# Source the new utility for installing from GitHub repositories.
source "$UTILS_DIR/install-from-repo.sh"

# --- Main Script Logic ---

info "Starting installation of core binaries from git repositories..."

# Ripgrep
install_binary "https://github.com/BurntSushi/ripgrep" "rg" "ripgrep-*-x86_64-unknown-linux-musl.tar.gz" "ripgrep* -> rg"
success "Ripgrep installed!"
# Fd
install_binary "https://github.com/sharkdp/fd" "fd" "fd-*-x86_64-unknown-linux-musl.tar.gz" "fd*/fd -> fd"
success "fd installed!"

# Eza
install_binary "https://github.com/eza-community/eza" "eza" "eza_linux_amd64.tar.gz"
success "Eza installed!"

# FZF
install_binary "https://github.com/junegunn/fzf" "fzf" "fzf-*-linux_amd64.tar.gz"
success "FZF installed!"

# Zoxide
install_binary "https://github.com/ajeetdsouza/zoxide" "zoxide" "zoxide-*-x86_64-unknown-linux-musl.tar.gz"
success "Z installed!"

# Mcfly
install_binary "https://github.com/cantino/mcfly" "mcfly" "mcfly-v*-x86_64-unknown-linux-musl.tar.gz"
success "Mcfly installed!"

# Mcfly-Fzf
install_binary "https://github.com/bnprks/mcfly-fzf" "mcfly-fzf" "mcfly-fzf-x86_64-unknown-linux-musl.tar.gz"
success "Mcfly-fzf installed!"

# Carapace
install_binary "https://github.com/carapace-sh/carapace-bin" "carapace" "carapace-bin_linux_amd64.tar.gz" "carapace-bin -> carapace"
success "Carapace installed!"

success "Finished install shell utils."
