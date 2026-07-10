-- =================================================================
-- 1. KHỞI TẠO HỆ THỐNG & BIẾN TOÀN CỤC
-- =================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

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
    FPS_Enabled = false,
    Aim_Enabled = false,
    Aim_Radius = 150,
    Aim_Mode = "All",
    Hitbox_Enabled = false,
    Hitbox_Size = 2,
    Hitbox_Transparency = 0.5,
    Hitbox_Originals = {},
    Menu_Visible = true
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

-- Danh sách lưu các nút để chạy hiệu ứng Rainbow màu sắc
local RainbowUIObjects = {}

-- =================================================================
-- 2. TẠO GIAO DIỆN MENU UI CHÍNH (GIAO DIỆN RAINBOW THẾ HỆ MỚI)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThanhCong_v1.2.0_Rainbow"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Khung Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 360)
MainFrame.Position = UDim2.new(0.5, -210, 0.4, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- VIỀN MENU HIỆU ỨNG RAINBOW
local MenuStroke = Instance.new("UIStroke")
MenuStroke.Thickness = 2.5
MenuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MenuStroke.LineJoinMode = Enum.LineJoinMode.Round
MenuStroke.Parent = MainFrame
table.insert(RainbowUIObjects, MenuStroke)

-- Thanh Tiêu Đề
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 10)

-- Viền ngăn cách dưới thanh tiêu đề
local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, 0, 0, 1)
TitleLine.Position = UDim2.new(0, 0, 1, -1)
TitleLine.BorderSizePixel = 0
TitleLine.Parent = TitleBar
table.insert(RainbowUIObjects, TitleLine)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "THÀNH CÔNG HUB v1.2.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Nút Thu Nhỏ/Đóng ngay góc Menu
local CloseCornerBtn = Instance.new("TextButton")
CloseCornerBtn.Size = UDim2.new(0, 30, 0, 30)
CloseCornerBtn.Position = UDim2.new(1, -35, 0, 6)
CloseCornerBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
CloseCornerBtn.Text = "X"
CloseCornerBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
CloseCornerBtn.Font = Enum.Font.SourceSansBold
CloseCornerBtn.TextSize = 14
CloseCornerBtn.Parent = TitleBar
Instance.new("UICorner", CloseCornerBtn).CornerRadius = UDim.new(0, 6)

-- Vùng chứa danh sách chức năng (Trái)
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(0, 240, 1, -55)
ContentScroll.Position = UDim2.new(0, 10, 0, 50)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 750)
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
ContentScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim2.new(0, 6)
UIListLayout.Parent = ContentScroll

-- Vùng Bảng Thống Kê Server (Phải)
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(0, 150, 1, -55)
StatsFrame.Position = UDim2.new(0, 260, 0, 50)
StatsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
StatsFrame.Parent = MainFrame
Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 8)

local StatsStroke = Instance.new("UIStroke")
StatsStroke.Thickness = 1
StatsStroke.Color = Color3.fromRGB(45, 45, 50)
StatsStroke.Parent = StatsFrame

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -12, 1, -12)
StatsLabel.Position = UDim2.new(0, 6, 0, 6)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.Font = Enum.Font.SourceSansBold
StatsLabel.TextSize = 13
StatsLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
StatsLabel.Parent = StatsFrame

-- =================================================================
-- 3. HÀM PHỤ TRỢ TẠO NÚT TRÊN UI (TÍCH HỢP VIỀN/CHỮ RAINBOW)
-- =================================================================
local function createToggle(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    btn.Text = "   [ TẮT ]  " .. text
    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.Parent = ContentScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1
    btnStroke.Color = Color3.fromRGB(40, 40, 45)
    btnStroke.Parent = btn

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.BackgroundColor3 = Color3.fromRGB(15, 35, 25)
            btn.Text = "   [ BẬT ]  " .. text
            -- Thêm vào danh sách đổi màu chữ Rainbow khi bật
            table.insert(RainbowUIObjects, btn)
            btnStroke.Thickness = 1.5
            table.insert(RainbowUIObjects, btnStroke)
        else
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
            btn.Text = "   [ TẮT ]  " .. text
            btn.TextColor3 = Color3.fromRGB(160, 160, 160)
            btnStroke.Color = Color3.fromRGB(40, 40, 45)
            btnStroke.Thickness = 1
            
            -- Loại bỏ khỏi hàng đợi Rainbow khi tắt
            for i, v in ipairs(RainbowUIObjects) do
                if v == btn or v == btnStroke then table.remove(RainbowUIObjects, i) end
            end
        end
        callback(enabled)
    end)
    return btn
end

