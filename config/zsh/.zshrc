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
# PATH & ENV SETUP
# =============================================================================
update_path() {
    for dir in "$@"; do
        [[ -d $dir ]] && export PATH=$dir:$PATH
    done
}
update_path ~/scripts ~/.local/bin /home/linuxbrew/.linuxbrew/bin/
[[ -x "$(command -v brew)" ]] && eval "$(brew shellenv)"
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
# Autosuggestions with paste magic
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
zinit ice wait'0a' lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
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

# History substring search (for up/down arrows)
zinit ice wait'0b' lucid atload'!export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=green,fg=black,bold"'
zinit light zsh-users/zsh-history-substring-search
setopt HIST_IGNORE_ALL_DUPS

# Core completions
zinit light-mode for \
    blockf \
        zsh-users/zsh-completions

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

# FZF integration
zinit ice lucid wait'0c' as'command' pick'bin/fzf-tmux'
zinit light junegunn/fzf

zinit ice lucid wait'0c' multisrc'shell/{completion,key-bindings}.zsh' id-as'junegunn/fzf_completions' pick'/dev/null'
zinit light junegunn/fzf

# FZF-related plugins
zinit ice wait'1' lucid
zinit light Aloxaf/fzf-tab

zinit ice wait'1' lucid
zinit light junegunn/fzf-git.sh

# Syntax highlighting and autopair (load late with proper completion replay)
zinit ice wait'0c' lucid atinit'zpcompinit;zpcdreplay'
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice wait'0c' lucid atinit'zpcompinit;zpcdreplay'
zinit light hlissner/zsh-autopair

# =============================================================================
# CARAPACE CONFIG
# =============================================================================
export CARAPACE_BRIDGES="zsh,fzf"
export CARAPACE_CACHE=1

if [[ -x "$(command -v carapace)" ]]; then
    zinit ice as'null' lucid wait'2' atload'
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

    (( ${#precmd_functions} )) || precmd_functions=()
    precmd_functions+=(_carapace_tmux_fix)
    _setup_carapace
    '
    zinit light zdharma-continuum/null
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
bindkey "^r" history-incremental-search-backward # ctrl+r (mcfly will override if installed)

# Word deletion
bindkey '^[^?' backward-kill-word       # alt+backspace
bindkey '^[[3;3~' kill-word             # alt+delete
bindkey '^w' backward-kill-word         # ctrl+w
bindkey '^k' kill-line                  # ctrl+k

# Line editing
bindkey '^a' beginning-of-line          # ctrl+a
bindkey '^e' end-of-line                # ctrl+e
bindkey '^u' kill-whole-line            # ctrl+u

# FZF file widget
bindkey '^F' fzf-file-widget

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
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --level=1 --color=always $realpath'
zstyle ':fzf-tab:*' query-string ''
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo $description'

# Enhanced cd completion with zoxide
_zoxide_cd_completion() {
  local word=${words[CURRENT]}
  local zoxide_results=("${(@f)$(zoxide query -l "$word" 2>/dev/null)}")
  if [[ ${#zoxide_results} -gt 0 ]]; then
    for result in $zoxide_results; do
      compadd -U -X "zoxide" "$result"
    done
  fi
  _path_files -/ -W "$PWD" -g "*(-/)"
}
compdef _zoxide_cd_completion cd

# =============================================================================
# TOOL INITIALIZATION (After plugins are loaded)
# =============================================================================
# Initialize external tools
[[ -x "$(command -v zoxide)" ]] && eval "$(zoxide init --cmd cd zsh)"

# Initialize mcfly-fzf or mcfly (mcfly-fzf takes priority and will override Ctrl+R)
if [[ -x "$(command -v mcfly-fzf)" ]]; then
    eval "$(mcfly-fzf init zsh)"
    # Ensure mcfly-fzf uses our FZF styling
    export MCFLY_FZF_OPTS="$FZF_DEFAULT_OPTS --height=60% --layout=reverse"
elif [[ -x "$(command -v mcfly)" ]]; then
    eval "$(mcfly init zsh)"
fi

# =============================================================================
# ALIASES
# =============================================================================
alias ls='eza --color=always --long --git --icons=always'
alias ll='eza --color=always --long --git --icons=always'
alias la='eza --color=always --long --git --icons=always --all'
alias lt='eza --color=always --tree --git --icons=always'
alias cat='bat --style=auto'
alias grep='grep --color=auto'
alias ocat='/bin/cat'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# =============================================================================
# LAZY LOAD SOME CONFIGURATIONS
# =============================================================================
# Lazy load kubectl completion
if command -v kubectl &>/dev/null; then
  kubectl() {
    unfunction kubectl
    # Load completion
    source <(command kubectl completion zsh 2>/dev/null)
    # Re-run original command
    command kubectl "$@"
  }
fi

# Lazy load NVM
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  nvm() {
    unfunction nvm
    source "$NVM_DIR/nvm.sh"
    nvm "$@"
  }
fi

# Lazy load SDKMAN
if [[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]]; then
  sdk() {
    unfunction sdk
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
    sdk "$@"
  }
fi

# =============================================================================
# UNTRACKED CUSTOMIZATION
# =============================================================================
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases
[[ -f ~/.zsh_functions ]] && source ~/.zsh_functions
[[ -f ~/.zshrc_extension ]] && source ~/.zshrc_extension

# Optional: Load extra config that is not tracked and unique per machine
[[ -f ~/.zsh_local ]] && source ~/.zsh_local
