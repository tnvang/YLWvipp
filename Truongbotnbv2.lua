if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
local camera = Workspace.CurrentCamera

local Config = {
    AimbotEnabled = false,
    FOVRadius = 100,
    Distance = 280,
    Smoothness = 0.15, -- Độ mượt aimbot (càng nhỏ càng mượt, tránh giật)
    WallCheckEnabled = true, -- Bật quét tường chuẩn bằng Raycast
    TeamCheckEnabled = true, -- Không aimbot đồng đội
    
    HitboxEnabled = false,
    HitboxSize = 5,
    HitboxTransparency = 0.5,
    
    NoclipEnabled = false,
    FixLagEnabled = false,

    WalkSpeedEnabled = false,
    WalkSpeedValue = 16,
    JumpPowerEnabled = false,
    JumpPowerValue = 50,
    InfiniteJumpEnabled = false,
    
    ESPNameEnabled = false,
    ESPBoxEnabled = false,

    SpherePetEnabled = false,
    RainbowRunEnabled = false
}

local SystemState = {
    TargetPosition = nil,
    OriginalHitboxData = {},
    OriginalCharData = { WalkSpeed = 16, JumpPower = 50 },
    OriginalMaterials = {},
    NoclipConnection = nil,
    InfJumpConnection = nil,
    RainbowRunConnection = nil,
    LagFixConnection = nil,
    PetInstance = nil
}

-- Vẽ vòng tròn FOV theo vị trí chuột/ngón tay chạm
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = Config.FOVRadius
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

local function updateFOV()
    if not Config.AimbotEnabled then
        FOVCircle.Visible = false
        return
    end
    FOVCircle.Radius = Config.FOVRadius
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = true
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TruongBot_Ultimate_Protected"
ScreenGui.ResetOnSpawn = false

local success, err = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = PlayerGui end

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 320, 0, 180)
KeyFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
KeyFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.ZIndex = 100
KeyFrame.Parent = ScreenGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 12)
KeyCorner.Parent = KeyFrame

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(255, 255, 255)
KeyStroke.Thickness = 2
KeyStroke.Parent = KeyFrame

local QuestionLabel = Instance.new("TextLabel")
QuestionLabel.Size = UDim2.new(1, -20, 0, 60)
QuestionLabel.Position = UDim2.new(0, 10, 0, 15)
QuestionLabel.BackgroundTransparency = 1
QuestionLabel.Text = "Thằng Trường là đàn em của\nAnh Vàn dz số 1 thgioi phải không!?"
QuestionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
QuestionLabel.Font = Enum.Font.SourceSansBold
QuestionLabel.TextSize = 16
QuestionLabel.ZIndex = 101
QuestionLabel.Parent = KeyFrame

local CorrectBtn = Instance.new("TextButton")
CorrectBtn.Size = UDim2.new(0, 135, 0, 40)
CorrectBtn.Position = UDim2.new(0, 15, 0, 95)
CorrectBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
CorrectBtn.Text = "Đúng rồi t là đàn e m"
CorrectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CorrectBtn.Font = Enum.Font.SourceSansBold
CorrectBtn.TextSize = 13
CorrectBtn.ZIndex = 101
CorrectBtn.Parent = KeyFrame

local CorrectCorner = Instance.new("UICorner")
CorrectCorner.CornerRadius = UDim.new(0, 8)
CorrectCorner.Parent = CorrectBtn

local WrongBtn = Instance.new("TextButton")
WrongBtn.Size = UDim2.new(0, 135, 0, 40)
WrongBtn.Position = UDim2.new(0, 170, 0, 95)
WrongBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
WrongBtn.Text = "cak m đàn e t"
WrongBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WrongBtn.Font = Enum.Font.SourceSansBold
WrongBtn.TextSize = 13
WrongBtn.ZIndex = 101
WrongBtn.Parent = KeyFrame

