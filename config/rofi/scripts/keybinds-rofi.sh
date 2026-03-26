#!/usr/bin/env bash
# Rofi script mode: Rofi's own navigation keybindings

if [[ -n "$1" ]]; then exit 0; fi

cat <<'EOF'
--- Navigation ---
Previous Entry                  Up / Ctrl+P
Next Entry                      Down / Ctrl+N
Page Up                         Page Up
Page Down                       Page Down
First Entry                     Home
Last Entry                      End
--- Tabs ---
Next Tab                        Shift+Right / Ctrl+Tab
Previous Tab                    Shift+Left / Ctrl+Shift+Tab
--- Input ---
Paste                           Ctrl+V / Shift+Insert
Clear Line                      Ctrl+W
Start of Line                   Ctrl+A
End of Line                     Ctrl+E
Word Back                       Alt+B / Ctrl+Left
Word Forward                    Alt+F / Ctrl+Right
Delete Word Back                Ctrl+Backspace
Delete Word Forward             Ctrl+Alt+D
Delete Char Forward             Delete / Ctrl+D
Delete Char Back                Backspace
Delete to End of Line           Ctrl+K
Delete to Start of Line         Ctrl+U
--- Actions ---
Accept Entry                    Enter / Ctrl+J
Accept Custom                   Ctrl+Enter
Accept Alt                      Shift+Enter
Delete Entry                    Shift+Delete
Toggle Case Sensitivity         ` (backtick)
Toggle Sort                     Alt+`
Cancel / Close                  Escape / Ctrl+G
Screenshot                      Alt+S
EOF
