local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local CurrentJobId = game.JobId

local AutoHopEnabled = false
local AutoHopHighEnabled = false
local AutoHopEmptyEnabled = false
local FixLagEnabled = false
local VisitedServers = {} 
local BlacklistedJobIds = {} 
BlacklistedJobIds[CurrentJobId] = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerHopHubV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local function Notify(text)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Server Hopper", Text = text, Duration = 3})
end

local function ApplyExtremeFixLag()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 0
    Lighting.Brightness = 1
    Lighting.ClockTime = 12
    Lighting.Technology = Enum.Technology.Compatibility
    
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") or child:IsA("Clouds") or child:IsA("SunRaysEffect") then
            child:Destroy()
        end
    end

    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    local function OptimizeInst(v)
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Texture = ""
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Beam") then
            v.Enabled = false
            v:Destroy()
        elseif v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.TextureID = ""
            v.CastShadow = false
        elseif v:IsA("SpecialMesh") then
            v.TextureId = ""
        elseif v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
            v:Destroy()
        elseif v:IsA("Highlight") or v:IsA("SurfaceAppearance") then
            v:Destroy()
        end
    end

    for _, v in ipairs(game:GetDescendants()) do
        OptimizeInst(v)
    end

    game.DescendantAdded:Connect(function(v)
        if FixLagEnabled then
            task.spawn(function()
                OptimizeInst(v)
            end)
        end
    end)
end

local function FetchServerList(cursor)
    cursor = cursor or ""
    local urls = {
        string.format("https://games.roproxy.com/v1/games/%d/servers/0?sortOrder=Asc&limit=100&cursor=%s", PlaceId, cursor),
        string.format("https://games.roblox.com/v1/games/%d/servers/0?sortOrder=Asc&limit=100&cursor=%s", PlaceId, cursor)
    }
    
    for _, url in ipairs(urls) do
        local success, response = pcall(function() return game:HttpGet(url) end)
        if success and response then
            local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(response) end)
            if decodeSuccess and data and data.data then
                return data.data, data.nextPageCursor
            end
        end
    end
    return nil, nil
end

local function SafeTeleport(jobId)
    Notify("Đang chuyển server...")
    BlacklistedJobIds[jobId] = true
    VisitedServers[jobId] = {
        time = os.date("%H:%M:%S"),
        jobId = jobId
    }
    local success = pcall(function()
        TeleportService:TeleportToPlaceInstance(PlaceId, jobId, LocalPlayer)
    end)
    if not success then
        Notify("Lỗi Teleport! Đang thử lại...")
    end
end

-- Tối ưu hóa thuật toán tìm nhanh server 0-1 người
local function PerformAutoHopEmpty()
    if not AutoHopEmptyEnabled then return end
    Notify("Đang tìm server RỖNG (0-1 người) siêu tốc...")
    
    local cursor = ""
    local bestServer = nil
    local attempts = 0
    
    while AutoHopEmptyEnabled and attempts < 5 do
        attempts = attempts + 1
        local servers, nextCursor = FetchServerList(cursor)
        if servers then
            for _, server in ipairs(servers) do
                if server.id ~= CurrentJobId and not BlacklistedJobIds[server.id] and server.playing <= 1 then
                    bestServer = server
                    break
                end
            end
            if bestServer then break end
            if nextCursor and nextCursor ~= "" then cursor = nextCursor else break end
        else
            task.wait(0.2)
        end
    end
    
    if bestServer then
        Notify("Tìm thấy server ít người: " .. bestServer.playing .. " người.")
        SafeTeleport(bestServer.id)
    else
        Notify("Không tìm thấy server 0-1 người. Thử lại...")
        task.wait(2)
        if AutoHopEmptyEnabled then PerformAutoHopEmpty() end
    end
end

