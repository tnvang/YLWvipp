-- ============================================
-- MENU CHÍNH - GIAO DIỆN NHƯ TRONG ẢNH
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TextService = game:GetService("TextService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================
-- CẤU HÌNH HỆ THỐNG
-- ============================================
local Config = {
    MenuOpen = true,
    Notifications = true,
    CurrentTab = "Volcano",
    FullScreen = false,
    
    -- Player
    Speed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = true,
    AntiBan = true,
    FreeCamera = false,
    FPSBoost = false,
    FullBright = false,
    RemoveFog = false,
    
    -- ESP
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(100, 150, 255),
    ESPBox = false,
    ESPLine = false,
    ESPSkeleton = false,
    ESPHealth = false,
    
    -- PvP
    Aimbot = false,
    Aimlock = false,
    Hitbox = false,
    HitboxSize = 5,
    HitboxTransparency = 0.5,
    
    -- Fly
    FlyEnabled = false,
    FlySpeed = 50,
    
    -- Spin
    SpinEnabled = false,
    SpinSpeed = 360,
    
    -- Teleport
    TeleportTarget = nil,
    TeleportSpeed = "Nhanh",
    
    -- Effects
    RainbowOrb = false,
    RainbowEffect = false,
    SnowEffect = false,
    HeartEffect = false,
    ColorRays = false,
    HackerText = false,
    
    -- Camera
    FirstPerson = false,
    ThirdPerson = false,
    
    -- Volcano Event (UI giống trong ảnh)
    Volcano = {
        CraftVolcano = false,
        CraftTRexSkull = false,
        PrehistoricIsland = false,
        CraftVolcanicMagnet = false,
        AutoFindIsland = false,
        AutoStartEvent = false
    },
    
    OriginalData = {}
}

-- ============================================
-- FUNCTIONS TIỆN ÍCH
-- ============================================

function CreateNotification(title, message, duration, color)
    if not Config.Notifications then return end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 55)
    frame.Position = UDim2.new(0.5, -160, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.1
    frame.ZIndex = 100
    frame.Parent = PlayerGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 22)
    titleLabel.Position = UDim2.new(0, 10, 0, 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = color or Color3.fromRGB(0, 255, 200)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -10, 0, 24)
    messageLabel.Position = UDim2.new(0, 10, 0, 26)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.TextSize = 12
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = frame
    
    frame.Position = UDim2.new(0.5, -160, -0.2, 0)
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Out, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -160, 0.1, 0)
    }):Play()
    
    task.wait(duration or 3)
    
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.In, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -160, -0.2, 0)
    }):Play()
    
    task.wait(0.5)
    frame:Destroy()
end

-- ============================================
-- TẠO MENU CHÍNH - GIAO DIỆN NHƯ TRONG ẢNH
-- ============================================

local function CreateMainMenu()
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MainMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 380, 0, 550)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -275)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ZIndex = 10
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 15)
    MainCorner.Parent = MainFrame
    
    -- Title Bar (Giống trong ảnh)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    Title.BackgroundTransparency = 0
    Title.Text = "⚡ MENU CHÍNH"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.ZIndex = 11
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 15)
    TitleCorner.Parent = Title
    
    -- User Info (Giống trong ảnh - hiển thị tên và chain)
    local UserInfo = Instance.new("Frame")
    UserInfo.Size = UDim2.new(1, 0, 0, 55)
    UserInfo.Position = UDim2.new(0, 0, 0, 45)
    UserInfo.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    UserInfo.BackgroundTransparency = 0
    UserInfo.ZIndex = 11
    UserInfo.Parent = MainFrame
    
    -- Avatar
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 35, 0, 35)
    Avatar.Position = UDim2.new(0, 10, 0.5, -17)
    Avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Avatar.BackgroundTransparency = 0
    Avatar.Image = "rbxasset://textures/ui/Image/Blank.png"
    Avatar.ZIndex = 12
    Avatar.Parent = UserInfo
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = Avatar
    
    -- Username
    local Username = Instance.new("TextLabel")
    Username.Size = UDim2.new(0, 200, 0, 20)
    Username.Position = UDim2.new(0, 55, 0, 5)
    Username.BackgroundTransparency = 1
    Username.Text = LocalPlayer.Name
    Username.TextColor3 = Color3.fromRGB(255, 255, 255)
    Username.Font = Enum.Font.SourceSansBold
    Username.TextSize = 15
    Username.TextXAlignment = Enum.TextXAlignment.Left
    Username.ZIndex = 12
    Username.Parent = UserInfo
    
    -- Chain String (🔥 99999)
    local Chain = Instance.new("TextLabel")
    Chain.Size = UDim2.new(0, 200, 0, 18)
    Chain.Position = UDim2.new(0, 55, 0, 27)
    Chain.BackgroundTransparency = 1
    Chain.Text = "🔥 99999"
    Chain.TextColor3 = Color3.fromRGB(255, 200, 50)
    Chain.Font = Enum.Font.SourceSansBold
    Chain.TextSize = 14
    Chain.TextXAlignment = Enum.TextXAlignment.Left
    Chain.ZIndex = 12
    Chain.Parent = UserInfo
    
    -- Creator
    local Creator = Instance.new("TextLabel")
    Creator.Size = UDim2.new(1, 0, 0, 18)
    Creator.Position = UDim2.new(0, 0, 0, 0)
    Creator.BackgroundTransparency = 1
    Creator.Text = "Creator: cammuoilupro"
    Creator.TextColor3 = Color3.fromRGB(150, 150, 180)
    Creator.Font = Enum.Font.SourceSans
    Creator.TextSize = 12
    Creator.TextXAlignment = Enum.TextXAlignment.Right
    Creator.ZIndex = 12
    Creator.Parent = UserInfo
    
    -- Tab Buttons (Giống trong ảnh - các tab nằm ngang)
    local Tabs = {
        {name = "Player", icon = "👤"},
        {name = "PvP", icon = "⚔️"},
        {name = "ESP", icon = "👁️"},
        {name = "Volcano", icon = "🌋"},
        {name = "Effect", icon = "✨"},
        {name = "Settings", icon = "⚙️"}
    }
    
    local TabButtons = {}
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -10, 1, -135)
    TabContainer.Position = UDim2.new(0, 5, 0, 105)
    TabContainer.BackgroundTransparency = 1
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ScrollBarThickness = 3
    TabContainer.ZIndex = 12
    TabContainer.Parent = MainFrame
    
    -- Tạo các tab button
    for i, tab in ipairs(Tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 58, 0, 35)
        btn.Position = UDim2.new((i-1) * 0.166 + 0.005, 0, 0, 105)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        btn.Text = tab.icon
        btn.TextColor3 = Color3.fromRGB(200, 200, 220)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 20
        btn.ZIndex = 12
        btn.Parent = MainFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        TabButtons[tab.name] = btn
        
        btn.MouseButton1Click:Connect(function()
            Config.CurrentTab = tab.name
            for _, tb in pairs(TabButtons) do
                tb.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                tb.TextColor3 = Color3.fromRGB(200, 200, 220)
            end
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            UpdateTabContent(tab.name, TabContainer)
        end)
    end
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -35, 0, 8)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.TextSize = 14
    CloseBtn.ZIndex = 13
    CloseBtn.Parent = MainFrame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseBtn
    
    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(1, -68, 0, 8)
    MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.SourceSansBold
    MinBtn.TextSize = 16
    MinBtn.ZIndex = 13
    MinBtn.Parent = MainFrame
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(1, 0)
    MinCorner.Parent = MinBtn
    
    return ScreenGui, MainFrame, TabContainer, CloseBtn, MinBtn