local WrongCorner = Instance.new("UICorner")
WrongCorner.CornerRadius = UDim.new(0, 8)
WrongCorner.Parent = WrongBtn

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 310)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 10
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 100, 0)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 35, 0, 35)
ToggleMenuBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
ToggleMenuBtn.Text = "T"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuBtn.Font = Enum.Font.SourceSansBold
ToggleMenuBtn.TextSize = 18
ToggleMenuBtn.ZIndex = 50
ToggleMenuBtn.Visible = false
ToggleMenuBtn.Active = true
ToggleMenuBtn.Draggable = true
ToggleMenuBtn.Parent = ScreenGui

local TCorner = Instance.new("UICorner")
TCorner.CornerRadius = UDim.new(1, 0)
TCorner.Parent = ToggleMenuBtn

local TStroke = Instance.new("UIStroke")
TStroke.Color = Color3.fromRGB(255, 255, 255)
TStroke.Thickness = 1
TStroke.Parent = ToggleMenuBtn

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(0.4, 0, 0, 30)
MenuTitle.Position = UDim2.new(0.3, 0, 0, 35)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "TRƯỜNG BOT"
MenuTitle.TextColor3 = Color3.fromRGB(255, 100, 0)
MenuTitle.Font = Enum.Font.SourceSansBold
MenuTitle.TextSize = 16
MenuTitle.ZIndex = 11
MenuTitle.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 35)
CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
CloseBtn.Text = "-"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.ZIndex = 12
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleMenuBtn.Visible = true
end)

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleMenuBtn.Visible = false
end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 0)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 11
TabBar.Parent = MainFrame

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 12)
TabBarCorner.Parent = TabBar

local function createTabBtn(name, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, 0, 1, 0)
    btn.Position = UDim2.new(xPos, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.ZIndex = 12
    btn.Parent = TabBar
    return btn
end

local Tab1Btn = createTabBtn("CHÍNH", 0)
local Tab2Btn = createTabBtn("NHÂN VẬT", 0.33)
local Tab3Btn = createTabBtn("VUI VẺ", 0.66)

local function createTabContainer()
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -75)
    container.Position = UDim2.new(0, 10, 0, 68)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ZIndex = 11
    container.ScrollBarThickness = 3
    container.CanvasSize = UDim2.new(0, 0, 0, 560)
    container.Visible = false
    container.Parent = MainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container
    
    return container
end

local Tab1Frame = createTabContainer()
local Tab2Frame = createTabContainer()
local Tab3Frame = createTabContainer()

local function switchTab(activeBtn, activeFrame)
    Tab1Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Tab2Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Tab3Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    
    Tab1Frame.Visible = false
    Tab2Frame.Visible = false
    Tab3Frame.Visible = false
    
    activeBtn.TextColor3 = Color3.fromRGB(255, 100, 0)
    activeFrame.Visible = true
end

Tab1Btn.MouseButton1Click:Connect(function() switchTab(Tab1Btn, Tab1Frame) end)
Tab2Btn.MouseButton1Click:Connect(function() switchTab(Tab2Btn, Tab2Frame) end)
Tab3Btn.MouseButton1Click:Connect(function() switchTab(Tab3Btn, Tab3Frame) end)
switchTab(Tab1Btn, Tab1Frame)

local function createToggle(parent, text, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.ZIndex = 12
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 12
    label.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 22)
    btn.Position = UDim2.new(1, -55, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.ZIndex = 13
    btn.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.Text = "ON"
            btn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        else
            btn.Text = "OFF"
            btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        end
        callback(active)
    end)
    return container
end

local function createSlider(parent, text, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.ZIndex = 12
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 12
    label.Parent = container
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -10, 0, 6)
    bar.Position = UDim2.new(0, 5, 0, 25)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bar.ZIndex = 12
    bar.Parent = container
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar
    
    local slideBtn = Instance.new("TextButton")
    slideBtn.Size = UDim2.new(0, 14, 0, 14)
    slideBtn.Position = UDim2.new((default - min)/(max - min), -7, -0.5, -1)
    slideBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slideBtn.Text = ""
    slideBtn.ZIndex = 13
    slideBtn.Parent = bar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = slideBtn
    
    local sliding = false
    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.round(min + (percentage * (max - min)))
        label.Text = text .. ": " .. tostring(val)
        slideBtn.Position = UDim2.new(percentage, -7, -0.5, -1)
        callback(val)
    end
    
    slideBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