local function PerformAutoHopHigh()
    if not AutoHopHighEnabled then return end
    Notify("Đang tìm server đông nhất...")
    
    local cursor = ""
    local bestServer = nil
    local attempts = 0
    
    while AutoHopHighEnabled and attempts < 3 do
        attempts = attempts + 1
        local servers, nextCursor = FetchServerList(cursor)
        if servers then
            table.sort(servers, function(a,b) return a.playing > b.playing end)
            for _, server in ipairs(servers) do
                if server.id ~= CurrentJobId and not BlacklistedJobIds[server.id] and server.playing < server.maxPlayers then
                    bestServer = server
                    break
                end
            end
            if bestServer then break end
            if nextCursor and nextCursor ~= "" then cursor = nextCursor else break end
        else
            task.wait(0.5)
        end
    end
    
    if bestServer then
        Notify("Tìm thấy server đông: " .. bestServer.playing .. " người.")
        SafeTeleport(bestServer.id)
    else
        Notify("Không tìm thấy server phù hợp. Thử lại...")
        task.wait(3)
        if AutoHopHighEnabled then PerformAutoHopHigh() end
    end
end

local function PerformAutoHop()
    if not AutoHopEnabled then return end
    Notify("Đang tìm server 1-3 người...")
    
    local cursor = ""
    local bestServer = nil
    local attempts = 0
    
    while AutoHopEnabled and attempts < 3 do
        attempts = attempts + 1
        local servers, nextCursor = FetchServerList(cursor)
        if servers then
            for _, server in ipairs(servers) do
                if server.id ~= CurrentJobId and not BlacklistedJobIds[server.id] then
                    if server.playing >= 1 and server.playing <= 3 then
                        bestServer = server
                        break
                    end
                end
            end
            
            if not bestServer then
                table.sort(servers, function(a,b) return a.playing < b.playing end)
                for _, server in ipairs(servers) do
                    if server.id ~= CurrentJobId and not BlacklistedJobIds[server.id] and server.playing < server.maxPlayers then
                        bestServer = server
                        break
                    end
                end
            end
            
            if bestServer then break end
            if nextCursor and nextCursor ~= "" then cursor = nextCursor else break end
        else
            task.wait(0.5)
        end
    end
    
    if bestServer then
        Notify("Đã tìm thấy server: " .. bestServer.playing .. " người.")
        SafeTeleport(bestServer.id)
    else
        Notify("Không tìm thấy server phù hợp. Thử lại...")
        task.wait(3)
        if AutoHopEnabled then PerformAutoHop() end
    end
end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 320)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Server Hop Hub V5"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 26, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 35)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, 0, 1, -32)
ContentContainer.Position = UDim2.new(0, 0, 0, 32)
ContentContainer.BackgroundTransparency = 1

local TabBar = Instance.new("Frame", ContentContainer)
TabBar.Size = UDim2.new(1, -12, 0, 28)
TabBar.Position = UDim2.new(0, 6, 0, 6)
TabBar.BackgroundTransparency = 1

local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.Padding = UDim.new(0, 4)