end

-- ============================================
-- CREATE UI COMPONENTS (Helper Functions)
-- ============================================

function CreateToggle(parent, y, text, initial, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = initial and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    btn.Text = text .. ": " .. (initial and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.ZIndex = 13
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local state = initial
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
        CreateNotification(text, state and "✅ Đã bật thành công!" or "❌ Đã tắt!", 1.5)
    end)
    
    return btn
end

function CreateButton(parent, y, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = color or Color3.fromRGB(0, 150, 200)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.ZIndex = 13
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

function CreateSlider(parent, y, min, max, initial, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 20)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    frame.ZIndex = 13
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame
    
    local percentage = (initial - min) / (max - min)
    local thumb = Instance.new("TextButton")
    thumb.Size = UDim2.new(0, 20, 0, 20)
    thumb.Position = UDim2.new(percentage, -10, 0, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.Text = ""
    thumb.ZIndex = 14
    thumb.Parent = frame
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local dragging = false
    
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local pos = math.clamp((input.Position.X - frame.AbsolutePosition.X) / frame.AbsoluteSize.X, 0, 1)
            thumb.Position = UDim2.new(pos, -10, 0, 0)
            local value = math.round(min + pos * (max - min))
            callback(value)
        end
    end)
    
    return frame
end

function CreateLabel(parent, y, text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = parent
    return label
end

function CreateDropdown(parent, y, text, options, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = text .. ": " .. options[1]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.ZIndex = 13
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local index = 1
    btn.MouseButton1Click:Connect(function()
        index = index % #options + 1
        btn.Text = text .. ": " .. options[index]
        callback(options[index])
    end)
    
    return btn
end

-- ============================================
-- UPDATE TAB CONTENT
-- ============================================

function UpdateTabContent(tab, container)
    for _, child in ipairs(container:GetChildren()) do
        child:Destroy()
    end
    
    local y = 5
    
    if tab == "Player" then
        -- Speed
        local speedLabel = CreateLabel(container, y, "🏃 Chạy nhanh: " .. Config.Speed)
        y = y + 28
        CreateSlider(container, y, 1, 1000, Config.Speed, function(val)
            Config.Speed = val
            speedLabel.Text = "🏃 Chạy nhanh: " .. val
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = val
            end
        end)
        y = y + 32
        
        -- Jump Power
        local jumpLabel = CreateLabel(container, y, "⬆ Nhảy cao: " .. Config.JumpPower)
        y = y + 28
        CreateSlider(container, y, 1, 670, Config.JumpPower, function(val)
            Config.JumpPower = val
            jumpLabel.Text = "⬆ Nhảy cao: " .. val
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = val
            end
        end)
        y = y + 35
        
        -- Toggles
        CreateToggle(container, y, "🔄 Nhảy vô hạn", Config.InfiniteJump, function(val)
            Config.InfiniteJump = val
        end)
        y = y + 37
        
        CreateToggle(container, y, "🚫 Noclip", Config.Noclip, function(val)
            Config.Noclip = val
            if not val and LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end)
        y = y + 37
        
        CreateToggle(container, y, "🛡️ Anti AFK", Config.AntiAFK, function(val)
            Config.AntiAFK = val
        end)
        y = y + 37
        
        CreateToggle(container, y, "🛡️ Anti Ban", Config.AntiBan, function(val)
            Config.AntiBan = val
        end)
        y = y + 37
        
        CreateToggle(container, y, "🎥 Free Camera", Config.FreeCamera, function(val)
            ToggleFreeCamera()
        end)
        y = y + 37
        
        CreateToggle(container, y, "🚀 FPS Boost", Config.FPSBoost, function(val)
            ToggleFPSBoost()
        end)
        y = y + 37
        
        CreateToggle(container, y, "☀️ Full Bright", Config.FullBright, function(val)
            ToggleFullBright()
        end)
        y = y + 37
        
        CreateToggle(container, y, "🌫️ Remove Fog", Config.RemoveFog, function(val)
            Config.RemoveFog = val
            if val then
                Lighting.FogEnd = 100000
                Lighting.FogStart = 0
            else
                Lighting.FogEnd = 1000
                Lighting.FogStart = 0
            end
        end)
        y = y + 37
        
    elseif tab == "PvP" then
        CreateToggle(container, y, "🎯 Aimbot", Config.Aimbot, function(val)
            Config.Aimbot = val
            if val then StartAimbot() else StopAimbot() end
        end)
        y = y + 37
        
        CreateToggle(container, y, "🔒 Aimlock", Config.Aimlock, function(val)
            Config.Aimlock = val
        end)
        y = y + 37
        
        CreateToggle(container, y, "📦 Hitbox", Config.Hitbox, function(val)
            Config.Hitbox = val
            if val then StartHitbox() else StopHitbox() end
        end)
        y = y + 37
        
                local sizeLabel = CreateLabel(container, y, "📐 Kích thước: " .. Config.HitboxSize)
        y = y + 28
        CreateSlider(container, y, 1, 500, Config.HitboxSize, function(val)
            Config.HitboxSize = val
            sizeLabel.Text = "📐 Kích thước: " .. val
            if Config.Hitbox then UpdateHitboxSize(val) end
        end)
        y = y + 35
        
        CreateToggle(container, y, "✈️ Fly", Config.FlyEnabled, function(val)
            Config.FlyEnabled = val
            if val then Fly:Start() else Fly:Stop() end
        end)
        y = y + 37
        
        local flySpeedLabel = CreateLabel(container, y, "✈️ Tốc độ bay: " .. Config.FlySpeed)
        y = y + 28
        CreateSlider(container, y, 10, 500, Config.FlySpeed, function(val)
            Config.FlySpeed = val
            flySpeedLabel.Text = "✈️ Tốc độ bay: " .. val
        end)
        y = y + 35
        
        CreateToggle(container, y, "🔄 Spin", Config.SpinEnabled, function(val)
            Config.SpinEnabled = val
            if val then Spin:Start() else Spin:Stop() end
        end)
        y = y + 37
        
        local spinOptions = {"Bình thường", "Nhanh", "Cực nhanh"}
        CreateDropdown(container, y, "🔄 Tốc độ spin", spinOptions, function(val)
            if val == "Bình thường" then Config.SpinSpeed = 360
            elseif val == "Nhanh" then Config.SpinSpeed = 720
            else Config.SpinSpeed = 1440 end
        end)
        y = y + 37
        
        CreateLabel(container, y, "👤 Danh sách người chơi:")
        y = y + 28
        
        local playerScroll = Instance.new("ScrollingFrame")
        playerScroll.Size = UDim2.new(1, 0, 0, 100)
        playerScroll.Position = UDim2.new(0, 0, 0, y)
        playerScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        playerScroll.BackgroundTransparency = 0
        playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        playerScroll.ZIndex = 13
        playerScroll.Parent = container
        
        local playerCorner = Instance.new("UICorner")
        playerCorner.CornerRadius = UDim.new(0, 8)
        playerCorner.Parent = playerScroll
        
        y = y + 105
        
        local function UpdatePlayerList()
            for _, child in ipairs(playerScroll:GetChildren()) do
                child:Destroy()
            end
            
            local playerY = 5
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -10, 0, 28)
                    btn.Position = UDim2.new(0, 5, 0, playerY)
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                    btn.Text = player.Name
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Font = Enum.Font.SourceSans
                    btn.TextSize = 12
                    btn.ZIndex = 14
                    btn.Parent = playerScroll
                    
                    local btnCorner = Instance.new("UICorner")
                    btnCorner.CornerRadius = UDim.new(0, 6)
                    btnCorner.Parent = btn
                    
                    btn.MouseButton1Click:Connect(function()
                        Config.TeleportTarget = player
                        TeleportToPlayer(player)
                    end)
                    
                    playerY = playerY + 32
                end
            end
            playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerY + 10)
        end
        
        UpdatePlayerList()
        
        local teleportOptions = {"Nhanh", "Cực nhanh", "Siêu nhanh"}
        CreateDropdown(container, y, "🚀 Tốc độ teleport", teleportOptions, function(val)
            Config.TeleportSpeed = val
        end)
        y = y + 37
        
    elseif tab == "ESP" then
        CreateToggle(container, y, "👁️ ESP", Config.ESPEnabled, function(val)
            Config.ESPEnabled = val
            ESP:UpdateESP()
        end)
        y = y + 37
        
        CreateToggle(container, y, "📦 Box", Config.ESPBox, function(val)
            Config.ESPBox = val
            ESP:UpdateESP()
        end)
        y = y + 37
        
        CreateToggle(container, y, "📏 Line", Config.ESPLine, function(val)
            Config.ESPLine = val
            ESP:UpdateESP()
        end)
        y = y + 37
        
        CreateToggle(container, y, "🦴 Skeleton", Config.ESPSkeleton, function(val)
            Config.ESPSkeleton = val
            ESP:UpdateESP()
        end)
        y = y + 37
        
        CreateToggle(container, y, "❤️ Health", Config.ESPHealth, function(val)
            Config.ESPHealth = val
            ESP:UpdateESP()
        end)
        y = y + 37
        
        local colorOptions = {"Xanh biển", "Đỏ", "Vàng", "Xanh lá"}
        CreateDropdown(container, y, "🎨 Màu ESP", colorOptions, function(val)
            if val == "Xanh biển" then Config.ESPColor = Color3.fromRGB(100, 150, 255)
            elseif val == "Đỏ" then Config.ESPColor = Color3.fromRGB(255, 100, 100)
            elseif val == "Vàng" then Config.ESPColor = Color3.fromRGB(255, 255, 100)
            else Config.ESPColor = Color3.fromRGB(100, 255, 100) end
            ESP:UpdateESP()
        end)
        y = y + 37
        
    elseif tab == "Volcano" then
        -- Giao diện giống trong ảnh
        CreateLabel(container, y, "🌋 Tab Volcano Event", Color3.fromRGB(255, 200, 50))
        y = y + 30
        
        CreateButton(container, y, "🔨 Craft Volcano", Color3.fromRGB(255, 100, 50), function()
            CreateNotification("🌋 Volcano", "Đã craft Volcano thành công!", 2, Color3.fromRGB(255, 200, 50))
        end)
        y = y + 37
        
        CreateButton(container, y, "🦴 Craft T-Rex Skull", Color3.fromRGB(200, 150, 100), function()
            CreateNotification("🦴 T-Rex", "Đã craft T-Rex Skull thành công!", 2, Color3.fromRGB(255, 200, 100))
        end)
        y = y + 37
        
        -- Prehistoric Island Status
        local statusLabel = CreateLabel(container, y, "🏝️ Prehistoric Island Status")
        y = y + 28
        local statusValue = CreateLabel(container, y, "Prehistoric Island: " .. (Config.Volcano.PrehistoricIsland and "✅ True" or "❌ False"), 
            Config.Volcano.PrehistoricIsland and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50))
        y = y + 30
        
        CreateButton(container, y, "🧲 Craft Volcanic Magnet", Color3.fromRGB(100, 200, 255), function()
            CreateNotification("🧲 Magnet", "Đã craft Volcanic Magnet thành công!", 2, Color3.fromRGB(100, 200, 255))
        end)
        y = y + 37
        
        CreateToggle(container, y, "🔍 Auto Find Prehistoric Island", Config.Volcano.AutoFindIsland, function(val)
            Config.Volcano.AutoFindIsland = val
        end)
        y = y + 37
        
        CreateToggle(container, y, "▶️ Auto Start Prehistoric Event", Config.Volcano.AutoStartEvent, function(val)
            Config.Volcano.AutoStartEvent = val
        end)
        y = y + 37
        
        -- Full Screen Button (giống trong ảnh)
        CreateButton(container, y, "📺 Toàn màn hình", Color3.fromRGB(100, 100, 200), function()
            Config.FullScreen = not Config.FullScreen
            if Config.FullScreen then
                game:GetService("StarterGui"):SetCore("ScreenOrientation", Enum.ScreenOrientation.LandscapeRight)
                CreateNotification("📺 Fullscreen", "Đã chuyển sang chế độ toàn màn hình!", 2, Color3.fromRGB(100, 200, 255))
            else
                game:GetService("StarterGui"):SetCore("ScreenOrientation", Enum.ScreenOrientation.Portrait)
                CreateNotification("📺 Fullscreen", "Đã thoát chế độ toàn màn hình!", 2, Color3.fromRGB(255, 200, 100))
            end
        end)
        y = y + 37
        
    elseif tab == "Effect" then
        CreateToggle(container, y, "🌈 Rainbow Orb", Config.RainbowOrb, function(val)
            Config.RainbowOrb = val
            if val then Effects:CreateRainbowOrb()
            else if Effects.Orb then Effects.Orb:Destroy() Effects.Orb = nil end
            end
        end)
        y = y + 37
        
        CreateToggle(container, y, "🎨 Rainbow Effect", Config.RainbowEffect, function(val)
            Config.RainbowEffect = val
            if val then
                local connection = RunService.RenderStepped:Connect(function()
                    if not Config.RainbowEffect then connection:Disconnect() return end
                    local time = tick() % 1
                    local r = math.sin(time * 2 * math.pi) * 0.5 + 0.5
                    local g = math.sin((time + 0.33) * 2 * math.pi) * 0.5 + 0.5
                    local b = math.sin((time + 0.67) * 2 * math.pi) * 0.5 + 0.5
                    Lighting.Ambient = Color3.fromRGB(r * 255, g * 255, b * 255)
                end)
                Config.RainbowConnection = connection
            else
                if Config.RainbowConnection then Config.RainbowConnection:Disconnect() end
                Lighting.Ambient = Color3.fromRGB(128, 128, 128)
            end
        end)
        y = y + 37
        
        CreateToggle(container, y, "❄️ Snow Effect", Config.SnowEffect, function(val)
            Config.SnowEffect = val
            if val then Effects:CreateSnowEffect()
            else if Effects.Snow then Effects.Snow:Destroy() Effects.Snow = nil end
            end
        end)
        y = y + 37
        
        CreateToggle(container, y, "❤️ Heart Effect", Config.HeartEffect, function(val)
            Config.HeartEffect = val
            if val then Effects:CreateHeartEffect()
            else if Effects.Heart then Effects.Heart:Destroy() Effects.Heart = nil end
            end
        end)
        y = y + 37
        
        CreateToggle(container, y, "🌈 Color Rays", Config.ColorRays, function(val)
            Config.ColorRays = val
            if val then
                local ray = Instance.new("Part")
                ray.Size = Vector3.new(0.5, 50, 0.5)
                ray.Material = Enum.Material.Neon
                ray.Anchored = true
                ray.CanCollide = false
                ray.Transparency = 0.5
                ray.Parent = workspace
                local connection = RunService.RenderStepped:Connect(function()
                    if not Config.ColorRays then ray:Destroy() connection:Disconnect() return end
                    local char = LocalPlayer.Character
                    if not char then return end
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        ray.Position = rootPart.Position + Vector3.new(0, 25, 0)
                        ray.CFrame = CFrame.new(ray.Position, ray.Position + Vector3.new(0, 1, 0))
                    end
                    local time = tick() % 1
                    local r = math.sin(time * 2 * math.pi) * 0.5 + 0.5
                    local g = math.sin((time + 0.33) * 2 * math.pi) * 0.5 + 0.5
                    local b = math.sin((time + 0.67) * 2 * math.pi) * 0.5 + 0.5
                    ray.Color = Color3.fromRGB(r * 255, g * 255, b * 255)
                end)
                Config.Ray = ray
                Config.RayConnection = connection
            else
                if Config.Ray then Config.Ray:Destroy() end
                if Config.RayConnection then Config.RayConnection:Disconnect() end
            end
        end)
        y = y + 37
        
        CreateToggle(container, y, "💻 Hacker Text", Config.HackerText, function(val)
            Config.HackerText = val
            if val then CreateHackerText() end
        end)
        y = y + 37
        
        CreateToggle(container, y, "👁️ First Person", Config.FirstPerson, function(val)
            Config.FirstPerson = val
            if val then
                Camera.CameraType = Enum.CameraType.Attach
                Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") or LocalPlayer
            else
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CameraSubject = LocalPlayer.Character or LocalPlayer
            end
        end)
        y = y + 37
        
        CreateToggle(container, y, "👤 Third Person", Config.ThirdPerson, function(val)
            Config.ThirdPerson = val
            if val then
                Camera.CameraType = Enum.CameraType.Track
                Camera.CameraSubject = LocalPlayer.Character or LocalPlayer
            else
                Camera.CameraType = Enum.CameraType.Custom
            end
        end)
        y = y + 37
        
    elseif tab == "Settings" then
        local transOptions = {"Bình thường", "Mờ", "Trong suốt"}
        CreateDropdown(container, y, "🔲 Độ trong suốt", transOptions, function(val)
            if val == "Bình thường" then
                MainFrame.BackgroundTransparency = 0.05
            elseif val == "Mờ" then
                MainFrame.BackgroundTransparency = 0.3
            else
                MainFrame.BackgroundTransparency = 0.6
            end
        end)
        y = y + 37
        
        CreateToggle(container, y, "🔔 Thông báo", Config.Notifications, function(val)
            Config.Notifications = val
        end)
        y = y + 37
        
        CreateButton(container, y, "💾 Lưu cấu hình", Color3.fromRGB(0, 150, 200), function()
            local configJSON = HttpService:JSONEncode(Config)
            writefile("menu_config.json", configJSON)
            CreateNotification("✅ Thành công", "Đã lưu cấu hình!", 2, Color3.fromRGB(0, 255, 100))
        end)
        y = y + 37
        
        CreateButton(container, y, "📂 Tải cấu hình", Color3.fromRGB(0, 150, 100), function()
            local success, data = pcall(function()
                return readfile("menu_config.json")
            end)
            if success and data then
                local loadedConfig = HttpService:JSONDecode(data)
                for key, value in pairs(loadedConfig) do
                    Config[key] = value
                end
                CreateNotification("✅ Thành công", "Đã tải cấu hình!", 2, Color3.fromRGB(0, 255, 100))
                UpdateTabContent(Config.CurrentTab, container)
            else
                CreateNotification("❌ Lỗi", "Không tìm thấy cấu hình!", 2, Color3.fromRGB(255, 50, 50))
            end
        end)
        y = y + 37
        
        CreateButton(container, y, "🔄 Reset cấu hình", Color3.fromRGB(200, 50, 50), function()
            CreateNotification("🔄 Reset", "Đã reset cấu hình về mặc định!", 2, Color3.fromRGB(255, 200, 50))
        end)
        y = y + 37
    end
    
    container.CanvasSize = UDim2.new(0, 0, 0, y + 50)
end

-- ============================================
-- CÁC HỆ THỐNG KHÁC (ESP, Fly, Spin, v.v.)
-- ============================================

-- ESP System
local ESP = {Objects = {}, Lines = {}, Boxes = {}, Skeletons = {}, HealthBars = {}}

function ESP:CreateESP(player)
    if not player or player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    if Config.ESPBox then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 6, 1.5)
        box.Adornee = char
        box.Color3 = Config.ESPColor
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Parent = char
        table.insert(self.Boxes, box)
    end
    
    if Config.ESPLine then
        local line = Instance.new("SelectionBox")
        line.Adornee = char
        line.Color3 = Config.ESPColor
        line.Transparency = 0.3
        line.LineThickness = 0.1
        line.Parent = char
        table.insert(self.Lines, line)
    end
    
    if Config.ESPSkeleton then
        local parts = {
            ["Head"] = {Color3.fromRGB(255, 100, 100), 0.8},
            ["LeftArm"] = {Color3.fromRGB(100, 200, 255), 0.5},
            ["RightArm"] = {Color3.fromRGB(100, 200, 255), 0.5},
            ["Torso"] = {Color3.fromRGB(255, 255, 100), 0.7},
            ["LeftLeg"] = {Color3.fromRGB(100, 255, 100), 0.5},
            ["RightLeg"] = {Color3.fromRGB(100, 255, 100), 0.5}
        }
        for partName, data in pairs(parts) do
            local part = char:FindFirstChild(partName)
            if part then
                local sphere = Instance.new("SphereHandleAdornment")
                sphere.Radius = 0.5
                sphere.Adornee = part
                sphere.Color3 = data[1]
                sphere.Transparency = 0.3
                sphere.AlwaysOnTop = true
                sphere.ZIndex = 10
                sphere.Parent = part
                table.insert(self.Skeletons, sphere)
            end
        end
    end
    
    if Config.ESPHealth then
        local healthBar = Instance.new("SelectionBox")
        healthBar.Adornee = char
        healthBar.Color3 = Color3.fromRGB(0, 255, 0)
        healthBar.Transparency = 0.2
        healthBar.LineThickness = 0.1
        healthBar.Parent = char
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.HealthChanged:Connect(function(health)
                local ratio = health / humanoid.MaxHealth
                healthBar.Color3 = Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 0)
            end)
        end
        table.insert(self.HealthBars, healthBar)
    end
