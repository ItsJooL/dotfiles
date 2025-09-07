#!/usr/bin/env bash
set -e

# Define script and utility directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$(dirname "$SCRIPT_DIR")/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# --- Helper Functions ---

# Detect the Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# --- Installation Functions ---

# Install packages for Arch Linux using yay
install_arch_packages() {
    info "Installing Hyprland ecosystem packages for Arch Linux..."
    local packages=(
        # Core Hyprland & UI
        "hyprland" "hypridle" "hyprpaper" "hyprshot" "hyprlock" "wlogout" "waybar" "swaync" "swww" "hyprpicker"
        "wireplumber" "upower" "libgtop" "bluez" "bluez-utils" "wl-clipboard"
        "brightnessctl" "btop" "networkmanager" "gnome-bluetooth"
        "pavucontrol" "blueman" "network-manager-applet" "pamixer"

    )

    info "Installing packages..."
    yay -S --noconfirm --needed "${packages[@]}"
    success "Arch Linux package installation complete!"
}

# Install packages for Fedora
install_fedora_packages() {
    info "Installing Hyprland ecosystem packages for Fedora..."

    # Enable required COPR repositories
    info "Enabling COPR repositories..."
    sudo dnf copr enable -y solopasha/hyprland &>/dev/null || warn "Failed to enable solopasha/hyprland COPR repo."
    sudo dnf copr enable -y erikreider/SwayNotificationCenter &>/dev/null || warn "Failed to enable COPR for SwayNotificationCenter."

    local packages=(
        # Core Hyprland & UI
        "hyprland" "hypridle" "hyprlock" "hyprpaper" "hyprshot" "wlogout" "waybar" "swaync" "swww" "hyprpicker"
        "wireplumber" "upower" "libgtop2" "bluez" "bluez-tools" "grimblast" "btop"
        "NetworkManager" "wl-clipboard" "brightnessctl" "gnome-bluetooth" "hyprland-qtutils"
        "pavucontrol" "blueman" "nm-connection-editor" "pamixer"

    )

    info "Installing packages..."
    for package in "${packages[@]}"; do
        "$UTILS_DIR/install-package.sh" "$package"
    done

    success "Fedora package installation complete!"
}

# Main installation logic dispatcher
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
            info "Ubuntu/Debian detected. Hyprland installation is not supported by this script. Silently exiting."
            exit 0
            ;;
        *)
            warn "Unknown or unsupported distribution: $distro. Silently exiting."
            exit 0
            ;;
    esac
}

# Link configuration files using stow
link_configurations() {
    local distro="$1"
    case "$distro" in
        ubuntu|debian|pop|mint)
            info "Skipping configuration linking as packages were not installed on $distro."
            return 0
            ;;
    esac

    info "Linking Hyprland ecosystem configurations..."
    local configs_to_link=("hypr" "waybar" "swaync")

    for config in "${configs_to_link[@]}"; do
        info "Linking $config configuration..."
        SOURCE_CONFIG_DIR="$SCRIPT_DIR/../config/${config}"
        TARGET_CONFIG_DIR="$HOME/.config/${config}"
        mkdir -p "$TARGET_CONFIG_DIR"
        stow -v -R -d "$SCRIPT_DIR/../config" -t "$TARGET_CONFIG_DIR" ${config}
        success "$config configuration linked!"


    done
    info "Configuration linking completed!"
}

# --- Main Execution ---

main() {
    local distro
    distro=$(detect_distro)
    info "Detected distribution: $distro"

    if [[ -z "$WAYLAND_DISPLAY" && "$XDG_SESSION_TYPE" != "wayland" ]]; then
        info "Note: No active Wayland session detected. Proceeding with installation."
    fi

    install_hyprland "$distro"
    link_configurations "$distro"

    case "$distro" in
        arch|manjaro|endeavouros|fedora|nobara)
            success "Hyprland ecosystem installation completed successfully!"
            ;;
        *)
            info "Migration finished (no packages were installed for $distro)."
            ;;
    esac
}

main
