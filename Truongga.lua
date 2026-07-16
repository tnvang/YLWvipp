local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

if game:GetService("CoreGui"):FindFirstChild("Trường newbie") then
    game:GetService("CoreGui")["Trường newbie"]:Destroy()
end

local Window = OrionLib:MakeWindow({
    Name = "Trường newbie", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "TruongNewbieConfig",
    IntroText = "Trường newbie"
})

local KeyTab = Window:MakeTab({
    Name = "Key System",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local KeyVerified = false

KeyTab:AddTextbox({
    Name = "Enter Key",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        if Value == "mày rất dz và còn dz nhất thgioi" then
            KeyVerified = true
            OrionLib:MakeNotification({
                Name = "Success",
                Content = "Access Granted",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        elseif Value == "sấu hơn t đẹp cl j" then
            game:GetService("Players").LocalPlayer:Kick("sấu hơn t đẹp cl j")
        end
    end
})

local function checkKey()
    if not KeyVerified then
        OrionLib:MakeNotification({
            Name = "Warning",
            Content = "Key Required",
            Image = "rbxassetid://4483345998",
            Time = 4
        })
        return false
    end
    return true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local AimbotEnabled = false
local HitboxEnabled = false
local NoclipEnabled = false
local InfJumpEnabled = false
local EspEnabled = false

local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 2
FOV_Circle.NumSides = 460
FOV_Circle.Radius = 150
FOV_Circle.Filled = false
FOV_Circle.Color = Color3.fromRGB(0, 255, 255)
FOV_Circle.Visible = false

local MainTab = Window:MakeTab({
    Name = "Tab chính",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Aimbot (Head)",
    Default = false,
    Callback = function(Value)
        if not checkKey() then return end
        AimbotEnabled = Value
        FOV_Circle.Visible = Value
    end
})

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOV_Circle.Position = Vector2.new(mousePos.X, mousePos.Y)
end)

local function isObstructed(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    if raycastResult then
        return true
    end
    return false
end

local function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = FOV_Circle.Radius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local isTeammate = (player.Team == LocalPlayer.Team and player.Team ~= nil)
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 and not isTeammate then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance then
                        if not isObstructed(head) then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and KeyVerified then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

local HITBOX_SIZE = Vector3.new(10, 10, 10)
local HITBOX_TRANSPARENCY = 0.6
local HITBOX_COLOR = Color3.fromRGB(255, 0, 0)
local TARGET_PART = "HumanoidRootPart"

local function applyHitbox(player)
    if player ~= LocalPlayer and player.Character then
        local character = player.Character
        local targetPart = character:FindFirstChild(TARGET_PART)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if targetPart and humanoid and humanoid.Health > 0 then
            targetPart.Size = HITBOX_SIZE
            targetPart.Transparency = HITBOX_TRANSPARENCY
            targetPart.Color = HITBOX_COLOR
            targetPart.Material = Enum.Material.Neon
            targetPart.CanCollide = false
        end
    end
end

local function resetHitbox(player)
    if player ~= LocalPlayer and player.Character then
        local targetPart = player.Character:FindFirstChild(TARGET_PART)
        if targetPart then
            targetPart.Size = Vector3.new(2, 2, 1)
            targetPart.Transparency = 1
            targetPart.Color = Color3.fromRGB(163, 162, 165)
            targetPart.Material = Enum.Material.Plastic
            targetPart.CanCollide = true
        end
    end
end

MainTab:AddToggle({
    Name = "Hitbox",
    Default = false,
    Callback = function(Value)
        if not checkKey() then return end
        HitboxEnabled = Value
    end
})

RunService.RenderStepped:Connect(function()
    if HitboxEnabled and KeyVerified then
        for _, player in ipairs(Players:GetPlayers()) do
            applyHitbox(player)
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            resetHitbox(player)
        end
    end
end)

MainTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        if not checkKey() then return end
        NoclipEnabled = Value
    end
})

RunService.Stepped:Connect(function()
    if NoclipEnabled and KeyVerified and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

MainTab:AddButton({
    Name = "Fix Lag",
    Callback = function()
        if not checkKey() then return end
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterDetailScale = 0
        end
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("PostEffect") then
                v.Enabled = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
        OrionLib:MakeNotification({
            Name = "System",
            Content = "Lag Fixed",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

local CharTab = Window:MakeTab({
    Name = "Tab nhân vật",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CharTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 300,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        if not checkKey() then return end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end
})

CharTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        if not checkKey() then return end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            hum.UseJumpPower = true
            hum.JumpPower = Value
        end
    end
})

CharTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        if not checkKey() then return end
        InfJumpEnabled = Value
    end
})

UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and KeyVerified and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

CharTab:AddToggle({
    Name = "ESP (Name + Box)",
    Default = false,
    Callback = function(Value)
        if not checkKey() then return end
        EspEnabled = Value
    end
})

local function createESP(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 2
    Box.Filled = false

    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Color = Color3.fromRGB(255, 255, 255)
    Text.Size = 16
    Text.Center = true
    Text.Outline = true

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if EspEnabled and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local hrp = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local sizeY = (Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0)).Y)
                local sizeX = sizeY / 1.5

                Box.Size = Vector2.new(sizeX, sizeY)
                Box.Position = Vector2.new(screenPos.X - sizeX / 2, screenPos.Y - sizeY / 2)
                Box.Visible = true

                Text.Text = player.Name
                Text.Position = Vector2.new(screenPos.X, screenPos.Y - sizeY / 2 - 18)
                Text.Visible = true
            else
                Box.Visible = false
                Text.Visible = false
            end
        else
            Box.Visible = false
            Text.Visible = false
            if not EspEnabled or not player.Parent then
                Box:Remove()
                Text:Remove()
                connection:Disconnect()
            end
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        createESP(p)
    end
end

local PlayerNames = {}
local TeleportDropdown

local function updatePlayerList()
    PlayerNames = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(PlayerNames, p.Name)
        end
    end
    if TeleportDropdown then
        TeleportDropdown:Refresh(PlayerNames, true)
    end
end

TeleportDropdown = CharTab:AddDropdown({
    Name = "Teleport Player",
    Default = "",
    Options = PlayerNames,
    Callback = function(Selected)
        if not checkKey() then return end
        local targetPlayer = Players:FindFirstChild(Selected)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
            end
        end
    end
})

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

local FunTab = Window:MakeTab({
    Name = "Tab vui",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local RainbowBall = nil
local RainbowWalkEnabled = false

FunTab:AddToggle({
    Name = "Rainbow Ball Back",
    Default = false,
    Callback = function(val)
        if not checkKey() then return end
        if val then
            RainbowBall = Instance.new("Part")
            RainbowBall.Size = Vector3.new(2.5, 2.5, 2.5)
            RainbowBall.Shape = Enum.PartType.Ball
            RainbowBall.Material = Enum.Material.Neon
            RainbowBall.CanCollide = false
            RainbowBall.Parent = Workspace
            
            local bg = Instance.new("BillboardGui")
            bg.Size = UDim2.new(0, 150, 0, 50)
            bg.AlwaysOnTop = true
            bg.StudsOffset = Vector3.new(0, 2, 0)
            bg.Parent = RainbowBall
            
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.Text = "bố vào đây"
            tl.TextColor3 = Color3.fromRGB(255, 255, 255)
            tl.TextScaled = true
            tl.Font = Enum.Font.SourceSansBold
            tl.Parent = bg
            
            task.spawn(function()
                local hue = 0
                while RainbowBall and RainbowBall.Parent do
                    hue = (hue + 1) % 360
                    local rainbowColor = Color3.fromHSV(hue/360, 1, 1)
                    RainbowBall.Color = rainbowColor
                    tl.TextColor3 = rainbowColor
                    
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        local targetPos = (hrp.CFrame * CFrame.new(0, 1.5, 3.5)).Position
                        RainbowBall.Position = RainbowBall.Position:Lerp(targetPos, 0.1)
                    end
                    task.wait()
                end
            end)
        else
            if RainbowBall then
                RainbowBall:Destroy()
                RainbowBall = nil
            end
        end
    end
})

FunTab:AddToggle({
    Name = "Rainbow Move Trail",
    Default = false,
    Callback = function(val)
        if not checkKey() then return end
        RainbowWalkEnabled = val
    end
})

RunService.RenderStepped:Connect(function()
    if RainbowWalkEnabled and KeyVerified and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            local p = Instance.new("Part")
            p.Size = Vector3.new(1, 0.2, 1)
            p.Anchored = true
            p.CanCollide = false
            p.Material = Enum.Material.Neon
            p.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -2, 0)
            p.Parent = Workspace
            
            local hue = (tick() * 120) % 360
            p.Color = Color3.fromHSV(hue/360, 1, 1)
            
            task.spawn(function()
                for i = 0, 1, 0.1 do
                    p.Transparency = i
                    task.wait(0.05)
                end
                p:Destroy()
            end)
        end
    end
end)

OrionLib:Init()