end

-- --- THUẬT TOÁN RAYCAST KIỂM TRA TƯỜNG (WALL CHECK) CHUẨN XÁC ---
local function IsVisible(targetCharacter, targetHead)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local origin = camera.CFrame.Position
    local destination = targetHead.Position
    local direction = destination - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char, targetCharacter}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    
    if not raycastResult then
        return true
    end
    return false
end

local function optimizeInstance(v)
    if v:IsA("BasePart") and not v:IsA("Terrain") then
        if not SystemState.OriginalMaterials[v] then
            SystemState.OriginalMaterials[v] = {Material = v.Material, Color = v.Color}
        end
        v.Material = Enum.Material.SmoothPlastic
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("Explosion") then
        v.Visible = false
    end
end

local function restoreInstance(v)
    if v:IsA("BasePart") and not v:IsA("Terrain") then
        local original = SystemState.OriginalMaterials[v]
        if original then
            v.Material = original.Material
        end
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 0
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = true
    end
end

createToggle(Tab1Frame, "Aimbot (Ghim Tâm Đầu)", function(state)
    Config.AimbotEnabled = state
    if not state then FOVCircle.Visible = false end
end)

createSlider(Tab1Frame, "Kích thước FOV (1-300)", 1, 300, 100, function(val)
    Config.FOVRadius = val
end)

createToggle(Tab1Frame, "Hitbox (Tăng kích thước)", function(state)
    Config.HitboxEnabled = state
    if not state then
        for hrp, data in pairs(SystemState.OriginalHitboxData) do
            if hrp and hrp.Parent then
                hrp.Size = data.Size
                hrp.Transparency = data.Transparency
                hrp.CanCollide = data.CanCollide
            end
        end
        table.clear(SystemState.OriginalHitboxData)
    end
end)

createSlider(Tab1Frame, "Kích thước Hitbox (1-300)", 1, 300, 5, function(val)
    Config.HitboxSize = val
end)

createToggle(Tab1Frame, "Noclip (Xuyên tường)", function(state)
    Config.NoclipEnabled = state
    if state then
        SystemState.NoclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char and Config.NoclipEnabled then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if SystemState.NoclipConnection then
            SystemState.NoclipConnection:Disconnect()
            SystemState.NoclipConnection = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end)

createToggle(Tab1Frame, "Giảm Lag (Fix Lag)", function(state)
    Config.FixLagEnabled = state
    if state then
        Lighting.GlobalShadows = false
        for _, v in ipairs(Workspace:GetDescendants()) do
            optimizeInstance(v)
        end
        SystemState.LagFixConnection = Workspace.DescendantAdded:Connect(function(v)
            if Config.FixLagEnabled then
                optimizeInstance(v)
            end
        end)
    else
        if SystemState.LagFixConnection then
            SystemState.LagFixConnection:Disconnect()
            SystemState.LagFixConnection = nil
        end
        Lighting.GlobalShadows = true
        for _, v in ipairs(Workspace:GetDescendants()) do
            restoreInstance(v)
        end
        table.clear(SystemState.OriginalMaterials)
    end
end)

createToggle(Tab2Frame, "Bật tốc độ chạy", function(state)
    Config.WalkSpeedEnabled = state
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = state and Config.WalkSpeedValue or 16
    end
end)

createSlider(Tab2Frame, "Tốc độ chạy (1-1000)", 1, 1000, 16, function(val)
    Config.WalkSpeedValue = val
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and Config.WalkSpeedEnabled then
        hum.WalkSpeed = val
    end
end)

