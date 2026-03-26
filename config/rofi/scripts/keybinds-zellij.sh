#!/usr/bin/env bash
# Rofi script mode: Zellij keybindings

if [[ -n "$1" ]]; then exit 0; fi

cat <<'EOF'
--- Mode Switching ---
Pane Mode                       Ctrl + P
Tab Mode                        Ctrl + T
Resize Mode                     Ctrl + N
Move Mode                       Ctrl + H
Scroll Mode                     Ctrl + S
Tmux Mode                       Ctrl + B
Normal Mode (from locked)       Ctrl + G
Exit Mode                       Enter / Esc
--- Global (Any Mode) ---
New Pane                        Alt + N
Toggle Floating                 Alt + F
Focus Left                      Alt + H / Left
Focus Right                     Alt + L / Right
Focus Up                        Alt + K / Up
Focus Down                      Alt + J / Down
Prev Swap Layout                Alt + [
Next Swap Layout                Alt + ]
Move Tab Left                   Alt + I
Move Tab Right                  Alt + O
Increase Size                   Alt + =
Decrease Size                   Alt + -
Quit                            Ctrl + Q
--- Pane Mode (Ctrl+P) ---
Rename Pane                     c
New Pane Down                   d
New Pane Right                  r / n
Toggle Embed/Float              e
Toggle Fullscreen               f
Switch Focus                    p
Toggle Floating Panes           w
Toggle Pane Frames              z
--- Tab Mode (Ctrl+T) ---
New Tab                         n
Rename Tab                      r
Close Tab                       x
Previous Tab                    h / Left / k
Next Tab                        l / Right / j
Go to Tab 1-9                   1-9
Toggle Tab                      Tab
Break Pane Left                 [
Break Pane Right                ]
Break Pane                      b
Sync Tab                        s
--- Resize Mode (Ctrl+N) ---
Increase Left                   h / Left
Increase Right                  l / Right
Increase Up                     k / Up
Increase Down                   j / Down
Decrease Left                   H
Decrease Right                  L
Decrease Up                     K
Decrease Down                   J
--- Move Mode (Ctrl+H) ---
Move Pane Left                  h / Left
Move Pane Right                 l / Right
Move Pane Up                    Up
Move Pane Down                  j / Down
Move Pane Forward               n / Tab
Move Pane Backward              p
--- Scroll Mode (Ctrl+S) ---
Page Up                         PgUp / Ctrl+B / h
Page Down                       PgDn / Ctrl+F / l
Half Page Up                    u
Half Page Down                  d
Scroll Up                       k
Scroll Down                     j
Edit Scrollback                 e
Search Mode                     s
Scroll Bottom and Exit          Ctrl+C
--- Session Mode (Ctrl+O) ---
Configuration                   c
Plugin Manager                  p
Session Manager                 w
Detach                          d
--- Tmux Compat (Ctrl+B) ---
Split Down                      "
Split Right                     %
New Tab                         c
Next Tab                        n
Prev Tab                        p
Rename Tab                      ,
Focus Next Pane                 o
Toggle Fullscreen               z
Close Pane                      x
Enter Scroll                    [
Detach                          d
Next Layout                     Space
EOF