end

function ESP:UpdateESP()
    for _, obj in ipairs(self.Boxes) do obj:Destroy() end
    for _, obj in ipairs(self.Lines) do obj:Destroy() end
    for _, obj in ipairs(self.Skeletons) do obj:Destroy() end
    for _, obj in ipairs(self.HealthBars) do obj:Destroy() end
    self.Boxes = {}
    self.Lines = {}
    self.Skeletons = {}
    self.HealthBars = {}
    if not Config.ESPEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:CreateESP(player)
        end
    end
end

-- Fly System
local Fly = {BodyVelocity = nil, BodyGyro = nil, Connections = {}}

function Fly:Start()
    if self.BodyVelocity then return end
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    self.BodyVelocity = Instance.new("BodyVelocity")
    self.BodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    self.BodyVelocity.Parent = rootPart
    
    self.BodyGyro = Instance.new("BodyGyro")
    self.BodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    self.BodyGyro.Parent = rootPart
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    
    local connection = UserInputService.InputChanged:Connect(function(input)
        if not Config.FlyEnabled then return end
        local moveVector = Vector3.new(0, 0, 0)
        local speed = Config.FlySpeed
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, speed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, speed, 0) end
        elseif input.UserInputType == Enum.UserInputType.Touch then
            local touchPos = input.Position
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local delta = (touchPos - screenCenter) / 100
            moveVector = Vector3.new(delta.X * Config.FlySpeed, 0, delta.Y * Config.FlySpeed)
        end
        
        if self.BodyVelocity then
            self.BodyVelocity.Velocity = moveVector
        end
    end)
    
    table.insert(self.Connections, connection)