local function CreateTabBtn(name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0.24, 0, 1, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    return btn
end

local BtnAuto = CreateTabBtn("Auto Hop")
local BtnList = CreateTabBtn("Server List")
local BtnJoin = CreateTabBtn("Join ID/User")
local BtnHistory = CreateTabBtn("History")

local Pages = Instance.new("Frame", ContentContainer)
Pages.Size = UDim2.new(1, -12, 1, -44)
Pages.Position = UDim2.new(0, 6, 0, 38)
Pages.BackgroundTransparency = 1

local PageAuto = Instance.new("Frame", Pages) PageAuto.Size = UDim2.new(1,0,1,0) PageAuto.BackgroundTransparency = 1
local PageList = Instance.new("ScrollingFrame", Pages) PageList.Size = UDim2.new(1,0,1,0) PageList.BackgroundTransparency = 1 PageList.Visible = false PageList.ScrollBarThickness = 3
local PageJoin = Instance.new("Frame", Pages) PageJoin.Size = UDim2.new(1,0,1,0) PageJoin.BackgroundTransparency = 1
local PageHistory = Instance.new("ScrollingFrame", Pages) PageHistory.Size = UDim2.new(1,0,1,0) PageHistory.BackgroundTransparency = 1 PageHistory.Visible = false PageHistory.ScrollBarThickness = 3

local ListLayout1 = Instance.new("UIListLayout", PageList) ListLayout1.Padding = UDim.new(0, 4)
local ListLayout2 = Instance.new("UIListLayout", PageHistory) ListLayout2.Padding = UDim.new(0, 4)

local function ShowPage(page, btn)
    PageAuto.Visible = false
    PageList.Visible = false
    PageJoin.Visible = false
    PageHistory.Visible = false
    
    BtnAuto.TextColor3 = Color3.fromRGB(150, 150, 150)
    BtnList.TextColor3 = Color3.fromRGB(150, 150, 150)
    BtnJoin.TextColor3 = Color3.fromRGB(150, 150, 150)
    BtnHistory.TextColor3 = Color3.fromRGB(150, 150, 150)
    
    page.Visible = true
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- Chức năng 1: Nút Hop Server Rỗng (0-1 người) siêu tốc
local ToggleEmptyBtn = Instance.new("TextButton", PageAuto)
ToggleEmptyBtn.Size = UDim2.new(1, 0, 0, 36)
ToggleEmptyBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleEmptyBtn.Text = "Hop Server Rỗng (0-1 người): OFF"
ToggleEmptyBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ToggleEmptyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleEmptyBtn.Font = Enum.Font.SourceSansBold
ToggleEmptyBtn.TextSize = 13
Instance.new("UICorner", ToggleEmptyBtn).CornerRadius = UDim.new(0, 6)

ToggleEmptyBtn.MouseButton1Click:Connect(function()
    AutoHopEmptyEnabled = not AutoHopEmptyEnabled
    if AutoHopEmptyEnabled then 
        AutoHopEnabled = false 
        AutoHopHighEnabled = false 
    end
    ToggleEmptyBtn.BackgroundColor3 = AutoHopEmptyEnabled and Color3.fromRGB(45, 160, 60) or Color3.fromRGB(180, 50, 50)
    ToggleEmptyBtn.Text = AutoHopEmptyEnabled and "Hop Server Rỗng: ON" or "Hop Server Rỗng (0-1 người): OFF"
    if AutoHopEmptyEnabled then task.spawn(PerformAutoHopEmpty) end
end)

local ToggleHopBtn = Instance.new("TextButton", PageAuto)
ToggleHopBtn.Size = UDim2.new(1, 0, 0, 36)
ToggleHopBtn.Position = UDim2.new(0, 0, 0, 42)
ToggleHopBtn.Text = "Hop Vắng Người (1-3 người): OFF"
ToggleHopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ToggleHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleHopBtn.Font = Enum.Font.SourceSansBold
ToggleHopBtn.TextSize = 13
Instance.new("UICorner", ToggleHopBtn).CornerRadius = UDim.new(0, 6)

ToggleHopBtn.MouseButton1Click:Connect(function()
    AutoHopEnabled = not AutoHopEnabled
    if AutoHopEnabled then 
        AutoHopHighEnabled = false 
        AutoHopEmptyEnabled = false 
    end
    ToggleHopBtn.BackgroundColor3 = AutoHopEnabled and Color3.fromRGB(45, 160, 60) or Color3.fromRGB(180, 50, 50)
    ToggleHopBtn.Text = AutoHopEnabled and "Hop Vắng Người: ON" or "Hop Vắng Người (1-3 người): OFF"
    if AutoHopEnabled then task.spawn(PerformAutoHop) end
end)

local ToggleHighBtn = Instance.new("TextButton", PageAuto)
ToggleHighBtn.Size = UDim2.new(1, 0, 0, 36)
ToggleHighBtn.Position = UDim2.new(0, 0, 0, 84)
ToggleHighBtn.Text = "Hop Server Đông Người: OFF"
ToggleHighBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ToggleHighBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleHighBtn.Font = Enum.Font.SourceSansBold
ToggleHighBtn.TextSize = 13
Instance.new("UICorner", ToggleHighBtn).CornerRadius = UDim.new(0, 6)

ToggleHighBtn.MouseButton1Click:Connect(function()
    AutoHopHighEnabled = not AutoHopHighEnabled
    if AutoHopHighEnabled then 
        AutoHopEnabled = false 
        AutoHopEmptyEnabled = false 
    end
    ToggleHighBtn.BackgroundColor3 = AutoHopHighEnabled and Color3.fromRGB(45, 160, 60) or Color3.fromRGB(180, 50, 50)
    ToggleHighBtn.Text = AutoHopHighEnabled and "Hop Server Đông: ON" or "Hop Server Đông Người: OFF"
    if AutoHopHighEnabled then task.spawn(PerformAutoHopHigh) end
end)

local FixLagBtn = Instance.new("TextButton", PageAuto)
FixLagBtn.Size = UDim2.new(1, 0, 0, 36)
FixLagBtn.Position = UDim2.new(0, 0, 0, 126)
FixLagBtn.Text = "Fix Lag Cực Đại (Xóa 85% Đồ Họa)"
FixLagBtn.BackgroundColor3 = Color3.fromRGB(50, 110, 180)
FixLagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FixLagBtn.Font = Enum.Font.SourceSansBold
FixLagBtn.TextSize = 13
Instance.new("UICorner", FixLagBtn).CornerRadius = UDim.new(0, 6)

FixLagBtn.MouseButton1Click:Connect(function()
    if not FixLagEnabled then
        FixLagEnabled = true
        ApplyExtremeFixLag()
        FixLagBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 60)
        FixLagBtn.Text = "Đã Bật Fix Lag Cực Đại!"
        Notify("Đã xóa 85% đồ họa để tối ưu FPS!")
    end
end)

