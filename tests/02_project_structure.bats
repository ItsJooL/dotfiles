#!/usr/bin/env bats

load 'test_helper'

# ---------------------------------------------------------------------------
# Verify expected project structure and files exist
# ---------------------------------------------------------------------------

@test "install.sh exists and is executable-capable" {
    [ -f "$DOTFILES_ROOT/install.sh" ]
}

@test "migrations directory exists" {
    [ -d "$MIGRATIONS_DIR" ]
}

@test "utils directory exists" {
    [ -d "$UTILS_DIR" ]
}

@test "config directory exists" {
    [ -d "$CONFIG_DIR" ]
}

@test "migrations are numbered sequentially without large gaps" {
    local prev=0
    for script in "$MIGRATIONS_DIR"/*.sh; do
        local name
        name=$(basename "$script" .sh)
        local num
        num=$(echo "$name" | grep -oE '^[0-9]+')
        # gap should be <= 10 (allows some skipped numbers for removed migrations)
        local gap=$(( 10#$num - prev ))
        [ "$gap" -le 10 ]
        prev=$((10#$num))
    done
}

@test "every config directory has content" {
    for dir in "$CONFIG_DIR"/*/; do
        local count
        count=$(find "$dir" -mindepth 1 -maxdepth 3 | head -1)
        [ -n "$count" ]
    done
}

# Ensure key stow config directories exist under config/
@test "expected stow config directories exist" {
    local expected_dirs=(bat git zsh nvim tmux kitty zellij mise rofi waybar swaync hypr)
    for dir in "${expected_dirs[@]}"; do
        [ -d "$CONFIG_DIR/$dir" ]
    done
}