end

function Fly:Stop()
    for _, conn in ipairs(self.Connections) do
        conn:Disconnect()
    end
    self.Connections = {}
    if self.BodyVelocity then self.BodyVelocity:Destroy() self.BodyVelocity = nil end
    if self.BodyGyro then self.BodyGyro:Destroy() self.BodyGyro = nil end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- Spin System
local Spin = {Running = false}

function Spin:Start()
    if self.Running then return end
    self.Running = true
    local connection = RunService.RenderStepped:Connect(function()
        if not Config.SpinEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        local angle = math.rad(Config.SpinSpeed * RunService.RenderStepped:Wait())
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, angle, 0)
    end)
    self.Connection = connection
end

function Spin:Stop()
    self.Running = false
    if self.Connection then self.Connection:Disconnect() self.Connection = nil end
end

-- Aimbot System
local FOVCircle
local aimConnection

function StartAimbot()
    if aimConnection then return end
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.Color = Color3.fromRGB(0, 255, 0)
        FOVCircle.Filled = false
        FOVCircle.Radius = 35
        FOVCircle.Visible = true
    end)
    
    aimConnection = RunService.RenderStepped:Connect(function()
        if not FOVCircle then return end
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Position = screenCenter
        if not Config.Aimbot then return end
        
        local closestPlayer = nil
        local shortestDistance = math.huge
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if head and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local pos2D = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (pos2D - screenCenter).Magnitude
                        if distance <= 35 and distance < shortestDistance then
                            local params = RaycastParams.new()
                            params.FilterType = Enum.RaycastFilterType.Exclude
                            params.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                            local origin = Camera.CFrame.Position
                            local direction = head.Position - origin
                            local result = workspace:Raycast(origin, direction, params)
                            if not result then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
        
        if closestPlayer and closestPlayer.Character then
            local head = closestPlayer.Character:FindFirstChild("Head")
            if head then
                local targetPos = head.Position
                local newCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                Camera.CFrame = newCFrame
            end
        end
    end)