local JobIdInput = Instance.new("TextBox", PageJoin)
JobIdInput.Size = UDim2.new(1, 0, 0, 36)
JobIdInput.Position = UDim2.new(0, 0, 0, 5)
JobIdInput.PlaceholderText = "Nhập Server Job ID vào đây..."
JobIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
JobIdInput.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
JobIdInput.Font = Enum.Font.SourceSansBold
JobIdInput.TextSize = 13
Instance.new("UICorner", JobIdInput).CornerRadius = UDim.new(0, 6)

local JoinIdBtn = Instance.new("TextButton", PageJoin)
JoinIdBtn.Size = UDim2.new(1, 0, 0, 36)
JoinIdBtn.Position = UDim2.new(0, 0, 0, 46)
JoinIdBtn.Text = "Vào Server Bằng Job ID"
JoinIdBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
JoinIdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinIdBtn.Font = Enum.Font.SourceSansBold
JoinIdBtn.TextSize = 13
Instance.new("UICorner", JoinIdBtn).CornerRadius = UDim.new(0, 6)

JoinIdBtn.MouseButton1Click:Connect(function()
    local id = JobIdInput.Text
    if id and id ~= "" then
        SafeTeleport(id)
    else
        Notify("Vui lòng nhập Job ID hợp lệ!")
    end
end)

-- Chức năng 2: Nút Sao chép Job ID server hiện tại
local CopyIdBtn = Instance.new("TextButton", PageJoin)
CopyIdBtn.Size = UDim2.new(1, 0, 0, 36)
CopyIdBtn.Position = UDim2.new(0, 0, 0, 87)
CopyIdBtn.Text = "Copy Server Job ID Hiện Tại"
CopyIdBtn.BackgroundColor3 = Color3.fromRGB(140, 60, 180)
CopyIdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyIdBtn.Font = Enum.Font.SourceSansBold
CopyIdBtn.TextSize = 13
Instance.new("UICorner", CopyIdBtn).CornerRadius = UDim.new(0, 6)

CopyIdBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(CurrentJobId)
        Notify("Đã copy Job ID vào clipboard!")
        CopyIdBtn.Text = "Đã Copy Job ID!"
    else
        print("Server JobID của bạn:", CurrentJobId)
        Notify("Không hỗ trợ setclipboard! Kiểm tra F12.")
        CopyIdBtn.Text = "Đã in Job ID vào F12 Console"
    end
    task.wait(2)
    CopyIdBtn.Text = "Copy Server Job ID Hiện Tại"
end)

local RejoinBtn = Instance.new("TextButton", PageJoin)
RejoinBtn.Size = UDim2.new(1, 0, 0, 36)
RejoinBtn.Position = UDim2.new(0, 0, 0, 128)
RejoinBtn.Text = "Vào Lại Server Hiện Tại (Rejoin)"
RejoinBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 40)
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.Font = Enum.Font.SourceSansBold
RejoinBtn.TextSize = 13
Instance.new("UICorner", RejoinBtn).CornerRadius = UDim.new(0, 6)

RejoinBtn.MouseButton1Click:Connect(function()
    Notify("Đang Rejoin lại server...")
    TeleportService:TeleportToPlaceInstance(PlaceId, CurrentJobId, LocalPlayer)
end)

