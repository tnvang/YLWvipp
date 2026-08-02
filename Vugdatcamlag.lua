local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local StreakFile = "TnVanHub_Streak.txt"
local CurrentStreak = 1

if readfile and writefile then
    if pcall(function() return readfile(StreakFile) end) then
        local savedStreak = tonumber(readfile(StreakFile))
        if savedStreak then
            CurrentStreak = savedStreak + 1
        end
    end
    pcall(function() writefile(StreakFile, tostring(CurrentStreak)) end)
end

local Config = {
    PlayerESP = false,
    WeaponESP = false,
    ItemESP = false,
    FoodESP = false,
    NameESP = false,
    Tracer = false,
    Box = false,
    Health = false,
    BoostFPS = false,
    SpeedHack = false,
    JumpHack = false,
    MaxDistance = 600
}

local Weapons = {"pistol", "flare", "knife", "rifle", "sniper", "hammer", "machete", "shotgun", "bat", "axe", "crowbar", "ak", "m4", "gun", "sword", "blade"}
local Items = {"bandage", "bullet", "binocular", "medkit", "med", "painkiller", "syringe", "backpack", "bag", "flashlight", "armor", "vest", "gas", "mask", "ammo", "pack"}
local Foods = {"apple", "cola", "water", "canned", "can", "chips", "chocolate", "food", "drink", "snack"}

local CachedObjects = {}
local DrawingCache = {}
local HighlightCache = {}
local TypeCache = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TnVanHub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "• Tn Vàn dz | Vùng Đất Câm Lặng •"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 30, 0, 25)
ToggleBtn.Position = UDim2.new(1, -35, 0, 5)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
ToggleBtn.Text = "-"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.TextSize = 18
ToggleBtn.Parent = TopBar

local IsCollapsed = false
ToggleBtn.MouseButton1Click:Connect(function()
    IsCollapsed = not IsCollapsed
    if IsCollapsed then
        MainFrame:TweenSize(UDim2.new(0, 480, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        ToggleBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 480, 0, 320), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        ToggleBtn.Text = "-"
    end
end)

local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(0, 150, 0, 40)
ProfileFrame.Position = UDim2.new(0, 10, 0, 40)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(25, 5, 5)
ProfileFrame.BorderSizePixel = 0
ProfileFrame.Parent = MainFrame

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 6)
ProfileCorner.Parent = ProfileFrame

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(0, 32, 0, 32)
AvatarImg.Position = UDim2.new(0, 4, 0, 4)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
AvatarImg.Parent = ProfileFrame

local PlayerName = Instance.new("TextLabel")
PlayerName.Size = UDim2.new(1, -45, 1, 0)
PlayerName.Position = UDim2.new(0, 42, 0, 0)
PlayerName.BackgroundTransparency = 1
PlayerName.Text = LocalPlayer.DisplayName
PlayerName.TextColor3 = Color3.fromRGB(255, 100, 100)
PlayerName.Font = Enum.Font.Code
PlayerName.TextSize = 12
PlayerName.TextXAlignment = Enum.TextXAlignment.Left
PlayerName.Parent = ProfileFrame

local InfoSidebar = Instance.new("Frame")
InfoSidebar.Size = UDim2.new(0, 150, 0, 215)
InfoSidebar.Position = UDim2.new(0, 10, 0, 90)
InfoSidebar.BackgroundColor3 = Color3.fromRGB(20, 2, 2)
InfoSidebar.BorderSizePixel = 0
InfoSidebar.Parent = MainFrame

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 6)
InfoCorner.Parent = InfoSidebar

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -10, 1, -10)
InfoText.Position = UDim2.new(0, 5, 0, 5)
InfoText.BackgroundTransparency = 1
InfoText.TextColor3 = Color3.fromRGB(255, 120, 120)
InfoText.Font = Enum.Font.Code
InfoText.TextSize = 11
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextWrapped = true
InfoText.Parent = InfoSidebar

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -185, 0, 265)
ContentFrame.Position = UDim2.new(0, 170, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)
UIList.Parent = ContentFrame

