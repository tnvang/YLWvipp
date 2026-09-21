local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local OldGui = PlayerGui:FindFirstChild("PhucLamFixLag")
if OldGui then
    OldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "PhúcLâmFixLag"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

local function new(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function corner(obj, radius)
    new("UICorner", {
        Parent = obj,
        CornerRadius = UDim.new(0, radius)
    })
end

local function stroke(obj, color, thickness, transparency)
    new("UIStroke", {
        Parent = obj,
        Color = color,
        Thickness = thickness,
        Transparency = transparency or 0
    })
end

local Loading = new("Frame", {
    Parent = Gui,
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(8, 8, 14),
    BorderSizePixel = 0
})

local LoadTitle = new("TextLabel", {
    Parent = Loading,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.45),
    Size = UDim2.fromScale(0.9, 0.1),
    BackgroundTransparency = 1,
    Text = "ĐANG TẢI SCRIPT Fix Lag",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold
})

local LoadSub = new("TextLabel", {
    Parent = Loading,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.54),
    Size = UDim2.fromScale(0.9, 0.05),
    BackgroundTransparency = 1,
    Text = "Fix lag+FPS Boost+Tối ưu máy Phúc Lâm Fix Lag",
    TextColor3 = Color3.fromRGB(120, 190, 255),
    TextScaled = true,
    Font = Enum.Font.Gotham
})

local BarBack = new("Frame", {
    Parent = Loading,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.62),
    Size = UDim2.fromScale(0.65, 0.018),
    BackgroundColor3 = Color3.fromRGB(35, 35, 45),
    BorderSizePixel = 0
})
corner(BarBack, 10)

local Bar = new("Frame", {
    Parent = BarBack,
    Size = UDim2.fromScale(0, 1),
    BackgroundColor3 = Color3.fromRGB(70, 170, 255),
    BorderSizePixel = 0
})
corner(Bar, 10)

TweenService:Create(
    Bar,
    TweenInfo.new(2, Enum.EasingStyle.Linear),
    {Size = UDim2.fromScale(1, 1)}
):Play()

task.wait(2)

LoadTitle.Text = "PHÚC LÂM FIX LAG"
LoadTitle.TextColor3 = Color3.fromRGB(255, 215, 80)
LoadSub.Text = "TỐI ƯU MÁY • FPS BOOST • FIX LAG"

task.wait(0.8)

Loading:Destroy()

local Main = new("Frame", {
    Parent = Gui,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0, 330, 0, 360),
    BackgroundColor3 = Color3.fromRGB(12, 14, 22),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ClipsDescendants = true
})
corner(Main, 18)
stroke(Main, Color3.fromRGB(70, 170, 255), 1.5)

local Header = new("Frame", {
    Parent = Main,
    Size = UDim2.new(1, 0, 0, 62),
    BackgroundTransparency = 1
})

local Title = new("TextLabel", {
    Parent = Header,
    Position = UDim2.new(0, 18, 0, 8),
    Size = UDim2.new(1, -110, 0, 27),
    BackgroundTransparency = 1,
    Text = "PHÚC LÂM FIX LAG",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Color3.fromRGB(255, 220, 90),
    TextScaled = true,
    Font = Enum.Font.GothamBlack
})

local Version = new("TextLabel", {
    Parent = Header,
    Position = UDim2.new(0, 20, 0, 37),
    Size = UDim2.new(1, -110, 0, 18),
    BackgroundTransparency = 1,
    Text = "Tác giả• Tvàn dz",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Color3.fromRGB(140, 170, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham
})

local Minimize = new("TextButton", {
    Parent = Header,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -52, 0, 12),
    Size = UDim2.new(0, 34, 0, 34),
    BackgroundColor3 = Color3.fromRGB(35, 38, 48),
    Text = "—",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = true
})
corner(Minimize, 10)

