-- [[ PREMIUM MOBILE HUB V4.8 - PORTAL SYSTEM INTEGRATION ]] --

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5) 
local Camera = workspace.CurrentCamera

-- Lưu thời điểm vào server
local joinTime = tick()

-- Tránh chạy trùng lặp script
if _G.MobileHubExecutedFinalV4_8 then
    print("[Mobile Hub] Hub V4.8 đang hoạt động!")
    return
else
    _G.MobileHubExecutedFinalV4_8 = true
end

-- Hệ thống Quản lý Trạng thái (State)
local State = {
    FPS_Enabled = false,
    Aim_Enabled = false,
    Aim_Mode = "All",
    Aim_Radius = 35,
    Hitbox_Enabled = false,
    Hitbox_Size = 5,
    Hitbox_Transparency = 0.5,
    Hitbox_Originals = {},
    
    ESP_Name = false,
    ESP_Box = false,
    ESP_Storage = {},
    
    WalkSpeed_Enabled = false,
    WalkSpeed_Value = 16,
    JumpPower_Enabled = false,
    JumpPower_Value = 50,
    InfJump_Enabled = false,
    Fly_Enabled = false,
    Fly_Speed = 50,
    Noclip_Enabled = false,
    
    VisualEffects_Enabled = false,
    Camera_FOV_Value = 70,

    Freecam_Enabled = false,
    Freecam_Speed = 2,
    FirstPerson_Enabled = false,
    ThirdPerson_Enabled = false,

    WallWalk_Enabled = false,
    FollowBot_Enabled = false
}

-- Khởi tạo biến quản lý Hệ thống Portal
local MAX_PORTALS = 5
local portals = {}
local debounces = {}
local currentSelectedId = nil

for i = 1, MAX_PORTALS do
    portals[i] = {}
    debounces[i] = false
end

local portalColors = {
    Color3.fromRGB(255, 50, 50),
    Color3.fromRGB(50, 255, 50),
    Color3.fromRGB(50, 50, 255),
    Color3.fromRGB(255, 255, 50),
    Color3.fromRGB(255, 50, 255)
}

local currentAimTarget = nil
local FlyVelocity = nil
local FlyGyro = nil
local hitboxConnection = nil
local FreecamConnection = nil
local FreecamRotX, FreecamRotY = 0, 0
local FreecamTouchConn = nil
local OldCameraType = nil
local OriginalAnchoredState = false

local WallConnection = nil
local FollowBot = nil
local FollowConnection = nil

-- Vẽ vòng tròn FOV Aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 0)
FOVCircle.Filled = false
FOVCircle.Radius = State.Aim_Radius
FOVCircle.Visible = false

-- KHỞI TẠO GUI CHÍNH
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PremiumMobileHub_V4_8"
ScreenGui.ResetOnSpawn = false
local success, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = PlayerGui end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35,35,45))
}
Gradient.Rotation = 45
Gradient.Parent = MainFrame

local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 14) MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke") MainStroke.Color = Color3.fromRGB(45, 45, 55) MainStroke.Thickness = 1.5 MainStroke.Parent = MainFrame

task.spawn(function()
    local h = 0
    while ScreenGui.Parent do
        h = (h + 0.003) % 1; MainStroke.Color = Color3.fromHSV(h,1,1); task.wait(0.02)
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 45) Title.Position = UDim2.new(0, 15, 0, 0) Title.BackgroundTransparency = 1
Title.Text = "PREMIUM MOBILE HUB V4.8" Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold Title.TextSize = 18 Title.TextXAlignment = Enum.TextXAlignment.Left Title.Parent = MainFrame

local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 35, 0, 30) MiniBtn.Position = UDim2.new(1, -45, 0, 7) MiniBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MiniBtn.Text = "—" MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255) MiniBtn.Font = Enum.Font.SourceSansBold MiniBtn.TextSize = 14 MiniBtn.Parent = MainFrame
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", MiniBtn).Color = Color3.fromRGB(60, 60, 70)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -55) Sidebar.Position = UDim2.new(0, 10, 0, 45) Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 27) Sidebar.BorderSizePixel = 0 Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
local SidebarStroke = Instance.new("UIStroke") SidebarStroke.Parent = Sidebar SidebarStroke.Thickness = 1.3
task.spawn(function() local h = 0 while ScreenGui.Parent do h = (h + 0.003) % 1; SidebarStroke.Color = Color3.fromHSV(h,1,1); task.wait(0.02) end end)