local function CreateToggle(text, configKey, onClick)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 30)
    Button.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    Button.BorderSizePixel = 0
    Button.Text = "  📌 " .. text
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.Font = Enum.Font.Code
    Button.TextSize = 13
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = ContentFrame

    local Status = Instance.new("Frame")
    Status.Size = UDim2.new(0, 14, 0, 14)
    Status.Position = UDim2.new(1, -22, 0.5, -7)
    Status.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Status.BorderSizePixel = 0
    Status.Parent = Button

    Button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        if Config[configKey] then
            Status.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Status.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        if onClick then onClick(Config[configKey]) end
    end)
end

CreateToggle("ESP Người Chơi", "PlayerESP")
CreateToggle("ESP Vũ Khí", "WeaponESP")
CreateToggle("ESP Vật Phẩm", "ItemESP")
CreateToggle("ESP Thực Phẩm", "FoodESP")
CreateToggle("Hiện Tên & Khoảng Cách", "NameESP")
CreateToggle("Đường Kẻ (Tracer)", "Tracer")
CreateToggle("Khung (Box)", "Box")
CreateToggle("Thanh Máu", "Health")
CreateToggle("Bật Chạy Nhanh", "SpeedHack")
CreateToggle("Bật Nhảy Cao", "JumpHack")

CreateToggle("Tăng FPS / Giảm Lag", "BoostFPS", function(state)
    if state then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = 1
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled = false
            end
        end
    end
end)

local function GetCategory(name)
    if TypeCache[name] ~= nil then return TypeCache[name] end
    local lowerName = string.lower(name)
    for _, v in ipairs(Weapons) do
        if string.find(lowerName, v) then
            TypeCache[name] = "Weapon"
            return "Weapon"
        end
    end
    for _, v in ipairs(Items) do
        if string.find(lowerName, v) then
            TypeCache[name] = "Item"
            return "Item"
        end
    end
    for _, v in ipairs(Foods) do
        if string.find(lowerName, v) then
            TypeCache[name] = "Food"
            return "Food"
        end
    end
    TypeCache[name] = false
    return false
end

local function GetPrimaryPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart end
        return obj:FindFirstChildWhichIsA("BasePart", true)
    end
    if obj:IsA("Tool") then
        local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
        return handle
    end
    return obj:FindFirstChildWhichIsA("BasePart", true)
end

local function GetDrawing(inst)
    if not DrawingCache[inst] then
        DrawingCache[inst] = {
            Text = Drawing.new("Text"),
            Tracer = Drawing.new("Line"),
            Box = Drawing.new("Square"),
            HealthBg = Drawing.new("Line"),
            HealthMain = Drawing.new("Line")
        }
        local d = DrawingCache[inst]
        d.Text.Size = 13
        d.Text.Center = true
        d.Text.Outline = true
        d.Text.Color = Color3.fromRGB(255, 255, 255)
        d.Text.Font = 2

        d.Tracer.Thickness = 1
        d.Tracer.Color = Color3.fromRGB(255, 0, 0)

        d.Box.Thickness = 1
        d.Box.Color = Color3.fromRGB(255, 0, 0)
        d.Box.Filled = false

        d.HealthBg.Thickness = 3
        d.HealthBg.Color = Color3.fromRGB(0, 0, 0)

        d.HealthMain.Thickness = 1.5
        d.HealthMain.Color = Color3.fromRGB(0, 255, 0)
    end
    return DrawingCache[inst]
end

