local UIS = game:GetService("UserInputService")
local LP = game:GetService("Players").LocalPlayer

local Utils = {}
local cleanups = {}
local binds = {}

function Utils.onCleanup(fn) table.insert(cleanups, fn) end

function Utils.runCleanups()
    for _, fn in ipairs(cleanups) do pcall(fn) end
    table.clear(cleanups)
end

function Utils.humanoid()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utils.root()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utils.notify(title, content)
    if Utils.notifyUI then Utils.notifyUI(title, content) end
end

function Utils.bind(id, enabled, fn)
    if binds[id] then binds[id]:Disconnect(); binds[id] = nil end
    if not enabled then return end
    binds[id] = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        pcall(fn, input)
    end)
end

local held = {}
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    held[i.KeyCode] = true
end)
UIS.InputEnded:Connect(function(i) held[i.KeyCode] = false end)

function Utils.key(name)
    local kc = Enum.KeyCode[name]
    if not kc then return false end
    return held[kc] == true or UIS:IsKeyDown(kc)
end

return Utils