local SidebarLayout = Instance.new("UIListLayout") SidebarLayout.Parent = Sidebar SidebarLayout.Padding = UDim.new(0, 4) SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -160, 1, -55) ContentContainer.Position = UDim2.new(0, 150, 0, 45) ContentContainer.BackgroundTransparency = 1 ContentContainer.Parent = MainFrame

local tabs, tabButtons = {}, {}
local function createTab(tabName, displayName)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = tabName .. "Tab" scroll.Size = UDim2.new(1, 0, 1, 0) scroll.BackgroundTransparency = 1 scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 650) scroll.ScrollBarThickness = 4 scroll.Visible = false scroll.Parent = ContentContainer
    local layout = Instance.new("UIListLayout") layout.Parent = scroll layout.SortOrder = Enum.SortOrder.LayoutOrder layout.Padding = UDim.new(0, 8)
    tabs[tabName] = scroll
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 114, 0, 30) tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38) tabBtn.Text = displayName
    tabBtn.TextColor3 = Color3.fromRGB(180, 180, 190) tabBtn.Font = Enum.Font.SourceSansBold tabBtn.TextSize = 12 tabBtn.Parent = Sidebar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
    tabButtons[tabName] = tabBtn
    
    tabBtn.MouseButton1Click:Connect(function()
        for t, s in pairs(tabs) do s.Visible = (t == tabName) end
        for t, b in pairs(tabButtons) do 
            b.BackgroundColor3 = (t == tabName) and Color3.fromRGB(55, 85, 140) or Color3.fromRGB(30, 30, 38)
            b.TextColor3 = (t == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
        end
    end)
end

createTab("Combat", "⚔️ CHÍNH")
createTab("Movement", "⚡ DI CHUYỂN")
createTab("Visuals", "👁️ GIAO DIỆN")
createTab("Portals", "🌀 CỔNG DỊCH CHUYỂN") -- Thêm Tab Portal mới vào UI
createTab("Stats", "📊 THỐNG KÊ")

tabs["Combat"].Visible = true
tabButtons["Combat"].BackgroundColor3 = Color3.fromRGB(55, 85, 140)
tabButtons["Combat"].TextColor3 = Color3.fromRGB(255, 255, 255)

local function createToggle(tab, text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38) btn.BackgroundColor3 = Color3.fromRGB(150, 45, 45) btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255) btn.Font = Enum.Font.SourceSansBold btn.TextSize = 14 btn.LayoutOrder = order btn.Parent = tabs[tab]
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.BackgroundColor3 = Color3.fromRGB(45, 140, 70)
            btn.Text = text .. ": ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
            btn.Text = text .. ": OFF"
        end
        callback(enabled)
    end)
    return btn
end

local function createSlider(tab, text, min, max, default, order, callback)
    local container = Instance.new("Frame") container.Size = UDim2.new(1, -10, 0, 42) container.BackgroundTransparency = 1 container.LayoutOrder = order container.Parent = tabs[tab]
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 140, 1, 0) lbl.BackgroundTransparency = 1 lbl.Text = text .. ": " .. tostring(default) lbl.TextColor3 = Color3.fromRGB(230, 230, 230) lbl.Font = Enum.Font.SourceSansBold lbl.TextSize = 13 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = container
    local sFrame = Instance.new("Frame") sFrame.Size = UDim2.new(1, -150, 0, 6) sFrame.Position = UDim2.new(0, 145, 0.5, -3) sFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45) sFrame.Parent = container
    Instance.new("UICorner", sFrame).CornerRadius = UDim.new(1, 0)
    local sBtn = Instance.new("TextButton") sBtn.Size = UDim2.new(0, 16, 0, 16) local initPct = math.clamp((default - min) / (max - min), 0, 1) sBtn.Position = UDim2.new(initPct, -8, -0.5, -5) sBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) sBtn.Text = "" sBtn.Parent = sFrame
    Instance.new("UICorner", sBtn).CornerRadius = UDim.new(1, 0)

    local sliding = false
    sBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local pct = math.clamp((i.Position.X - sFrame.AbsolutePosition.X) / sFrame.AbsoluteSize.X, 0, 1)
            sBtn.Position = UDim2.new(pct, -8, -0.5, -5)
            local val = math.clamp(math.round(min + (pct * (max - min))), min, max)
            lbl.Text = text .. ": " .. tostring(val)
            callback(val)
        end
    end)
end

