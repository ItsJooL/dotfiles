#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"
ORIGINAL_DIR="$(pwd)"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# Detect distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Check if running in Wayland session (optional check)
check_wayland_session() {
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
        return 0
    fi
    return 1
}

# Install AGS v2 (Astal + AGS) on Arch
install_ags_arch() {
    info "Installing AGS v2 on Arch..."

    # Install AGS from AUR
    if command -v yay >/dev/null 2>&1; then
        yay -S --noconfirm aylurs-gtk-shell
        success "AGS installed from AUR!"
    else
        error "yay not available - cannot install AGS. Please install yay first."
        exit 1
    fi
}

# Install AGS v2 (Astal + AGS) on Fedora - from source
install_ags_fedora() {
    info "Installing AGS v2 dependencies on Fedora..."

    # Install build dependencies for AGS
    local build_deps=(
        "npm" "meson" "ninja-build" "golang" "gobject-introspection-devel"
        "gtk3-devel" "gtk-layer-shell-devel" "gtk4-devel" "gtk4-layer-shell-devel"
        "git" "cmake"
        "vala" "valadoc" "wayland-protocols-devel"
    )

    for dep in "${build_deps[@]}"; do
        "$UTILS_DIR/install-package.sh" "$dep"
    done

    info "Building and installing Astal (required for AGS v2)..."
    local temp_dir=$(mktemp -d)

    # Install Astal
    git clone https://github.com/aylur/astal "$temp_dir/astal"
    # astal-io
    cd "$temp_dir/astal/lib/astal/io"
    meson setup build
    sudo meson install -C build
    # astal-3
    cd "$temp_dir/astal/lib/astal/gtk3"
    meson setup build
    sudo meson install -C build
    # astal-4
    cd "$temp_dir/astal/lib/astal/gtk4"
    meson setup build
    sudo meson install -C build

    cd "$temp_dir/astal/lang/gjs"
    meson setup --prefix /usr build
    sudo meson install -C build

    # Install AGS
    info "Building and installing AGS v2..."
    git clone https://github.com/aylur/ags.git "$temp_dir/ags"
    cd "$temp_dir/ags"
    npm install
    meson setup build
    sudo meson install -C build

    # Cleanup
    rm -rf "$temp_dir"
    success "AGS v2 installed from source!"
    cd $ORIGINAL_DIR
}

# Install packages for Arch Linux
install_arch_packages() {
    info "Installing Hyprland ecosystem packages for Arch Linux..."

    local core_packages=(
        "hyprland"
        "hypridle"
        "hyprpaper"
        "waybar"
        "swww"
    )

    # Install core packages via pacman
    for package in "${core_packages[@]}"; do
        "$UTILS_DIR/install-package.sh" "$package"
    done

    # Install AGS first (required for HyprPanel)
    install_ags_arch

    # Install HyprPanel from AUR
    if command -v yay >/dev/null 2>&1; then
        info "Installing HyprPanel dependencies..."
        # Install required dependencies that might not be automatically resolved
        local hyprpanel_deps=(
            "wireplumber" "libgtop" "bluez" "bluez-utils" "networkmanager"
            "dart-sass" "wl-clipboard" "upower" "gvfs" "gtksourceview3" "libsoup3"
        )

        for dep in "${hyprpanel_deps[@]}"; do
            yay -S --noconfirm --needed "$dep"
        done

        info "Installing HyprPanel from AUR..."
        yay -S --noconfirm ags-hyprpanel-git
        success "HyprPanel installed from AUR!"
    else
        error "yay not available - cannot install HyprPanel"
        exit 1
    fi
}

