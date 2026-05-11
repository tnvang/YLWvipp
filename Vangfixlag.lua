local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local COLOR_BG = Color3.fromRGB(255, 245, 180) 
local COLOR_MAIN = Color3.fromRGB(255, 220, 50) 
local COLOR_BORDER = Color3.fromRGB(180, 140, 0) 

local Toggles = {Noclip = false}
local gui = Instance.new("ScreenGui")
gui.Name = "Vangfixlag"
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
    fpsLabel.Text = "FPS: " .. math.floor(1/dt)
    fpsLabel.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
end)

-- === 2. NÚT THU GỌN ẢNH HACKER ===
local minimizeBtn = Instance.new("ImageButton")
minimizeBtn.Parent = gui
minimizeBtn.Size = UDim2.new(0, 45, 0, 45)
minimizeBtn.Position = UDim2.new(0, 10, 0.5, -22)
minimizeBtn.BackgroundColor3 = COLOR_MAIN
minimizeBtn.Image = "rbxassetid://13426111166" -- Icon Hacker
minimizeBtn.Visible = false 
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", minimizeBtn).Color = COLOR_BORDER

-- === 3. MENU VANGFIXLAG ===
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 180, 0, 170) 
main.Position = UDim2.new(0.5, -90, 0.5, -85)
main.BackgroundColor3 = COLOR_BG
Instance.new("UICorner", main)
Instance.new("UIStroke", main).Color = COLOR_BORDER

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = COLOR_MAIN
title.Text = "Vangfixlag"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(0,0,0)
title.Parent = main
Instance.new("UICorner", title)

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 2)
closeBtn.Text = "-"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundTransparency = 1
closeBtn.MouseButton1Click:Connect(function() main.Visible = false minimizeBtn.Visible = true end)
minimizeBtn.MouseButton1Click:Connect(function() main.Visible = true minimizeBtn.Visible = false end)

local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -20, 1, -45)
container.Position = UDim2.new(0, 10, 0, 40)
container.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)

-- === 4. CHỨC NĂNG ===
local function UltraFixLag()
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

local noclipBtn = Instance.new("TextButton", container)
noclipBtn.Size = UDim2.new(1, 0, 0, 35)
noclipBtn.Text = "Noclip: OFF"
noclipBtn.Font = Enum.Font.GothamMedium
noclipBtn.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", noclipBtn)

noclipBtn.MouseButton1Click:Connect(function()
    Toggles.Noclip = not Toggles.Noclip
    noclipBtn.Text = "Noclip: " .. (Toggles.Noclip and "ON" or "OFF")
    noclipBtn.BackgroundColor3 = Toggles.Noclip and COLOR_MAIN or Color3.new(1,1,1)
    
    -- Fix lỗi không tắt được noclip
    if not Toggles.Noclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)

local fixBtn = Instance.new("TextButton", container)
fixBtn.Size = UDim2.new(1, 0, 0, 35)
fixBtn.Text = "ULTRA FIX LAG"
fixBtn.Font = Enum.Font.GothamBold
fixBtn.BackgroundColor3 = COLOR_MAIN
Instance.new("UICorner", fixBtn)
fixBtn.MouseButton1Click:Connect(UltraFixLag)

-- HỆ THỐNG NOCLIP
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