local isMinimized = false
MiniBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        Sidebar.Visible = false; ContentContainer.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 520, 0, 45) }):Play()
        MiniBtn.Text = "＋"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 520, 0, 320) }):Play()
        task.wait(0.25) Sidebar.Visible = true; ContentContainer.Visible = true; MiniBtn.Text = "—"
    end
end)

local Dragging, DragInput, DragStart, StartPosition
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true; DragStart = input.Position; StartPosition = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
    end
end)

-- TAB 1: COMBAT
local toggleAimbot, toggleHitbox
local Aim_Btn = createToggle("Combat", "AIMBOT", 1, function(state) toggleAimbot(state) end)
local AimMode_Btn = Instance.new("TextButton") AimMode_Btn.Size = UDim2.new(1, -10, 0, 36) AimMode_Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) AimMode_Btn.Text = "AIM TARGET: ALL" AimMode_Btn.TextColor3 = Color3.fromRGB(255, 255, 255) AimMode_Btn.Font = Enum.Font.SourceSansBold AimMode_Btn.TextSize = 14 AimMode_Btn.LayoutOrder = 2 AimMode_Btn.Parent = tabs["Combat"]
Instance.new("UICorner", AimMode_Btn).CornerRadius = UDim.new(0, 6)

createSlider("Combat", "Phạm vi Aimbot (FOV)", 10, 500, 35, 3, function(v) State.Aim_Radius = v; FOVCircle.Radius = v end)
local Hitbox_Btn = createToggle("Combat", "HITBOX EXPANDER", 4, function(state) toggleHitbox(state) end)
createSlider("Combat", "Kích thước Hitbox", 5, 100, 5, 5, function(v) State.Hitbox_Size = v end)

local TransContainer = Instance.new("Frame") TransContainer.Size = UDim2.new(1, -10, 0, 36) TransContainer.BackgroundTransparency = 1 TransContainer.LayoutOrder = 6 TransContainer.Parent = tabs["Combat"]
local TransBox = Instance.new("TextBox") TransBox.Size = UDim2.new(0, 60, 1, 0) TransBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45) TransBox.Text = "0.5" TransBox.TextColor3 = Color3.fromRGB(255, 255, 255) TransBox.Font = Enum.Font.SourceSansBold TransBox.TextSize = 14 TransBox.Parent = TransContainer
Instance.new("UICorner", TransBox).CornerRadius = UDim.new(0, 5)
local TransLabel = Instance.new("TextLabel") TransLabel.Size = UDim2.new(1, -70, 1, 0) TransLabel.Position = UDim2.new(0, 70, 0, 0) TransLabel.BackgroundTransparency = 1 TransLabel.Text = "Độ trong suốt Hitbox (0 - 1)" TransLabel.TextColor3 = Color3.fromRGB(160, 160, 170) TransLabel.Font = Enum.Font.SourceSans TransLabel.TextSize = 13 TransLabel.TextXAlignment = Enum.TextXAlignment.Left TransLabel.Parent = TransContainer

-- TAB 2: MOVEMENT
local toggleFly, toggleWallWalk, toggleFollowBot
createToggle("Movement", "SPEED SYSTEM", 1, function(state) State.WalkSpeed_Enabled = state if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end end)
createSlider("Movement", "Tốc độ chạy", 16, 500, 100, 2, function(v) State.WalkSpeed_Value = v end)
createToggle("Movement", "JUMP SYSTEM", 3, function(state) State.JumpPower_Enabled = state if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50 end end)
createSlider("Movement", "Sức mạnh nhảy", 50, 500, 120, 4, function(v) State.JumpPower_Value = v end)

createToggle("Movement", "INFINITE JUMP", 5, function(state) State.InfJump_Enabled = state end)
createToggle("Movement", "FLY MOBILE (GÓC NHÌN)", 6, function(state) toggleFly(state) end)
createSlider("Movement", "Tốc độ bay", 10, 300, 50, 7, function(v) State.Fly_Speed = v end)
createToggle("Movement", "NOCLIP (XUYÊN TƯỜNG)", 8, function(state) State.Noclip_Enabled = state end)
createToggle("Movement", "WALL WALK (ĐI TRÊN TƯỜNG)", 9, function(state) toggleWallWalk(state) end)
createToggle("Movement", "TRIỆU HỒI BOT THEO ĐUÔI", 10, function(state) toggleFollowBot(state) end)

