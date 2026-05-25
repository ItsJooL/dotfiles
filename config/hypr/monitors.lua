-- Monitor configuration
--
-- External monitors are matched by description (port-agnostic — survives dock changes).
-- eDP-1 (laptop panel) is always configured; the startup hook disables it when docked.
--
-- Home desk setup:
--   Left  — Acer Technologies XV272U  @ 0x0
--   Right — ASUSTek COMPUTER INC BE27A @ 2560x0

hl.monitor({ desc = "XV272U",   mode = "2560x1440", position = "0x0",    scale = 1 })
hl.monitor({ desc = "BE27A",    mode = "2560x1440", position = "2560x0", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "preferred",  position = "auto",   scale = 1.6 })
hl.monitor({ output = "",      mode = "preferred",  position = "auto",   scale = "auto" })

hl.on("hyprland.start", function()
    -- Disable laptop panel when both desk monitors are present
    local h = io.popen("hyprctl monitors -j 2>/dev/null")
    if not h then return end
    local json = h:read("*a"); h:close()
    if json:find("XV272U") and json:find("BE27A") then
        os.execute("hyprctl keyword monitor eDP-1,disabled")
    end
end)