local Close = new("TextButton", {
    Parent = Header,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -12, 0, 12),
    Size = UDim2.new(0, 34, 0, 34),
    BackgroundColor3 = Color3.fromRGB(35, 38, 48),
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = true
})
corner(Close, 10)

local StatsBox = new("Frame", {
    Parent = Main,
    Position = UDim2.new(0, 14, 0, 70),
    Size = UDim2.new(1, -28, 0, 78),
    BackgroundColor3 = Color3.fromRGB(20, 23, 34),
    BorderSizePixel = 0
})
corner(StatsBox, 14)
stroke(StatsBox, Color3.fromRGB(45, 55, 75), 1)

local FPSLabel = new("TextLabel", {
    Parent = StatsBox,
    Position = UDim2.new(0, 12, 0, 8),
    Size = UDim2.new(0.33, -8, 0, 28),
    BackgroundTransparency = 1,
    Text = "FPS\n--",
    TextColor3 = Color3.fromRGB(100, 220, 130),
    TextScaled = true,
    Font = Enum.Font.GothamBold
})

local CPULabel = new("TextLabel", {
    Parent = StatsBox,
    Position = UDim2.new(0.33, 0, 0, 8),
    Size = UDim2.new(0.34, 0, 0, 28),
    BackgroundTransparency = 1,
    Text = "CPU\n--",
    TextColor3 = Color3.fromRGB(255, 210, 90),
    TextScaled = true,
    Font = Enum.Font.GothamBold
})