-- TAB 3: VISUALS
local toggleFPS, toggleVisualEffects, toggleFreecam, FirstPerson, ThirdPerson
createToggle("Visuals", "FPS BOOSTER", 1, function(state) toggleFPS(state) end)
createToggle("Visuals", "ESP NAME", 2, function(state) State.ESP_Name = state end)
createToggle("Visuals", "ESP BOX", 3, function(state) State.ESP_Box = state end)
createSlider("Visuals", "Góc Nhìn Camera (FOV)", 30, 120, 70, 4, function(v) State.Camera_FOV_Value = v; Camera.FieldOfView = v end)
createToggle("Visuals", "FREECAM MOBILE (CỐ ĐỊNH)", 5, function(state) toggleFreecam(state) end)
createToggle("Visuals", "GÓC NHÌN THỨ NHẤT", 6, function(state) FirstPerson(state) end)
createToggle("Visuals", "GÓC NHÌN THỨ BA", 7, function(state) ThirdPerson(state) end)
local EffBtn_Rainbow = createToggle("Visuals", "HIỆU ỨNG RAINBOW CẦU VỒNG", 8, function(state) toggleVisualEffects("Rainbow", state) end)
local EffBtn_Ice = createToggle("Visuals", "HIỆU ỨNG BĂNG GIÁ KHỞI CHẠY", 9, function(state) toggleVisualEffects("Ice", state) end)
local EffBtn_Smoke = createToggle("Visuals", "HIỆU ỨNG KHÓI BAY KHỞI CHẠY", 10, function(state) toggleVisualEffects("Smoke", state) end)

-- TAB 4: PORTALS SYSTEM (XÂY DỰNG TRÊN NỀN TAB MỚI CỦA HUB)
local previewPortal = Instance.new("Part")
previewPortal.Size = Vector3.new(4, 6, 0.5)
previewPortal.Anchored = true
previewPortal.CanCollide = false
previewPortal.Material = Enum.Material.Neon
previewPortal.Parent = workspace
previewPortal.Transparency = 1 

RunService.RenderStepped:Connect(function()
    if currentSelectedId and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        previewPortal.CFrame = hrp.CFrame * CFrame.new(0, 0, -6)
        previewPortal.Transparency = 0.6
        previewPortal.Color = portalColors[currentSelectedId] or Color3.fromRGB(255, 255, 255)
    else
        previewPortal.Transparency = 1
    end
end)

local function deletePortalPair(id)
    if portals[id] then
        for _, p in pairs(portals[id]) do p:Destroy() end
        portals[id] = {}
    end
end

local function createPortal(id)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    if #portals[id] >= 2 then deletePortalPair(id) end
    
    local p = Instance.new("Part")
    p.Size = Vector3.new(4, 6, 0.5)
    p.CFrame = previewPortal.CFrame
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = portalColors[id]
    p.Parent = workspace
    
    local bgui = Instance.new("BillboardGui", p)
    bgui.Size = UDim2.new(0, 50, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 4, 0)
    bgui.AlwaysOnTop = true
    
    local tl = Instance.new("TextLabel", bgui)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = "PORTAL " .. tostring(id)
    tl.TextSize = 16
    tl.Font = Enum.Font.SourceSansBold
    tl.TextColor3 = p.Color
    
    table.insert(portals[id], p)
    
    p.Touched:Connect(function(hit)
        if debounces[id] then return end
        if LocalPlayer.Character and hit.Parent == LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _, other in ipairs(portals[id]) do
                if other ~= p then
                    debounces[id] = true
                    hrp.CFrame = other.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.pi, 0)
                    task.wait(1.2)
                    debounces[id] = false
                    break
                end
            end
        end
    end)
end

