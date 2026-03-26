#!/usr/bin/env bats

load 'test_helper'

# ---------------------------------------------------------------------------
# Test that stow can successfully link each config directory
# These tests use a temporary HOME to avoid touching real configs
# ---------------------------------------------------------------------------

setup() {
    setup_temp_home
}

teardown() {
    teardown_temp_home
}

@test "stow links bat config to ~/.config/bat" {
    mkdir -p "$HOME/.config/bat"
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME/.config/bat" bat
    assert_success
    [ -L "$HOME/.config/bat/config" ]
}

@test "stow links git config to ~/" {
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME" git
    assert_success
    [ -L "$HOME/.gitconfig" ]
}

@test "stow links zsh config to ~/" {
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME" zsh
    assert_success
    [ -L "$HOME/.zshrc" ]
}

@test "stow links nvim config to ~/.config/nvim" {
    mkdir -p "$HOME/.config/nvim"
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME/.config/nvim" nvim
    assert_success
    [ -L "$HOME/.config/nvim/init.lua" ]
}

@test "stow links tmux config to ~/.config/tmux" {
    mkdir -p "$HOME/.config/tmux"
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME/.config/tmux" tmux
    assert_success
    [ -L "$HOME/.config/tmux/tmux.conf" ]
}

@test "stow links kitty config to ~/.config/kitty" {
    mkdir -p "$HOME/.config/kitty"
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME/.config/kitty" kitty
    assert_success
    [ -L "$HOME/.config/kitty/kitty.conf" ]
}

@test "stow links zellij config to ~/.config/zellij" {
    mkdir -p "$HOME/.config/zellij"
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME/.config/zellij" zellij
    assert_success
    [ -L "$HOME/.config/zellij/config.kdl" ]
}

@test "stow links mise config.toml to ~/.config/mise/" {
    mkdir -p "$HOME/.config/mise"
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME" mise
    assert_success
    [ -L "$HOME/.config/mise/config.toml" ]
}

@test "stow links rofi config to ~/.config/rofi" {
    mkdir -p "$HOME/.config/rofi"
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME/.config/rofi" rofi
    assert_success
}

@test "stow links waybar config to ~/.config/waybar" {
    mkdir -p "$HOME/.config/waybar"
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME/.config/waybar" waybar
    assert_success
}

@test "stow links swaync config to ~/.config/swaync" {
    mkdir -p "$HOME/.config/swaync"
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME/.config/swaync" swaync
    assert_success
}

@test "stow links hyprland config to ~/.config/hypr" {
    mkdir -p "$HOME/.config/hypr"
    run stow -v -R -d "$CONFIG_DIR" -t "$HOME/.config/hypr" hypr
    assert_success
}

@test "stow-linked .gitconfig uses ~ for home paths (no placeholders)" {
    stow -v -R -d "$CONFIG_DIR" -t "$HOME" git
    # Should use ~ not __HOME__ placeholders
    run grep -c '__HOME__' "$HOME/.gitconfig"
    assert_failure  # grep returns 1 = no matches, good
    run grep -c '~/\.' "$HOME/.gitconfig"
    assert_success
}
