#!/bin/bash

# Cross-platform package installer with AUR support
# Usage: ./install-package.sh <package_name> [<package_name_fedora>] [<package_name_arch>] [<aur_package_name>]
# If only one package name is provided, it will be used for all distributions
# On Arch, will try pacman first, then yay (if available) for AUR packages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/log.sh"

if [[ $# -lt 1 ]]; then
    error "Usage: $0 <package_name> [<package_name_fedora>] [<package_name_arch>] [<aur_package_name>]"
    info "Examples:"
    info "  $0 git"
    info "  $0 build-essential gcc gcc"
    info "  $0 python3-pip python3-pip python-pip"
    info "  $0 kitty kitty kitty kitty-git  # Uses kitty-git from AUR if kitty not in repos"
    exit 1
fi

PACKAGE_DEBIAN="$1"
PACKAGE_FEDORA="${2:-$1}"
PACKAGE_ARCH="${3:-$1}"
PACKAGE_AUR="${4:-$3}"

# Detect distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/fedora-release ]]; then
        echo "fedora"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

# Check if package is already installed
is_installed_debian() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

is_installed_fedora() {
    rpm -q "$1" >/dev/null 2>&1
}

is_installed_arch() {
    pacman -Qi "$1" >/dev/null 2>&1
}

# Check if package is available in official repos
is_available_in_repos() {
    pacman -Si "$1" >/dev/null 2>&1
}

# Check if package is available in AUR (requires yay)
is_available_in_aur() {
    if command -v yay >/dev/null 2>&1; then
        yay -Si "$1" >/dev/null 2>&1
    else
        return 1
    fi
}

# Install package based on distribution
install_package() {
    local distro="$1"
    local package="$2"

    case "$distro" in
        debian|ubuntu)
            if is_installed_debian "$package"; then
                info "Package $package is already installed (Debian/Ubuntu)"
                return 0
            fi
            info "Installing $package on Debian/Ubuntu..."
            sudo apt-get update -qq
            sudo apt-get install -y "$package"
            ;;
        fedora|centos|rhel)
            if is_installed_fedora "$package"; then
                info "Package $package is already installed (Fedora/RHEL)"
                return 0
            fi
            info "Installing $package on Fedora/RHEL..."
            sudo dnf install -y "$package"
            ;;
        arch|manjaro|endeavouros)
            if is_installed_arch "$package"; then
                info "Package $package is already installed (Arch)"
                return 0
            fi
            
            # Try official repos first
            if is_available_in_repos "$package"; then
                info "Installing $package from official repos..."
                sudo pacman -S --noconfirm "$package"
            elif [[ "$package" != "$PACKAGE_AUR" ]] && is_available_in_repos "$PACKAGE_AUR"; then
                info "Package $package not found in repos, trying alternative: $PACKAGE_AUR"
                sudo pacman -S --noconfirm "$PACKAGE_AUR"
            elif command -v yay >/dev/null 2>&1; then
                # Try AUR with yay
                if is_available_in_aur "$package"; then
                    info "Installing $package from AUR..."
                    yay -S --noconfirm --needed "$package"
                elif [[ "$package" != "$PACKAGE_AUR" ]] && is_available_in_aur "$PACKAGE_AUR"; then
                    info "Package $package not found, trying AUR alternative: $PACKAGE_AUR"
                    yay -S --noconfirm --needed "$PACKAGE_AUR"
                else
                    error "Package $package not found in repos or AUR"
                    return 1
                fi
            else
                error "Package $package not found in official repos and yay is not available"
                warn "Consider installing yay for AUR support: https://github.com/Jguer/yay"
                return 1
            fi
            ;;
        *)
            error "Unsupported distribution: $distro"
            error "Please install $package manually"
            exit 1
            ;;
    esac
}

# Main execution
DISTRO=$(detect_distro)
info "Detected distribution: $DISTRO"

case "$DISTRO" in
    debian|ubuntu)
        install_package "$DISTRO" "$PACKAGE_DEBIAN"
        ;;
    fedora|centos|rhel)
        install_package "$DISTRO" "$PACKAGE_FEDORA"
        ;;
    arch|manjaro|endeavouros)
        install_package "$DISTRO" "$PACKAGE_ARCH"
        ;;
    *)
        error "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

success "Package installation completed!"
