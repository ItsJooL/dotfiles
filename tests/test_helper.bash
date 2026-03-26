#!/usr/bin/env bash

# Load bats helpers
load '/usr/local/lib/bats-support/load'
load '/usr/local/lib/bats-assert/load'

# Project root (parent of tests/)
DOTFILES_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
MIGRATIONS_DIR="$DOTFILES_ROOT/migrations"
UTILS_DIR="$DOTFILES_ROOT/utils"
CONFIG_DIR="$DOTFILES_ROOT/config"

# Create a temporary HOME for tests that do stow linking
setup_temp_home() {
    export ORIGINAL_HOME="$HOME"
    export HOME="$(mktemp -d)"
    mkdir -p "$HOME/.config"
}

teardown_temp_home() {
    if [[ -n "${ORIGINAL_HOME:-}" ]]; then
        rm -rf "$HOME"
        export HOME="$ORIGINAL_HOME"
        unset ORIGINAL_HOME
    fi
}
