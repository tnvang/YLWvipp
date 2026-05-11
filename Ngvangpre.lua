local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local COLOR_BG = Color3.fromRGB(255, 245, 180) 
local COLOR_MAIN = Color3.fromRGB(255, 220, 50) 
local COLOR_BORDER = Color3.fromRGB(180, 140, 0) 

local Toggles = {Aimbot = false, ESP = false, Hitbox = false}
local Vars = {Hitbox = 1, Speed = 16, Jump = 50}
local sliding = nil 

local gui = Instance.new("ScreenGui")
gui.Name = "Ngvangpre"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- ICON NINJA
local minimizeBtn = Instance.new("ImageButton")
minimizeBtn.Parent = gui
minimizeBtn.Size = UDim2.new(0, 45, 0, 45)
minimizeBtn.Position = UDim2.new(0, 10, 0.5, -22)
minimizeBtn.BackgroundColor3 = COLOR_MAIN
minimizeBtn.Image = "rbxassetid://13426111166" 
minimizeBtn.Visible = false 
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", minimizeBtn).Color = COLOR_BORDER

-- MAIN MENU
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 260, 0, 400) 
main.Position = UDim2.new(0.4, 0, 0.3, 0)
main.BackgroundColor3 = COLOR_BG
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", main).Color = COLOR_BORDER

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = COLOR_MAIN
title.Text = "Ngvangpre Hub"
title.TextColor3 = Color3.new(0, 0, 0) 
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(0, 0, 0)
closeBtn.TextScaled = true
closeBtn.Parent = main

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    minimizeBtn.Visible = true
end)

minimizeBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    minimizeBtn.Visible = false
end)

local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -20, 1, -60)
container.Position = UDim2.new(0, 10, 0, 50)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 2, 0) 
container.ScrollBarThickness = 0
container.Parent = main
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 10)

-- THANH TRƯỢT
local function createSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.new(0,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    local bar = Instance.new("TextButton", frame)
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0.7, 0)
    bar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    bar.Text = ""
    Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = COLOR_BORDER
    Instance.new("UICorner", fill)
    local function update()
        local percent = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (percent * (max - min)))
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = name .. ": " .. val
        callback(val)
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = update end end)
end

-- NÚT BẬT/TẮT
local function createToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.new(1,1,1)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = container
    Instance.new("UICorner", btn)
    Instance.new("UIStroke", btn).Color = COLOR_BORDER
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and COLOR_MAIN or Color3.new(1,1,1)
        callback(state)
    end)
end

createToggle("Aimbot Closest", function(v) Toggles.Aimbot = v end)
createToggle("ESP Name", function(v) Toggles.ESP = v end)
createToggle("Big Hitbox", function(v) Toggles.Hitbox = v end)

createSlider("Hitbox Size", 1, 200, 1, function(v) Vars.Hitbox = v end)
createSlider("Walk Speed", 16, 250, 16, function(v) Vars.Speed = v end)
createSlider("Jump Power", 50, 500, 50, function(v) Vars.Jump = v end)

UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = nil end end)

RunService.RenderStepped:Connect(function()
    if sliding then sliding() end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = Vars.Speed
        player.Character.Humanoid.JumpPower = Vars.Jump
    end
    local closest, shortestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if Toggles.Hitbox then
                hrp.Size = Vector3.new(Vars.Hitbox, Vars.Hitbox, Vars.Hitbox)
                hrp.Transparency = 0.8
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
            end
            local tag = hrp:FindFirstChild("NgpreTag")
            if Toggles.ESP then
                if not tag then
                    tag = Instance.new("BillboardGui", hrp)
                    tag.Name = "NgpreTag"
                    tag.Size = UDim2.new(0, 100, 0, 50)
                    tag.AlwaysOnTop = true
                    tag.ExtentsOffset = Vector3.new(0, 3, 0)
                    local l = Instance.new("TextLabel", tag)
                    l.BackgroundTransparency = 1
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.Text = p.Name
                    l.Font = Enum.Font.GothamBold
                    l.TextSize = 12
                    l.TextColor3 = Color3.new(1, 1, 1)
                    Instance.new("UIStroke", l).Thickness = 1
                end
            elseif tag then tag:Destroy() end
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mag < shortestDist then shortestDist = mag closest = hrp end
            end
        end
    end
    if Toggles.Aimbot and closest and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        camera.CFrame = CFrame.new(camera.CFrame.Position, closest.Position)
    end
end)

-- Kéo Menu
local dragging, dragStart, startPos
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
    local delta = i.Position - dragStart
    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