local function ApplyHighlight(obj, category)
    if not HighlightCache[obj] then
        local hl = Instance.new("Highlight")
        hl.Adornee = obj
        hl.FillTransparency = 0.3
        hl.OutlineTransparency = 0
        hl.Parent = CoreGui

        if category == "Weapon" then
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        elseif category == "Item" then
            hl.FillColor = Color3.fromRGB(0, 255, 100)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        elseif category == "Food" then
            hl.FillColor = Color3.fromRGB(255, 220, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
        HighlightCache[obj] = hl
    end
    return HighlightCache[obj]
end

local function TrackObject(obj)
    if obj:IsDescendantOf(Players) then return end
    local cat = GetCategory(obj.Name)
    if cat then
        local part = GetPrimaryPart(obj)
        if part then
            CachedObjects[obj] = {Object = obj, Part = part, Category = cat}
        end
    end
end

for _, obj in ipairs(workspace:GetDescendants()) do TrackObject(obj) end
workspace.DescendantAdded:Connect(TrackObject)

local FrameCount = 0
local Fps = 60
local LastFpsCheck = tick()

RunService.RenderStepped:Connect(function(deltaTime)
    FrameCount = FrameCount + 1
    if tick() - LastFpsCheck >= 1 then
        Fps = FrameCount
        FrameCount = 0
        LastFpsCheck = tick()
    end

    InfoText.Text = "🎮 Game:\n Vùng Đất Câm Lặng\n\n🔥 Chuỗi Chạy:\n Chuỗi " .. CurrentStreak .. "🔥\n\n💬 Discord:\n cammuoilupro\n\n⚡ FPS: " .. Fps .. " | Scope: 600m"

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if character and humanoid and rootPart and humanoid.Health > 0 then
        if Config.JumpHack then
            humanoid.JumpPower = 120
        else
            humanoid.JumpPower = 50
        end

        if Config.SpeedHack then
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                local targetVelocity = moveDir * 65
                rootPart.AssemblyLinearVelocity = Vector3.new(
                    targetVelocity.X,
                    rootPart.AssemblyLinearVelocity.Y,
                    targetVelocity.Z
                )
            end
        end
    end

    for inst, drawTable in pairs(DrawingCache) do
        for _, drawObj in pairs(drawTable) do
            drawObj.Visible = false
        end
    end

    for obj, hl in pairs(HighlightCache) do
        hl.Enabled = false
    end

    local camPos = Camera.CFrame.Position
    local viewportSize = Camera.ViewportSize

    if Config.PlayerESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")

                if hrp and hum then
                    local dist = (camPos - hrp.Position).Magnitude
                    if dist <= Config.MaxDistance then
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local draw = GetDrawing(player)
                            if Config.NameESP then
                                draw.Text.Text = player.Name .. " [" .. math.floor(dist) .. "m]"
                                draw.Text.Position = Vector2.new(pos.X, pos.Y - 25)
                                draw.Text.Visible = true
                            end

                            if Config.Tracer then
                                draw.Tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                                draw.Tracer.To = Vector2.new(pos.X, pos.Y)
                                draw.Tracer.Visible = true
                            end

                            if Config.Box then
                                local sizeY = math.clamp((1000 / pos.Z) * 2, 10, 300)
                                local sizeX = sizeY * 0.6
                                draw.Box.Size = Vector2.new(sizeX, sizeY)
                                draw.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                                draw.Box.Visible = true

                                if Config.Health then
                                    local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                    local barPos = Vector2.new(pos.X - sizeX / 2 - 5, pos.Y + sizeY / 2)
                                    draw.HealthBg.From = barPos
                                    draw.HealthBg.To = Vector2.new(barPos.X, barPos.Y - sizeY)
                                    draw.HealthBg.Visible = true

                                    draw.HealthMain.From = barPos
                                    draw.HealthMain.To = Vector2.new(barPos.X, barPos.Y - (sizeY * healthPct))
                                    draw.HealthMain.Color = Color3.fromRGB(255 - (255 * healthPct), 255 * healthPct, 0)
                                    draw.HealthMain.Visible = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for obj, entry in pairs(CachedObjects) do
        if not obj or not obj.Parent or obj:IsDescendantOf(Players) then
            if HighlightCache[obj] then
                HighlightCache[obj]:Destroy()
                HighlightCache[obj] = nil
            end
            CachedObjects[obj] = nil
        else
            local shouldShow = false
            if entry.Category == "Weapon" and Config.WeaponESP then shouldShow = true end
            if entry.Category == "Item" and Config.ItemESP then shouldShow = true end
            if entry.Category == "Food" and Config.FoodESP then shouldShow = true end

            if shouldShow then
                local dist = (camPos - entry.Part.Position).Magnitude
                if dist <= Config.MaxDistance then
                    local hl = ApplyHighlight(obj, entry.Category)
                    hl.Enabled = true

                    local pos, onScreen = Camera:WorldToViewportPoint(entry.Part.Position)
                    if onScreen then
                        local draw = GetDrawing(obj)
                        if Config.NameESP then
                            draw.Text.Text = obj.Name .. " [" .. math.floor(dist) .. "m]"
                            draw.Text.Position = Vector2.new(pos.X, pos.Y)
                            draw.Text.Visible = true
                        end

                        if Config.Tracer then
                            draw.Tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                            draw.Tracer.To = Vector2.new(pos.X, pos.Y)
                            draw.Tracer.Visible = true
                        end
                    end
                end
            end
        end
    end
end)