-- Vòng lặp quét bổ sung khoảng cách giúp tăng độ nhạy dịch chuyển trên Mobile
task.spawn(function()
    while ScreenGui.Parent do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            for id = 1, MAX_PORTALS do
                if not debounces[id] and #portals[id] == 2 then
                    for _, p in ipairs(portals[id]) do
                        if (hrp.Position - p.Position).Magnitude < 4.5 then
                            for _, other in ipairs(portals[id]) do
                                if other ~= p then
                                    debounces[id] = true
                                    hrp.CFrame = other.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.pi, 0)
                                    task.wait(1.2)
                                    debounces[id] = false
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Tạo các hàng điều khiển cổng trong Tab Portals
for i = 1, MAX_PORTALS do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 45)
    row.BackgroundTransparency = 0.9
    row.BackgroundColor3 = portalColors[i]
    row.LayoutOrder = i
    row.Parent = tabs["Portals"]
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 120, 1, 0) lbl.Position = UDim2.new(0, 10, 0, 0) lbl.BackgroundTransparency = 1
    lbl.Text = "Hệ Thống Cổng " .. tostring(i) lbl.TextColor3 = portalColors[i] lbl.Font = Enum.Font.SourceSansBold lbl.TextSize = 14 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = row
    
    local buildBtn = Instance.new("TextButton")
    buildBtn.Size = UDim2.new(0, 90, 0, 32) buildBtn.Position = UDim2.new(1, -195, 0.5, -16) buildBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 45)
    buildBtn.Text = "ĐẶT CỔNG" buildBtn.TextColor3 = Color3.fromRGB(200, 255, 200) buildBtn.Font = Enum.Font.SourceSansBold buildBtn.TextSize = 12 buildBtn.Parent = row
    Instance.new("UICorner", buildBtn).CornerRadius = UDim.new(0, 5)
    
    buildBtn.MouseButton1Down:Connect(function() currentSelectedId = i end)
    buildBtn.MouseButton1Click:Connect(function() createPortal(i) currentSelectedId = nil end)
    
    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0, 80, 0, 32) delBtn.Position = UDim2.new(1, -95, 0.5, -16) delBtn.BackgroundColor3 = Color3.fromRGB(55, 45, 45)
    delBtn.Text = "XÓA CỔNG" delBtn.TextColor3 = Color3.fromRGB(255, 200, 200) delBtn.Font = Enum.Font.SourceSansBold delBtn.TextSize = 12 delBtn.Parent = row
    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 5)
    
    delBtn.MouseButton1Click:Connect(function() deletePortalPair(i) end)
end

local clearAllPortalsBtn = Instance.new("TextButton")
clearAllPortalsBtn.Size = UDim2.new(1, -10, 0, 40) clearAllPortalsBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
clearAllPortalsBtn.Text = "❌ XÓA TOÀN BỘ TẤT CẢ CÁC CỔNG DỊCH CHUYỂN" clearAllPortalsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearAllPortalsBtn.Font = Enum.Font.SourceSansBold clearAllPortalsBtn.TextSize = 14 clearAllPortalsBtn.LayoutOrder = MAX_PORTALS + 1 clearAllPortalsBtn.Parent = tabs["Portals"]
Instance.new("UICorner", clearAllPortalsBtn).CornerRadius = UDim.new(0, 6)
clearAllPortalsBtn.MouseButton1Click:Connect(function() for id = 1, MAX_PORTALS do deletePortalPair(id) end currentSelectedId = nil end)

-- TAB 5: STATS TEXTLABEL DISPLAY
local StatsTextLabel = Instance.new("TextLabel")
StatsTextLabel.Size = UDim2.new(1, -10, 0, 200) StatsTextLabel.BackgroundTransparency = 1 StatsTextLabel.Text = "Đang tải dữ liệu thống kê..."
StatsTextLabel.TextColor3 = Color3.fromRGB(240, 240, 255) StatsTextLabel.Font = Enum.Font.SourceSansBold StatsTextLabel.TextSize = 16
StatsTextLabel.TextXAlignment = Enum.TextXAlignment.Left StatsTextLabel.TextYAlignment = Enum.TextYAlignment.Top StatsTextLabel.LayoutOrder = 1 StatsTextLabel.Parent = tabs["Stats"]

local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

task.spawn(function()
    while ScreenGui.Parent do
        local serverTime = workspace.DistributedGameTime
        local playTime = tick() - joinTime
        local playerCount = #Players:GetPlayers()
        local playerName = LocalPlayer.Name
        
        StatsTextLabel.Text = 
            "📊 THỐNG KÊ HỆ THỐNG\n" ..
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n" ..
            "⏰ Thời gian Server đã mở :  " .. formatTime(serverTime) .. "\n\n" ..
            "⌛ Thời gian bạn đã chơi  :  " .. formatTime(playTime) .. "\n\n" ..
            "👥 Số người chơi hiện tại :  " .. tostring(playerCount) .. " người\n\n" ..
            "👤 Tên người chơi của bạn :  " .. playerName
            
        task.wait(1)
    end
end)