local GPULabel = new("TextLabel", {
    Parent = StatsBox,
    Position = UDim2.new(0.67, 0, 0, 8),
    Size = UDim2.new(0.33, -12, 0, 28),
    BackgroundTransparency = 1,
    Text = "GPU\n--",
    TextColor3 = Color3.fromRGB(100, 190, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold
})

local Status = new("TextLabel", {
    Parent = StatsBox,
    Position = UDim2.new(0, 10, 1, -24),
    Size = UDim2.new(1, -20, 0, 18),
    BackgroundTransparency = 1,
    Text = "Trạng thái: Hoạt động ✅",
    TextColor3 = Color3.fromRGB(170, 180, 195),
    TextScaled = true,
    Font = Enum.Font.Gotham
})

local Buttons = new("Frame", {
    Parent = Main,
    Position = UDim2.new(0, 14, 0, 158),
    Size = UDim2.new(1, -28, 0, 184),
    BackgroundTransparency = 1
})

new("UIListLayout", {
    Parent = Buttons,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local function makeButton(text, description, order)
    local B = new("TextButton", {
        Parent = Buttons,
        Size = UDim2.new(1, 0, 0, 53),
        BackgroundColor3 = Color3.fromRGB(23, 27, 39),
        BorderSizePixel = 0,
        Text = "",
        LayoutOrder = order,
        AutoButtonColor = false
    })
    corner(B, 13)
    stroke(B, Color3.fromRGB(45, 55, 75), 1)

    new("TextLabel", {
        Parent = B,
        Position = UDim2.new(0, 14, 0, 6),
        Size = UDim2.new(1, -28, 0, 21),
        BackgroundTransparency = 1,
        Text = text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromRGB(245, 245, 250),
        TextScaled = true,
        Font = Enum.Font.GothamBold
    })

    new("TextLabel", {
        Parent = B,
        Position = UDim2.new(0, 14, 0, 29),
        Size = UDim2.new(1, -28, 0, 16),
        BackgroundTransparency = 1,
        Text = description,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromRGB(130, 145, 165),
        TextScaled = true,
        Font = Enum.Font.Gotham
    })

    return B
end

  local FixButton = makeButton("FIX LAG🔥", "Giảm hiệu ứng và Giảm lag ", 1)
  local FPSButton = makeButton("FPS BOOST⚡", "Ưu tiên hiệu suất và mượt mà hơn", 2)
  local OptimizeButton = makeButton("TỐI ƯU MÁY🦾", "Áp dụng cấu hình tối ưu nhẹ cho thiết bị", 3)

local MiniToggle = new("TextButton", {
    Parent = Gui,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -14, 0, 14),
    Size = UDim2.new(0, 46, 0, 46),
    BackgroundColor3 = Color3.fromRGB(20, 23, 34),
    Text = "PL",
    TextColor3 = Color3.fromRGB(255, 220, 90),
    TextScaled = true,
    Font = Enum.Font.GothamBlack,
    AutoButtonColor = true,
    Visible = false
})
corner(MiniToggle, 12)
stroke(MiniToggle, Color3.fromRGB(70, 170, 255), 1.5)

local function setStatus(text)
    Status.Text = "Trạng thái: " .. text
end

local cachedParts = {}
local cacheTime = 0
local CACHE_DURATION = 5

local function refreshCache()
    local now = tick()
    if now - cacheTime < CACHE_DURATION and #cachedParts > 0 then
        return cachedParts
    end
    cachedParts = Workspace:GetDescendants()
    cacheTime = now
    return cachedParts
end

local function invalidateCache()
    cacheTime = 0
    cachedParts = {}
end

local function optimizeLighting()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 1e6
        Lighting.Brightness = 2
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.Ambient = Color3.fromRGB(110, 110, 110)
        Lighting.OutdoorAmbient = Color3.fromRGB(110, 110, 110)
        Lighting.ClockTime = 12
        Lighting.GeographicLatitude = 0
        Lighting.ShadowSoftness = 0
        Lighting.ExposureCompensation = 0
    end)

    pcall(function()
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("Clouds") then
                if v:IsA("PostEffect") then
                    v.Enabled = false
                elseif v:IsA("Atmosphere") then
                    v.Density = 0
                    v.Haze = 0
                    v.Glare = 0
                elseif v:IsA("Clouds") then
                    v.Cover = 0
                    v.Density = 0
                end
            end
        end
    end)
end

local function optimizeEffects()
    for _, obj in ipairs(refreshCache()) do
        local className = obj.ClassName
        if className == "ParticleEmitter" or className == "Trail" or className == "Beam" then
            pcall(function() obj.Enabled = false end)
        elseif className == "Smoke" or className == "Fire" or className == "Sparkles" then
            pcall(function() obj.Enabled = false end)
        elseif className == "PostEffect" or className == "Highlight" then
            pcall(function() obj.Enabled = false end)
        elseif className == "BlurEffect" or className == "BloomEffect" or className == "SunRaysEffect" then
            pcall(function() obj.Enabled = false end)
        elseif className == "Explosion" then
            pcall(function() obj.BlastPressure = 0 end)
        end
    end
end

local function optimizeTerrain()
    pcall(function()
        local Terrain = Workspace:FindFirstChildOfClass("Terrain")
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
            Terrain.Decoration = false
        end
    end)
end

local function optimizeParts(full)
    for _, obj in ipairs(refreshCache()) do
        if obj:IsA("BasePart") then
            pcall(function()
                obj.CastShadow = false
                if full then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    if obj:IsA("MeshPart") then
                        obj.RenderFidelity = Enum.RenderFidelity.Performance
                    end
                end
            end)
        elseif full then
            if obj:IsA("Decal") or obj:IsA("Texture") then
                pcall(function()
                    if obj.Transparency < 0.7 then
                        obj.Transparency = 0.7
                    end
                end)
            elseif obj:IsA("MeshPart") then
                pcall(function()
                    obj.CastShadow = false
                    obj.Reflectance = 0
                    obj.RenderFidelity = Enum.RenderFidelity.Performance
                end)
            elseif obj:IsA("SurfaceAppearance") then
                pcall(function()
                    obj.AlphaMode = Enum.AlphaMode.Overlay
                end)
            end
        end
    end
end

local function setLowQuality()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    pcall(function()
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    end)
end

local function optimizeCamera()
    pcall(function()
        if Camera then
            Camera.FieldOfView = 70
        end
    end)
end

local function optimizePlayers()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local char = plr.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            part.CastShadow = false
                            part.Material = Enum.Material.SmoothPlastic
                            part.Reflectance = 0
                        end)
                    elseif part:IsA("Decal") or part:IsA("Texture") then
                        pcall(function()
                            part.Transparency = 1
                        end)
                    elseif part:IsA("Accessory") then
                        pcall(function()
                            part:Destroy()
                        end)
                    end
                end
            end
        end
    end