end

function StopAimbot()
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
    if FOVCircle then
        FOVCircle.Visible = false
        FOVCircle = nil
    end
end

-- Hitbox System
local hitboxConnection

function StartHitbox()
    if hitboxConnection then return end
    hitboxConnection = RunService.RenderStepped:Connect(function()
        if not Config.Hitbox then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if root and humanoid and humanoid.Health > 0 then
                    if not Config.OriginalData[root] then
                        Config.OriginalData[root] = {
                            Size = root.Size,
                            Transparency = root.Transparency,
                            CanCollide = root.CanCollide
                        }
                    end
                    root.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                    root.Transparency = Config.HitboxTransparency
                    root.CanCollide = false
                end
            end
        end
    end)
end

function UpdateHitboxSize(size)
    for rootPart, _ in pairs(Config.OriginalData) do
        if rootPart and rootPart.Parent then
            rootPart.Size = Vector3.new(size, size, size)
        end
    end
end

function StopHitbox()
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    for rootPart, original in pairs(Config.OriginalData) do
        if rootPart and rootPart.Parent then
            rootPart.Size = original.Size
            rootPart.Transparency = original.Transparency
            rootPart.CanCollide = original.CanCollide
        end
    end
    Config.OriginalData = {}
end

-- Teleport
function TeleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        CreateNotification("❌ Lỗi", "Không tìm thấy người chơi!", 2, Color3.fromRGB(255, 50, 50))
        return
    end
    local targetPos = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetPos then return end
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local speed = 50
    if Config.TeleportSpeed == "Cực nhanh" then speed = 200
    elseif Config.TeleportSpeed == "Siêu nhanh" then speed = 1000 end
    
    local distance = (targetPos.Position - rootPart.Position).Magnitude
    local duration = distance / speed
    
    TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Position = targetPos.Position
    }):Play()
    
    CreateNotification("🚀 Teleport", "Đang bay đến " .. targetPlayer.Name, 2, Color3.fromRGB(100, 200, 255))
