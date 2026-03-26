#!/usr/bin/env bats

load 'test_helper'

# ---------------------------------------------------------------------------
# Validate configuration file content and correctness
# ---------------------------------------------------------------------------

# --- Git ---

@test "git config has user.name set" {
    run grep -q 'name =' "$CONFIG_DIR/git/.gitconfig"
    assert_success
}

@test "git config has user.email set" {
    run grep -q 'email =' "$CONFIG_DIR/git/.gitconfig"
    assert_success
}

@test "git config sets defaultBranch to main" {
    run grep -q 'defaultBranch = main' "$CONFIG_DIR/git/.gitconfig"
    assert_success
}

@test "git config uses nvim as editor" {
    run grep -q 'editor = nvim' "$CONFIG_DIR/git/.gitconfig"
    assert_success
}

@test "git config conditional includes use ~ for home directory" {
    run grep -c 'includeIf' "$CONFIG_DIR/git/.gitconfig"
    assert_success
    # No includeIf should use hardcoded absolute paths
    run bash -c "grep 'includeIf' '$CONFIG_DIR/git/.gitconfig' | grep -vE '~/|__HOME__' | wc -l"
    assert_output "0"
}

# --- Zsh ---

@test "zshrc exists and is non-empty" {
    [ -s "$CONFIG_DIR/zsh/.zshrc" ]
}

@test "zshrc bootstraps antidote (not zinit)" {
    run grep -q 'antidote.zsh' "$CONFIG_DIR/zsh/.zshrc"
    assert_success
}

@test "zshrc does not source zinit" {
    run grep -q 'zinit.zsh' "$CONFIG_DIR/zsh/.zshrc"
    assert_failure
}

@test "zsh_plugins.txt exists" {
    [ -f "$CONFIG_DIR/zsh/.zsh_plugins.txt" ]
}

@test "zsh_plugins.txt loads fzf-tab before fast-syntax-highlighting" {
    local fzf_tab_line fsh_line
    fzf_tab_line=$(grep -n '^Aloxaf/fzf-tab' "$CONFIG_DIR/zsh/.zsh_plugins.txt" | head -1 | cut -d: -f1)
    fsh_line=$(grep -n '^zdharma-continuum/fast-syntax-highlighting' "$CONFIG_DIR/zsh/.zsh_plugins.txt" | head -1 | cut -d: -f1)
    [ "$fzf_tab_line" -lt "$fsh_line" ]
}

@test "zshrc activates mise" {
    run grep -q 'mise activate' "$CONFIG_DIR/zsh/.zshrc"
    assert_success
}

@test "zshrc sets up Oh My Posh" {
    run grep -q 'oh-my-posh' "$CONFIG_DIR/zsh/.zshrc"
    assert_success
}

@test "zshrc does not load unused zinit annexes" {
    run grep -c 'zinit-annex' "$CONFIG_DIR/zsh/.zshrc"
    assert_output "0"
}

@test "zshrc has no lucid ice modifiers" {
    run grep -c "lucid" "$CONFIG_DIR/zsh/.zshrc"
    assert_output "0"
}

@test "zsh_plugins.txt contains fzf-tab plugin" {
    run grep -q '^Aloxaf/fzf-tab' "$CONFIG_DIR/zsh/.zsh_plugins.txt"
    assert_success
}

@test "zsh_plugins.txt defers fzf-tab with kind:defer" {
    run bash -c "grep '^Aloxaf/fzf-tab' '$CONFIG_DIR/zsh/.zsh_plugins.txt' | grep -q 'kind:defer'"
    assert_success
}

@test "zsh_plugins.txt defers zsh-completions with kind:defer" {
    run bash -c "grep '^zsh-users/zsh-completions' '$CONFIG_DIR/zsh/.zsh_plugins.txt' | grep -q 'kind:defer'"
    assert_success
}

@test "zshrc does not contain _register_completions (dead code)" {
    run grep -q '_register_completions' "$CONFIG_DIR/zsh/.zshrc"
    assert_failure
}

@test "zshrc does not contain _init_completions_once (dead code)" {
    run grep -q '_init_completions_once' "$CONFIG_DIR/zsh/.zshrc"
    assert_failure
}

@test "zshrc does not define a custom _zoxide_cd_completion (overwritten by zoxide)" {
    run grep -q '_zoxide_cd_completion' "$CONFIG_DIR/zsh/.zshrc"
    assert_failure
}

@test "zshrc does not define a kubectl lazy-load wrapper (conflicts with carapace)" {
    run bash -c "grep -A3 'command -v kubectl' '$CONFIG_DIR/zsh/.zshrc' | grep -q 'unfunction kubectl'"
    assert_failure
}

@test "CARAPACE_BRIDGES does not include invalid 'fzf' value" {
    run bash -c "grep 'CARAPACE_BRIDGES' '$CONFIG_DIR/zsh/.zshrc' | grep -q ',fzf'"
    assert_failure
}

@test "zshrc does not set FZF_CTRL_R_OPTS (dead with mcfly-fzf owning Ctrl+R)" {
    run grep -q 'FZF_CTRL_R_OPTS' "$CONFIG_DIR/zsh/.zshrc"
    assert_failure
}

@test "zshrc does not have redundant bindkey for Ctrl+R (overwritten by mcfly)" {
    run bash -c "grep 'bindkey.*\\^r.*history-incremental-search-backward' '$CONFIG_DIR/zsh/.zshrc'"
    assert_failure
}

