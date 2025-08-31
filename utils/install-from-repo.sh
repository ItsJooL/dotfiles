#!/bin/bash
set -e

# Define script and utility directories relative to the script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")"
source "$UTILS_DIR/log.sh"

ARCH="amd64"
OS="linux"

# Function to install a binary from a GitHub release
# Usage: install_binary <repo_url> <binary_name> [<custom_archive_name>] [<rename_pattern>] [<post_install_cmd>]
install_binary() {
    local repo_url=$1
    local binary_name=$2
    local custom_archive_name=$3
    local rename_pattern=$4
    local post_install_cmd=$5

    if command -v "$binary_name" &> /dev/null; then
        info "$binary_name is already installed. Skipping."
        return 0
    fi

    info "Installing $binary_name..."
    TEMP_DIR=$(mktemp -d)

    # Construct download URL
    local download_url
    if [[ -n "$custom_archive_name" ]]; then
        download_url="$repo_url/releases/latest/download/$custom_archive_name"
    else
        download_url="$repo_url/releases/latest/download/${binary_name}_${OS}_${ARCH}.tar.gz"
    fi

    info "Downloading from $download_url"
    curl -L --progress-bar -o "$TEMP_DIR/archive.tar.gz" "$download_url"

    # Handle different archive types
    if [[ "$download_url" == *.tar.gz ]]; then
        tar -xzf "$TEMP_DIR/archive.tar.gz" -C "$TEMP_DIR"
    elif [[ "$download_url" == *.zip ]]; then
        unzip "$TEMP_DIR/archive.tar.gz" -d "$TEMP_DIR"
    fi

    # Find the binary based on the rename pattern or a default name
    local source_binary
    if [[ -n "$rename_pattern" ]]; then
        source_binary=$(find "$TEMP_DIR" -type f -name "${rename_pattern%% ->*}" -print -quit)
    else
        source_binary=$(find "$TEMP_DIR" -type f -name "$binary_name" -print -quit)
    fi

    if [[ -n "$source_binary" ]]; then
        info "Installing $source_binary to /usr/local/bin/$binary_name..."
        sudo install -Dm755 "$source_binary" "/usr/local/bin/$binary_name"
        if [[ -n "$rename_pattern" ]]; then
             local new_name="${rename_pattern##* -> }"
             info "Renaming $binary_name to $new_name..."
             sudo mv "/usr/local/bin/$binary_name" "/usr/local/bin/$new_name"
        fi
        success "$binary_name installation completed!"
    else
        error "Could not find binary in archive."
    fi

    rm -rf "$TEMP_DIR"

    # Run any post-install commands (e.g., cache build)
    if [[ -n "$post_install_cmd" ]]; then
        eval "$post_install_cmd"
    fi
}
