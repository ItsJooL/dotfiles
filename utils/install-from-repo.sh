#!/bin/bash

# Helper function to get latest release tag from GitHub API
get_latest_tag() {
    local repo_url=$1
    local repo_path=$(echo "$repo_url" | sed 's|https://github.com/||')
    curl -fsSL "https://api.github.com/repos/$repo_path/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Helper function to find matching asset URL from latest release
get_latest_asset_url() {
    local repo_url=$1
    local pattern=$2
    local repo_path=$(echo "$repo_url" | sed 's|https://github.com/||')

    # Get release info
    local release_data=$(curl -fsSL "https://api.github.com/repos/$repo_path/releases/latest")

    # Find matching asset
    echo "$release_data" | grep -o '"browser_download_url": "[^"]*"' | \
        grep -o 'https://[^"]*' | \
        grep -E "$pattern" | \
        head -1
}

# Function to install a binary from a GitHub release
# Usage: install_binary <repo_url> <binary_name> [<archive_pattern_or_name>] [<rename_pattern>] [<post_install_cmd>]
install_binary() {
    local repo_url=$1
    local binary_name=$2
    local archive_pattern=$3
    local rename_pattern=$4
    local post_install_cmd=$5

    if command -v "$binary_name" &> /dev/null; then
        info "$binary_name is already installed. Skipping."
        return 0
    fi

    info "Installing $binary_name..."
    TEMP_DIR=$(mktemp -d)

    local download_url

    # Determine download strategy
    if [[ -z "$archive_pattern" ]]; then
        # Default pattern: ${binary_name}_${OS}_${ARCH}.tar.gz
        download_url="$repo_url/releases/latest/download/${binary_name}_${OS}_${ARCH}.tar.gz"
        info "Using default pattern: ${binary_name}_${OS}_${ARCH}.tar.gz"
    elif [[ "$archive_pattern" == *".tar.gz" ]] || [[ "$archive_pattern" == *".zip" ]]; then
        # Specific filename provided - check if it contains version placeholders
        if [[ "$archive_pattern" == *"{{VERSION}}"* ]] || [[ "$archive_pattern" == *"{{TAG}}"* ]]; then
            # Get latest version and substitute
            local latest_tag=$(get_latest_tag "$repo_url")
            if [[ -n "$latest_tag" ]]; then
                # Remove 'v' prefix if present for {{VERSION}}
                local version="${latest_tag#v}"
                archive_pattern="${archive_pattern//\{\{VERSION\}\}/$version}"
                archive_pattern="${archive_pattern//\{\{TAG\}\}/$latest_tag}"
                info "Using latest version $latest_tag in pattern: $archive_pattern"
            else
                error "Failed to get latest version for $binary_name"
                rm -rf "$TEMP_DIR"
                return 1
            fi
        fi
        download_url="$repo_url/releases/latest/download/$archive_pattern"
    else
        # Pattern for auto-detection (e.g., "linux_amd64", "x86_64-unknown-linux-musl")
        info "Auto-detecting latest asset matching pattern: $archive_pattern"
        download_url=$(get_latest_asset_url "$repo_url" "$archive_pattern")
        if [[ -z "$download_url" ]]; then
            error "No matching asset found for pattern: $archive_pattern"
            rm -rf "$TEMP_DIR"
            return 1
        fi
        info "Found matching asset: $download_url"
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
        if ! unzip -q "$TEMP_DIR/archive.tar.gz" -d "$TEMP_DIR"; then
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
        source_binary=$(find "$TEMP_DIR" -type f -name "$binary_name" -executable -print -quit)
        # Fallback: look for any executable file if exact name not found
        if [[ -z "$source_binary" ]]; then
            source_binary=$(find "$TEMP_DIR" -type f -executable -print -quit)
        fi
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
