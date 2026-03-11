-- XuanAnhiuem - ULTIMATE PVP V4 (FIXED & OPTIMIZED)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- --- GUI SETUP ---
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "XuanAnhiuem_V4"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 420)
Main.Position = UDim2.new(0.5, -130, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- Minimize Button
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextSize = 20
Instance.new("UICorner", MinBtn)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "XuanAnhiuem - PRO"
Title.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Instance.new("UICorner", Title)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -10, 1, -55)
Container.Position = UDim2.new(0, 5, 0, 45)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 1.8, 0)
Container.ScrollBarThickness = 2
local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 8)

-- Minimize Logic
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Container.Visible = false
        Main:TweenSize(UDim2.new(0, 260, 0, 40), "Out", "Quad", 0.3, true)
        MinBtn.Text = "+"
    else
        Main:TweenSize(UDim2.new(0, 260, 0, 420), "Out", "Quad", 0.3, true)
        task.wait(0.3)
        Container.Visible = true
        MinBtn.Text = "-"
    end
end)

-- --- SETTINGS ---
local _G = {
    Speed = 16,
    FlySpeed = 100,
    HitboxSize = 2,
    Flying = false,
    FastAttack = false,
    AttackSpeed = 0.05
}

-- --- UTILS ---
local function CreateToggle(text, callback)
    local on = false
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, -5, 0, 35)
    Btn.Text = text .. " : OFF"
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(function()
        on = not on
        Btn.Text = text .. (on and " : ON" or " : OFF")
        Btn.BackgroundColor3 = on and Color3.fromRGB(255, 100, 150) or Color3.fromRGB(35, 35, 40)
        callback(on)
    end)
end

-- --- FEATURES ---

-- 1. WalkSpeed (Velocity Method - No Jump Lag)
RunService.Heartbeat:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hum = player.Character.Humanoid
            if _G.Speed > 16 and hum.MoveDirection.Magnitude > 0 then
                local moveDir = hum.MoveDirection
                player.Character.HumanoidRootPart.Velocity = Vector3.new(moveDir.X * _G.Speed, player.Character.HumanoidRootPart.Velocity.Y, moveDir.Z * _G.Speed)
            end
        end
    end)
end)

-- 2. Fly + Noclip
RunService.Stepped:Connect(function()
    if _G.Flying and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

CreateToggle("Fly + Noclip", function(v)
    _G.Flying = v
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if v and root then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "XuanAn_Fly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while _G.Flying do
                bv.Velocity = camera.CFrame.LookVector * _G.FlySpeed
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

-- 3. Fast Attack (Universal Virtual Click)
task.spawn(function()
    while task.wait() do
        if _G.FastAttack then
            pcall(function()
                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                -- Hỗ trợ thêm cho các Tool cụ thể
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end)
            task.wait(_G.AttackSpeed)
        end
    end
end)

CreateToggle("Fast Attack", function(v)
    _G.FastAttack = v
    _G.AttackSpeed = 0.05
end)

CreateToggle("ULTRA Fast Attack", function(v)
    _G.FastAttack = v
    _G.AttackSpeed = 0.0001
end)

-- 4. Hitbox Expander (Fix Lag)
task.spawn(function()
    while task.wait(0.5) do
        if _G.HitboxSize > 2 then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = v.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                    hrp.Transparency = 0.8
                    hrp.CanCollide = false
                end
            end
        end
    end
end)

-- --- SLIDERS ---
local function CreateSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame", Container)
    Frame.Size = UDim2.new(1, -5, 0, 45)
    Frame.BackgroundTransparency = 1
    local Text = Instance.new("TextLabel", Frame)
    Text.Size = UDim2.new(1, 0, 0, 15)
    Text.Text = name .. ": " .. default
    Text.TextColor3 = Color3.new(1, 1, 1)
    Text.BackgroundTransparency = 1
    local Bar = Instance.new("Frame", Frame)
    Bar.Size = UDim2.new(0.9, 0, 0, 5)
    Bar.Position = UDim2.new(0.05, 0, 0.7, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 100, 150)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local move = UIS.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(min + (max - min) * pos)
                    Text.Text = name .. ": " .. val
                    callback(val)
                end
            end)
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end
            end)
        end
    end)
end

CreateSlider("Walk Speed", 16, 500, 16, function(v) _G.Speed = v end)
CreateSlider("Hitbox Scale", 2, 100, 2, function(v) _G.HitboxSize = v end)
CreateSlider("Fly Velocity", 50, 500, 100, function(v) _G.FlySpeed = v end)

-- Final Load Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "XuanAnhiuem V4",
    Text = "Ready to Dominate!",
    Duration = 5
})

