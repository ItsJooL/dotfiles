#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$HOME/.dotfiles-migration-state"
MIGRATIONS_DIR="$SCRIPT_DIR/migrations"
UTILS_DIR="$SCRIPT_DIR/utils"

# Source logging utilities
source "$UTILS_DIR/log.sh"

# Check dependencies first
log "Checking dependencies..."
if ! "$UTILS_DIR/check-dependencies.sh"; then
    error "Dependency check failed. Please install missing dependencies."
    exit 1
fi

# Create state directory if it doesn't exist
mkdir -p "$STATE_DIR"

# Function to calculate checksum of a migration script
calculate_checksum() {
    local script="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$script" | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$script" | cut -d' ' -f1
    else
        error "No checksum utility found (sha256sum or shasum)"
        exit 1
    fi
}

# Function to get the state file path for a migration
get_state_file() {
    local migration_name="$1"
    echo "$STATE_DIR/${migration_name}.state"
}

# Function to check if migration needs to run
needs_migration() {
    local script="$1"
    local migration_name=$(basename "$script" .sh)
    local state_file=$(get_state_file "$migration_name")
    local current_checksum=$(calculate_checksum "$script")
    if [[ ! -f "$state_file" ]]; then
        return 0  # Never run before
    fi

    local stored_checksum=$(cat "$state_file" 2>/dev/null || echo "")
    if [[ "$current_checksum" != "$stored_checksum" ]]; then
        return 0  # Script changed
    fi

    return 1  # No need to run
}

# Function to mark migration as completed
mark_completed() {
    local script="$1"
    local migration_name=$(basename "$script" .sh)
    local state_file=$(get_state_file "$migration_name")
    local checksum=$(calculate_checksum "$script")

    echo "$checksum" > "$state_file"
    success "Marked $migration_name as completed"
}

# Function to run a migration
run_migration() {
    local script="$1"
    local migration_name=$(basename "$script" .sh)

    log "Running migration: $migration_name"

    # Make script executable
    chmod +x "$script"

    # Run the migration
    if "$script"; then
        mark_completed "$script"
        success "Migration $migration_name completed successfully"
    else
        error "Migration $migration_name failed"
        exit 1
    fi
}

# Main execution
log "Starting dotfiles installation..."

# Check if migrations directory exists
if [[ ! -d "$MIGRATIONS_DIR" ]]; then
    error "Migrations directory not found: $MIGRATIONS_DIR"
    exit 1
fi

# Find and sort migration scripts
migration_scripts=()
while IFS= read -r -d '' script; do
    migration_scripts+=("$script")
done < <(find "$MIGRATIONS_DIR" -name "*.sh" -type f -print0 | sort -z)

if [[ ${#migration_scripts[@]} -eq 0 ]]; then
    warn "No migration scripts found in $MIGRATIONS_DIR"
    exit 0
fi

log "Found ${#migration_scripts[@]} migration script(s)"

# Process each migration
total_migrations=${#migration_scripts[@]}
current_migration=0
for script in "${migration_scripts[@]}"; do
    migration_name=$(basename "$script" .sh)
    current_migration=$((current_migration + 1))
    if needs_migration "$script"; then
        progress "$current_migration" "$total_migrations" "Running: $migration_name"
        run_migration "$script"
    else
        progress "$current_migration" "$total_migrations" "Skipping: $migration_name (up to date)"
        log "Skipping $migration_name (already up to date)"
    fi
done

echo  # Ensure we end with a newline after progress bars

success "All migrations completed successfully!"
log "Installation finished. State tracked in: $STATE_DIR"
