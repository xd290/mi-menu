-- mi-menu | loader
-- Uso: loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/xd290/mi-menu@main/src/loader.lua"))()

local BASE = "https://cdn.jsdelivr.net/gh/xd290/mi-menu@main/src/"

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/refs/tags/v1.6.66/dist/main.lua"
))()

local Utils = loadstring(game:HttpGet(BASE .. "utils.lua"))()

local Window = WindUI:CreateWindow({
    Title = "mi-menu",
    Folder = "mimenu",
    Icon = "solar:folder-2-bold-duotone",
    NewElements = true,
    HideSearchBar = true,
    Topbar = { Height = 44, ButtonsType = "Mac" },
})

Window:Tag({ Title = "v1.0.0", Icon = "github", Color = Color3.fromHex("#1c1c1c"), Border = true })

Utils.onCleanup(function()
    Window:Destroy()
end)

for _, name in ipairs({ "player", "visual", "teleport", "misc" }) do
    local ok, mod = pcall(function()
        return loadstring(game:HttpGet(BASE .. "modules/" .. name .. ".lua"))()
    end)
    if ok and type(mod) == "function" then
        task.spawn(mod, Window, Utils)
    else
        warn(("[mi-menu] modulo '%s' fallo: %s"):format(name, tostring(mod)))
    end
end

Window:OnDestroy(Utils.runCleanups)
