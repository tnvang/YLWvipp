local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- MÀU SẮC VANGFLAG (VÀNG NHẠT)
local COLOR_BG = Color3.fromRGB(255, 245, 180) 
local COLOR_MAIN = Color3.fromRGB(255, 220, 50) 
local COLOR_BORDER = Color3.fromRGB(180, 140, 0) 

local Toggles = {Aimbot = false, ESP = false, Hitbox = false, Noclip = false}
local Vars = {Hitbox = 1, Speed = 16, Jump = 50}
local sliding = nil 

local gui = Instance.new("ScreenGui")
gui.Name = "Vangflag"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- === 1. FPS CẦU VỒNG GÓC MÀN HÌNH ===
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 60, 0, 20)
fpsLabel.Position = UDim2.new(0, 15, 0, 15)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: ..."
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 14
fpsLabel.Parent = gui
local fpsStroke = Instance.new("UIStroke", fpsLabel)
fpsStroke.Thickness = 1

RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1/dt)
    fpsLabel.Text = "FPS: " .. fps
    local hue = tick() % 5 / 5
    fpsLabel.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
end)

-- === 2. ICON NINJA THU GỌN ===
local minimizeBtn = Instance.new("ImageButton")
minimizeBtn.Parent = gui
minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
minimizeBtn.Position = UDim2.new(0, 10, 0.5, -20)
minimizeBtn.BackgroundColor3 = COLOR_MAIN
minimizeBtn.Image = "rbxassetid://13426111166" 
minimizeBtn.Visible = false 
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", minimizeBtn).Color = COLOR_BORDER

-- === 3. MENU CHÍNH VANGFLAG (MINI) ===
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 210, 0, 360) 
main.Position = UDim2.new(0.5, -105, 0.5, -180)
main.BackgroundColor3 = COLOR_BG
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = COLOR_BORDER
mainStroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = COLOR_MAIN
title.Text = "Vangflag Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(0,0,0)
title.Parent = main
Instance.new("UICorner", title)

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundTransparency = 1
closeBtn.MouseButton1Click:Connect(function() main.Visible = false minimizeBtn.Visible = true end)
minimizeBtn.MouseButton1Click:Connect(function() main.Visible = true minimizeBtn.Visible = false end)

local container = Instance.new("ScrollingFrame", main)
container.Size = UDim2.new(1, -10, 1, -50)
container.Position = UDim2.new(0, 5, 0, 45)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 2.8, 0)
container.ScrollBarThickness = 0
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)

-- === 4. HÀM ULTRA FIX LAG (XOÁ TRỜI/NƯỚC/VẬT THỂ) ===
local function UltraFixLag()
    local terrain = workspace:FindFirstChildOfClass('Terrain')
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0
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
    game:GetService("Lighting").GlobalShadows = false
    settings().Rendering.QualityLevel = 1
end

-- === 5. UI COMPONENTS ===
local function createToggle(name, callback)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = name .. ": OFF"
    btn.Font = Enum.Font.GothamMedium
    btn.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and COLOR_MAIN or Color3.new(1,1,1)
        callback(state)
    end)
end

local function createSlider(name, min, max, default, callback)
    local f = Instance.new("Frame", container)
    f.Size = UDim2.new(1, 0, 0, 40)
    f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,0,0,15)
    l.Text = name..": "..default
    l.Font = Enum.Font.Gotham
    l.BackgroundTransparency = 1
    local bar = Instance.new("TextButton", f)
    bar.Size = UDim2.new(1,0,0,5)
    bar.Position = UDim2.new(0,0,0.65,0)
    bar.BackgroundColor3 = Color3.new(0.8,0.8,0.8)
    bar.Text = ""
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = COLOR_BORDER
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = function()
        local p = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(min+(p*(max-min)))
        fill.Size = UDim2.new(p,0,1,0) l.Text = name..": "..v callback(v)
    end end end)
end

-- CÀI ĐẶT CÁC NÚT
createToggle("Noclip (Xuyên Tường)", function(v) Toggles.Noclip = v end)
createToggle("Aimbot Closest", function(v) Toggles.Aimbot = v end)
createToggle("ESP Name", function(v) Toggles.ESP = v end)
createToggle("Big Hitbox", function(v) Toggles.Hitbox = v end)

local fixBtn = Instance.new("TextButton", container)
fixBtn.Size = UDim2.new(1,0,0,32)
fixBtn.Text = "ULTRA FIX LAG"
fixBtn.Font = Enum.Font.GothamBold
fixBtn.BackgroundColor3 = COLOR_MAIN
Instance.new("UICorner", fixBtn)
fixBtn.MouseButton1Click:Connect(UltraFixLag)

createSlider("Hitbox Size", 1, 100, 1, function(v) Vars.Hitbox = v end)
createSlider("Walk Speed", 16, 200, 16, function(v) Vars.Speed = v end)
createSlider("Jump Power", 50, 400, 50, function(v) Vars.Jump = v end)

-- === 6. HỆ THỐNG VẬN HÀNH ===
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = nil end end)

RunService.Stepped:Connect(function()
    if sliding then sliding() end
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = not Toggles.Noclip end
        end
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = Vars.Speed hum.JumpPower = Vars.Jump end
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