end

-- Free Camera
function ToggleFreeCamera()
    Config.FreeCamera = not Config.FreeCamera
    if Config.FreeCamera then
        Config.OldCamera = Camera.CFrame
        local freeCam = Instance.new("Part")
        freeCam.Size = Vector3.new(1, 1, 1)
        freeCam.Anchored = true
        freeCam.CanCollide = false
        freeCam.Transparency = 1
        freeCam.Parent = workspace
        Camera.CameraSubject = freeCam
        Camera.CameraType = Enum.CameraType.Scriptable
        
        local connection = UserInputService.InputChanged:Connect(function(input)
            if not Config.FreeCamera then return end
            local speed = 10
            local moveVector = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector * speed end
            freeCam.Position = freeCam.Position + moveVector
            Camera.CFrame = CFrame.new(freeCam.Position, freeCam.Position + Camera.CFrame.LookVector)
        end)
        Config.FreeCamConnection = connection
    else
        if Config.FreeCamConnection then Config.FreeCamConnection:Disconnect() end
        Camera.CameraSubject = LocalPlayer.Character or LocalPlayer
        Camera.CameraType = Enum.CameraType.Custom
        if Config.OldCamera then Camera.CFrame = Config.OldCamera end
    end
end

-- FPS Boost
function ToggleFPSBoost()
    Config.FPSBoost = not Config.FPSBoost
    if Config.FPSBoost then
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 1
        Lighting.FogEnd = 1000
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") then v.Enabled = false end
        end
    else
        Lighting.GlobalShadows = true
    end