createToggle(Tab2Frame, "Bật nhảy cao", function(state)
    Config.JumpPowerEnabled = state
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = state and Config.JumpPowerValue or 50
    end
end)

createSlider(Tab2Frame, "Độ cao nhảy (1-300)", 1, 300, 50, function(val)
    Config.JumpPowerValue = val
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and Config.JumpPowerEnabled then
        hum.JumpPower = val
    end
end)

createToggle(Tab2Frame, "Nhảy vô hạn", function(state)
    Config.InfiniteJumpEnabled = state
    if state then
        SystemState.InfJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and Config.InfiniteJumpEnabled then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if SystemState.InfJumpConnection then
            SystemState.InfJumpConnection:Disconnect()
            SystemState.InfJumpConnection = nil
        end
    end
end)

createToggle(Tab2Frame, "Esp người chơi", function(state)
    Config.ESPNameEnabled = state
end)

createToggle(Tab2Frame, "Esp box", function(state)
    Config.ESPBoxEnabled = state
end)

createToggle(Tab3Frame, "Tạo quả cầu bảo vệ", function(state)
    Config.SpherePetEnabled = state
    if state then
        local p = Instance.new("Part")
        p.Size = Vector3.new(2, 2, 2)
        p.Shape = Enum.PartType.Ball
        p.Material = Enum.Material.Neon
        p.CanCollide = false
        p.Anchored = true
        p.Parent = Workspace
        SystemState.PetInstance = p

        local b = Instance.new("BillboardGui")
        b.Size = UDim2.new(0, 150, 0, 50)
        b.StudsOffset = Vector3.new(0, 2, 0)
        b.AlwaysOnTop = true
        b.Parent = p
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "bố vàn đây"
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.Font = Enum.Font.SourceSansBold
        text.TextSize = 16
        text.Parent = b
        
        task.spawn(function()
            local hue = 0
            while Config.SpherePetEnabled and p and p.Parent do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hue = (hue + 1) % 360
                    local rainbowColor = Color3.fromHSV(hue / 360, 1, 1)
                    p.Color = rainbowColor
                    text.TextColor3 = rainbowColor
                    
                    local angle = tick() * 3
                    local targetPos = hrp.Position + Vector3.new(math.cos(angle) * 5, 3, math.sin(angle) * 5)
                    p.Position = p.Position:Lerp(targetPos, 0.2)
                end
                task.wait()
            end
            if p then p:Destroy() end
        end)
    else
        if SystemState.PetInstance then
            SystemState.PetInstance:Destroy()
            SystemState.PetInstance = nil
        end
    end
end)

createToggle(Tab3Frame, "Chạy vòng tròn 7 màu", function(state)
    Config.RainbowRunEnabled = state
    if state then
        SystemState.RainbowRunConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 then
                local p = Instance.new("Part")
                p.Size = Vector3.new(1, 0.2, 1)
                p.Transparency = 0.4
                p.Anchored = true
                p.CanCollide = false
                p.Material = Enum.Material.Neon
                p.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
                p.Position = char.PrimaryPart.Position - Vector3.new(0, 2.8, 0)
                p.Parent = Workspace
                game:GetService("Debris"):AddItem(p, 0.6)
            end
        end)
    else
        if SystemState.RainbowRunConnection then
            SystemState.RainbowRunConnection:Disconnect()
            SystemState.RainbowRunConnection = nil
        end
    end
end)

-- // KHU VỰC CHỨC NĂNG DỊCH CHUYỂN NGƯỜI CHƠI (TAB CHÍNH - TAB 1) //
local TeleportContainer = Instance.new("Frame")
TeleportContainer.Size = UDim2.new(1, 0, 0, 80)
TeleportContainer.BackgroundTransparency = 1
TeleportContainer.ZIndex = 12
TeleportContainer.Parent = Tab1Frame

