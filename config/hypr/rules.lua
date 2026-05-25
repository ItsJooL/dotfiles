-- Window and layer rules

hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.layer_rule({
    name  = "no-blur-rofi",
    match = { namespace = "^rofi$" },
    blur  = false,
})

hl.window_rule({
    name    = "kitty-opacity",
    match   = { class = "^(kitty)$" },
    opacity = 0.9,
})

hl.window_rule({
    name    = "rofi-opacity",
    match   = { class = "^(rofi)$" },
    opacity = 0.8,
})

hl.window_rule({
    name             = "pangp-ui",
    match            = { class = "^(PanGPUI)$" },
    no_initial_focus = true,
    move             = "1829 40",
})

-- Claude AI launcher — floats centred at a comfortable size
hl.window_rule({
    name   = "claudeai",
    match  = { class = "^(chrome%-claude%.ai__new%-Profile_1)$" },
    float  = true,
    size   = "1200 800",
    center = true,
})