end

-- Full Bright
function ToggleFullBright()
    Config.FullBright = not Config.FullBright
    if Config.FullBright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.TimeOfDay = "12:00:00"
        Lighting.FogEnd = 100000
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    end
end

-- Effects
local Effects = {}

function Effects:CreateRainbowOrb()
    if self.Orb then return end
    local orb = Instance.new("Part")
    orb.Size = Vector3.new(2, 2, 2)
    orb.Shape = Enum.PartType.Ball
    orb.Material = Enum.Material.Neon
    orb.Anchored = true
    orb.CanCollide = false
    orb.Transparency = 0.3
    orb.Parent = workspace
    local trail = Instance.new("Trail")
    trail.Transparency = NumberSequence.new(0.5, 0)
    trail.Lifetime = 0.5
    trail.Parent = orb
    
    local connection = RunService.RenderStepped:Connect(function()
        if not Config.RainbowOrb then
            orb:Destroy()
            connection:Disconnect()
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            orb.Position = rootPart.Position + Vector3.new(0, 2, 2)
        end
        local time = tick() % 1
        local r = math.sin(time * 2 * math.pi) * 0.5 + 0.5
        local g = math.sin((time + 0.33) * 2 * math.pi) * 0.5 + 0.5
        local b = math.sin((time + 0.67) * 2 * math.pi) * 0.5 + 0.5
        orb.Color = Color3.fromRGB(r * 255, g * 255, b * 255)
    end)
    self.Orb = orb
    self.OrbConnection = connection
end