local function createButton(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.LayoutOrder = order
    btn.Parent = ContentScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    -- Các nút nhấn mặc định sẽ có viền Rainbow chạy liên tục
    table.insert(RainbowUIObjects, btnStroke)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Nút Thu Nhỏ Menu (Nút bay tự do trên màn hình để mở lại)
local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Size = UDim2.new(0, 90, 0, 32)
OpenCloseBtn.Position = UDim2.new(0, 15, 0, 15)
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
OpenCloseBtn.Text = "Mở Menu"
OpenCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseBtn.Font = Enum.Font.SourceSansBold
OpenCloseBtn.TextSize = 13
OpenCloseBtn.Visible = false
OpenCloseBtn.Parent = ScreenGui
Instance.new("UICorner", OpenCloseBtn).CornerRadius = UDim.new(0, 6)

local OpenBtnStroke = Instance.new("UIStroke")
OpenBtnStroke.Thickness = 2
OpenBtnStroke.Parent = OpenCloseBtn
table.insert(RainbowUIObjects, OpenBtnStroke)
table.insert(RainbowUIObjects, OpenCloseBtn)

-- HÀM ĐÓNG MỞ MENU CÓ HIỆU ỨNG MỜ DẦN (TWEEN)
local function ToggleMenuWindow(show)
    State.Menu_Visible = show
    if show then
        MainFrame.Visible = true
        OpenCloseBtn.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 420, 0, 360)}):Play()
        task.wait(0.05)
        for _, child in ipairs(MainFrame:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ScrollingFrame") then
                TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = child:IsA("TextLabel") and 1 or 0}):Play()
            end
        end
    else
        for _, child in ipairs(MainFrame:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ScrollingFrame") then
                if child ~= TitleBar and child ~= TitleLabel and child ~= CloseCornerBtn then
                    TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
                end
            end
        end
        task.wait(0.1)
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 420, 0, 0)}):Play()
        task.wait(0.2)
        MainFrame.Visible = false
        OpenCloseBtn.Visible = true
    end
end

CloseCornerBtn.MouseButton1Click:Connect(function() ToggleMenuWindow(false) end)
OpenCloseBtn.MouseButton1Click:Connect(function() ToggleMenuWindow(true) end)


-- VÒNG LẶP LIÊN TỤC CẬP NHẬT MÀU SẮC RAINBOW CHO UI
RunService.RenderStepped:Connect(function()
    local hue = (tick() % 4) / 4 -- Tốc độ chuyển màu Rainbow mượt mà
    local color = Color3.fromHSV(hue, 0.9, 1)
    
    for _, uiObj in ipairs(RainbowUIObjects) do
        if uiObj and uiObj.Parent then
            if uiObj:IsA("UIStroke") then
                uiObj.Color = color
            elseif uiObj:IsA("TextButton") then
                uiObj.TextColor3 = color
            elseif uiObj:IsA("Frame") then
                uiObj.BackgroundColor3 = color
            end
        end
    end
end)

-- =================================================================
-- 4. LOGIC XỬ LÝ TOÀN BỘ CÁC CHỨC NĂNG (GIỮ NGUYÊN 100%)
-- =================================================================

-- CHỨC NĂNG: XỬ LÝ HIỆU ỨNG RAINBOW VÀ TUYẾT RƠI KHI DI CHUYỂN
local function toggleVisualEffects(mode, enable)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if snowRenderConnection then snowRenderConnection:Disconnect(); snowRenderConnection = nil end
    if State.RainbowLoop then State.RainbowLoop = false end
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

-- CHỨC NĂNG: FREECAM (DI CHUYỂN CAM THOẢI MÁI NHƯNG NHÂN VẬT ĐỨNG IM)
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
        
        FlyVelocity = Instance.new("BodyVelocity")
        FlyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        FlyVelocity.Parent = root
        
        FlyGyro = Instance.new("BodyGyro")
        FlyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        FlyGyro.Parent = root
        
        flyRenderConnection = RunService.Heartbeat:Connect(function()
            if not State.Fly_Enabled or not char.Parent or not root.Parent then return end
            local moveDir = hum.MoveDirection
            local camCFrame = Camera.CFrame
            local direction = camCFrame.LookVector * (-moveDir.Z) + camCFrame.RightVector * moveDir.X
            if direction.Magnitude > 0 then
                FlyVelocity.Velocity = direction.Unit * State.Fly_Speed
            else
                FlyVelocity.Velocity = Vector3.new(0, 0.1, 0)
            end
            FlyGyro.CFrame = camCFrame
        end)
    else
        if flyRenderConnection then flyRenderConnection:Disconnect() end
        if FlyVelocity then FlyVelocity:Destroy() end
        if FlyGyro then FlyGyro:Destroy() end
    end
end

-- CHỨC NĂNG: QUÉT SÂU AIMBOT CHO NPC & NGƯỜI CHƠI
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

-- LOGIC PHỤ TRỢ: ESP KHUNG VÀ TÊN
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

-- VÒNG LẶP DI CHUYỂN, NHẢY VÀ XUYÊN TƯỜNG
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

-- =================================================================
-- 5. ĐỒNG BỘ BẢNG THỐNG KÊ REAL-TIME
-- =================================================================
local function FormatTime(sec)
    local h = math.floor(sec/3600)
    local m = math.floor((sec%3600)/60)
    local s = math.floor(sec%60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

RunService.RenderStepped:Connect(function()
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

createToggle("BẬT FLY MOBILE (HƯỚNG CHUẨN VECTOR)", 3, function(s) toggleFly(s) end)
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

createButton("🚀 BẬT TỐC ĐỘ CHẠY NHANH (WALKSPEED = 80)", 14, function()
    State.WalkSpeed_Enabled = true State.WalkSpeed_Value = 80
end)
createButton("🦘 BẬT NHẢY CAO (JUMPPOWER = 120)", 15, function()
    State.JumpPower_Enabled = true State.JumpPower_Value = 120
end)
createButton("🔄 RESET TỐC ĐỘ & NHẢY VỀ MẶC ĐỊNH", 16, function()
    State.WalkSpeed_Enabled = false State.JumpPower_Enabled = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") h.WalkSpeed = 16 h.JumpPower = 50
    end
end)

-- Tự động bật lại hiệu ứng khi nhân vật hồi sinh
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if State.VisualEffects_Enabled and currentActiveEffect then
        toggleVisualEffects(currentActiveEffect, true)
    end
end)

