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
# ANTIDOTE SETUP
# =============================================================================
ANTIDOTE_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/antidote"
[[ ! -d $ANTIDOTE_HOME ]] && git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_HOME"
source "${ANTIDOTE_HOME}/antidote.zsh"

# =============================================================================
# PATH & ENV SETUP
# =============================================================================
update_path() {
    for dir in "$@"; do
        [[ -d $dir ]] && export PATH=$dir:$PATH
    done
}
update_path ~/scripts ~/.local/bin /home/linuxbrew/.linuxbrew/bin/
[[ -x "$(command -v brew)" ]] && eval "$(brew shellenv)"

# Initialize mise early to ensure managed binaries are available
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
fi

[[ -x "$(command -v mise)" ]] && source <(mise completion zsh 2>/dev/null)

[[ -x "$(command -v oh-my-posh)" ]] && eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/omp.toml)"

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
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
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

export QUOTING_STYLE=literal

# =============================================================================
# FZF CONFIGURATION
# =============================================================================
export FZF_DEFAULT_OPTS="--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --color=selected-bg:#45475a,selected-fg:#cdd6f4 --color=gutter:#1e1e2e,border:#89b4fa --border=rounded --multi"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --theme=\"Catppuccin Mocha\" --line-range :500 {}' --preview-window=right:60%:wrap"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200' --preview-window=right:60%:wrap"

export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --height=7"

_fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'awk -v HOST={} -f ~/.ssh/bin/host2conf.awk ~/.ssh/config'  "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# =============================================================================
# PLUGINS
# =============================================================================
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=green,fg=black,bold"

antidote load "${ZDOTDIR:-$HOME}/.zsh_plugins.txt"

# Completion system — after antidote load so all fpath additions are visible
autoload -Uz compinit && compinit -C

# Paste magic
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
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(expand-or-complete bracketed-paste accept-line push-line-or-edit)

# =============================================================================
# CARAPACE CONFIG
# =============================================================================
export CARAPACE_BRIDGES="zsh"
export CARAPACE_CACHE=1

if [[ -x "$(command -v carapace)" ]]; then
    _setup_carapace() {
        precmd_functions=(${precmd_functions:#_setup_carapace})
        zstyle ":completion:*" format "${CATPPUCCIN_MOCHA_YELLOW}%d${RESET_COLOR}"
        source <(carapace _carapace)
    }
    (( ${#precmd_functions} )) || precmd_functions=()
    precmd_functions+=(_setup_carapace)
fi

# =============================================================================
# KEYBINDINGS
# =============================================================================
bindkey -e  # Emacs keybindings

# Basic movement
bindkey "^[[D" backward-char
bindkey "^[[C" forward-char
bindkey "^[[A" history-substring-search-up      # Use substring search for up/down
bindkey "^[[B" history-substring-search-down

# Character deletion
bindkey '^[[3~' delete-char             # delete key
bindkey '^?' backward-delete-char       # backspace

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

# Word deletion
bindkey '^[^?' backward-kill-word       # alt+backspace
bindkey '^[[3;3~' kill-word             # alt+delete
bindkey '^w' backward-kill-word         # ctrl+w
bindkey '^k' kill-line                  # ctrl+k

# Line editing
bindkey '^a' beginning-of-line          # ctrl+a
bindkey '^e' end-of-line                # ctrl+e
bindkey '^u' kill-whole-line            # ctrl+u

# Home/End — kitty sends these sequences
bindkey '^[[H' beginning-of-line        # Home
bindkey '^[[F' end-of-line              # End

# Edit current command in $EDITOR (nvim)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line        # ctrl+x ctrl+e

# Shelve current command, run something else, restore on next prompt
bindkey '^[q' push-line                  # alt+q

# Repeat the previous word/argument at cursor position
bindkey '\em' copy-prev-shell-word      # alt+m

# FZF file widget
bindkey '^F' fzf-file-widget            # ctrl+f

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================
# Zoxide with FZF
_zoxide_fzf_widget() {
  local selected_dir
  selected_dir=$(zoxide query -l | fzf --preview 'eza --tree --level=1 --color=always {}')
  if [[ -n "$selected_dir" ]]; then
    BUFFER="cd ${(q)selected_dir}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N _zoxide_fzf_widget
bindkey '^[z' _zoxide_fzf_widget  # Alt+z

# Background job management with FZF
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
bindkey '^Z' fancy-ctrl-z

# =============================================================================
# COMPLETION STYLING
# =============================================================================
fpath+=~/.zfunc

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '-- %d --'
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:complete:*:options' sort false
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# FZF-TAB configuration
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
                            --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
                            --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
                            --color=gutter:#1e1e2e,border:#89b4fa \
                            --height=60% \
                            --layout=reverse \
                            --border=rounded \
                            --border-label="  Selection  " \
                            --border-label-pos=2 \
                            --preview-window=right:60%:wrap \
                            --multi

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=1 --color=always $realpath'
zstyle ':fzf-tab:*' show-group brief
zstyle ':fzf-tab:*' query-string ''
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo $description'

# =============================================================================
# TOOL INITIALIZATION (After plugins are loaded)
# =============================================================================
# Initialize external tools
[[ -x "$(command -v zoxide)" ]] && eval "$(zoxide init --cmd cd zsh)"
[[ -x "$(command -v fzf)" ]] && eval "$(fzf --zsh)"

# McFly configuration
export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=2
export MCFLY_RESULTS=50
export MCFLY_INTERFACE_VIEW=BOTTOM
export MCFLY_RESULTS_SORT=LAST_RUN

if [[ -x "$(command -v mcfly)" ]]; then
    _setup_mcfly() {
        precmd_functions=(${precmd_functions:#_setup_mcfly})
        eval "$(mcfly init zsh)"
        if [[ -x "$(command -v mcfly-fzf)" ]]; then
            eval "$(mcfly-fzf init zsh)"
            bindkey "^R" mcfly-fzf-history-widget
        else
            bindkey "^R" history-incremental-search-backward
        fi
    }
    (( ${#precmd_functions} )) || precmd_functions=()
    precmd_functions+=(_setup_mcfly)
fi

# =============================================================================
# ALIASES
# =============================================================================
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

# =============================================================================
# UNTRACKED CUSTOMIZATION
# =============================================================================
[[ -f ~/.zsh_aliases_local ]] && source ~/.zsh_aliases_local
[[ -f ~/.zsh_functions ]] && source ~/.zsh_functions
[[ -f ~/.zshrc_extension ]] && source ~/.zshrc_extension
[[ -f ~/.zsh_local ]] && source ~/.zsh_local
