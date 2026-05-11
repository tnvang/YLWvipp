local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local COLOR_MAIN = Color3.fromRGB(255, 230, 100)
local COLOR_BORDER = Color3.fromRGB(200, 160, 0)
local COLOR_BG = Color3.fromRGB(25, 25, 25)

local Toggles = {
    Aura = false,
    Aimbot = false,
    ESP = false,
    Hitbox = false
}

local HitboxSize = 1 

local gui = Instance.new("ScreenGui")
gui.Name = "Vanghehe"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = gui
main.Size = UDim2.new(0, 250, 0, 380) -- Tăng chiều cao để chứa slider
main.Position = UDim2.new(0.4, 0, 0.3, 0)
main.BackgroundColor3 = COLOR_BG
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = COLOR_BORDER
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = COLOR_MAIN
title.Text = "Vanghehe Hub"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -20, 1, -60)
container.Position = UDim2.new(0, 10, 0, 50)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 1.3, 0)
container.ScrollBarThickness = 2
container.Visible = false
container.Parent = main
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)

local loadBg = Instance.new("Frame", main)
loadBg.Size = UDim2.new(0.8, 0, 0, 5)
loadBg.Position = UDim2.new(0.1, 0, 0.5, 0)
loadBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
local loadBar = Instance.new("Frame", loadBg)
loadBar.Size = UDim2.new(0, 0, 1, 0)
loadBar.BackgroundColor3 = COLOR_MAIN

TweenService:Create(loadBar, TweenInfo.new(2), {Size = UDim2.new(1, 0, 1, 0)}):Play()
task.delay(2.1, function()
    loadBg:Destroy()
    container.Visible = true
end)

local function createToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = container
    Instance.new("UICorner", btn)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and COLOR_BORDER or Color3.fromRGB(35, 35, 35)
        callback(state)
    end)
end

-- Slider Hitbox (1 - 200)
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(1, 0, 0, 50)
sliderFrame.BackgroundTransparency = 1
sliderFrame.Parent = container

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0, 20)
sliderLabel.Text = "Hitbox Size: 1"
sliderLabel.TextColor3 = Color3.new(1, 1, 1)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Font = Enum.Font.GothamMedium
sliderLabel.Parent = sliderFrame

local sliderBar = Instance.new("TextButton")
sliderBar.Size = UDim2.new(0.9, 0, 0, 6)
sliderBar.Position = UDim2.new(0.05, 0, 0.7, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
sliderBar.Text = ""
sliderBar.Parent = sliderFrame
Instance.new("UICorner", sliderBar)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = COLOR_MAIN
sliderFill.Parent = sliderBar
Instance.new("UICorner", sliderFill)

local function updateSlider()
    local mousePos = UserInputService:GetMouseLocation().X
    local barPos = sliderBar.AbsolutePosition.X
    local barWidth = sliderBar.AbsoluteSize.X
    local percent = math.clamp((mousePos - barPos) / barWidth, 0, 1)
    
    HitboxSize = math.floor(1 + (percent * 199))
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderLabel.Text = "Hitbox Size: " .. tostring(HitboxSize)
end

local sliding = false
sliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = true
        updateSlider()
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider()
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)

-- Chức năng
local currentAura
createToggle("Khiên Aura", function(v)
    Toggles.Aura = v
    if v then
        local char = player.Character
        currentAura = Instance.new("Part", char)
        currentAura.Shape = "Ball"
        currentAura.Size = Vector3.new(10, 10, 10)
        currentAura.Material = "ForceField"
        currentAura.Color = COLOR_MAIN
        currentAura.CanCollide = false
        local w = Instance.new("WeldConstraint", currentAura)
        w.Part0 = char.HumanoidRootPart
        w.Part1 = currentAura
    else
        if currentAura then currentAura:Destroy() end
    end
end)

createToggle("Aimbot Head", function(v) Toggles.Aimbot = v end)
RunService.RenderStepped:Connect(function()
    if Toggles.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local closest = nil
        local dist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if mag < dist then
                        dist = mag
                        closest = p.Character.Head
                    end
                end
            end
        end
        if closest then
            camera.CFrame = CFrame.new(camera.CFrame.Position, closest.Position)
        end
    end
end)

createToggle("ESP Player", function(v) Toggles.ESP = v end)
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local box = p.Character:FindFirstChild("TNV_ESP")
            if Toggles.ESP then
                if not box then
                    box = Instance.new("Highlight", p.Character)
                    box.Name = "TNV_ESP"
                    box.FillTransparency = 1
                    box.OutlineColor = COLOR_MAIN
                end
            else
                if box then box:Destroy() end
            end
        end
    end
end)

createToggle("Big Hitbox", function(v) Toggles.Hitbox = v end)
RunService.RenderStepped:Connect(function()
    if Toggles.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                hrp.Transparency = 0.7
                hrp.Color = COLOR_MAIN
                hrp.CanCollide = false
            end
        end
    end
end)

local dragging, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
main.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

