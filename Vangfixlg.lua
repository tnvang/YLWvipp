local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local COLOR_BG = Color3.fromRGB(255, 245, 180) 
local COLOR_MAIN = Color3.fromRGB(255, 220, 50) 
local COLOR_BORDER = Color3.fromRGB(180, 140, 0) 

local Toggles = {Noclip = false}
local gui = Instance.new("ScreenGui")
gui.Name = "Vangfixlg"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- === 1. FPS CẦU VỒNG (NHỎ GỌN) ===
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 50, 0, 20)
fpsLabel.Position = UDim2.new(0, 15, 0, 15)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: ..."
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 13
fpsLabel.Parent = gui
local fpsStroke = Instance.new("UIStroke", fpsLabel)
fpsStroke.Thickness = 1

RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1/dt)
    fpsLabel.Text = "FPS: " .. fps
    fpsLabel.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
end)

-- === 2. MENU VANGFIXLG (SIÊU MINI) ===
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 170, 0, 160) 
main.Position = UDim2.new(0.5, -85, 0.5, -80)
main.BackgroundColor3 = COLOR_BG
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", main).Color = COLOR_BORDER

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = COLOR_MAIN
title.Text = "Vangfixlg"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -20, 1, -45)
container.Position = UDim2.new(0, 10, 0, 40)
container.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)

-- === 3. CHỨC NĂNG CHÍNH ===
local function UltraFixLag()
    local terrain = workspace:FindFirstChildOfClass('Terrain')
    if terrain then
        terrain.WaterWaveSize, terrain.WaterWaveSpeed, terrain.WaterReflectance, terrain.WaterTransparency = 0,0,0,0
    end
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("Sky") or v:IsA("Clouds") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
    settings().Rendering.QualityLevel = 1
end

local function createBtn(name, callback, isToggle)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Text = name
    btn.BackgroundColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    Instance.new("UICorner", btn)
    
    if isToggle then
        btn.MouseButton1Click:Connect(function()
            Toggles.Noclip = not Toggles.Noclip
            btn.Text = "Noclip: " .. (Toggles.Noclip and "ON" or "OFF")
            btn.BackgroundColor3 = Toggles.Noclip and COLOR_MAIN or Color3.new(1,1,1)
        end)
    else
        btn.BackgroundColor3 = COLOR_MAIN
        btn.MouseButton1Click:Connect(callback)
    end
end

createBtn("Noclip: OFF", nil, true)
createBtn("ULTRA FIX LAG", UltraFixLag, false)

-- VẬN HÀNH
RunService.Stepped:Connect(function()
    if player.Character and Toggles.Noclip then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Kéo Menu
local drag, dStart, sPos
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true dStart = i.Position sPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
    local delta = i.Position - dStart
    main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)