@test "zshrc does not have __zoxide_z fzf-tab zstyle (dead with --cmd cd)" {
    run grep -q '__zoxide_z' "$CONFIG_DIR/zsh/.zshrc"
    assert_failure
}

@test "zshrc does not load colored-man-pages (dead with MANPAGER=nvim)" {
    run grep -q 'colored-man-pages' "$CONFIG_DIR/zsh/.zshrc"
    assert_failure
}

@test "zshrc does not use zdharma-continuum/null (replaced by precmd hooks)" {
    run grep -q 'zdharma-continuum/null' "$CONFIG_DIR/zsh/.zshrc"
    assert_failure
}

@test "zshrc carapace init uses precmd pattern" {
    run bash -c "grep -A5 'command -v carapace' '$CONFIG_DIR/zsh/.zshrc' | grep -q 'precmd_functions'"
    assert_success
}

@test "fzf initialised via eval fzf --zsh (not via zinit plugin)" {
    run grep -q 'eval "$(fzf --zsh)"' "$CONFIG_DIR/zsh/.zshrc"
    assert_success
}

@test "zshrc does not double-load fzf via zinit" {
    run bash -c "grep -c 'junegunn/fzf\"' '$CONFIG_DIR/zsh/.zshrc'"
    assert_output "0"
}

# --- Bat ---

@test "bat config exists" {
    [ -f "$CONFIG_DIR/bat/config" ]
}

# --- Tmux ---

@test "tmux.conf exists" {
    [ -f "$CONFIG_DIR/tmux/tmux.conf" ]
}

@test "tmux.conf references TPM" {
    run grep -q 'tpm' "$CONFIG_DIR/tmux/tmux.conf"
    assert_success
}

# --- Kitty ---

@test "kitty.conf exists" {
    [ -f "$CONFIG_DIR/kitty/kitty.conf" ]
}

# --- Neovim ---

@test "neovim init.lua exists" {
    [ -f "$CONFIG_DIR/nvim/init.lua" ]
}

@test "neovim lazy-lock.json exists" {
    [ -f "$CONFIG_DIR/nvim/lazy-lock.json" ]
}

@test "neovim uses LazyVim" {
    run grep -rq 'lazyvim' "$CONFIG_DIR/nvim/"
    assert_success
}

# --- Zellij ---

@test "zellij config.kdl exists" {
    [ -f "$CONFIG_DIR/zellij/config.kdl" ]
}

@test "zellij has at least one layout" {
    local count
    count=$(find "$CONFIG_DIR/zellij/layouts" -name "*.kdl" 2>/dev/null | wc -l)
    [ "$count" -gt 0 ]
}

@test "zellij has at least one theme" {
    local count
    count=$(find "$CONFIG_DIR/zellij/themes" -name "*.kdl" 2>/dev/null | wc -l)
    [ "$count" -gt 0 ]
}

# --- Mise / config.toml ---

@test "mise config.toml exists" {
    [ -f "$CONFIG_DIR/mise/.config/mise/config.toml" ]
}

@test "mise config defines node version" {
    run grep -q '^node' "$CONFIG_DIR/mise/.config/mise/config.toml"
    assert_success
}

@test "mise config defines golang version" {
    run grep -q '^golang' "$CONFIG_DIR/mise/.config/mise/config.toml"
    assert_success
}

@test "mise config defines java version" {
    run grep -q '^java' "$CONFIG_DIR/mise/.config/mise/config.toml"
    assert_success
}

@test "mise config includes shell utilities (ripgrep, fd, fzf, eza)" {
    for tool in ripgrep fd eza fzf; do
        run grep -qi "$tool" "$CONFIG_DIR/mise/.config/mise/config.toml"
        assert_success
    done
}

@test "mise config includes devops tools (gh, kubectl, helm)" {
    for tool in gh kubectl helm; do
        run grep -q "^$tool" "$CONFIG_DIR/mise/.config/mise/config.toml"
        assert_success
    done
}

# --- Hyprland ---

@test "hyprland.conf exists" {
    [ -f "$CONFIG_DIR/hypr/hyprland.conf" ]
}

@test "hyprland config uses modular imports" {
    run grep -q 'source' "$CONFIG_DIR/hypr/hyprland.conf"
    assert_success
}

# --- Waybar ---

@test "waybar config exists" {
    run bash -c "ls '$CONFIG_DIR/waybar/'*.jsonc 2>/dev/null | wc -l"
    [ "$(ls "$CONFIG_DIR/waybar/"*.jsonc 2>/dev/null | wc -l)" -gt 0 ]
}

# --- Oh My Posh ---

@test "oh-my-posh theme config exists" {
    run find "$CONFIG_DIR/prompt" -name "*.toml" -o -name "*.json" -o -name "*.yaml"
    assert_success
    [ -n "$output" ]
}

@test "oh-my-posh config has shell_integration enabled" {
    local omp_config
    omp_config=$(find "$CONFIG_DIR" -name "omp.toml" | head -1)
    run grep -q 'shell_integration = true' "$omp_config"
    assert_success
}

@test "zshrc loads mise completion" {
    run bash -c "grep 'mise completion' '$CONFIG_DIR/zsh/.zshrc'"
    assert_success
}