-- CHỨC NĂNG LEO TƯỜNG KHÔNG BÌ TUỘT
function toggleWallWalk(state)
    State.WallWalk_Enabled = state
    if WallConnection then WallConnection:Disconnect(); WallConnection = nil end

    if state then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")

        WallConnection = RunService.Heartbeat:Connect(function()
            if not State.WallWalk_Enabled or not char.Parent or not root.Parent then return end

            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {char}

            local checkDir = (hum.MoveDirection.Magnitude > 0) and hum.MoveDirection or root.CFrame.LookVector
            local result = workspace:Raycast(root.Position, checkDir * 3.8, rayParams)

            if result and math.abs(result.Normal.Y) < 0.85 then
                local normal = result.Normal
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                local targetLeft = root.CFrame.RightVector:Cross(normal).Unit
                local targetCFrame = CFrame.fromMatrix(root.Position, root.CFrame.RightVector, normal, targetLeft)
                root.CFrame = root.CFrame:Lerp(targetCFrame, 0.25)
                
                if hum.MoveDirection.Magnitude > 0 then
                    root.CFrame = root.CFrame * CFrame.new(hum.MoveDirection.X * 0.4, -hum.MoveDirection.Z * 0.4, 0)
                end
            end
        end)
    else
        if WallConnection then WallConnection:Disconnect(); WallConnection = nil end
    end
end

-- TRIỆU HỒI BOT ĐỔI MÀU LƠ LỬNG
function toggleFollowBot(state)
    State.FollowBot_Enabled = state
    if FollowConnection then FollowConnection:Disconnect(); FollowConnection = nil end
    if FollowBot then FollowBot:Destroy(); FollowBot = nil end

    if state then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")

        local bot = Instance.new("Part")
        bot.Name = "VisualCompanionBot"
        bot.Size = Vector3.new(1.5, 1.5, 1.5)
        bot.Shape = Enum.PartType.Ball
        bot.Material = Enum.Material.Neon
        bot.Anchored = true
        bot.CanCollide = false
        bot.Parent = workspace

        local wingL = Instance.new("Part", bot)
        wingL.Size = Vector3.new(0.4, 0.8, 1.8)
        wingL.Material = Enum.Material.Glass
        wingL.Color = Color3.fromRGB(255,255,255)
        wingL.CanCollide = false
        wingL.Anchored = true

        local gui = Instance.new("BillboardGui", bot)
        gui.Size = UDim2.new(0, 80, 0, 30)
        gui.AlwaysOnTop = true
        gui.ExtentsOffset = Vector3.new(0, 1.4, 0)
        
        local text = Instance.new("TextLabel", gui)
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "⭐ FRIEND"
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.Font = Enum.Font.SourceSansBold
        text.TextSize = 13

        FollowBot = bot
        local hue = 0

        FollowConnection = RunService.RenderStepped:Connect(function()
            if not State.FollowBot_Enabled or not FollowBot or not char.Parent or not root.Parent then return end
            
            hue = (hue + 0.005) % 1
            bot.Color = Color3.fromHSV(hue, 1, 1)
            
            local backOffset = root.CFrame * CFrame.new(0, 2.2, 3.5)
            local bobbing = math.sin(tick() * 4) * 0.4
            local finalTargetPos = backOffset.Position + Vector3.new(0, bobbing, 0)
            
            bot.CFrame = bot.CFrame:Lerp(CFrame.new(finalTargetPos, root.Position), 0.1)
            wingL.CFrame = bot.CFrame * CFrame.new(-1, 0, 0) * CFrame.Angles(0, 0, math.rad(15))
        end)
    end
end

-- BAY THEO CHÍNH XÁC GÓC NHÌN CAMERA MOBILE
local flyRenderConnection
function toggleFly(enable)
    State.Fly_Enabled = enable
    if enable then
        if FlyVelocity then FlyVelocity:Destroy() end
        if FlyGyro then FlyGyro:Destroy() end
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        
        FlyVelocity = Instance.new("BodyVelocity")
        FlyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        FlyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyVelocity.Parent = root
        
        FlyGyro = Instance.new("BodyGyro")
        FlyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        FlyGyro.CFrame = root.CFrame
        FlyGyro.Parent = root
        
        flyRenderConnection = RunService.Heartbeat:Connect(function()
            if not State.Fly_Enabled or not char.Parent or not root.Parent then 
                if flyRenderConnection then flyRenderConnection:Disconnect() flyRenderConnection = nil end 
                return 
            end
            
            local moveDir = hum.MoveDirection
            local camLook = Camera.CFrame.LookVector
            
            if moveDir.Magnitude > 0 then
                local rightVec = Camera.CFrame.RightVector
                local forwardVec = camLook
                local combinedDir = (rightVec * moveDir.X) + (forwardVec * -moveDir.Z)
                FlyVelocity.Velocity = combinedDir.Unit * State.Fly_Speed
            else
                FlyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
            FlyGyro.CFrame = Camera.CFrame
        end)
    else
        if flyRenderConnection then flyRenderConnection:Disconnect() flyRenderConnection = nil end
        if FlyVelocity then FlyVelocity:Destroy() FlyVelocity = nil end
        if FlyGyro then FlyGyro:Destroy() FlyGyro = nil end
    end
