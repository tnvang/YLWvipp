--[[ 
    XUANANHIU HUB - PREMIUM EDITION
    Features: ESP, Aimlock, Speed, Jump, Hitbox
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Header = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Container = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- UI Settings
ScreenGui.Parent = game.CoreGui
MainFrame.Name = "Xuananhiu_Hub"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -150)
MainFrame.Size = UDim2.new(0, 220, 0, 360)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(255, 105, 180) -- Hot Pink Theme
Header.Size = UDim2.new(1, 0, 0, 40)
local HCorner = Instance.new("UICorner")
HCorner.CornerRadius = UDim.new(0, 15)
HCorner.Parent = Header

Title.Parent = Header
Title.Text = "XUANANHIU HUB"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 50)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.CanvasSize = UDim2.new(0, 0, 1.8, 0)
Container.ScrollBarThickness = 2

UIListLayout.Parent = Container
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Button Creator Function
local function AddButton(text, color, func)
    local b = Instance.new("TextButton")
    local bc = Instance.new("UICorner")
    b.Parent = Container
    b.Text = text
    b.Size = UDim2.new(1, 0, 0, 35)
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = b
    b.MouseButton1Click:Connect(func)
end

-- --- CORE FEATURES ---

-- 1. ESP (Wallhack)
AddButton("Enable ESP", Color3.fromRGB(46, 204, 113), function()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character then
            if not v.Character:FindFirstChild("Highlight") then
                local h = Instance.new("Highlight", v.Character)
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency = 0.5
            end
        end
    end
end)

-- 2. Aimlock (Auto Target)
AddButton("Enable Aimlock", Color3.fromRGB(230, 126, 34), function()
    local cam = workspace.CurrentCamera
    game:GetService("RunService").RenderStepped:Connect(function()
        local target = nil
        local dist = math.huge
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local pos, onScreen = cam:WorldToScreenPoint(v.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                    if mag < dist then target = v; dist = mag end
                end
            end
        end
        if target then cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.Head.Position) end
    end)
end)

-- 3. WalkSpeed (100)
AddButton("WalkSpeed (100)", Color3.fromRGB(52, 152, 219), function()
    local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = 100 end
end)

-- 4. JumpPower (150)
AddButton("JumpPower (150)", Color3.fromRGB(127, 140, 141), function()
    local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then 
        hum.JumpPower = 150 
        hum.UseJumpPower = true
    end
end)

-- 5. Expand Hitbox (25)
AddButton("Expand Hitbox (25)", Color3.fromRGB(155, 89, 182), function()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character:FindFirstChild("HumanoidRootPart") then
            v.Character.HumanoidRootPart.Size = Vector3.new(25, 25, 25)
            v.Character.HumanoidRootPart.Transparency = 0.7
            v.Character.HumanoidRootPart.CanCollide = false
        end
    end
end)

-- 6. RESET ALL
AddButton("RESET SETTINGS", Color3.fromRGB(192, 57, 43), function()
    local h = game.Players.LocalPlayer.Character.Humanoid
    h.WalkSpeed = 16
    h.JumpPower = 50
    for _, v in pairs(game.Players:GetPlayers()) do
        if v.Character:FindFirstChild("Highlight") then v.Character.Highlight:Destroy() end
        if v.Character:FindFirstChild("HumanoidRootPart") then
            v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            v.Character.HumanoidRootPart.Transparency = 1
        end
    end
end)
