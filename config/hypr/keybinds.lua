-- Keybindings

local mainMod = "SUPER"

local terminal = "kitty"
local menu     = "rofi -show drun -modi drun,filebrowser,run,window -theme ~/.config/rofi/launcher.rasi"


-- ─── Monitor scale stepping ────────────────────────────────────────────────
-- Replaces scripts/scale.sh — runs entirely in Lua at bind time.

local function step_scale(direction)
    -- Get the active monitor name
    local aw = io.popen("hyprctl activeworkspace -j 2>/dev/null")
    if not aw then return end
    local aw_json = aw:read("*a"); aw:close()
    local monitor = aw_json:match('"monitor":"([^"]+)"')
    if not monitor then return end

    -- Get that monitor's current dimensions and scale
    local h = io.popen("hyprctl monitors -j 2>/dev/null")
    if not h then return end
    local json = h:read("*a"); h:close()

    local pos = json:find('"' .. monitor .. '"')
    if not pos then return end
    local block = json:sub(pos, pos + 500)

    local width   = tonumber(block:match('"width":(%d+)'))
    local height  = tonumber(block:match('"height":(%d+)'))
    local current = tonumber(block:match('"scale":([%d%.]+)'))
    if not current then return end

    local scales
    if width == 2560 and height == 1440 then
        scales = { 1.00, 1.25, 1.33, 1.50, 1.60, 2.00 }
    elseif width == 1920 and height == 1080 then
        scales = { 0.75, 1.00, 1.20, 1.25, 1.50, 2.00 }
    else
        scales = { 1.00, 1.25, 1.50, 2.00 }
    end

    local idx = 1
    for i, v in ipairs(scales) do
        if math.abs(v - current) < 0.01 then idx = i; break end
    end

    if direction == "up"   then idx = math.min(idx + 1, #scales) end
    if direction == "down" then idx = math.max(idx - 1, 1)       end

    local new = scales[idx]
    os.execute(string.format("hyprctl keyword monitor '%s,preferred,auto,%.2f'", monitor, new))
    os.execute(string.format(
        "notify-send -u low -t 1500 -h string:x-canonical-private-synchronous:scale-notify " ..
        "'Monitor Scale (%s)' 'Scale: %.2f'", monitor, new
    ))
end


-- ─── Media keys ────────────────────────────────────────────────────────────

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%"),  { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"),  { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"),                      { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                      { locked = true, repeating = true })


-- ─── Application shortcuts ────────────────────────────────────────────────

hl.bind(mainMod .. " + T",           hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + space",       hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + C",   hl.dsp.exec_cmd("~/.config/rofi/scripts/clipboard.sh"))
hl.bind(mainMod .. " + slash",       hl.dsp.exec_cmd("~/.config/rofi/scripts/keybinds.sh"))
hl.bind(mainMod .. " + C",           hl.dsp.exec_cmd("flatpak run com.google.Chrome --app=https://claude.ai/new --class=claudeai"))


-- ─── Window management ────────────────────────────────────────────────────

hl.bind(mainMod .. " + Q",           hl.dsp.window.close())
hl.bind(mainMod .. " + M",           hl.dsp.exec_cmd("hyprctl dispatch exit"))
hl.bind(mainMod .. " + V",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F",   hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + W",           hl.dsp.exec_cmd("hyprctl dispatch togglegroup"))
hl.bind(mainMod .. " + Y",           hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + E",           hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + P",           hl.dsp.window.pseudo())


-- ─── System ───────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + L",           hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + R",   hl.dsp.exec_cmd("hyprctl reload"))


-- ─── Monitor control ──────────────────────────────────────────────────────

hl.bind(mainMod .. " + SHIFT + D",   hl.dsp.exec_cmd("hyprctl keyword monitor eDP-1,disable"))
hl.bind(mainMod .. " + SHIFT + CTRL + F",   hl.dsp.exec_cmd("hyprctl keyword monitor 'eDP-1,preferred,auto,1.20'"))
hl.bind(mainMod .. " + SHIFT + CTRL + Up",   function() step_scale("up")   end)
hl.bind(mainMod .. " + SHIFT + CTRL + Down", function() step_scale("down") end)


-- ─── Screenshots ──────────────────────────────────────────────────────────

hl.bind(mainMod .. " + S",           hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. " + A",           hl.dsp.exec_cmd("hyprshot -m region"))


-- ─── Focus ────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + left",        hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right",       hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",          hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",        hl.dsp.focus({ direction = "down"  }))


-- ─── Workspaces ───────────────────────────────────────────────────────────

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,                hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,        hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down",  hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",    hl.dsp.focus({ workspace = "e-1" }))


-- ─── Mouse window actions ─────────────────────────────────────────────────

hl.bind(mainMod .. " + mouse:272",   hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",   hl.dsp.window.resize(), { mouse = true })
