#!/usr/bin/env bats

load 'test_helper'

# ---------------------------------------------------------------------------
# Test migration scripts for safety & robustness patterns
# ---------------------------------------------------------------------------

@test "no migration uses rm -rf on HOME or root paths" {
    for script in "$MIGRATIONS_DIR"/*.sh; do
        # Should not have dangerous rm -rf on critical paths
        run bash -c "grep -nE 'rm\s+-rf\s+(/|~|\\\$HOME\b[^/])' '$script'"
        assert_failure  # grep should find nothing (exit 1)
    done
}

@test "no migration pipes curl directly to sudo" {
    for script in "$MIGRATIONS_DIR"/*.sh; do
        run bash -c "grep -nE 'curl.*\|\s*sudo' '$script'"
        assert_failure
    done
}

@test "migrations use stow_config wrapper instead of bare stow" {
    for script in "$MIGRATIONS_DIR"/*.sh; do
        if grep -qE '^\s*stow_config\s' "$script"; then
            # Should use stow_config, not bare stow
            run bash -c "grep -E '^\s*stow\s+-v' '$script'"
            assert_failure
        fi
    done
}

@test "all migrations source log.sh" {
    for script in "$MIGRATIONS_DIR"/*.sh; do
        run grep -q 'source.*log.sh' "$script"
        assert_success
    done
}

@test "002-install-yay.sh skips on non-Arch systems" {
    # On Fedora, yay install should be skipped
    if [ ! -f /etc/arch-release ]; then
        run grep -q 'arch-release\|Arch' "$MIGRATIONS_DIR/002-install-yay.sh"
        assert_success
    fi
}

@test "010-install-hyprland.sh has Fedora-specific COPR logic" {
    run grep -q 'copr\|dnf' "$MIGRATIONS_DIR/010-install-hyprland.sh"
    assert_success
}

@test "005-install-tmux.sh clones TPM" {
    run grep -q 'tmux-plugins/tpm' "$MIGRATIONS_DIR/005-install-tmux.sh"
    assert_success
}

@test "013-configure-git.sh uses stow without sed" {
    run grep -q 'stow' "$MIGRATIONS_DIR/013-configure-git.sh"
    assert_success
    # Should no longer need sed substitution
    run grep -q 'sed.*__HOME__' "$MIGRATIONS_DIR/013-configure-git.sh"
    assert_failure
}

@test "018-install-mise.sh installs via mise.run" {
    run grep -q 'mise.run' "$MIGRATIONS_DIR/018-install-mise.sh"
    assert_success
}

@test "019-install-zellij.sh depends on mise being available" {
    run grep -q 'mise' "$MIGRATIONS_DIR/019-install-zellij.sh"
    assert_success
}

@test "no migration contains hardcoded usernames in paths" {
    for script in "$MIGRATIONS_DIR"/*.sh; do
        # Should use $HOME or ~ instead of /home/specific-user
        run bash -c "grep -nE '/home/[a-z][a-z0-9_-]+/' '$script'"
        assert_failure
    done
}

@test "no migration uses deprecated backtick command substitution" {
    for script in "$MIGRATIONS_DIR"/*.sh; do
        # Allow backticks inside comments and strings but flag bare usage
        run bash -c "grep -nP '(?<!#.*)\x60[^\x60]+\x60' '$script' | grep -v '^[[:space:]]*#'"
        assert_failure
    done
}
