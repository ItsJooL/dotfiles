#!/usr/bin/env bats

load 'test_helper'

# ---------------------------------------------------------------------------
# Fedora-specific compatibility tests
# These tests only run inside the Fedora container
# ---------------------------------------------------------------------------

setup() {
    if [ ! -f /etc/fedora-release ]; then
        skip "Not running on Fedora"
    fi
}

@test "detected distro is fedora" {
    source "$UTILS_DIR/log.sh"
    eval "$(sed -n '/^detect_distro()/,/^}/p' "$UTILS_DIR/install-package.sh")"
    run detect_distro
    assert_output "fedora"
}

@test "all required binaries are installed" {
    local bins=(dnf stow git curl sha256sum tar unzip find gzip rsync)
    local missing=()
    for bin in "${bins[@]}"; do
        if ! command -v "$bin" >/dev/null 2>&1; then
            missing+=("$bin")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing binaries: ${missing[*]}" >&2
        return 1
    fi
}

@test "install-package.sh can install a real package on Fedora" {
    # Install a tiny, harmless package to verify the install path works
    if rpm -q tree >/dev/null 2>&1; then
        skip "tree already installed"
    fi
    run "$UTILS_DIR/install-package.sh" tree
    assert_success
    command -v tree
}

@test "install-package.sh reports already-installed packages correctly" {
    # git should already be installed in the container
    run "$UTILS_DIR/install-package.sh" git
    assert_success
    assert_output --partial "already installed"
}

@test "check-dependencies.sh passes on Fedora container" {
    run "$UTILS_DIR/check-dependencies.sh"
    assert_success
}