local TeleportLabel = Instance.new("TextLabel")
TeleportLabel.Size = UDim2.new(1, 0, 0, 20)
TeleportLabel.BackgroundTransparency = 1
TeleportLabel.Text = "Dịch chuyển đến người chơi"
TeleportLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
TeleportLabel.Font = Enum.Font.SourceSansBold
TeleportLabel.TextSize = 13
TeleportLabel.TextXAlignment = Enum.TextXAlignment.Left
TeleportLabel.ZIndex = 12
TeleportLabel.Parent = TeleportContainer

local PlayerDropdown = Instance.new("TextButton")
PlayerDropdown.Size = UDim2.new(1, -10, 0, 25)
PlayerDropdown.Position = UDim2.new(0, 5, 0, 25)
PlayerDropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
PlayerDropdown.Text = "Chọn người chơi..."
PlayerDropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
PlayerDropdown.Font = Enum.Font.SourceSansBold
PlayerDropdown.TextSize = 12
PlayerDropdown.ZIndex = 13
PlayerDropdown.Parent = TeleportContainer

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 6)
DropdownCorner.Parent = PlayerDropdown

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(1, -10, 0, 100)
DropdownList.Position = UDim2.new(0, 5, 0, 52)
DropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
DropdownList.ZIndex = 15
DropdownList.Visible = false
DropdownList.ScrollBarThickness = 3
DropdownList.Parent = TeleportContainer

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.SortOrder = Enum.SortOrder.Name
DropdownLayout.Parent = DropdownList

local function updatePlayerList()
    for _, child in ipairs(DropdownList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local players = Players:GetPlayers()
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, #players * 25)
    
    for _, player in ipairs(players) do
        if player ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 25)
            pBtn.BackgroundTransparency = 1
            pBtn.Text = player.DisplayName .. " (@" .. player.Name .. ")"
            pBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            pBtn.Font = Enum.Font.SourceSansBold
            pBtn.TextSize = 11
            pBtn.ZIndex = 16
            pBtn.Parent = DropdownList
            
            pBtn.MouseButton1Click:Connect(function()
                PlayerDropdown.Text = player.DisplayName
                DropdownList.Visible = false
                
                local targetChar = player.Character
                local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                if targetHrp and myHrp then
                    myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
                end
            end)
        end
    end
end

PlayerDropdown.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
end)

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

CorrectBtn.MouseButton1Click:Connect(function()
    KeyFrame.Visible = false
    MainFrame.Visible = true
end)

WrongBtn.MouseButton1Click:Connect(function()
    LocalPlayer:Kick("Chọn sai rồi em trai, nạp lần đầu để chọn lại!")
end)

-- --- THUẬT TOÁN AIMBOT: CHỐNG GHIM NGƯỜI CHẾT + MƯỢT MÀ TỪ MOUSE LOCATION ---
local function getClosestPlayerToMouse()
    local target = nil
    local maxDistance = Config.FOVRadius
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        -- Kiểm tra không phải bản thân và lọc đồng đội
        if player ~= LocalPlayer and (not Config.TeamCheckEnabled or player.Team ~= LocalPlayer.Team) then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local head = char:FindFirstChild("Head")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                
                -- ĐIỀU KIỆN QUAN TRỌNG: Phải còn sống (Health > 0) và không ở trạng thái chết (Dead)
                if hum and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead and head and hrp then
                    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                    
                    if onScreen then
                        local distanceToPlayer = (camera.CFrame.Position - head.Position).Magnitude
                        -- Kiểm tra tầm xa của cấu hình aimbot
                        if distanceToPlayer <= Config.Distance then
                            -- Kiểm tra xuyên tường bằng Raycast nâng cao
                            local visible = true
                            if Config.WallCheckEnabled then
                                visible = IsVisible(char, head)
                            end
                            
                            if visible then
                                -- Tính khoảng cách từ Đầu mục tiêu đến điểm chạm/chuột thực tế
                                local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                if mouseDist < maxDistance then
                                    maxDistance = mouseDist
                                    target = head
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end

