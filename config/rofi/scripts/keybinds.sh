#!/usr/bin/env bash
# Launch rofi keybind cheatsheet with tabbed modes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rofi -show "Hyprland" \
    -modi "Hyprland:${SCRIPT_DIR}/keybinds-hyprland.sh,Zellij:${SCRIPT_DIR}/keybinds-zellij.sh,Tmux:${SCRIPT_DIR}/keybinds-tmux.sh,Neovim:${SCRIPT_DIR}/keybinds-neovim.sh,Rofi:${SCRIPT_DIR}/keybinds-rofi.sh" \
    -theme "${SCRIPT_DIR}/../keybinds.rasi"
