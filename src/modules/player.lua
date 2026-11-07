return function(Window, Utils)
    local LP = game:GetService("Players").LocalPlayer
    local RunService = game:GetService("RunService")

    local tab = Window:Tab({ Title = "Player", Icon = "solar:user-bold" })
    local sec = tab:Section({ Title = "Movimiento" })

    local speed = 16

    local applySpeed = function()
        local h = Utils.humanoid()
        if h then h.WalkSpeed = speed end
    end

    local charConn = LP.CharacterAdded:Connect(function()
        task.wait(1)
        applySpeed()
    end)
    Utils.onCleanup(function() charConn:Disconnect() end)

    sec:Slider({
        Title = "WalkSpeed", Step = 1,
        Value = { Min = 16, Max = 300, Default = 16 },
        Callback = function(v) speed = v; applySpeed() end,
    })

    sec:Space()

    sec:Slider({
        Title = "JumpPower", Step = 1,
        Value = { Min = 50, Max = 500, Default = 50 },
        Callback = function(v)
            local h = Utils.humanoid()
            if h then h.UseJumpPower = true; h.JumpPower = v end
        end,
    })

    sec:Space()

    sec:Toggle({
        Title = "Infinite Jump",
        Desc = "Salta en el aire con Espacio",
        Callback = function(on)
            Utils.bind("InfJump", on, function(input)
                if input.KeyCode ~= Enum.KeyCode.Space then return end
                local h = Utils.humanoid()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end,
    })

    local noclip = false
    local noclipConn = RunService.Stepped:Connect(function()
        if not noclip then return end
        local char = LP.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
    Utils.onCleanup(function() noclipConn:Disconnect() end)

    sec:Toggle({
        Title = "Noclip",
        Desc = "Atraviesa paredes",
        Callback = function(on) noclip = on end,
    })

    local flying, bv, bg
    local flyConn = RunService.RenderStepped:Connect(function()
        if not flying then return end
        local root = Utils.root()
        if not root or not bv then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if Utils.key("W") then dir += cam.CFrame.LookVector end
        if Utils.key("S") then dir -= cam.CFrame.LookVector end
        if Utils.key("A") then dir -= cam.CFrame.RightVector end
        if Utils.key("D") then dir += cam.CFrame.RightVector end
        if Utils.key("Space") then dir += Vector3.yAxis end
        if Utils.key("LeftControl") then dir -= Vector3.yAxis end
        bv.Velocity = dir * 80
        bg.CFrame = cam.CFrame
    end)
    Utils.onCleanup(function() flyConn:Disconnect() end)

    local function stopFly()
        flying = false
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        bv, bg = nil, nil
    end
    Utils.onCleanup(stopFly)

    sec:Toggle({
        Title = "Fly",
        Desc = "WASD mueve, Espacio sube, Ctrl baja",
        Callback = function(on)
            if not on then return stopFly() end
            local root = Utils.root()
            if not root then return end
            flying = true
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.one * 1e5
            bv.Parent = root
            bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.one * 1e5
            bg.P = 1e4
            bg.Parent = root
        end,
    })

    local util = tab:Section({ Title = "Utilidades" })

    util:Button({
        Title = "Reset Character", Icon = "rotate-ccw", Justify = "Center",
        Callback = function()
            local char = LP.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
            end
        end,
    })

    util:Button({
        Title = "Restaurar default", Icon = "undo", Justify = "Center",
        Callback = function()
            local h = Utils.humanoid()
            if h then h.WalkSpeed = 16; h.JumpPower = 50 end
        end,
    })
end
