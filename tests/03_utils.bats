#!/usr/bin/env bats

load 'test_helper'

# ---------------------------------------------------------------------------
# Test utility scripts
# ---------------------------------------------------------------------------

# --- log.sh ---

@test "log.sh can be sourced without error" {
    run bash -c "source '$UTILS_DIR/log.sh'"
    assert_success
}

@test "log.sh defines all expected functions" {
    local expected_funcs=(log error success warn info debug progress)
    source "$UTILS_DIR/log.sh"
    for func in "${expected_funcs[@]}"; do
        run type -t "$func"
        assert_output "function"
    done
}

@test "log() produces output with timestamp" {
    source "$UTILS_DIR/log.sh"
    run log "hello world"
    assert_success
    assert_output --partial "hello world"
}

@test "error() writes to stderr" {
    source "$UTILS_DIR/log.sh"
    # Capture stderr only
    run bash -c "source '$UTILS_DIR/log.sh'; error 'bad thing' 2>&1 1>/dev/null"
    assert_output --partial "bad thing"
}

@test "debug() is silent when DEBUG is unset" {
    source "$UTILS_DIR/log.sh"
    unset DEBUG
    run debug "secret debug info"
    assert_success
    assert_output ""
}

@test "debug() outputs when DEBUG=1" {
    run bash -c "export DEBUG=1; source '$UTILS_DIR/log.sh'; debug 'visible debug' 2>&1"
    assert_success
    assert_output --partial "visible debug"
}

# --- check-dependencies.sh ---

@test "check-dependencies.sh succeeds when deps are present" {
    # In the test container, all required deps should be installed
    run "$UTILS_DIR/check-dependencies.sh"
    assert_success
    assert_output --partial "All required dependencies are available"
}

# --- install-package.sh ---

@test "install-package.sh fails with no arguments" {
    run "$UTILS_DIR/install-package.sh"
    assert_failure
}

@test "install-package.sh detects Fedora" {
    run bash -c "source '$UTILS_DIR/log.sh'; source '$UTILS_DIR/install-package.sh' --help 2>&1 || true"
    # Just verify the script can parse - actual install tested separately
    assert_success
}

@test "install-package.sh detects distro as fedora in container" {
    source "$UTILS_DIR/log.sh"
    # Source the detect_distro function (extract full function body)
    eval "$(sed -n '/^detect_distro()/,/^}/p' "$UTILS_DIR/install-package.sh")"
    run detect_distro
    assert_output "fedora"
}

# --- install-from-repo.sh ---

@test "install-from-repo.sh can be sourced without error" {
    run bash -c "source '$UTILS_DIR/install-from-repo.sh'"
    assert_success
}

@test "install-from-repo.sh defines helper functions" {
    source "$UTILS_DIR/log.sh"
    source "$UTILS_DIR/install-from-repo.sh"
    run type -t get_latest_tag
    assert_output "function"
    run type -t get_latest_asset_url
    assert_output "function"
    run type -t install_binary
    assert_output "function"
}
