-- =================================================================
-- 1. KHỞI TẠO SERVICES HỆ THỐNG
-- =================================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

-- =================================================================
-- 2. KHAI BÁO BIẾN TOÀN CỤC & TRẠNG THÁI (SETTINGS)
-- =================================================================
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
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
    Freecam_Enabled = false,
    VisualEffects_Enabled = false,
    RainbowLoop = false,
    Aim_Enabled = false,
    Aim_Radius = 150,
    Aim_Mode = "All"
}

local Connections = {}
local FlyVelocity, FlyGyro
local currentActiveEffect, ActiveTrail, ActiveSparkles, ActiveSnowEmitter
local currentAimTarget = nil
local freecamCamPart = nil

-- Khởi tạo an toàn Drawing trên Delta Mobile
local FOVCircle = nil
if pcall(function() return Drawing and Drawing.new end) then
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        FOVCircle.Thickness = 1.5
        FOVCircle.Radius = State.Aim_Radius
        FOVCircle.Filled = false
        FOVCircle.Visible = false
    end)
end

-- =================================================================
-- 3. KHỞI TẠO GIAO DIỆN CHÍNH (TỐI ƯU CHO DELTA)
-- =================================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ThanhCongHub_Delta"
gui.ResetOnSpawn = false

-- Delta ưu tiên đưa vào CoreGui, nếu không được mới xuống PlayerGui
local successCore, _ = pcall(function() gui.Parent = CoreGui end)
if not successCore or gui.Parent == nil then
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 440, 0, 380)
Main.Position = UDim2.new(0.5, -220, 0.4, -190)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = false -- Giúp hiển thị mượt trên Mobile
Main.ZIndex = 2
Main.Parent = gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ThanhCong Hub v2.1.0"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 25)
Close.Position = UDim2.new(1, -45, 0, 8)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 14
Close.ZIndex = 10 -- Đẩy ZIndex lên cao nhất để Delta không bị đè nút bấm
Close.Parent = Main

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.new(0, 35, 0, 25)
Mini.Position = UDim2.new(1, -85, 0, 8)
Mini.Text = "-"
Mini.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
Mini.TextColor3 = Color3.new(1, 1, 1)
Mini.Font = Enum.Font.SourceSansBold
Mini.TextSize = 14
Mini.ZIndex = 10
Mini.Parent = Main

local Open = Instance.new("TextButton")
Open.Size = UDim2.new(0, 110, 0, 35)
Open.Position = UDim2.new(0, 15, 0, 15)
Open.Text = "OPEN MENU"
Open.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Open.TextColor3 = Color3.new(1, 1, 1)
Open.Font = Enum.Font.SourceSansBold
Open.TextSize = 13
Open.Visible = false
Open.ZIndex = 10
Open.Parent = gui

local function AddRainbowBorder(element, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 2
    stroke.Parent = element
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = element

    task.spawn(function()
        while gui.Parent and element.Parent do
            for i = 0, 1, 0.005 do
                if not element.Parent then break end
                stroke.Color = Color3.fromHSV(i, 1, 1)
                task.wait(0.02)
            end
        end
    end)
end

AddRainbowBorder(Main, 3)
AddRainbowBorder(Close, 1.5)
AddRainbowBorder(Mini, 1.5)
AddRainbowBorder(Open, 2)

-- =================================================================
-- 4. BẢNG THỐNG KÊ SERVER REAL-TIME & KHUNG CUỘN CHỨC NĂNG
-- =================================================================
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(0, 240, 1, -60)
ContentScroll.Position = UDim2.new(0, 15, 0, 50)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 650)
ContentScroll.ScrollBarThickness = 5
ContentScroll.ZIndex = 4
ContentScroll.Parent = Main

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim2.new(0, 6)
UIListLayout.Parent = ContentScroll

local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(0, 155, 1, -60)
StatsFrame.Position = UDim2.new(0, 270, 0, 50)
StatsFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 35)
StatsFrame.BorderSizePixel = 0
StatsFrame.ZIndex = 3
StatsFrame.Parent = Main
AddRainbowBorder(StatsFrame, 1.5)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -12, 1, -12)
StatsLabel.Position = UDim2.new(0, 6, 0, 6)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.Font = Enum.Font.SourceSansBold
StatsLabel.TextSize = 13
StatsLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
StatsLabel.ZIndex = 4
StatsLabel.Parent = StatsFrame

-- =================================================================
-- 5. CƠ CHẾ DRAG (KÉO THẢ) MỚI TỐI ƯU RIÊNG CHO MOBILE / DELTA
-- =================================================================
local DragBar = Instance.new("Frame")
DragBar.Size = UDim2.new(1, -90, 0, 40)
DragBar.Position = UDim2.new(0, 0, 0, 0)
DragBar.BackgroundTransparency = 1
DragBar.ZIndex = 4
DragBar.Parent = Main

