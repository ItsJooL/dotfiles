-- Autostart — equivalent to exec-once in hyprlang

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user stop dunst")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --watch cliphist store")
end)
