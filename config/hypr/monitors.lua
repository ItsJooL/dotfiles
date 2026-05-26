-- Monitor configuration
--
-- External monitors are matched by description (port-agnostic — survives dock changes).
-- eDP-1 (laptop panel) is always configured; the startup hook disables it when docked.
--
-- Home desk setup:
--   Left  — Acer Technologies XV272U  @ 0x0
--   Right — ASUSTek COMPUTER INC BE27A @ 2560x0

hl.monitor({ output = "desc:XV272U", mode = "2560x1440", position = "0x0",    scale = 1 })
hl.monitor({ output = "desc:BE27A", mode = "2560x1440", position = "2560x0", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "preferred",  position = "auto",   scale = 1.6 })
hl.monitor({ output = "",      mode = "preferred",  position = "auto",   scale = "auto" })

-- Resolves the real output name (e.g. "DP-3") for a monitor whose description
-- contains fragment. "name" always precedes "description" in hyprctl JSON, so
-- grabbing the last "name" before the fragment position gives the right object.
local function monitor_name_for(json, fragment)
    local pos = json:find(fragment, 1, true)
    if not pos then return nil end
    return json:sub(1, pos):match('.*"name":"([^"]+)"')
end

hl.on("hyprland.start", function()
    local h = io.popen("hyprctl monitors -j 2>/dev/null")
    if not h then return end
    local json = h:read("*a"); h:close()

    local left  = monitor_name_for(json, "XV272U")
    local right = monitor_name_for(json, "BE27A")

    if left and right then
        -- Disable laptop panel when docked
        os.execute("hyprctl keyword monitor eDP-1,disabled")

        -- Pin workspaces to monitors by real output name (port-agnostic:
        -- description → name resolved above, so dock port changes are invisible)
        for i, ws in ipairs({ "1", "2", "3" }) do
            hl.workspace_rule({ workspace = ws, monitor = left,  default = (i == 1) })
        end
        for i, ws in ipairs({ "4", "5", "6" }) do
            hl.workspace_rule({ workspace = ws, monitor = right, default = (i == 1) })
        end
    end
end)