local function processAimbot()
    if not Config.AimbotEnabled then return end
    
    local targetPart = getClosestPlayerToMouse()
    if targetPart then
        local currentCFrame = camera.CFrame
        -- Tạo góc nhìn hướng trực diện tới Đầu mục tiêu
        local targetCFrame = CFrame.new(currentCFrame.Position, targetPart.Position)
        
        -- Ghim tâm mượt mà (Lerp) theo cấu hình mượt Smoothness để tránh bị giật khung hình
        camera.CFrame = currentCFrame:Lerp(targetCFrame, Config.Smoothness)
    end
end

local function processHitbox()
    if not Config.HitboxEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (not player.Team or player.Team ~= LocalPlayer.Team) and player.Character then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                if not SystemState.OriginalHitboxData[hrp] then
                    SystemState.OriginalHitboxData[hrp] = {
                        Size = hrp.Size,
                        Transparency = hrp.Transparency,
                        CanCollide = hrp.CanCollide
                    }
                end
                hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                hrp.Transparency = Config.HitboxTransparency
                hrp.CanCollide = false
            end
        end
    end
end

local function clearESP(player)
    if player.Character then
        local oldEsp = player.Character:FindFirstChild("ESP_TRUONGBOT")
        if oldEsp then oldEsp:Destroy() end
    end
end

local function processESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                
                if hum and hum.Health > 0 and hrp then
                    local espFolder = char:FindFirstChild("ESP_TRUONGBOT")
                    if not espFolder then
                        espFolder = Instance.new("Folder")
                        espFolder.Name = "ESP_TRUONGBOT"
                        espFolder.Parent = char
                    end
                    
                    local nameESP = espFolder:FindFirstChild("NameESP")
                    if Config.ESPNameEnabled then
                        if not nameESP then
                            nameESP = Instance.new("BillboardGui")
                            nameESP.Name = "NameESP"
                            nameESP.Size = UDim2.new(0, 200, 0, 50)
                            nameESP.AlwaysOnTop = true
                            nameESP.StudsOffset = Vector3.new(0, 3, 0)
                            nameESP.Adornee = hrp
                            nameESP.Parent = espFolder
                            
                            local label = Instance.new("TextLabel")
                            label.Name = "Label"
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.fromRGB(255, 255, 255)
                            label.TextStrokeTransparency = 0
                            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            label.Font = Enum.Font.SourceSansBold
                            label.TextSize = 13
                            label.Parent = nameESP
                        end
                        local distance = math.round((camera.CFrame.Position - hrp.Position).Magnitude)
                        nameESP.Label.Text = player.DisplayName .. " (@" .. player.Name .. ") \n[" .. distance .. "m] [" .. math.round(hum.Health) .. " HP]"
                    else
                        if nameESP then nameESP:Destroy() end
                    end
                    
                    local boxESP = espFolder:FindFirstChild("BoxESP")
                    if Config.ESPBoxEnabled then
                        if not boxESP then
                            boxESP = Instance.new("BoxHandleAdornment")
                            boxESP.Name = "BoxESP"
                            boxESP.AlwaysOnTop = true
                            boxESP.ZIndex = 5
                            boxESP.Adornee = char
                            boxESP.Color3 = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255, 100, 0)
                            boxESP.Transparency = 0.65
                            boxESP.Parent = espFolder
                        end
                        boxESP.Size = char:GetExtentsSize() + Vector3.new(0.3, 0.3, 0.3)
                    else
                        if boxESP then boxESP:Destroy() end
                    end
                else
                    clearESP(player)
                end
            end
        end
    end
end

Players.PlayerRemoving:Connect(clearESP)

-- VÒNG LẶP RENDER CHÍNH MƯỢT MÀ TỐI ƯU
RunService.RenderStepped:Connect(function()
    processAimbot()
    updateFOV()
    processHitbox()
    processESP()
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if Config.WalkSpeedEnabled then
        hum.WalkSpeed = Config.WalkSpeedValue
    end
    if Config.JumpPowerEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = Config.JumpPowerValue
    end
end)