# Install packages for Fedora
install_fedora_packages() {
    info "Installing Hyprland ecosystem packages for Fedora..."

    # Enable COPR repositories
    info "Enabling COPR repositories..."
    sudo dnf copr enable -y solopasha/hyprland 2>/dev/null || warn "Failed to enable solopasha/hyprland COPR repo"
    sudo dnf copr enable -y heus-sueh/packages 2>/dev/null || warn "Failed to enable heus-sueh/packages COPR repo"

    # Set priority for heus-sueh/packages to avoid conflicts
    sudo dnf config-manager --save --setopt=copr:copr.fedorainfracloud.org:heus-sueh:packages.priority=200 || warn "Failed to set repo priority"

    local core_packages=(
        "hyprland"
        "hypridle"
        "hyprlock"
        "hyprpaper"
        "waybar"
        "swww"
    )

    # Install core packages via dnf
    for package in "${core_packages[@]}"; do
        info "Installing $package..."
        sudo dnf install -y "$package" || warn "Failed to install $package"
    done

    # Install AGS v2 from source (required for HyprPanel)
    install_ags_fedora

    # Install HyprPanel dependencies
    info "Installing HyprPanel dependencies..."
    local hyprpanel_deps=(
        "wireplumber" "upower" "libgtop2" "bluez" "bluez-tools"
        "grimblast" "hyprpicker" "btop" "NetworkManager" "wl-clipboard"
        "brightnessctl" "gnome-bluetooth" "power-profiles-daemon"
        "gvfs" "nodejs" "gtksourceview3" "libsoup3"
    )

    for dep in "${hyprpanel_deps[@]}"; do
        sudo dnf install -y "$dep" || warn "Failed to install $dep"
    done

    # Install sass via npm
    info "Installing sass via npm..."
    sudo npm install -g sass || warn "Failed to install sass via npm"
    sudo dnf install -y "hyprpanel" || warn "Failed to install hyprpanel"
}

# Install HyprPanel from source (used for Fedora)
install_hyprpanel_from_source() {
    info "Installing HyprPanel from source..."

    local temp_dir=$(mktemp -d)
    git clone https://github.com/Jas-SinghFSU/HyprPanel.git "$temp_dir/HyprPanel"

    cd "$temp_dir/HyprPanel"
    npm i
    meson setup build
    meson compile -C build
    sudo meson install -C build

    # Install fonts script if available
    if [[ -f "scripts/install_fonts.sh" ]]; then
        info "Installing JetBrainsMono NerdFont via HyprPanel script..."
        chmod +x scripts/install_fonts.sh
        ./scripts/install_fonts.sh || warn "Font installation script failed"
    fi

    # Cleanup
    rm -rf "$temp_dir"
    success "HyprPanel installed from source!"
}

# Main installation logic
install_hyprland() {
    local distro="$1"

    case "$distro" in
        arch|manjaro|endeavouros)
            install_arch_packages
            ;;
        fedora|nobara)
            install_fedora_packages
            ;;
        ubuntu|debian|pop|mint)
            info "Ubuntu/Debian detected - Hyprland installation not supported, silently exiting."
            exit 0
            ;;
        *)
            warn "Unknown or unsupported distribution: $distro, silently exiting."
            exit 0
            ;;
    esac
}

# Link configuration files
link_configurations() {
    local distro="$1"

    # Skip configuration linking for Ubuntu/Debian since packages aren't installed
    case "$distro" in
        ubuntu|debian|pop|mint)
            info "Skipping configuration linking (packages not installed on $distro)"
            return 0
            ;;
    esac

    info "Linking Hyprland configurations..."

    # Link Hyprland config
    if [[ -d "$SCRIPT_DIR/../config/hypr" ]]; then
        mkdir -p "$HOME/.config/hypr"
        stow -v -R -d "$SCRIPT_DIR/../config" -t "$HOME/.config" hypr
        success "Hyprland configuration linked!"
    else
        warn "Hyprland config directory not found, skipping..."
    fi

    # Link HyprPanel config
       if [[ -d "$SCRIPT_DIR/../config/hyprpanel" ]]; then
           mkdir -p "$HOME/.config/hyprpanel"
           stow -v -R -d "$SCRIPT_DIR/../config" -t "$HOME/.config" hyprpanel
           success "HyprPanel configuration linked!"
       else
           warn "HyprPanel config directory not found, skipping..."
       fi
    # Create additional config directories that might be needed
    mkdir -p "$HOME/.config/waybar"
    mkdir -p "$HOME/.config/swww"
    mkdir -p "$HOME/.config/ags"

    info "Configuration linking completed!"
}

# Main execution
DISTRO=$(detect_distro)
info "Detected distribution: $DISTRO"

# Wayland assumption check (informational only)
if [[ -z "$WAYLAND_DISPLAY" ]] && [[ "$XDG_SESSION_TYPE" != "wayland" ]]; then
    info "Note: No Wayland session detected currently, but proceeding with installation"
fi

# Perform installation
install_hyprland "$DISTRO"

# Link configurations
link_configurations "$DISTRO"

case "$DISTRO" in
    arch|manjaro|endeavouros|fedora|nobara)
        success "Hyprland ecosystem installation completed!"
        ;;
    *)
        info "Migration completed (no packages installed for $DISTRO)"
        ;;
esac