local dragging = false
local dragStart, startPos

DragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local currMousePos = UserInputService:GetMouseLocation()
        local delta = currMousePos - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- LOGIC NÚT THU NHỎ / ĐÓNG / MỞ MENU
local minimized = false
Mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 440, 0, 40) or UDim2.new(0, 440, 0, 380)
    TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    Open.Visible = true
end)

Open.MouseButton1Click:Connect(function()
    Main.Visible = true
    Open.Visible = false
end)

-- =================================================================
-- 6. XỬ LÝ TOÀN BỘ CÁC HÀM TÍNH NĂNG CHẠY THỰC TẾ TRONG GAME
-- =================================================================
local function isVisible(targetChar, targetPart)
    return pcall(function()
        local castParams = RaycastParams.new()
        castParams.FilterType = Enum.RaycastFilterType.Exclude
        castParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
        local raycastResult = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, castParams)
        return raycastResult == nil
    end)
end

local function getClosestAimTarget()
    local closest, shortestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if State.Aim_Mode == "All" or State.Aim_Mode == "Players" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen and isVisible(p.Character, p.Character.Head) then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist <= State.Aim_Radius and dist < shortestDist then
                            shortestDist = dist
                            closest = p.Character.Head
                        end
                    end
                end
            end
        end
    end
    
    if State.Aim_Mode == "All" or State.Aim_Mode == "NPCs" then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("Model") and desc ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(desc) then
                local head = desc:FindFirstChild("Head") or desc:FindFirstChild("HumanoidRootPart")
                local hum = desc:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen and isVisible(desc, head) then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist <= State.Aim_Radius and dist < shortestDist then
                            shortestDist = dist
                            closest = head
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function toggleAimbot(enable)
    State.Aim_Enabled = enable
    if FOVCircle then FOVCircle.Visible = enable end
    if enable then
        local connection = RunService.RenderStepped:Connect(function()
            if FOVCircle then
                FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                FOVCircle.Radius = State.Aim_Radius
            end
            if currentAimTarget and currentAimTarget.Parent and currentAimTarget.Parent:FindFirstChildOfClass("Humanoid") and currentAimTarget.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, currentAimTarget.Position)
            else
                currentAimTarget = getClosestAimTarget()
            end
        end)
        table.insert(Connections, connection)
    end
end

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
        
        local connection = RunService.Heartbeat:Connect(function()
            if not State.Fly_Enabled or not char.Parent or not root.Parent then return end
            local moveDir = hum.MoveDirection
            local direction = Camera.CFrame.LookVector * (-moveDir.Z) + Camera.CFrame.RightVector * moveDir.X
            if direction.Magnitude > 0 then
                FlyVelocity.Velocity = direction.Unit * State.Fly_Speed
            else
                FlyVelocity.Velocity = Vector3.new(0, 0.1, 0)
            end
            FlyGyro.CFrame = Camera.CFrame
        end)
        table.insert(Connections, connection)
    else
        if FlyVelocity then FlyVelocity:Destroy() end
        if FlyGyro then FlyGyro:Destroy() end
    end
end

local function toggleVisualEffects(mode, enable)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    State.RainbowLoop = false
    for _, item in ipairs(root:GetChildren()) do
        if item.Name == "SnowEffect" or item.Name == "RainbowEffect" or item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Sparkles") or item:IsA("Attachment") then 
            item:Destroy() 
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
            ActiveTrail.Lifetime = 0.4
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
            ActiveSnowEmitter.Size = NumberSequence.new(0.3, 0)
            ActiveSnowEmitter.Lifetime = NumberRange.new(1, 2)
            ActiveSnowEmitter.Speed = NumberRange.new(3, 5)
            ActiveSnowEmitter.Acceleration = Vector3.new(0, -7, 0)
            ActiveSnowEmitter.Parent = root

            local connection = RunService.RenderStepped:Connect(function()
                if not ActiveSnowEmitter or not hum.Parent then return end
                ActiveSnowEmitter.Rate = (hum.MoveDirection.Magnitude > 0) and 55 or 0
            end)
            table.insert(Connections, connection)
        end
    else
        if mode == currentActiveEffect then
            State.VisualEffects_Enabled = false
            currentActiveEffect = nil
        end
    end
