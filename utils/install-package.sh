#!/bin/bash

# Cross-platform package installer
# Usage: ./install-package.sh <package_name> [<package_name_fedora>] [<package_name_arch>]
# If only one package name is provided, it will be used for all distributions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/log.sh"

if [[ $# -lt 1 ]]; then
    error "Usage: $0 <package_name> [<package_name_fedora>] [<package_name_arch>]"
    info "Examples:"
    info "  $0 git"
    info "  $0 build-essential gcc gcc"
    info "  $0 python3-pip python3-pip python-pip"
    exit 1
fi

PACKAGE_DEBIAN="$1"
PACKAGE_FEDORA="${2:-$1}"
PACKAGE_ARCH="${3:-$1}"

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
            if command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y "$package"
            else
                sudo yum install -y "$package"
            fi
            ;;
        arch|manjaro)
            if is_installed_arch "$package"; then
                info "Package $package is already installed (Arch)"
                return 0
            fi
            info "Installing $package on Arch Linux..."
            sudo pacman -S --noconfirm "$package"
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
    arch|manjaro)
        install_package "$DISTRO" "$PACKAGE_ARCH"
        ;;
    *)
        error "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

success "Package installation completed!"
