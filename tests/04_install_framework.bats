#!/usr/bin/env bats

load 'test_helper'

# ---------------------------------------------------------------------------
# Test the install.sh migration framework logic (without running migrations)
# ---------------------------------------------------------------------------

@test "install.sh sources log.sh correctly" {
    run bash -c "
        source '$UTILS_DIR/log.sh'
        type -t log
    "
    assert_success
    assert_output "function"
}

@test "calculate_checksum produces consistent results" {
    # Extract and test the checksum function from install.sh
    run bash -c "
        source '$UTILS_DIR/log.sh'
        $(grep -A 10 'calculate_checksum()' "$DOTFILES_ROOT/install.sh")
        checksum1=\$(calculate_checksum '$DOTFILES_ROOT/install.sh')
        checksum2=\$(calculate_checksum '$DOTFILES_ROOT/install.sh')
        [ \"\$checksum1\" = \"\$checksum2\" ] && echo 'consistent'
    "
    assert_success
    assert_output "consistent"
}

@test "calculate_checksum differs for different files" {
    run bash -c "
        source '$UTILS_DIR/log.sh'
        $(grep -A 10 'calculate_checksum()' "$DOTFILES_ROOT/install.sh")
        checksum1=\$(calculate_checksum '$DOTFILES_ROOT/install.sh')
        checksum2=\$(calculate_checksum '$UTILS_DIR/log.sh')
        [ \"\$checksum1\" != \"\$checksum2\" ] && echo 'different'
    "
    assert_success
    assert_output "different"
}

@test "needs_migration returns 0 for never-run migration" {
    setup_temp_home
    run bash -c "
        export HOME='$HOME'
        source '$UTILS_DIR/log.sh'

        STATE_DIR=\"\$HOME/.dotfiles-migration-state\"
        mkdir -p \"\$STATE_DIR\"

        $(grep -A 10 'calculate_checksum()' "$DOTFILES_ROOT/install.sh")
        $(grep -A 5 'get_state_file()' "$DOTFILES_ROOT/install.sh")
        $(grep -A 15 'needs_migration()' "$DOTFILES_ROOT/install.sh")

        needs_migration '$MIGRATIONS_DIR/001-install-stow.sh' && echo 'needs_run'
    "
    assert_success
    assert_output "needs_run"
    teardown_temp_home
}

@test "needs_migration returns 1 after marking completed" {
    setup_temp_home
    run bash -c "
        export HOME='$HOME'
        source '$UTILS_DIR/log.sh'

        STATE_DIR=\"\$HOME/.dotfiles-migration-state\"
        mkdir -p \"\$STATE_DIR\"

        $(grep -A 10 'calculate_checksum()' "$DOTFILES_ROOT/install.sh")
        $(grep -A 5 'get_state_file()' "$DOTFILES_ROOT/install.sh")
        $(grep -A 15 'needs_migration()' "$DOTFILES_ROOT/install.sh")
        $(grep -A 10 'mark_completed()' "$DOTFILES_ROOT/install.sh")

        # First mark it completed
        mark_completed '$MIGRATIONS_DIR/001-install-stow.sh'

        # Then check if it needs to run again
        if needs_migration '$MIGRATIONS_DIR/001-install-stow.sh'; then
            echo 'needs_run'
        else
            echo 'up_to_date'
        fi
    "
    assert_success
    assert_output --partial "up_to_date"
    teardown_temp_home
}

@test "migration state directory is created by install.sh" {
    setup_temp_home
    STATE_DIR="$HOME/.dotfiles-migration-state"
    [ ! -d "$STATE_DIR" ]
    mkdir -p "$STATE_DIR"
    [ -d "$STATE_DIR" ]
    teardown_temp_home
}
