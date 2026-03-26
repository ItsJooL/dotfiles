#!/usr/bin/env bash
# Rofi script mode: Hyprland keybindings

if [[ -n "$1" ]]; then exit 0; fi

cat <<'EOF'
--- Media ---
Volume Up                       XF86AudioRaiseVolume
Volume Down                     XF86AudioLowerVolume
Mute Toggle                     XF86AudioMut
Brightness Up                   XF86MonBrightnessUp
Brightness Down                 XF86MonBrightnessDown
--- Applications ---
Terminal (Kitty)                Super + T
App Launcher (Rofi)             Super + Space
Lock Screen                     Super + L
Keybind Cheatsheet              Super + /
--- Window Management ---
Kill Window                     Super + Q
Exit Hyprland                   Super + M
Toggle Floating                 Super + V
Maximise Fullscreen             Super + F
Toggle Group                    Super + W
Toggle Split                    Super + E / Y
Pseudo Tile                     Super + P
--- Screenshots ---
Screenshot Window               Super + S
Screenshot Region               Super + A
--- Focus ---
Focus Left                      Super + Left
Focus Right                     Super + Right
Focus Up                        Super + Up
Focus Down                      Super + Down
--- Monitor ---
Disable Monitor                 Super + Shift + D
Enable Monitor (1.20x)          Super + Shift + F
Scale Up                        Super + Shift + Ctrl + Up
Scale Down                      Super + Shift + Ctrl + Down
--- System ---
Reload Config                   Super + Shift + R
--- Workspaces ---
Switch Workspace 1-9            Super + 1-9
Switch Workspace 10             Super + 0
Move Window to WS 1-9           Super + Shift + 1-9
Move Window to WS 10            Super + Shift + 0
--- Mouse ---
Next Workspace                  Super + Scroll Down
Prev Workspace                  Super + Scroll Up
Move Window                     Super + Left Drag
Resize Window                   Super + Right Drag
EOF