local function PopulateServerList()
    for _, child in ipairs(PageList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
    end
    
    local RefreshBtn = Instance.new("TextButton", PageList)
    RefreshBtn.Size = UDim2.new(1, 0, 0, 28)
    RefreshBtn.Text = "Làm mới danh sách"
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RefreshBtn.Font = Enum.Font.SourceSansBold
    RefreshBtn.TextSize = 12
    Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)
    RefreshBtn.MouseButton1Click:Connect(PopulateServerList)

    local servers, _ = FetchServerList("")
    if not servers then return end

    table.sort(servers, function(a, b) return a.playing < b.playing end)

    for _, server in ipairs(servers) do
        local card = Instance.new("Frame", PageList)
        card.Size = UDim2.new(1, 0, 0, 35)
        card.BackgroundColor3 = (server.id == CurrentJobId) and Color3.fromRGB(30, 55, 35) or Color3.fromRGB(34, 34, 44)
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
        
        local info = Instance.new("TextLabel", card)
        info.Size = UDim2.new(0.55, 0, 1, 0)
        info.Position = UDim2.new(0, 8, 0, 0)
        info.Text = string.format("[%d/%d] %s", server.playing, server.maxPlayers, string.sub(server.id, 1, 6).."...")
        info.TextColor3 = Color3.fromRGB(220, 220, 220)
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.SourceSans
        info.TextSize = 12
        info.BackgroundTransparency = 1
        local joinBtn = Instance.new("TextButton", card)
        joinBtn.Size = UDim2.new(0.22, -2, 0.7, 0)
        joinBtn.Position = UDim2.new(0.76, 0, 0.15, 0)
        joinBtn.BackgroundColor3 = (server.id == CurrentJobId) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(40, 130, 50)
        joinBtn.Text = (server.id == CurrentJobId) and "Hiện tại" or "Vào"
        joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        joinBtn.Font = Enum.Font.SourceSansBold
        joinBtn.TextSize = 11
        Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 4)
        
        if server.id ~= CurrentJobId then
            joinBtn.MouseButton1Click:Connect(function() SafeTeleport(server.id) end)
        end
    end
    PageList.CanvasSize = UDim2.new(0, 0, 0, (#servers + 1) * 39)
end

local function PopulateHistoryList()
    for _, child in ipairs(PageHistory:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local count = 0
    for jobId, data in pairs(VisitedServers) do
        count = count + 1
        local card = Instance.new("Frame", PageHistory)
        card.Size = UDim2.new(1, 0, 0, 35)
        card.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
        
        local info = Instance.new("TextLabel", card)
        info.Size = UDim2.new(0.5, 0, 1, 0)
        info.Position = UDim2.new(0, 8, 0, 0)
        info.Text = string.format("%s | %s", data.time, string.sub(jobId, 1, 6).."...")
        info.TextColor3 = Color3.fromRGB(220, 220, 220)
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.SourceSans
        info.TextSize = 12
        info.BackgroundTransparency = 1

        local joinBtn = Instance.new("TextButton", card)
        joinBtn.Size = UDim2.new(0.4, 0, 0.7, 0)
        joinBtn.Position = UDim2.new(0.55, 0, 0.15, 0)
        joinBtn.BackgroundColor3 = Color3.fromRGB(45, 90, 150)
        joinBtn.Text = "Vào lại Server"
        joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        joinBtn.Font = Enum.Font.SourceSansBold
        joinBtn.TextSize = 11
        Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 4)

        joinBtn.MouseButton1Click:Connect(function() SafeTeleport(jobId) end)
    end
    PageHistory.CanvasSize = UDim2.new(0, 0, 0, count * 39)
end

BtnAuto.MouseButton1Click:Connect(function() ShowPage(PageAuto, BtnAuto) end)
BtnList.MouseButton1Click:Connect(function() ShowPage(PageList, BtnList); PopulateServerList() end)
BtnJoin.MouseButton1Click:Connect(function() ShowPage(PageJoin, BtnJoin) end)
BtnHistory.MouseButton1Click:Connect(function() ShowPage(PageHistory, BtnHistory); PopulateHistoryList() end)

ShowPage(PageAuto, BtnAuto)