end

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

        local connection = RunService.RenderStepped:Connect(function()
            if not State.Freecam_Enabled or not freecamCamPart then return end
            Camera.CFrame = freecamCamPart.CFrame
            local speed = 1.5
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then freecamCamPart.CFrame *= CFrame.new(0, 0, -speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then freecamCamPart.CFrame *= CFrame.new(0, 0, speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then freecamCamPart.CFrame *= CFrame.new(-speed, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then freecamCamPart.CFrame *= CFrame.new(speed, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then freecamCamPart.CFrame *= CFrame.new(0, speed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then freecamCamPart.CFrame *= CFrame.new(0, -speed, 0) end
        end)
        table.insert(Connections, connection)
    else
        if freecamCamPart then freecamCamPart:Destroy() freecamCamPart = nil end
        if root then root.Anchored = false end
        Camera.CameraType = Enum.CameraType.Custom
    end
end

local function createESP(p)
    if State.ESP_Storage[p] then return end
    local box = nil
    local text = nil
    if FOVCircle then 
        box = Drawing.new("Square") box.Color = Color3.fromRGB(255, 50, 50) box.Thickness = 1.5 box.Filled = false box.Visible = false
        text = Drawing.new("Text") text.Color = Color3.fromRGB(255, 255, 255) text.Center = true text.Outline = true text.Visible = false
    end
    State.ESP_Storage[p] = {Box = box, Text = text}
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(p)
    if State.ESP_Storage[p] then
        if State.ESP_Storage[p].Box then State.ESP_Storage[p].Box:Destroy() end
        if State.ESP_Storage[p].Text then State.ESP_Storage[p].Text:Destroy() end
        State.ESP_Storage[p] = nil
    end
end)
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end end

local espConnection = RunService.RenderStepped:Connect(function()
    for player, esp in pairs(State.ESP_Storage) do
        if esp.Box and esp.Text and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local root = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen and (State.ESP_Name or State.ESP_Box) then
                        local distance = (Camera.CFrame.Position - root.Position).Magnitude
                    if State.ESP_Name then
                        esp.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                        esp.Text.Text = player.Name .. " [" .. math.round(distance) .. "m]"
                        esp.Text.Size = 14 
                        esp.Text.Visible = true
                    else 
                        esp.Text.Visible = false 
                    end
                    
                    if State.ESP_Box then
                        local sizeX, sizeY = 2000 / distance, 3000 / distance
                        esp.Box.Size = Vector2.new(sizeX, sizeY)
                        esp.Box.Position = Vector2.new(screenPos.X - (sizeX / 2), screenPos.Y - (sizeY / 2))
                        esp.Box.Visible = true
                    else 
                        esp.Box.Visible = false 
                    end
                else 
                    esp.Box.Visible = false 
                    esp.Text.Visible = false 
                end
            else 
                esp.Box.Visible = false 
                esp.Text.Visible = false 
            end
        elseif esp.Box and esp.Text then 
            esp.Box.Visible = false 
            esp.Text.Visible = false 
        end
    end
end)
table.insert(Connections, espConnection)

local loopConnection = RunService.PostSimulation:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if State.WalkSpeed_Enabled then hum.WalkSpeed = State.WalkSpeed_Value end
            if State.JumpPower_Enabled then hum.JumpPower = State.JumpPower_Value hum.UseJumpPower = true end
        end
        if State.Spider_Enabled then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local ray = Ray.new(root.Position, root.CFrame.LookVector * 1.8)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                if hit then root.Velocity = Vector3.new(root.Velocity.X, 35, root.Velocity.Z) end
            end
        end
    end
end)
table.insert(Connections, loopConnection)

local jumpConnection = UserInputService.JumpRequest:Connect(function()
    if State.InfJump_Enabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
table.insert(Connections, jumpConnection)

local noclipConnection = RunService.Stepped:Connect(function()
    if State.Noclip_Enabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)
table.insert(Connections, noclipConnection)

local fpsAssetConnection
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
        fpsAssetConnection = workspace.DescendantAdded:Connect(function(v)
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
            end
        end)
    else
        if fpsAssetConnection then fpsAssetConnection:Disconnect() end
    end
end

local function FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local uiStatsConnection = RunService.RenderStepped:Connect(function()
    local serverUptime = workspace:GetServerTimeNow() - ServerStart
    local userSession = tick() - JoinTime
    StatsLabel.Text = 
        "📊 THỐNG KÊ SERVER\n\n"..
        "⏱️ Server mở: \n   " .. FormatTime(serverUptime) .. "\n\n" ..
        "🕒 Bạn đã vào: \n   " .. FormatTime(userSession) .. "\n\n" ..
        "👥 Người chơi: " .. #Players:GetPlayers() .. "\n\n" ..
        "👤 Người dùng:\n   " .. LocalPlayer.Name
end)
table.insert(Connections, uiStatsConnection)

-- =================================================================
-- 8. HÀM PHỤ TRỢ TẠO THÀNH PHẦN NÚT THỰC THI GIAO DIỆN (ZINDEX ĐẨY CAO)
-- =================================================================
local function createToggle(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = "  [ TẮT ] " .. text
    btn.TextColor3 = Color3.fromRGB(185, 185, 185)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.ZIndex = 6
    btn.Parent = ContentScroll
    AddRainbowBorder(btn, 1.5)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.BackgroundColor3 = Color3.fromRGB(0, 140, 90)
            btn.Text = "  [ BẬT ] " .. text
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            btn.Text = "  [ TẮT ] " .. text
            btn.TextColor3 = Color3.fromRGB(185, 185, 185)
        end
        task.spawn(function()
            local success, err = pcall(callback, active)
            if not success then warn("Lỗi xử lý tính năng: " .. tostring(err)) end
        end)
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
    btn.ZIndex = 6
    btn.Parent = ContentScroll
    AddRainbowBorder(btn, 1.5)

    btn.MouseButton1Click:Connect(function()
        task.spawn(function()
            local success, err = pcall(callback)
            if not success then warn("Lỗi thực thi nút bấm: " .. tostring(err)) end
        end)
    end)
    return btn
end

-- =================================================================
-- 9. KẾT NỐI GUI VỚI CHỨC NĂNG (KHỞI TẠO NÚT BẤM)
-- =================================================================
createToggle("BẬT AIMBOT LOCK MỤC TIÊU", 1, function(state) toggleAimbot(state) end)

local TargetModeBtn = createButton("🎯 MỤC TIÊU: TẤT CẢ (NPC + PLAYER)", 2, function()
    if State.Aim_Mode == "All" then 
        State.Aim_Mode = "Players" 
        TargetModeBtn.Text = "🎯 MỤC TIÊU: CHỈ NGƯỜI CHƠI"
    elseif State.Aim_Mode == "Players" then 
        State.Aim_Mode = "NPCs" 
        TargetModeBtn.Text = "🎯 MỤC TIÊU: CHỈ NPC / ZOMBIE"
    else 
        State.Aim_Mode = "All" 
        TargetModeBtn.Text = "🎯 MỤC TIÊU: TẤT CẢ (NPC + PLAYER)" 
    end
    currentAimTarget = nil
end)

createToggle("BẬT FLY MOBILE CHUẨN VECTOR", 3, function(state) toggleFly(state) end)
createToggle("HIỆU ỨNG CẦU VỒNG (RAINBOW TRAIL)", 4, function(state) toggleVisualEffects("Rainbow", state) end)
createToggle("HIỆU ỨNG TUYẾT RƠI KHI DI CHUYỂN", 5, function(state) toggleVisualEffects("Snow", state) end)
createToggle("BẬT ĐI TRÊN TƯỜNG (SPIDER CLIMB)", 6, function(state) State.Spider_Enabled = state end)
createToggle("FREECAM (CAMERA TỰ DO BAY LƯỢN)", 7, function(state) toggleFreecam(state) end)

createButton("🎥 GÓC NHÌN THỨ NHẤT (LOCK 1ST PERSON)", 8, function()
    LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
end)

createButton("📷 GÓC NHÌN THỨ BA (CLASSIC 3RD PERSON)", 9, function()
    LocalPlayer.CameraMode = Enum.CameraMode.Classic
    LocalPlayer.CameraMinZoomDistance = 0.5
    LocalPlayer.CameraMaxZoomDistance = 128
end)

createToggle("HIỂN THỊ ESP BOX KHUNG ĐỎ", 10, function(state) State.ESP_Box = state end)
createToggle("HIỂN THỊ ESP NAME TÊN & KHOẢNG CÁCH", 11, function(state) State.ESP_Name = state end)
createToggle("XUYÊN TƯỜNG (NOCLIP HỆ THỐNG)", 12, function(state) State.Noclip_Enabled = state end)
createToggle("NHẢY VÔ HẠN (INFINITE JUMP)", 13, function(state) State.InfJump_Enabled = state end)
createToggle("TỐI ƯU FPS GIẢM ĐỒ HỌA (FPS BOOSTER)", 14, function(state) toggleFPS(state) end)

createButton("🚀 KÍCH TỐC ĐỘ CHẠY (WALKSPEED = 80)", 15, function()
    State.WalkSpeed_Enabled = true 
    State.WalkSpeed_Value = 80
end)

createButton("🦘 KÍCH ĐỘ CAO NHẢY (JUMPPOWER = 120)", 16, function()
    State.JumpPower_Enabled = true 
    State.JumpPower_Value = 120
end)

createButton("🔄 RESET TỐC ĐỘ & NHẢY VỀ MẶC ĐỊNH", 17, function()
    State.WalkSpeed_Enabled = false 
    State.JumpPower_Enabled = false
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then 
        hum.WalkSpeed = 16 
        hum.JumpPower = 50 
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.2)
    if State.VisualEffects_Enabled and currentActiveEffect then
        toggleVisualEffects(currentActiveEffect, true)
    end
end)

