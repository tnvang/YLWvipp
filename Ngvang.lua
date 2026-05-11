local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local COLOR_BG = Color3.fromRGB(255, 245, 180) -- Vàng nhạt (Nền)
local COLOR_MAIN = Color3.fromRGB(255, 220, 50) -- Vàng chuẩn
local COLOR_BORDER = Color3.fromRGB(180, 140, 0) -- Vàng đậm

local Toggles = {Aura = false, Aimbot = false, ESP = false, Hitbox = false}
local HitboxSize = 1 
local sliding = false

local gui = Instance.new("ScreenGui")
gui.Name = "Ngvang"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- NÚT THU GỌN (ICON NINJA)
local minimizeBtn = Instance.new("ImageButton")
minimizeBtn.Name = "NinjaIcon"
minimizeBtn.Parent = gui
minimizeBtn.Size = UDim2.new(0, 45, 0, 45)
minimizeBtn.Position = UDim2.new(0, 10, 0.5, -22)
minimizeBtn.BackgroundColor3 = COLOR_MAIN
minimizeBtn.Image = "rbxassetid://13426111166" 
minimizeBtn.Visible = false 
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)
local miniStroke = Instance.new("UIStroke", minimizeBtn)
miniStroke.Color = COLOR_BORDER
miniStroke.Thickness = 2

-- MAIN MENU
local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = gui
main.Size = UDim2.new(0, 250, 0, 380)
main.Position = UDim2.new(0.4, 0, 0.3, 0)
main.BackgroundColor3 = COLOR_BG
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Thickness = 3
mainStroke.Color = COLOR_BORDER

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = COLOR_MAIN
title.Text = "Ngvang Hub"
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
container.CanvasSize = UDim2.new(0, 0, 1.4, 0)
container.ScrollBarThickness = 0
container.Parent = main
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)

local function createToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = container
    Instance.new("UICorner", btn)
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = COLOR_BORDER
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and COLOR_MAIN or Color3.new(1,1,1)
        callback(state)
    end)
end

-- Slider Hitbox
local sliderFrame = Instance.new("Frame", container)
sliderFrame.Size = UDim2.new(1, 0, 0, 50)
sliderFrame.BackgroundTransparency = 1
local sliderLabel = Instance.new("TextLabel", sliderFrame)
sliderLabel.Size = UDim2.new(1, 0, 0, 20)
sliderLabel.Text = "Hitbox Size: 1"
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.new(0,0,0)
local sliderBar = Instance.new("TextButton", sliderFrame)
sliderBar.Size = UDim2.new(0.9, 0, 0, 6)
sliderBar.Position = UDim2.new(0.05, 0, 0.7, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
sliderBar.Text = ""
local sliderFill = Instance.new("Frame", sliderBar)
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = COLOR_BORDER

local function updateSlider()
    local mousePos = UserInputService:GetMouseLocation().X
    local barPos = sliderBar.AbsolutePosition.X
    local percent = math.clamp((mousePos - barPos) / sliderBar.AbsoluteSize.X, 0, 1)
    HitboxSize = math.floor(1 + (percent * 199))
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderLabel.Text = "Hitbox Size: " .. tostring(HitboxSize)
end

sliderBar.InputBegan:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
        sliding = true 
    end 
end)
UserInputService.InputEnded:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
        sliding = false 
    end 
end)
RunService.RenderStepped:Connect(function() 
    if sliding then updateSlider() end 
end)

-- LOGIC CHỨC NĂNG
local currentAura
local function makeAura()
    if currentAura then currentAura:Destroy() end
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        currentAura = Instance.new("Part", char)
        currentAura.Shape = "Ball"
        currentAura.Size = Vector3.new(10, 10, 10)
        currentAura.Material = "ForceField"
        currentAura.Color = COLOR_MAIN
        currentAura.CanCollide = false
        local w = Instance.new("WeldConstraint", currentAura)
        w.Part0 = char.HumanoidRootPart
        w.Part1 = currentAura
    end
end

createToggle("Khiên Aura", function(v) 
    Toggles.Aura = v 
    if v then makeAura() else if currentAura then currentAura:Destroy() end end 
end)

createToggle("Aimbot Closest", function(v) Toggles.Aimbot = v end)
createToggle("ESP Name", function(v) Toggles.ESP = v end)
createToggle("Big Hitbox", function(v) Toggles.Hitbox = v end)

RunService.RenderStepped:Connect(function()
    local closest = nil
    local shortestDist = math.huge

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            
            -- Hitbox
            if Toggles.Hitbox then
                hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                hrp.Transparency = 0.8
                hrp.Color = COLOR_MAIN
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
            end

            -- ESP Name
            local tag = hrp:FindFirstChild("NgvangTag")
            if Toggles.ESP then
                if not tag then
                    tag = Instance.new("BillboardGui", hrp)
                    tag.Name = "NgvangTag"
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

            -- Aimbot Target
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mag < shortestDist then
                    shortestDist = mag
                    closest = hrp
                end
            end
        end
    end

    if Toggles.Aimbot and closest and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        camera.CFrame = CFrame.new(camera.CFrame.Position, closest.Position)
    end
end)

player.CharacterAdded:Connect(function() 
    if Toggles.Aura then task.wait(1) makeAura() end 
end)

-- Kéo Menu
local dragging, dragStart, startPos
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
    local delta = i.Position - dragStart
    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

