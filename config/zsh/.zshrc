#!/usr/bin/env zsh
# =============================================================================
# THEME COLORS - CATPPUCCIN MOCHA
# =============================================================================
CATPPUCCIN_MOCHA_ROSEWATER="#f5e0dc"
CATPPUCCIN_MOCHA_FLAMINGO="#f2cdcd"
CATPPUCCIN_MOCHA_PINK="#f5c2e7"
CATPPUCCIN_MOCHA_MAUVE="#cba6f7"
CATPPUCCIN_MOCHA_RED="#f38ba8"
CATPPUCCIN_MOCHA_MAROON="#eba0ac"
CATPPUCCIN_MOCHA_PEACH="#fab387"
CATPPUCCIN_MOCHA_YELLOW="#f9e2af"
CATPPUCCIN_MOCHA_GREEN="#a6e3a1"
CATPPUCCIN_MOCHA_TEAL="#94e2d5"
CATPPUCCIN_MOCHA_SKY="#89dceb"
CATPPUCCIN_MOCHA_SAPPHIRE="#74c7ec"
CATPPUCCIN_MOCHA_BLUE="#89b4fa"
CATPPUCCIN_MOCHA_LAVENDER="#b4befe"
CATPPUCCIN_MOCHA_TEXT="#cdd6f4"
CATPPUCCIN_MOCHA_SUBTEXT1="#bac2de"
CATPPUCCIN_MOCHA_SUBTEXT0="#a6adc8"
CATPPUCCIN_MOCHA_OVERLAY2="#9399b2"
CATPPUCCIN_MOCHA_OVERLAY1="#7f849c"
CATPPUCCIN_MOCHA_OVERLAY0="#6c7086"
CATPPUCCIN_MOCHA_SURFACE2="#585b70"
CATPPUCCIN_MOCHA_SURFACE1="#45475a"
CATPPUCCIN_MOCHA_SURFACE0="#313244"
CATPPUCCIN_MOCHA_BASE="#1e1e2e"
CATPPUCCIN_MOCHA_MANTLE="#181825"
CATPPUCCIN_MOCHA_CRUST="#11111b"

# =============================================================================
# SHELL ENVIRONMENT
# =============================================================================
export EDITOR=$(command -v nvim &>/dev/null && echo nvim || (command -v vim &>/dev/null && echo vim || echo vi))
export SUDO_EDITOR="$EDITOR"
export TERMINAL='kitty'
export PAGER='less'
export LESS='-F -g -i -M -R -S -w -X -z-4 -~ --mouse'
export LESS_TERMCAP_mb=$'\E[6m'     # begin blinking
export LESS_TERMCAP_md=$'\E[34m'    # begin bold
export LESS_TERMCAP_us=$'\E[4;32m'  # begin underline
export LESS_TERMCAP_so=$'\E[0m'     # begin standout-mode, remove background
export LESS_TERMCAP_me=$'\E[0m'     # end mode
export LESS_TERMCAP_ue=$'\E[0m'     # end underline
export LESS_TERMCAP_se=$'\E[0m'     # end standout-mode
export MANPAGER='nvim +Man!'
export WORDCHARS='~!#$%^&*(){}[]<>?.+;'
export PROMPT_EOL_MARK=''
export GPG_TTY=$(tty)

# =============================================================================
# HISTORY SETTINGS
# =============================================================================
HISTSIZE=290000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt extended_history \
    hist_expire_dups_first \
    hist_ignore_all_dups \
    hist_ignore_space \
    hist_verify \
    inc_append_history \
    share_history

# =============================================================================
# SHELL OPTIONS
# =============================================================================
setopt always_to_end \
    hash_list_all \
    completealiases \
    complete_in_word \
    nocorrect \
    list_ambiguous \
    nolisttypes \
    listpacked \
    automenu \
    interactivecomments \
    autocd

# =============================================================================
# PATH CONFIGURATION
# =============================================================================
# Function to update PATH with directories that exist
update_path() {
    for dir in "$@"; do
        [[ -d $dir ]] && export PATH=$dir:$PATH
    done
}
update_path ~/scripts ~/.local/bin /home/linuxbrew/.linuxbrew/bin

# =============================================================================
# ALIASES
# =============================================================================
alias ls='eza --color=always --long --git --icons=always'
alias ll='eza --color=always --long --git --icons=always'
alias la='eza --color=always --long --git --icons=always --all'
alias lt='eza --color=always --tree --git --icons=always'
alias cat='bat --style=auto'
alias grep='rg --color=auto'
alias ocat='/bin/cat'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================
# Fzf Background job management
function fg-fzf() {
  job="$(jobs | fzf -0 -1 | sed -E 's/\[(.+)\].*/\1/')" && echo '' && fg %$job
}

function fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER=" fg-fzf"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N fancy-ctrl-z

# Fzf Zoxide
_zoxide_fzf_widget() {
  local selected_dir
  selected_dir=$(zoxide query -l | fzf --preview 'eza --icons=always --tree --level=1 --color=always {}')
  if [[ -n "$selected_dir" ]]; then
    BUFFER="cd ${(q)selected_dir}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N _zoxide_fzf_widget

# Carapace setup
_setup_carapace() {
  [[ -n "$_CARAPACE_INIT_DONE" ]] && return
  autoload -Uz compinit && compinit -C
  zstyle ":completion:*" format "${CATPPUCCIN_MOCHA_YELLOW}%d${RESET_COLOR}"
  source <(carapace _carapace)
  export _CARAPACE_INIT_DONE=1
}

_carapace_tmux_fix() {
  if [[ -n "$TMUX" ]] && [[ -z "$_CARAPACE_TMUX_INIT_DONE" ]]; then
    _setup_carapace
    export _CARAPACE_TMUX_INIT_DONE=1
  fi
}

# =============================================================================
# KEYBINDINGS
# =============================================================================
bindkey -e  # Emacs keybindings

# Basic movement
bindkey "^[[D" backward-char
bindkey "^[[C" forward-char
bindkey "^[[A" up-line-or-history
bindkey "^[[B" down-line-or-history

# Word movement
bindkey "^[[1;3C" forward-word         # alt+right
bindkey "^[[1;3D" backward-word        # alt+left
bindkey "^[[1;5C" forward-word         # ctrl+right
bindkey "^[[1;5D" backward-word        # ctrl+left

# Enhanced word movement (vim-like)
bindkey '\eb' backward-word            # alt+b
bindkey '\ef' forward-word             # alt+f
bindkey '\ee' end-of-line              # alt+e
bindkey '\ea' beginning-of-line        # alt+a

# History navigation
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey "^[[1;5A" up-line-or-history    # ctrl+up
bindkey "^[[1;5B" down-line-or-history  # ctrl+down
bindkey "^r" history-incremental-search-backward # ctrl+r

# Word deletion
bindkey '^[^?' backward-kill-word       # alt+backspace
bindkey '^[[3;3~' kill-word             # alt+delete
bindkey '^w' backward-kill-word         # ctrl+w
bindkey '^k' kill-line                  # ctrl+k

# Line editing
bindkey '^a' beginning-of-line          # ctrl+a
bindkey '^e' end-of-line                # ctrl+e
bindkey '^u' kill-whole-line            # ctrl+u

# Custom keybindings
bindkey '^Z' fancy-ctrl-z
bindkey '^[e' _zoxide_fzf_widget

# =============================================================================
# COMPLETION STYLING
# =============================================================================
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # case insensitive completion
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '-- %d --'
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# URl/Paste AutoSuggest
autoload -U url-quote-magic bracketed-paste-magic
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
# Clear widgets for autosuggestions
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(expand-or-complete bracketed-paste accept-line push-line-or-edit)

# =============================================================================
# FZF CONFIGURATION
# =============================================================================
# Configure FZF with catppuccin mocha colors
export FZF_DEFAULT_OPTS="
  --color=bg+:$CATPPUCCIN_MOCHA_SURFACE0,bg:$CATPPUCCIN_MOCHA_BASE,spinner:$CATPPUCCIN_MOCHA_ROSEWATER,hl:$CATPPUCCIN_MOCHA_RED
  --color=fg:$CATPPUCCIN_MOCHA_TEXT,header:$CATPPUCCIN_MOCHA_RED,info:$CATPPUCCIN_MOCHA_MAUVE,pointer:$CATPPUCCIN_MOCHA_ROSEWATER
  --color=marker:$CATPPUCCIN_MOCHA_LAVENDER,fg+:$CATPPUCCIN_MOCHA_TEXT,prompt:$CATPPUCCIN_MOCHA_MAUVE,hl+:$CATPPUCCIN_MOCHA_RED
  --color=selected-bg:$CATPPUCCIN_MOCHA_SURFACE1,selected-fg:$CATPPUCCIN_MOCHA_TEXT
  --color=gutter:$CATPPUCCIN_MOCHA_BASE,border:$CATPPUCCIN_MOCHA_BLUE
  --border=rounded
  --multi"

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --theme='Catppuccin Mocha' --line-range :500 {}' --preview-window=right:60%:wrap"
export FZF_ALT_C_OPTS="--preview 'eza --tree --icons=always --color=always {} | head -200' --preview-window=right:60%:wrap"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git --type f"

# Configure FZF-TAB
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons=always --tree --level=1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --icons=always --tree --level=1 --color=always $realpath'
zstyle ':fzf-tab:*' query-string ''
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo $description'

zstyle ':fzf-tab:*' fzf-flags \
  --color=bg+:$CATPPUCCIN_MOCHA_SURFACE0,bg:$CATPPUCCIN_MOCHA_BASE,spinner:$CATPPUCCIN_MOCHA_ROSEWATER,hl:$CATPPUCCIN_MOCHA_RED \
  --color=fg:$CATPPUCCIN_MOCHA_TEXT,header:$CATPPUCCIN_MOCHA_RED,info:$CATPPUCCIN_MOCHA_MAUVE,pointer:$CATPPUCCIN_MOCHA_ROSEWATER \
  --color=marker:$CATPPUCCIN_MOCHA_LAVENDER,fg+:$CATPPUCCIN_MOCHA_TEXT,prompt:$CATPPUCCIN_MOCHA_MAUVE,hl+:$CATPPUCCIN_MOCHA_RED \
  --color=gutter:$CATPPUCCIN_MOCHA_BASE,border:$CATPPUCCIN_MOCHA_BLUE \
  --height=60% \
  --layout=reverse \
  --border=rounded \
  --border-label="  Selection  " \
  --border-label-pos=2 \
  --preview-window=right:60%:wrap \
  --multi

# =============================================================================
# ZINIT SETUP
# =============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[[ ! -d $ZINIT_HOME ]] && mkdir -p $(dirname ${ZINIT_HOME}) && git clone https://github.com/zdharma-continuum/zinit.git $ZINIT_HOME
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# =============================================================================
# PLUGIN HELPER FUNCTIONS
# =============================================================================

# Helper function for regular plugins with wait/lucid options
function zicy() {
    # $1: wait time, $2: GitHub repo, $3+: optional extra ice modifiers
    local wait_time=$1 repo=$2
    shift 2

    local ice_args=(lucid wait"${wait_time}")

    # Add any extra modifiers passed as arguments
    for mod in "$@"; do
        ice_args+=("$mod")
    done

    zinit ice "${ice_args[@]}"
    zinit light "$repo"
}

# Helper function for zinit snippets
function zicy-snip() {
    # $1: wait time, $2: snippet URL, $3+: optional extra ice modifiers
    local wait_time=$1 url=$2
    shift 2

    local ice_args=(lucid wait"${wait_time}")

    # Add any extra modifiers passed as arguments
    for mod in "$@"; do
        ice_args+=("$mod")
    done

    zinit ice "${ice_args[@]}"
    zinit snippet "$url"
}

# =============================================================================
# PLUGINS
# =============================================================================
# Oh-My-Zsh plugins
zinit wait'1' lucid for \
    OMZL::git.zsh \
    OMZP::git \
    OMZP::sudo \
    OMZP::extract \
    OMZP::colored-man-pages \
    OMZP::kubectl \
    OMZP::kubectx \
    OMZP::command-not-found



# Carapace shell completion
export CARAPACE_BRIDGES="zsh,fzf"
export CARAPACE_CACHE=1

# Regular plugins
zicy "0c" "hlissner/zsh-autopair"
zicy "0c" "zdharma-continuum/fast-syntax-highlighting"
zicy "0c" "junegunn/fzf-git.sh"
zicy "1c" "Aloxaf/fzf-tab"
zicy "0a" "junegunn/fzf" as"command" pick"bin/fzf-tmux"
zicy "0a" "zsh-users/zsh-autosuggestions" atload'_zsh_autosuggest_start'

zinit ice lucid wait"1a" as"null" atload'command -v zoxide &> /dev/null && eval "$(zoxide init --cmd cd zsh)"'
zinit load zdharma-continuum/null
zinit ice lucid wait"2a" as"null" atload'command -v mcfly &> /dev/null && eval "$(mcfly init zsh)"'
zinit load zdharma-continuum/null
zinit ice lucid wait"3a" as"null" atload'command -v mcfly-fzf &> /dev/null && eval "$(mcfly-fzf init zsh)"'
zinit load zdharma-continuum/null
zinit ice lucid wait"2b" as"null" atload'command -v carapace &> /dev/null && source <(carapace _carapace zsh)'
zinit load zdharma-continuum/null
zinit ice lucid wait"1a" as"null" atload'command -v oh-my-posh &> /dev/null && eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/omp.toml)"'
zinit load zdharma-continuum/null


zinit light-mode for \
    blockf \
        zsh-users/zsh-completions

# FZF snippets
zicy-snip "0a" "https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh"
zicy-snip "1c" "https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh"

# =============================================================================
# COMPLETION INITIALIZATION
# =============================================================================
autoload -Uz compinit && compinit
zinit cdreplay -q

# Optional: Load extra config that is not tracked and unique per machine
[[ -f ~/.zsh_local ]] && source ~/.zsh_local