end

local function disableAnimations()
    pcall(function()
        local char = Player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    if not track.Animation or track.Priority ~= Enum.AnimationPriority.Action then
                        track:Stop(0)
                    end
                end
            end
        end
    end)
end

local function fixLag()
    setStatus("Đang Fix Lag...")
    invalidateCache()
    optimizeLighting()
    optimizeEffects()
    optimizeTerrain()
    optimizeParts(false)
    setLowQuality()
    task.wait(0.15)
    setStatus("Fix Lag đã bật")
end

local function fpsBoost()
    setStatus("Đang Boost FPS...")
    invalidateCache()
    optimizeLighting()
    optimizeEffects()
    optimizeTerrain()
    optimizeParts(true)
    optimizePlayers()
    optimizeCamera()
    setLowQuality()
    disableAnimations()
    task.wait(0.15)
    setStatus("FPS Boost đã bật")
end

local function optimizeMachine()
    setStatus("Đang tối ưu máy...")
    invalidateCache()
    optimizeLighting()
    optimizeEffects()
    optimizeTerrain()
    optimizeParts(true)
    optimizePlayers()
    optimizeCamera()
    setLowQuality()
    disableAnimations()

    pcall(function()
        ContentProvider:PreloadAsync({})
    end)

    pcall(function()
        collectgarbage("collect")
    end)

    task.wait(0.2)
    setStatus("Tối ưu máy hoàn tất")
end

FixButton.MouseButton1Click:Connect(fixLag)
FPSButton.MouseButton1Click:Connect(fpsBoost)
OptimizeButton.MouseButton1Click:Connect(optimizeMachine)

local dragging = false
local dragStart
local startPos
local collapsed = false

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                conn:Disconnect()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local function setCollapsed(state)
    collapsed = state
    if collapsed then
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 330, 0, 62)
        }):Play()
        StatsBox.Visible = false
        Buttons.Visible = false
        MiniToggle.Visible = true
        TweenService:Create(Main, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    else
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 330, 0, 360)
        }):Play()
        StatsBox.Visible = true
        Buttons.Visible = true
        MiniToggle.Visible = false
        TweenService:Create(Main, TweenInfo.new(0.2), {BackgroundTransparency = 0.08}):Play()
    end
end

Minimize.MouseButton1Click:Connect(function()
    setCollapsed(true)
end)

MiniToggle.MouseButton1Click:Connect(function()
    setCollapsed(false)
end)

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

local frames = 0
local last = os.clock()

RunService.RenderStepped:Connect(function()
    frames += 1

    local now = os.clock()
    if now - last >= 1 then
        local fps = math.floor(frames / (now - last) + 0.5)
        FPSLabel.Text = "FPS\n" .. fps

        local cpu = "--"
        local gpu = "--"

        pcall(function()
            local network = Stats:FindFirstChild("PerformanceStats")
            if network then
                local cpuStat = network:FindFirstChild("CPU")
                local gpuStat = network:FindFirstChild("GPU")

                if cpuStat then
                    cpu = tostring(cpuStat:GetValueString())
                end

                if gpuStat then
                    gpu = tostring(gpuStat:GetValueString())
                end
            end
        end)

        CPULabel.Text = "CPU\n" .. cpu
        GPULabel.Text = "GPU\n" .. gpu

        frames = 0
        last = now
    end
end)