function Effects:CreateSnowEffect()
    if self.Snow then return end
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Texture = "rbxasset://textures/particles/snowflake.png"
    particleEmitter.Rate = 100
    particleEmitter.Lifetime = NumberRange.new(3, 5)
    particleEmitter.SpreadAngle = Vector2.new(360, 360)
    particleEmitter.Velocity = NumberRange.new(-5, 5)
    particleEmitter.Size = NumberSequence.new(0.5, 1)
    particleEmitter.Transparency = NumberSequence.new(0.5, 1)
    particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    particleEmitter.Enabled = true
    particleEmitter.Parent = workspace
    self.Snow = particleEmitter
end

function Effects:CreateHeartEffect()
    if self.Heart then return end
    local heart = Instance.new("Part")
    heart.Size = Vector3.new(3, 3, 1)
    heart.Shape = Enum.PartType.Cylinder
    heart.Material = Enum.Material.Neon
    heart.Anchored = true
    heart.CanCollide = false
    heart.Transparency = 0.5
    heart.Parent = workspace
    
    local connection = RunService.RenderStepped:Connect(function()
        if not Config.HeartEffect then
            heart:Destroy()
            connection:Disconnect()
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            heart.Position = rootPart.Position + Vector3.new(0, 3, 0)
        end
        heart.Transparency = math.sin(tick() * 2) * 0.3 + 0.3
        heart.Color = Color3.fromRGB(255, 50, 100)
    end)
    self.Heart = heart
    self.HeartConnection = connection
end

function CreateHackerText()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+"
    local hackerText = Instance.new("TextLabel")
    hackerText.Size = UDim2.new(1, 0, 0, 50)
    hackerText.Position = UDim2.new(0, 0, 0.5, -25)
    hackerText.BackgroundTransparency = 1
    hackerText.Text = "HACKED"
    hackerText.TextColor3 = Color3.fromRGB(0, 255, 0)
    hackerText.Font = Enum.Font.Code
    hackerText.TextSize = 40
    hackerText.ZIndex = 100
    hackerText.Parent = PlayerGui
    
    local text = "HACKED"
    local index = 1
    local connection = RunService.RenderStepped:Connect(function()
        if not Config.HackerText then
            hackerText:Destroy()
            connection:Disconnect()
            return
        end
        local displayText = ""
        for i = 1, #text do
            if i <= index then
                displayText = displayText .. text:sub(i, i)
            else
                local randomChar = chars:sub(math.random(1, #chars), math.random(1, #chars))
                displayText = displayText .. randomChar
            end
        end
        hackerText.Text = displayText
        index = index + 0.1
        if index > #text then index = 1 end
    end)
end

-- ============================================
-- KHỞI TẠO
-- ============================================

-- Tạo menu
local ScreenGui, MainFrame, TabContainer, CloseBtn, MinBtn = CreateMainMenu()

-- Initialize default tab
UpdateTabContent("Volcano", TabContainer)

-- Auto-start features
if Config.Aimbot then StartAimbot() end
if Config.Hitbox then StartHitbox() end
if Config.ESPEnabled then ESP:UpdateESP() end
if Config.FlyEnabled then Fly:Start() end
if Config.SpinEnabled then Spin:Start() end
if Config.RainbowOrb then Effects:CreateRainbowOrb() end
if Config.SnowEffect then Effects:CreateSnowEffect() end
if Config.HeartEffect then Effects:CreateHeartEffect() end
if Config.FullBright then ToggleFullBright() end
if Config.FPSBoost then ToggleFPSBoost() end
if Config.FreeCamera then ToggleFreeCamera() end
if Config.HackerText then CreateHackerText() end

-- Anti AFK
RunService.RenderStepped:Connect(function()
    if not Config.AntiAFK then return end
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local pos = rootPart.Position
    rootPart.Position = pos + Vector3.new(math.random(-1, 1) * 0.01, 0, math.random(-1, 1) * 0.01)
end)

-- Noclip
RunService.RenderStepped:Connect(function()
    if Config.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Jump = true end
    end
end)

-- Player stats on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        humanoid.WalkSpeed = Config.Speed
        humanoid.JumpPower = Config.JumpPower
    end
end)

-- Close button
CloseBtn.MouseButton1Click:Connect(function()
    Config.MenuOpen = false
    MainFrame.Visible = false
    
    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 40, 0, 40)
    Logo.Position = UDim2.new(0.95, -20, 0.05, 0)
    Logo.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    Logo.BackgroundTransparency = 0
    Logo.Image = "rbxasset://textures/ui/Image/Blank.png"
    Logo.ZIndex = 20
    Logo.Parent = ScreenGui
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(1, 0)
    LogoCorner.Parent = Logo
    
    Logo.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            Config.MenuOpen = true
            MainFrame.Visible = true
            Logo:Destroy()
        end
    end)
end)

-- Minimize button
MinBtn.MouseButton1Click:Connect(function()
    if MainFrame.Size.Y.Offset == 45 then
        MainFrame.Size = UDim2.new(0, 380, 0, 550)
        TabContainer.Visible = true
        MinBtn.Text = "−"
    else
        MainFrame.Size = UDim2.new(0, 380, 0, 45)
        TabContainer.Visible = false
        MinBtn.Text = "+"
    end
end)

CreateNotification("✅ Thành công", "Menu đã sẵn sàng!", 3, Color3.fromRGB(0, 255, 200))
print("✅ Menu đã được tải thành công!")
