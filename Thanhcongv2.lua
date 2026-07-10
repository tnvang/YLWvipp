-- =================================================================
-- 1. KHỞI TẠO HỆ THỐNG & BIẾN TOÀN CỤC
-- =================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local JoinTime = tick()
local ServerStart = workspace:GetServerTimeNow()

local State = {
    WalkSpeed_Enabled = false,
    WalkSpeed_Value = 16,
    JumpPower_Enabled = false,
    JumpPower_Value = 50,
    InfJump_Enabled = false,
    Noclip_Enabled = false,
    Spider_Enabled = false,
    Fly_Enabled = false,
    Fly_Speed = 50,
    ESP_Name = false,
    ESP_Box = false,
    ESP_Storage = {},
    Camera_FOV_Value = 70,
    Freecam_Enabled = false,
    VisualEffects_Enabled = false,
    RainbowLoop = false,
    Aim_Enabled = false,
    Aim_Radius = 150,
    Aim_Mode = "All"
}

local FlyVelocity, FlyGyro, flyRenderConnection
local currentActiveEffect, ActiveTrail, ActiveSparkles, ActiveSnowEmitter
local currentAimTarget = nil
local snowRenderConnection = nil
local freecamCamPart = nil
local freecamConnection = nil

-- Vòng tròn FOV Aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.Radius = State.Aim_Radius
FOVCircle.Filled = false
FOVCircle.Visible = false

-- =================================================================
-- 2. TẠO GIAO DIỆN MENU UI CHÍNH (ĐỔI TÊN THÀNH THANHCONG HUB V2.1.0)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThanhCongHub_v2.1.0"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Khung Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 360)
MainFrame.Position = UDim2.new(0.5, -210, 0.4, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Đường viền Rainbow cho MainFrame
local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Thickness = 2
MainUIStroke.Color = Color3.fromRGB(255, 0, 0)
MainUIStroke.Parent = MainFrame

-- Thanh Tiêu Đề
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.45, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ThanhCong Hub v2.1.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Phần hiển thị chỉ số hệ thống thực tế (FPS | Ping | RAM)
local HardwareStatsLabel = Instance.new("TextLabel")
HardwareStatsLabel.Size = UDim2.new(0.55, -10, 1, 0)
HardwareStatsLabel.Position = UDim2.new(0.45, 0, 0, 0)
HardwareStatsLabel.BackgroundTransparency = 1
HardwareStatsLabel.Text = "FPS: Đang tính... | Ping: --ms | RAM: --MB"
HardwareStatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HardwareStatsLabel.Font = Enum.Font.SourceSansBold
HardwareStatsLabel.TextSize = 13
HardwareStatsLabel.TextXAlignment = Enum.TextXAlignment.Right
HardwareStatsLabel.Parent = TitleBar

-- Vùng chứa danh sách chức năng (Trái)
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(0, 230, 1, -55)
ContentScroll.Position = UDim2.new(0, 10, 0, 48)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 620)
ContentScroll.ScrollBarThickness = 4
ContentScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim2.new(0, 6)
UIListLayout.Parent = ContentScroll

-- Vùng Bảng Thống Kê Server (Phải)
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(0, 160, 1, -55)
StatsFrame.Position = UDim2.new(0, 250, 0, 48)
StatsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
StatsFrame.BorderSizePixel = 0
StatsFrame.Parent = MainFrame
Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 6)

-- Đường viền Rainbow cho StatsFrame
local StatsUIStroke = Instance.new("UIStroke")
StatsUIStroke.Thickness = 1.5
StatsUIStroke.Color = Color3.fromRGB(255, 0, 0)
StatsUIStroke.Parent = StatsFrame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -12, 1, -12)
StatsLabel.Position = UDim2.new(0, 6, 0, 6)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.Font = Enum.Font.SourceSansBold
StatsLabel.TextSize = 13
StatsLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
StatsLabel.Parent = StatsFrame

-- Nút Bật/Tắt Thu Nhỏ Menu (Đặt gọn ở góc trên bên trái màn hình)
local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Size = UDim2.new(0, 120, 0, 32)
OpenCloseBtn.Position = UDim2.new(0, 15, 0, 15)
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
OpenCloseBtn.Text = "ThanhCong Hub"
OpenCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseBtn.Font = Enum.Font.SourceSansBold
OpenCloseBtn.TextSize = 13
OpenCloseBtn.Parent = ScreenGui
Instance.new("UICorner", OpenCloseBtn).CornerRadius = UDim.new(0, 5)