end

-- FREECAM MOBILE (CỐ ĐỊNH PHÍM)
function toggleFreecam(state)
    State.Freecam_Enabled = state
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if state then
        if root then 
            OriginalAnchoredState = root.Anchored
            root.Anchored = true 
        end
        
        OldCameraType = Camera.CameraType
        Camera.CameraType = Enum.CameraType.Scriptable
        
        FreecamRotX = 0
        FreecamRotY = 0

        FreecamTouchConn = UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
            if gameProcessed then return end
            local delta = touch.Delta
            FreecamRotX = FreecamRotX - (delta.X * 0.4)
            FreecamRotY = math.clamp(FreecamRotY - (delta.Y * 0.4), -80, 80)
        end)

        FreecamConnection = RunService.RenderStepped:Connect(function()
            if not State.Freecam_Enabled then return end
            
            local targetRotation = CFrame.Angles(0, math.rad(FreecamRotX), 0) * CFrame.Angles(math.rad(FreecamRotY), 0, 0)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position) * targetRotation
            
            if hum and hum.MoveDirection.Magnitude > 0 then
                local moveDir = hum.MoveDirection
                local moveVector = (Camera.CFrame.RightVector * moveDir.X) + (Camera.CFrame.LookVector * -moveDir.Z)
                Camera.CFrame = Camera.CFrame + (moveVector.Unit * State.Freecam_Speed)
            end
        end)
    else
        if FreecamTouchConn then FreecamTouchConn:Disconnect() FreecamTouchConn = nil end
        if FreecamConnection then FreecamConnection:Disconnect() FreecamConnection = nil end
        if root then root.Anchored = OriginalAnchoredState end
        Camera.CameraType = OldCameraType or Enum.CameraType.Custom
    end
end

function FirstPerson(state) State.FirstPerson_Enabled = state if state then LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson else LocalPlayer.CameraMode = Enum.CameraMode.Classic end end
function ThirdPerson(state) State.ThirdPerson_Enabled = state if state then LocalPlayer.CameraMode = Enum.CameraMode.Classic LocalPlayer.CameraMinZoomDistance = 8 LocalPlayer.CameraMaxZoomDistance = 20 else LocalPlayer.CameraMinZoomDistance = 0.5 LocalPlayer.CameraMaxZoomDistance = 128 end end

-- HIỆU ỨNG RAINBOW / ICE / SMOKE PARTICLE
function toggleVisualEffects(mode, enable)
    local char = LocalPlayer.Character if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") if not root then return end
    
    if enable then
        State.VisualEffects_Enabled = true
        if mode ~= "Rainbow" and EffBtn_Rainbow.Text:find("ON") then EffBtn_Rainbow.MouseButton1Click:Fire() end
        if mode ~= "Ice" and EffBtn_Ice.Text:find("ON") then EffBtn_Ice.MouseButton1Click:Fire() end
        if mode ~= "Smoke" and EffBtn_Smoke.Text:find("ON") then EffBtn_Smoke.MouseButton1Click:Fire() end
        
        for _, v in ipairs(root:GetChildren()) do if v:IsA("ParticleEmitter") or v:IsA("Attachment") or v:IsA("Trail") then v:Destroy() end end
        
        if mode == "Rainbow" then
            local topAtt = Instance.new("Attachment", root) topAtt.Position = Vector3.new(0, 2, 0)
            local bottomAtt = Instance.new("Attachment", root) bottomAtt.Position = Vector3.new(0, -2, 0)
            local trail = Instance.new("Trail", root)
            trail.Attachment0 = topAtt; trail.Attachment1 = bottomAtt; trail.Lifetime = 0.5
            task.spawn(function()
                local h = 0
                while State.VisualEffects_Enabled and trail.Parent do
                    h = (h + 0.01) % 1
                    trail.Color = ColorSequence.new(Color3.fromHSV(h, 1, 1))
                    task.wait(0.02)
                end
            end)
        elseif mode == "Ice" then
            local p = Instance.new("ParticleEmitter", root)
            p.Name = "IceEffect"
            p.Color = ColorSequence.new(Color3.fromRGB(150, 230, 255), Color3.fromRGB(255, 255, 255))
            p.Size = NumberSequence.new(1.2, 0)
            p.Lifetime = NumberRange.new(0.6, 1.2)
            p.Rate = 50
            p.Speed = NumberRange.new(3, 6)
            p.SpreadAngle = Vector2.new(45, 45)
        elseif mode == "Smoke" then
            local p = Instance.new("ParticleEmitter", root)
            p.Name = "SmokeEffect"
            p.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200))
            p.Size = NumberSequence.new(1.5, 3.5)
            p.Transparency = NumberSequence.new(0.4, 1)
            p.Lifetime = NumberRange.new(1, 1.8)
            p.Rate = 35
            p.Speed = NumberRange.new(1, 3)
        end
    else
        for _, v in ipairs(root:GetChildren()) do if v.Name == "IceEffect" or v.Name == "SmokeEffect" or v:IsA("Trail") or v:IsA("Attachment") then v:Destroy() end end
    end
