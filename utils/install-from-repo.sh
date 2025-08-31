#!/bin/bash
set -e

# Define script directory - this script is in utils/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source logging utilities from the same directory
source "$SCRIPT_DIR/log.sh"

ARCH="x86_64"
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
    if ! curl -L --progress-bar -o "$TEMP_DIR/archive.tar.gz" "$download_url"; then
        error "Failed to download $binary_name from $download_url"
        rm -rf "$TEMP_DIR"
        return 1
    fi

    # Handle different archive types
    if [[ "$download_url" == *.tar.gz ]]; then
        if ! tar -xzf "$TEMP_DIR/archive.tar.gz" -C "$TEMP_DIR"; then
            error "Failed to extract archive for $binary_name"
            rm -rf "$TEMP_DIR"
            return 1
        fi
    elif [[ "$download_url" == *.zip ]]; then
        if ! unzip "$TEMP_DIR/archive.tar.gz" -d "$TEMP_DIR"; then
            error "Failed to extract zip archive for $binary_name"
            rm -rf "$TEMP_DIR"
            return 1
        fi
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
        if ! sudo install -Dm755 "$source_binary" "/usr/local/bin/$binary_name"; then
            error "Failed to install $binary_name to /usr/local/bin"
            rm -rf "$TEMP_DIR"
            return 1
        fi

        if [[ -n "$rename_pattern" ]]; then
            local new_name="${rename_pattern##* -> }"
            info "Renaming $binary_name to $new_name..."
            if ! sudo mv "/usr/local/bin/$binary_name" "/usr/local/bin/$new_name"; then
                error "Failed to rename $binary_name to $new_name"
                rm -rf "$TEMP_DIR"
                return 1
            fi
        fi
        success "$binary_name installation completed!"
    else
        error "Could not find binary in archive for $binary_name"
        rm -rf "$TEMP_DIR"
        return 1
    fi

    rm -rf "$TEMP_DIR"

    # Run any post-install commands (e.g., cache build)
    if [[ -n "$post_install_cmd" ]]; then
        info "Running post-install command: $post_install_cmd"
        if ! eval "$post_install_cmd"; then
            warn "Post-install command failed, but continuing..."
        fi
    fi
}
