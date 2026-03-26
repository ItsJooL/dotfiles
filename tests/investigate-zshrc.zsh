#!/usr/bin/env zsh
# Investigation script - sources .zshrc and reports results

echo "=== ZSH VERSION ==="
zsh --version

echo ""
echo "=== CHECKING HOME ==="
echo "HOME=$HOME"
echo "USER=$USER"
ls -la ~/.zshrc 2>/dev/null && echo "~/.zshrc exists" || echo "~/.zshrc MISSING"

echo ""
echo "=== SOURCING .zshrc (capturing stderr) ==="
errors_file=$(mktemp)

# Use a subshell to source .zshrc and capture any errors
(
    # Set a non-interactive flag check workaround
    export TERM=xterm-256color
    source ~/.zshrc 2>"$errors_file"
    echo "EXIT_CODE: $?"
    echo ""
    echo "=== BINDKEY OUTPUT AFTER FULL LOAD ==="
    bindkey 2>/dev/null || echo "bindkey not available"
    echo ""
    echo "=== AVAILABLE COMMANDS CHECK ==="
    for cmd in zoxide mcfly fzf carapace mise oh-my-posh kubectl eza bat fd rg zellij; do
        if command -v "$cmd" &>/dev/null; then
            echo "FOUND: $cmd -> $(command -v $cmd)"
        else
            echo "MISSING: $cmd"
        fi
    done
    echo ""
    echo "=== ZINIT STATUS ==="
    if command -v zinit &>/dev/null; then
        echo "zinit is available"
        zinit list 2>/dev/null | head -40 || echo "(zinit list failed)"
    else
        echo "zinit NOT available"
    fi
    echo ""
    echo "=== precmd_functions ==="
    print -l "${precmd_functions[@]}" 2>/dev/null || echo "(none)"
    echo ""
    echo "=== ACTIVE WIDGETS (zle -l) ==="
    zle -l 2>/dev/null | head -50 || echo "(zle not available)"
)

echo ""
echo "=== STDERR CAPTURED DURING .zshrc SOURCING ==="
if [[ -s "$errors_file" ]]; then
    cat "$errors_file"
else
    echo "(no stderr output)"
fi
rm -f "$errors_file"