end

-- VÒNG LẶP HỆ THỐNG PHỤ
Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function() if Camera.FieldOfView ~= State.Camera_FOV_Value then Camera.FieldOfView = State.Camera_FOV_Value end end)
RunService.PostSimulation:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if State.WalkSpeed_Enabled then hum.WalkSpeed = State.WalkSpeed_Value end
        if State.JumpPower_Enabled then hum.JumpPower = State.JumpPower_Value hum.UseJumpPower = true end
    end
end)
UserInputService.JumpRequest:Connect(function() if State.InfJump_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end end)
RunService.Stepped:Connect(function() if State.Noclip_Enabled and LocalPlayer.Character then for _, part in ipairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end end end)

-- DRAWING ESP & AIMBOT
local box, nameText
function createESP(player) if State.ESP_Storage[player] then return end local box = Drawing.new("Square") box.Color = Color3.fromRGB(255, 50, 50) box.Thickness = 1.5 box.Filled = false box.Visible = false local nameText = Drawing.new("Text") nameText.Color = Color3.fromRGB(255, 255, 255) nameText.Center = true nameText.Outline = true nameText.Visible = false State.ESP_Storage[player] = {Box = box, Text = nameText} end
function removeESP(player) if State.ESP_Storage[player] then State.ESP_Storage[player].Box:Destroy() State.ESP_Storage[player].Text:Destroy() State.ESP_Storage[player] = nil end end
Players.PlayerAdded:Connect(createESP) Players.PlayerRemoving:Connect(removeESP)
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end end

RunService.RenderStepped:Connect(function()
    for player, esp in pairs(State.ESP_Storage) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local root = player.Character.HumanoidRootPart local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen and (State.ESP_Name or State.ESP_Box) then
                local distance = (Camera.CFrame.Position - root.Position).Magnitude
                if State.ESP_Name then esp.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 35) esp.Text.Text = player.Name .. " [" .. math.round(distance) .. "m]" esp.Text.Size = math.clamp(math.round(400 / distance) + 10, 11, 20) esp.Text.Visible = true else esp.Text.Visible = false end
                if State.ESP_Box then local sizeX, sizeY = 2000 / distance, 3000 / distance esp.Box.Size = Vector2.new(sizeX, sizeY) esp.Box.Position = Vector2.new(screenPos.X - (sizeX / 2), screenPos.Y - (sizeY / 2)) esp.Box.Visible = true else esp.Box.Visible = false end
            else esp.Box.Visible = false esp.Text.Visible = false end
        else esp.Box.Visible = false esp.Text.Visible = false end
    end
end)

function toggleFPS(enable) State.FPS_Enabled = enable if enable then Lighting.GlobalShadows = false for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.CastShadow = false elseif v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end end end end
function isVisible(targetChar, targetPart) local p = RaycastParams.new() p.FilterType = Enum.RaycastFilterType.Exclude p.FilterDescendantsInstances = {LocalPlayer.Character, targetChar} return workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, p) == nil end

function getClosestAimTarget()
    local closest, shortestDist = nil, math.huge local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if State.Aim_Mode == "All" or State.Aim_Mode == "Players" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart") local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    local pos, visible = Camera:WorldToViewportPoint(head.Position)
                    if visible and isVisible(p.Character, head) then local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude if dist <= State.Aim_Radius and dist < shortestDist then shortestDist = dist closest = {Character = p.Character, Part = head} end end
                end
            end
        end
    end
    if State.Aim_Mode == "All" or State.Aim_Mode == "NPCs" then
        local folders = {workspace, workspace:FindFirstChild("Mobs"), workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Zombies"), workspace:Fin
