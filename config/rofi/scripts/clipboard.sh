#!/usr/bin/env bash
set -euo pipefail

format_label() {
    local entry="$1"
    local preview="$entry"
    local collapsed

    if [[ "$entry" == *$'\t'* ]]; then
        preview="${entry#*$'\t'}"
    fi

    collapsed="$(printf '%s' "$preview" | tr '\t' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')"

    if [[ -z "$collapsed" ]]; then
        printf 'TXT  (empty clipboard entry)'
        return
    fi

    if [[ "$collapsed" =~ ^\[\[\ binary\ data\ (.+)\ ([[:alnum:].+-]+)\ ([0-9]+x[0-9]+)\ \]\]$ ]]; then
        printf 'IMG  %s  %s  %s' "${BASH_REMATCH[2]^^}" "${BASH_REMATCH[1]}" "${BASH_REMATCH[3]}"
        return
    fi

    if [[ "$collapsed" =~ ^\[\[\ binary\ data\ (.+)\ ([[:alnum:].+-]+)\ \]\]$ ]]; then
        printf 'BIN  %s  %s' "${BASH_REMATCH[2]^^}" "${BASH_REMATCH[1]}"
        return
    fi

    if ((${#collapsed} > 110)); then
        collapsed="${collapsed:0:107}..."
    fi

    printf 'TXT  %s' "$collapsed"
}

selection="$(
    cliphist list | while IFS= read -r entry; do
        label="$(format_label "$entry")"
        printf '%s\0display\x1f%s\x1fmeta\x1f%s\n' "$entry" "$label" "$label"
    done | rofi -dmenu -i -markup-rows -theme "${HOME}/.config/rofi/clipboard.rasi"
)"

[[ -n "$selection" ]] || exit 0

printf '%s' "$selection" | cliphist decode | wl-copy
