#!/usr/bin/env bash
# Rofi script mode: Tmux keybindings

if [[ -n "$1" ]]; then exit 0; fi

cat <<'EOF'
--- Custom Bindings (Prefix = Ctrl+B) ---
New Window (home dir)           Prefix + Ctrl+C
New Window                      Prefix + t
Detach                          Prefix + Ctrl+D
Previous Window                 Prefix + H
Next Window                     Prefix + L
Rename Window                   Prefix + r
Reload Config                   Prefix + R
Last Window                     Prefix + Ctrl+A
List Windows                    Prefix + Ctrl+W
Split Vertical                  Prefix + v
Split Horizontal                Prefix + h
Choose Window                   Prefix + "
Fuzzy Find                      Prefix + f
Command Prompt                  Prefix + :
Sync Panes                      Prefix + *
Pane Border Status              Prefix + P
Kill Pane                       Prefix + c
Swap Pane Down                  Prefix + x
Choose Session                  Prefix + S
Clear Screen                    Prefix + K
Begin Selection (vi)            v  (in copy mode)
--- Plugin Bindings ---
Floating Pane                   Prefix + p  (floax)
Session Picker                  Prefix + o  (sessionx)
URL Picker                      Prefix + u  (fzf-url)
--- Default Bindings ---
List Keys                       Prefix + ?
Scroll Mode (copy)              Prefix + [
Paste Buffer                    Prefix + ]
Select Pane Up                  Prefix + Up
Select Pane Down                Prefix + Down
Select Pane Left                Prefix + Left
Select Pane Right               Prefix + Right
Go to Window N                  Prefix + 0-9
Next Window                     Prefix + n
Previous Window                 Prefix + p
Zoom Pane                       Prefix + z
Mouse                           Enabled (select/scroll/resize)
EOF
