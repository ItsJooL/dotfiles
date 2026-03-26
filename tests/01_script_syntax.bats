#!/usr/bin/env bats

load 'test_helper'

# ---------------------------------------------------------------------------
# Verify all shell scripts have valid syntax (bash -n)
# ---------------------------------------------------------------------------

@test "install.sh has valid bash syntax" {
    bash -n "$DOTFILES_ROOT/install.sh"
}

@test "utils/log.sh has valid bash syntax" {
    bash -n "$UTILS_DIR/log.sh"
}

@test "utils/check-dependencies.sh has valid bash syntax" {
    bash -n "$UTILS_DIR/check-dependencies.sh"
}

@test "utils/install-package.sh has valid bash syntax" {
    bash -n "$UTILS_DIR/install-package.sh"
}

@test "utils/install-from-repo.sh has valid bash syntax" {
    bash -n "$UTILS_DIR/install-from-repo.sh"
}

@test "all migration scripts have valid bash syntax" {
    for script in "$MIGRATIONS_DIR"/*.sh; do
        run bash -n "$script"
        assert_success
    done
}

@test "all scripts have a shebang line" {
    local scripts=("$DOTFILES_ROOT/install.sh" "$UTILS_DIR"/*.sh "$MIGRATIONS_DIR"/*.sh)
    for script in "${scripts[@]}"; do
        local first_line
        first_line=$(head -1 "$script")
        assert_regex "$first_line" '^#!'
    done
}

@test "all scripts use 'set -e' for error handling" {
    for script in "$MIGRATIONS_DIR"/*.sh; do
        run grep -q 'set -e' "$script"
        assert_success
    done
}
