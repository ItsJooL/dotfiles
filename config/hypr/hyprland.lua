-- Hyprland configuration — targets Hyprland 0.55+
-- Refer to: https://wiki.hypr.land/Configuring/Start/
--
-- Modular layout:
--   colors.lua   — Catppuccin Mocha palette
--   monitors.lua — Display setup with smart docking detection
--   startup.lua  — Autostart applications
--   keybinds.lua — Keyboard/mouse bindings (includes scale stepping)
--   rules.lua    — Window and layer rules
--   local.lua    — Optional per-machine overrides (not tracked)

local c = require("colors")
require("monitors")
require("startup")
require("keybinds")
require("rules")


-- ─── Environment variables ────────────────────────────────────────────────

hl.env("XCURSOR_SIZE",          "24")
hl.env("QT_STYLE_OVERRIDE",     "kvantum")
hl.env("QT_QPA_PLATFORMTHEME",  "qt5ct")


-- ─── General ──────────────────────────────────────────────────────────────

hl.config({
    general = {
        border_size      = 3,
        resize_on_border = true,
        gaps_in          = 6,
        gaps_out         = 10,
        layout           = "dwindle",
        allow_tearing    = false,
        col = {
            active_border   = { colors = { c.mauve, c.flamingo }, angle = 90 },
            inactive_border = c.subtext0,
        },
    },
})


-- ─── Decoration ───────────────────────────────────────────────────────────

hl.config({
    decoration = {
        rounding = 4,
        blur = {
            enabled = true,
            size    = 10,
            passes  = 1,
        },
    },
})


-- ─── Animations ───────────────────────────────────────────────────────────

hl.curve("linear", { type = "bezier", points = { { 0.0, 0.0 }, { 1.0, 1.0 } } })

hl.animation({ leaf = "borderangle", enabled = true,  speed = 50,  bezier = "linear", style = "loop" })
hl.animation({ leaf = "workspaces",  enabled = true,  speed = 0.5, bezier = "default" })
hl.animation({ leaf = "windows",     enabled = false })
hl.animation({ leaf = "fade",        enabled = false })


-- ─── Layout ───────────────────────────────────────────────────────────────

hl.config({
    dwindle = {
        pseudotile     = true,
        preserve_split = true,
    },
})


-- ─── Input ────────────────────────────────────────────────────────────────

hl.config({
    input = {
        kb_layout    = "us",
        kb_options   = "ctrl:nocaps",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


-- ─── XWayland ─────────────────────────────────────────────────────────────

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})


-- ─── Misc ─────────────────────────────────────────────────────────────────

hl.config({
    misc = {
        force_default_wallpaper = 0,
    },
})


-- ─── Per-machine overrides ────────────────────────────────────────────────

pcall(require, "local")
