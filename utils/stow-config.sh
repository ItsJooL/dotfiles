#!/bin/bash

# Wrapper around stow that respects DOTFILES_FORCE.
# When DOTFILES_FORCE=1, uses --adopt to take ownership of existing files.
#
# Usage: source this file, then call stow_config with the same args you'd pass to stow.
#   stow_config -d "$SCRIPT_DIR/../config" -t "$HOME/.config/tmux" tmux

stow_config() {
    if [[ "${DOTFILES_FORCE:-0}" == "1" ]]; then
        local target_dir=""
        local prev=""
        for a in "$@"; do
            if [[ "$prev" == "-t" ]]; then target_dir="$a"; break; fi
            prev="$a"
        done

        # Dry-run to find conflicts, extract filenames from all conflict message formats
        local conflicts
        conflicts=$(stow -v -R --no "$@" 2>&1 | grep '^\s*\*' | \
            sed -n 's/.*existing target \(is not owned by stow: \)\(.*\)/\2/p; s/.*over existing target \(.*\) since.*/\1/p' || true)
        if [[ -n "$conflicts" ]]; then
            while IFS= read -r file; do
                [[ -z "$file" ]] && continue
                rm -rf "$target_dir/$file"
            done <<< "$conflicts"
        fi
    fi
    stow -v -R "$@"
}