-- Đường viền Rainbow cho nút mở Menu
local BtnUIStroke = Instance.new("UIStroke")
BtnUIStroke.Thickness = 1.5
BtnUIStroke.Color = Color3.fromRGB(255, 0, 0)
BtnUIStroke.Parent = OpenCloseBtn

OpenCloseBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = not MainFrame.Visible 
end)

-- Vòng lặp đổi màu Rainbow mượt mà cho toàn bộ đường viền
task.spawn(function()
    local hue = 0
    while task.wait(0.01) do
        hue = (hue + 0.005) % 1
        local rainbowColor = Color3.fromHSV(hue, 1, 1)
        MainUIStroke.Color = rainbowColor
        StatsUIStroke.Color = rainbowColor
        BtnUIStroke.Color = rainbowColor
    end
end)

-- =================================================================
-- 3. HÀM PHỤ TRỢ TẠO CẤU TRÚC NÚT BẤM
-- =================================================================
local function createToggle(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = "  [ TẮT ] " .. text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.Parent = ContentScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.BackgroundColor3 = Color3.fromRGB(0, 140, 90)
            btn.Text = "  [ BẬT ] " .. text
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            btn.Text = "  [ TẮT ] " .. text
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        callback(enabled)
    end)
    return btn
end

local function createButton(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.LayoutOrder = order
    btn.Parent = ContentScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- =================================================================
-- 4. LOGIC XỬ LÝ TOÀN BỘ CÁC CHỨC NĂNG
-- =================================================================

-- CHỨC NĂNG: HIỆU ỨNG RAINBOW HOẶC TUYẾT RƠI KHI DI CHUYỂN
local function toggleVisualEffects(mode, enable)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if snowRenderConnection then snowRenderConnection:Disconnect(); snowRenderConnection = nil end
    State.RainbowLoop = false
    
    for _, v in ipairs(root:GetChildren()) do
        if v.Name == "SnowEffect" or v.Name == "RainbowEffect" or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Sparkles") or v:IsA("Attachment") then 
            v:Destroy() 
        end
    end

    if enable then
        State.VisualEffects_Enabled = true
        currentActiveEffect = mode

        if mode == "Rainbow" then
            State.RainbowLoop = true
            local topAtt = Instance.new("Attachment", root) topAtt.Position = Vector3.new(0, 2, 0) topAtt.Name = "RainbowEffect"
            local bottomAtt = Instance.new("Attachment", root) bottomAtt.Position = Vector3.new(0, -2, 0) bottomAtt.Name = "RainbowEffect"
            ActiveTrail = Instance.new("Trail")
            ActiveTrail.Name = "RainbowEffect"
            ActiveTrail.Attachment0 = topAtt
            ActiveTrail.Attachment1 = bottomAtt
            ActiveTrail.Lifetime = 0.5
            ActiveTrail.WidthScale = NumberSequence.new(1, 0)
            ActiveTrail.Parent = root
            
            ActiveSparkles = Instance.new("Sparkles")
            ActiveSparkles.Name = "RainbowEffect"
            ActiveSparkles.Parent = root

            task.spawn(function()
                local hue = 0
                while State.RainbowLoop and hum.Parent and ActiveTrail and ActiveTrail.Parent do
                    if hum.MoveDirection.Magnitude > 0 then
                        ActiveTrail.Enabled = true
                        ActiveSparkles.Enabled = true
                        hue = (hue + 0.02) % 1
                        local col = Color3.fromHSV(hue, 1, 1)
                        ActiveTrail.Color = ColorSequence.new(col)
                        ActiveSparkles.SparkleColor = col
                    else
                        ActiveTrail.Enabled = false
                        ActiveSparkles.Enabled = false
                    end
                    task.wait(0.02)
                end
            end)
        elseif mode == "Snow" then
            ActiveSnowEmitter = Instance.new("ParticleEmitter")
            ActiveSnowEmitter.Name = "SnowEffect"
            ActiveSnowEmitter.Texture = "rbxassetid://243660364"
            ActiveSnowEmitter.Size = NumberSequence.new(0.4, 0)
            ActiveSnowEmitter.Lifetime = NumberRange.new(1.5, 2.5)
            ActiveSnowEmitter.Speed = NumberRange.new(2, 4)
            ActiveSnowEmitter.Acceleration = Vector3.new(0, -8, 0)
            ActiveSnowEmitter.Parent = root

            snowRenderConnection = RunService.RenderStepped:Connect(function()
                if not ActiveSnowEmitter or not hum.Parent then return end
                if hum.MoveDirection.Magnitude > 0 then ActiveSnowEmitter.Rate = 60 else ActiveSnowEmitter.Rate = 0 end
            end)
        end
    else
        State.VisualEffects_Enabled = false
        currentActiveEffect = nil
    end
end

-- CHỨC NĂNG: ĐI TRÊN TƯỜNG (SPIDER CLIMB)
RunService.Stepped:Connect(function()
    if State.Spider_Enabled and LocalPlayer.Character then
        local char = LocalPlayer.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local ray = Ray.new(root.Position, root.CFrame.LookVector * 1.8)
            local part = workspace:FindPartOnRayWithIgnoreList(ray, {char})
            if part then
                root.Velocity = Vector3.new(root.Velocity.X, 35, root.Velocity.Z)
            end
        end
    end
end)

-- CHỨC NĂNG: FREECAM (CAM TỰ DO)
local function toggleFreecam(enable)
    State.Freecam_Enabled = enable
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if enable then
        if root then root.Anchored = true end
        Camera.CameraType = Enum.CameraType.Scriptable
        
        freecamCamPart = Instance.new("Part")
        freecamCamPart.Transparency = 1
        freecamCamPart.CanCollide = false
        freecamCamPart.Anchored = true
        freecamCamPart.CFrame = Camera.CFrame
        freecamCamPart.Parent = workspace

        freecamConnection = RunService.RenderStepped:Connect(function()
            if not State.Freecam_Enabled then return end
            Camera.CFrame = freecamCamPart.CFrame
            
            local speed = 1.5
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then freecamCamPart.CFrame *= CFrame.new(0, 0, -speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then freecamCamPart.CFrame *= CFrame.new(0, 0, speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then freecamCamPart.CFrame *= CFrame.new(-speed, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then freecamCamPart.CFrame *= CFrame.new(speed, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then freecamCamPart.CFrame *= CFrame.new(0, speed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then freecamCamPart.CFrame *= CFrame.new(0, -speed, 0) end
        end)
    else
        if freecamConnection then freecamConnection:Disconnect(); freecamConnection = nil end
        if freecamCamPart then freecamCamPart:Destroy(); freecamCamPart = nil end
        if root then root.Anchored = false end
        Camera.CameraType = Enum.CameraType.Custom
    end
end

-- CHỨC NĂNG: FLY MOBILE CHUẨN VECTOR
local function toggleFly(enable)
    State.Fly_Enabled = enable
    if enable then
        if FlyVelocity then FlyVelocity:Destroy() end
        if FlyGyro then FlyGyro:Destroy() end
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        
        local currentVelocity = Instance.new("BodyVelocity")
        currentVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        currentVelocity.Parent = root
        FlyVelocity = currentVelocity
        
        local currentGyro = Instance.new("BodyGyro")
        currentGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        currentGyro.Parent = root
        FlyGyro = currentGyro
        
        flyRenderConnection = RunService.Heartbeat:Connect(function()
            if not State.Fly_Enabled or not char.Parent or not root.Parent or not currentVelocity.Parent then return end
            local moveDir = hum.MoveDirection
            local camCFrame = Camera.CFrame
            local direction = camCFrame.LookVector * (-moveDir.Z) + camCFrame.RightVector * moveDir.X
            if direction.Magnitude > 0 then
                currentVelocity.Velocity = direction.Unit * State.Fly_Speed
            else
                currentVelocity.Velocity = Vector3.new(0, 0.1, 0)
            end
            currentGyro.CFrame = camCFrame
        end)
    else
        if flyRenderConnection then flyRenderConnection:Disconnect() end
        if FlyVelocity then FlyVelocity:Destroy() end
        if FlyGyro then FlyGyro:Destroy() end
    end
end

-- CHỨC NĂNG: XỬ LÝ QUÉT SÂU AIMBOT
local function isVisible(targetChar, targetPart)
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
    return workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, p) == nil
end

local function getClosestAimTarget()
    local closest, shortestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if State.Aim_Mode == "All" or State.Aim_Mode == "Players" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local pos, visible = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if visible and isVisible(p.Character, p.Character.Head) then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist <= State.Aim_Radius and dist < shortestDist then shortestDist = dist; closest = {Character = p.Character, Part = p.Character.Head} end
                end
            end
        end
    end
    if State.Aim_Mode == "All" or State.Aim_Mode == "NPCs" then
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(model) then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local head = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
                if hum and head and hum.Health > 0 then
                    local pos, visible = Camera:WorldToViewportPoint(head.Position)
                    if visible and isVisible(model, head) then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist <= State.Aim_Radius and dist < shortestDist then shortestDist = dist; closest = {Character = model, Part = head} end
                    end
                end
            end
        end
    end
    return closest
end

local aimConnection
local function toggleAimbot(enable)
    State.Aim_Enabled = enable
    if enable then
        FOVCircle.Visible = true
        aimConnection = RunService.RenderStepped:Connect(function()
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            if currentAimTarget and currentAimTarget.Character.Parent and isVisible(currentAimTarget.Character, currentAimTarget.Part) then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, currentAimTarget.Part.Position)
            else
                currentAimTarget = getClosestAimTarget()
            end
        end)
    else
        FOVCircle.Visible = false
        if aimConnection then aimConnection:Disconnect() end
    end
end

-- CHỨC NĂNG: ESP KHUNG VÀ TÊN
local function createESP(p)
    if State.ESP_Storage[p] then return end
    local box = Drawing.new("Square") box.Color = Color3.fromRGB(255, 50, 50) box.Thickness = 1.5 box.Filled = false box.Visible = false
    local text = Drawing.new("Text") text.Color = Color3.fromRGB(255, 255, 255) text.Center = true text.Outline = true text.Visible = false
    State.ESP_Storage[p] = {Box = box, Text = text}
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(p) if State.ESP_Storage[p] then State.ESP_Storage[p].Box:Destroy() State.ESP_Storage[p].Text:Destroy() State.ESP_Storage[p] = nil end end)
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end end

RunService.RenderStepped:Connect(function()
    for player, esp in pairs(State.ESP_Storage) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local root = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen and (State.ESP_Name or State.ESP_Box) then
                local distance = (Camera.CFrame.Position - root.Position).Magnitude
                if State.ESP_Name then
                    esp.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                    esp.Text.Text = player.Name .. " [" .. math.round(distance) .. "m]"
                    esp.Text.Size = 14 esp.Text.Visible = true
                else esp.Text.Visible = false end
                if State.ESP_Box then
                    local sizeX, sizeY = 2000 / distance, 3000 / distance
                    esp.Box.Size = Vector2.new(sizeX, sizeY)
                    esp.Box.Position = Vector2.new(screenPos.X - (sizeX / 2), screenPos.Y - (sizeY / 2))
                    esp.Box.Visible = true
                else esp.Box.Visible = false end
            else esp.Box.Visible = false esp.Text.Visible = false end
        else esp.Box.Visible = false esp.Text.Visible = false end
    end
end)

-- CHỨC NĂNG: LOOPS TOÀN CỤC CHẠY/NHẢY/XUYÊN TƯỜNG
RunService.PostSimulation:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if State.WalkSpeed_Enabled then hum.WalkSpeed = State.WalkSpeed_Value end
        if State.JumpPower_Enabled then hum.JumpPower = State.JumpPower_Value hum.UseJumpPower = true end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJump_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

RunService.Stepped:Connect(function()
    if State.Noclip_Enabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
end)

-- CHỨC NĂNG: TỐI ƯU HÓA FPS ĐỒ HỌA (FPS BOOSTER)
local fpsConnection
local function toggleFPS(enable)
    if enable then
        Lighting.GlobalShadows = false
        Lighting.ClockTime = 12
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
            elseif v:IsA("Texture") or v:IsA("Decal") or v:IsA("ParticleEmitter") then
                v:Destroy()
            end
        end
        fpsConnection = workspace.DescendantAdded:Connect(function(v)
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
            end
        end)
    else
        if fpsConnection then fpsConnection:Disconnect(); fpsConnection = nil end
    end
end

-- =================================================================
-- 5. ĐỒNG BỘ CHỈ SỐ HỆ THỐNG & BẢNG THỐNG KÊ REAL-TIME
-- =================================================================
local function FormatTime(sec)
    local h = math.floor(sec/3600)
    local m = math.floor((sec%3600)/60)
    local s = math.floor(sec%60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local fpsCount = 0
local lastFpsUpdate = os.clock()
local currentFps = 60

RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = os.clock()
    if now - lastFpsUpdate >= 1 then
        currentFps = fpsCount
        fpsCount = 0
        lastFpsUpdate = now
    end

    local ping = math.round(Stats.Network.ServerToClientPing:GetValue() * 1000)
    local ram = math.round(Stats:GetTotalMemoryUsageMb())

    HardwareStatsLabel.Text = string.format("FPS: %d | Ping: %dms | RAM: %dMB  ", currentFps, ping, ram)

    local serverTime = workspace:GetServerTimeNow() - ServerStart
    local joinTime = tick() - JoinTime

    StatsLabel.Text = 
        "📊 THỐNG KÊ SERVER\n\n"..
        "⏱️ Server mở: \n   " .. FormatTime(serverTime) .. "\n\n" ..
        "🕒 Bạn đã vào: \n   " .. FormatTime(joinTime) .. "\n\n" ..
        "👥 Người chơi: " .. #Players:GetPlayers() .. "\n\n" ..
        "👤 Người dùng:\n   " .. LocalPlayer.Name
end)

-- =================================================================
-- 6. KHỞI TẠO CÁC NÚT CHỨC NĂNG LÊN CONTENT SCROLL
-- =================================================================
createToggle("BẬT AIMBOT (KHÓA MỤC TIÊU)", 1, function(s) toggleAimbot(s) end)

local TargetBtn = createButton("🎯 KHÓA: TẤT CẢ (NPC + PLAYER)", 2, function()
    if State.Aim_Mode == "All" then State.Aim_Mode = "Players" TargetBtn.Text = "🎯 KHÓA: CHỈ NGƯỜI CHƠI"
    elseif State.Aim_Mode == "Players" then State.Aim_Mode = "NPCs" TargetBtn.Text = "🎯 KHÓA: CHỈ NPC / ZOMBIE"
    else State.Aim_Mode = "All" TargetBtn.Text = "🎯 KHÓA: TẤT CẢ (NPC + PLAYER)" end
    currentAimTarget = nil
end)

createToggle("BẬT FLY MOBILE (HƯỚNG VECTOR CHUẨN)", 3, function(s) toggleFly(s) end)
createToggle("HIỆU ỨNG RAINBOW CẦU VỒNG KHI CHẠY", 4, function(s) toggleVisualEffects("Rainbow", s) end)
createToggle("HIỆU ỨNG TUYẾT RƠI KHI CHẠY", 5, function(s) toggleVisualEffects("Snow", s) end)
createToggle("ĐI TRÊN TƯỜNG (SPIDER CLIMB)", 6, function(s) State.Spider_Enabled = s end)
createToggle("FREECAM (CAM TỰ DO - KHÓA NGƯỜI)", 7, function(s) toggleFreecam(s) end)

createButton("🎥 GÓC NHÌN THỨ NHẤT (1ST PERSON)", 8, function()
    LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
end)

createButton("📷 GÓC NHÌN THỨ BA (3RD PERSON)", 9, function()
    LocalPlayer.CameraMode = Enum.CameraMode.Classic
    LocalPlayer.CameraMinZoomDistance = 0.5
    LocalPlayer.CameraMaxZoomDistance = 128
end)

createToggle("HIỂN THỊ ESP BOX (KHUNG ĐỎ)", 10, function(s) State.ESP_Box = s end)
createToggle("HIỂN THỊ ESP NAME (TÊN + KHOẢNG CÁCH)", 11, function(s) State.ESP_Name = s end)
createToggle("NOCLIP (XUYÊN TƯỜNG)", 12, function(s) State.Noclip_Enabled = s end)
createToggle("INFINITE JUMP (NHẢY VÔ HẠN)", 13, function(s) State.InfJump_Enabled = s end)
createToggle("TỐI ƯU FPS ĐỒ HỌA (FPS BOOSTER)", 14, function(s) toggleFPS(s) end)

createButton("🚀 BẬT TỐC ĐỘ CHẠY NHANH (WALKSPEED = 80)", 15, function()
    State.WalkSpeed_Enabled = true State.WalkSpeed_Value = 80
end)
createButton("🦘 BẬT NHẢY CAO (JUMPPOWER = 120)", 16, function()
    State.JumpPower_Enabled = true State.JumpPower_Value = 120
end)
createButton("🔄 RESET TỐC ĐỘ & NHẢY VỀ MẶC ĐỊNH", 17, function()
    State.WalkSpeed_Enabled = false State.JumpPower_Enabled = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") h.WalkSpeed = 16 h.JumpPower = 50
    end
end)

-- Tự động kích hoạt lại các hiệu ứng hình ảnh sau khi hồi sinh
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if State.VisualEffects_Enabled and currentActiveEffect then
        toggleVisualEffects(currentActiveEffect, true)
    end
end)
