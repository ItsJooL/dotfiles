#!/usr/bin/env zsh
# Pre-fetch all zinit plugins

ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
mkdir -p "$(dirname ${ZINIT_HOME})"
git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" 2>&1 || true
source "${ZINIT_HOME}/zinit.zsh"

# Load annexes
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Load all plugins synchronously (no wait)
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-completions
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::extract
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found
zinit light junegunn/fzf
zinit light Aloxaf/fzf-tab
zinit light junegunn/fzf-git.sh
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light hlissner/zsh-autopair
zinit light zdharma-continuum/null

echo "All plugins pre-downloaded successfully"
