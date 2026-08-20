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

local JoinTime = os.time()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerHopHubV5_Pro"
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
            task.spawn(function() OptimizeInst(v) end)
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
    Notify("Đang chuyển server lọ vương...")
    BlacklistedJobIds[jobId] = true
    VisitedServers[jobId] = { time = os.date("%H:%M:%S"), jobId = jobId }
    local success = pcall(function()
        TeleportService:TeleportToPlaceInstance(PlaceId, jobId, LocalPlayer)
    end)
    if not success then Notify("Lỗi Teleport! Đang thử lại đi bạn...") end
end

local function PerformAutoHopEmpty()
    if not AutoHopEmptyEnabled then return end
    Notify("Đang tìm server RỖNG (0-1 người) chờ đi nha...")
    
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
        Notify("Tìm thấy server rỗng: " .. bestServer.playing .. " người.")
        SafeTeleport(bestServer.id)
    else
        Notify("Không tìm thấy server hoặc vào sever mới. Thử lại nhé bạn...")
        task.wait(1.5)
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
        Notify("Tìm thấy server siêu đông: " .. bestServer.playing .. " người.")
        SafeTeleport(bestServer.id)
    else
        Notify("Không tìm thấy server phù hợp. Thử lại...")
        task.wait(2)
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
                if server.id ~= CurrentJobId and not BlacklistedJobIds[server.id] and server.playing >= 1 and server.playing <= 3 then
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
        Notify("Đã tìm thấy server: " .. bestServer.playing .. " người.")
        SafeTeleport(bestServer.id)
    else
        Notify("Thử lại sau 2 giây...")
        task.wait(2)
        if AutoHopEnabled then PerformAutoHop() end
    end
end

-- ================= GIAO DIỆN (UI MODERN) =================

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 330, 0, 310)
MainFrame.Position = UDim2.new(0.5, -165, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(60, 60, 80)
MainStroke.Thickness = 1.5

-- Nút Thu Gọn Menu (Open Button Widget)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "OpenMenuBtn"
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
OpenBtn.Text = "HUB"
OpenBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 14
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true

local OpenCorner = Instance.new("UICorner", OpenBtn)
OpenCorner.CornerRadius = UDim.new(1, 0)

local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(0, 220, 255)
OpenStroke.Thickness = 2

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "Vàn Hop sever 🥀"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.BackgroundTransparency = 1

local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 26, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -56, 0, 6)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 16
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 26, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 6)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 35)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, 0, 1, -36)
ContentContainer.Position = UDim2.new(0, 0, 0, 36)
ContentContainer.BackgroundTransparency = 1

local TabBar = Instance.new("Frame", ContentContainer)
TabBar.Size = UDim2.new(1, -12, 0, 26)
TabBar.Position = UDim2.new(0, 6, 0, 6)
TabBar.BackgroundTransparency = 1

local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.Padding = UDim.new(0, 4)

local function CreateTabBtn(name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0.188, 0, 1, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    btn.TextColor3 = Color3.fromRGB(160, 160, 180)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

local BtnAuto = CreateTabBtn("Auto Hop")
local BtnList = CreateTabBtn("Server")
local BtnJoin = CreateTabBtn("Join ID")
local BtnInfo = CreateTabBtn("Thống Kê")
local BtnHistory = CreateTabBtn("Lịch Sử")

local Pages = Instance.new("Frame", ContentContainer)
Pages.Size = UDim2.new(1, -12, 1, -40)
Pages.Position = UDim2.new(0, 6, 0, 34)
Pages.BackgroundTransparency = 1

local PageAuto = Instance.new("Frame", Pages) PageAuto.Size = UDim2.new(1,0,1,0) PageAuto.BackgroundTransparency = 1
local PageList = Instance.new("ScrollingFrame", Pages) PageList.Size = UDim2.new(1,0,1,0) PageList.BackgroundTransparency = 1 PageList.Visible = false PageList.ScrollBarThickness = 2
local PageJoin = Instance.new("Frame", Pages) PageJoin.Size = UDim2.new(1,0,1,0) PageJoin.BackgroundTransparency = 1 PageJoin.Visible = false
local PageInfo = Instance.new("Frame", Pages) PageInfo.Size = UDim2.new(1,0,1,0) PageInfo.BackgroundTransparency = 1 PageInfo.Visible = false
local PageHistory = Instance.new("ScrollingFrame", Pages) PageHistory.Size = UDim2.new(1,0,1,0) PageHistory.BackgroundTransparency = 1 PageHistory.Visible = false PageHistory.ScrollBarThickness = 2

Instance.new("UIListLayout", PageList).Padding = UDim.new(0, 4)
Instance.new("UIListLayout", PageHistory).Padding = UDim.new(0, 4)

local function ShowPage(page, btn)
    PageAuto.Visible = false
    PageList.Visible = false
    PageJoin.Visible = false
    PageInfo.Visible = false
    PageHistory.Visible = false
    
    BtnAuto.TextColor3 = Color3.fromRGB(150, 150, 150)
    BtnList.TextColor3 = Color3.fromRGB(150, 150, 150)
    BtnJoin.TextColor3 = Color3.fromRGB(150, 150, 150)
    BtnInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
    BtnHistory.TextColor3 = Color3.fromRGB(150, 150, 150)
    
    page.Visible = true
    btn.TextColor3 = Color3.fromRGB(0, 220, 255)
end

-- TAB 1: AUTO HOP
local ToggleEmptyBtn = Instance.new("TextButton", PageAuto)
ToggleEmptyBtn.Size = UDim2.new(1, 0, 0, 34)
ToggleEmptyBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleEmptyBtn.Text = "Hop Server Rỗng (0-1 người): OFF"
ToggleEmptyBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 50)
ToggleEmptyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleEmptyBtn.Font = Enum.Font.SourceSansBold
ToggleEmptyBtn.TextSize = 12
Instance.new("UICorner", ToggleEmptyBtn).CornerRadius = UDim.new(0, 6)

ToggleEmptyBtn.MouseButton1Click:Connect(function()
    AutoHopEmptyEnabled = not AutoHopEmptyEnabled
    if AutoHopEmptyEnabled then AutoHopEnabled = false AutoHopHighEnabled = false end
    ToggleEmptyBtn.BackgroundColor3 = AutoHopEmptyEnabled and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(160, 40, 50)
    ToggleEmptyBtn.Text = AutoHopEmptyEnabled and "Hop Server Rỗng: ON" or "Hop Server Rỗng (0-1 người): OFF"
    if AutoHopEmptyEnabled then task.spawn(PerformAutoHopEmpty) end
end)

local ToggleHopBtn = Instance.new("TextButton", PageAuto)
ToggleHopBtn.Size = UDim2.new(1, 0, 0, 34)
ToggleHopBtn.Position = UDim2.new(0, 0, 0, 40)
ToggleHopBtn.Text = "Hop Vắng Người (1-3 người): OFF"
ToggleHopBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 50)
ToggleHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleHopBtn.Font = Enum.Font.SourceSansBold
ToggleHopBtn.TextSize = 12
Instance.new("UICorner", ToggleHopBtn).CornerRadius = UDim.new(0, 6)

ToggleHopBtn.MouseButton1Click:Connect(function()
    AutoHopEnabled = not AutoHopEnabled
    if AutoHopEnabled then AutoHopHighEnabled = false AutoHopEmptyEnabled = false end
    ToggleHopBtn.BackgroundColor3 = AutoHopEnabled and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(160, 40, 50)
    ToggleHopBtn.Text = AutoHopEnabled and "Hop Vắng Người: ON" or "Hop Vắng Người (1-3 người): OFF"
    if AutoHopEnabled then task.spawn(PerformAutoHop) end
end)

local ToggleHighBtn = Instance.new("TextButton", PageAuto)
ToggleHighBtn.Size = UDim2.new(1, 0, 0, 34)
ToggleHighBtn.Position = UDim2.new(0, 0, 0, 80)
ToggleHighBtn.Text = "Hop Server Đông Người: OFF"
ToggleHighBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 50)
ToggleHighBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleHighBtn.Font = Enum.Font.SourceSansBold
ToggleHighBtn.TextSize = 12
Instance.new("UICorner", ToggleHighBtn).CornerRadius = UDim.new(0, 6)

ToggleHighBtn.MouseButton1Click:Connect(function()
    AutoHopHighEnabled = not AutoHopHighEnabled
    if AutoHopHighEnabled then AutoHopEnabled = false AutoHopEmptyEnabled = false end
    ToggleHighBtn.BackgroundColor3 = AutoHopHighEnabled and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(160, 40, 50)
    ToggleHighBtn.Text = AutoHopHighEnabled and "Hop Server Đông: ON" or "Hop Server Đông Người: OFF"
    if AutoHopHighEnabled then task.spawn(PerformAutoHopHigh) end
end)

local FixLagBtn = Instance.new("TextButton", PageAuto)
FixLagBtn.Size = UDim2.new(1, 0, 0, 34)
FixLagBtn.Position = UDim2.new(0, 0, 0, 120)
FixLagBtn.Text = "Fix Lag cho máy lỏ(Tối Ưu FPS)"
FixLagBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 160)
FixLagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FixLagBtn.Font = Enum.Font.SourceSansBold
FixLagBtn.TextSize = 12
Instance.new("UICorner", FixLagBtn).CornerRadius = UDim.new(0, 6)

FixLagBtn.MouseButton1Click:Connect(function()
    if not FixLagEnabled then
        FixLagEnabled = true
        ApplyExtremeFixLag()
        FixLagBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        FixLagBtn.Text = "Fix Lag ok rồi nhá!"
        Notify("Đã tối ưu hóa FPS thành công!")
    end
end)

-- TAB 3: JOIN ID
local JobIdInput = Instance.new("TextBox", PageJoin)
JobIdInput.Size = UDim2.new(1, 0, 0, 34)
JobIdInput.Position = UDim2.new(0, 0, 0, 5)
JobIdInput.PlaceholderText = "Nhập Server Job ID vào đây..."
JobIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
JobIdInput.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
JobIdInput.Font = Enum.Font.SourceSansBold
JobIdInput.TextSize = 12
Instance.new("UICorner", JobIdInput).CornerRadius = UDim.new(0, 6)

local JoinIdBtn = Instance.new("TextButton", PageJoin)
JoinIdBtn.Size = UDim2.new(1, 0, 0, 34)
JoinIdBtn.Position = UDim2.new(0, 0, 0, 45)
JoinIdBtn.Text = "Vào Server Bằng Job ID"
JoinIdBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
JoinIdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinIdBtn.Font = Enum.Font.SourceSansBold
JoinIdBtn.TextSize = 12
Instance.new("UICorner", JoinIdBtn).CornerRadius = UDim.new(0, 6)

JoinIdBtn.MouseButton1Click:Connect(function()
    local id = JobIdInput.Text
    if id and id ~= "" then SafeTeleport(id) else Notify("Nhập Job ID hợp lệ!") end
end)

local CopyIdBtn = Instance.new("TextButton", PageJoin)
CopyIdBtn.Size = UDim2.new(1, 0, 0, 34)
CopyIdBtn.Position = UDim2.new(0, 0, 0, 85)
CopyIdBtn.Text = "Copy Server Job ID Hiện Tại"
CopyIdBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 160)
CopyIdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyIdBtn.Font = Enum.Font.SourceSansBold
CopyIdBtn.TextSize = 12
Instance.new("UICorner", CopyIdBtn).CornerRadius = UDim.new(0, 6)

CopyIdBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(CurrentJobId)
        Notify("Đã copy Job ID!")
        CopyIdBtn.Text = "Đã Copy Job ID!"
    else
        print("Job ID:", CurrentJobId)
        Notify("Kiểm tra F12 Console!")
    end
    task.wait(1.5)
    CopyIdBtn.Text = "Copy Server Job ID sever này"
end)

local RejoinBtn = Instance.new("TextButton", PageJoin)
RejoinBtn.Size = UDim2.new(1, 0, 0, 34)
RejoinBtn.Position = UDim2.new(0, 0, 0, 125)
RejoinBtn.Text = "Vào Lại Server Hiện Tại (Rejoin)"
RejoinBtn.BackgroundColor3 = Color3.fromRGB(180, 90, 30)
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.Font = Enum.Font.SourceSansBold
RejoinBtn.TextSize = 12
Instance.new("UICorner", RejoinBtn).CornerRadius = UDim.new(0, 6)

RejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:TeleportToPlaceInstance(PlaceId, CurrentJobId, LocalPlayer)
end)

-- TAB 4: THỐNG KÊ & TÁC GIẢ
local InfoFrame = Instance.new("Frame", PageInfo)
InfoFrame.Size = UDim2.new(1, 0, 1, 0)
InfoFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
Instance.new("UICorner", InfoFrame).CornerRadius = UDim.new(0, 6)

local InfoText = Instance.new("TextLabel", InfoFrame)
InfoText.Size = UDim2.new(1, -16, 1, -10)
InfoText.Position = UDim2.new(0, 8, 0, 5)
InfoText.TextColor3 = Color3.fromRGB(220, 220, 230)
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.Font = Enum.Font.SourceSans
InfoText.TextSize = 13
InfoText.BackgroundTransparency = 1
InfoText.RichText = true

local function FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

task.spawn(function()
    while task.wait(1) do
        if PageInfo.Visible then
            local serverUptime = workspace.DistributedGameTime
            local myStayTime = os.time() - JoinTime
            local playerCount = #Players:GetPlayers()
            
            InfoText.Text = string.format([[
<font color="#00FFCC"><b>[ THỐNG KÊ SERVER ]</b></font>
• Thời gian Server đã mở: <b>%s</b>
• Thời gian bạn đã ở đây: <b>%s</b>
• Số người trong Server: <b>%d người</b>
• Người dùng Menu: <b>%d người</b>

<font color="#00FFCC"><b>[ TÁC GIẢ Dz vl]</b></font>
• Discord: <b>cammuoilupro</b>
• TikTok: <b>viet69xhamter</b>
]], FormatTime(serverUptime), FormatTime(myStayTime), playerCount, playerCount)
        end
    end
end)

-- LIST SERVERS & HISTORY FUNCTIONS
local function PopulateServerList()
    for _, child in ipairs(PageList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
    end
    
    local RefreshBtn = Instance.new("TextButton", PageList)
    RefreshBtn.Size = UDim2.new(1, 0, 0, 26)
    RefreshBtn.Text = "Reset danh sách"
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RefreshBtn.Font = Enum.Font.SourceSansBold
    RefreshBtn.TextSize = 11
    Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)
    RefreshBtn.MouseButton1Click:Connect(PopulateServerList)

    local servers = FetchServerList("")
    if not servers then return end
    table.sort(servers, function(a, b) return a.playing < b.playing end)

    for _, server in ipairs(servers) do
        local card = Instance.new("Frame", PageList)
        card.Size = UDim2.new(1, 0, 0, 32)
        card.BackgroundColor3 = (server.id == CurrentJobId) and Color3.fromRGB(30, 55, 35) or Color3.fromRGB(30, 30, 40)
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
        
        local info = Instance.new("TextLabel", card)
        info.Size = UDim2.new(0.6, 0, 1, 0)
        info.Position = UDim2.new(0, 8, 0, 0)
        info.Text = string.format("[%d/%d] %s", server.playing, server.maxPlayers, string.sub(server.id, 1, 8))
        info.TextColor3 = Color3.fromRGB(220, 220, 220)
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.SourceSans
        info.TextSize = 11
        info.BackgroundTransparency = 1

        local joinBtn = Instance.new("TextButton", card)
        joinBtn.Size = UDim2.new(0.24, 0, 0.7, 0)
        joinBtn.Position = UDim2.new(0.74, 0, 0.15, 0)
        joinBtn.BackgroundColor3 = (server.id == CurrentJobId) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(40, 130, 60)
        joinBtn.Text = (server.id == CurrentJobId) and "Hiện tại" or "Vào"
        joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        joinBtn.Font = Enum.Font.SourceSansBold
        joinBtn.TextSize = 11
        Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 4)
        
        if server.id ~= CurrentJobId then
            joinBtn.MouseButton1Click:Connect(function() SafeTeleport(server.id) end)
        end
    end
    PageList.CanvasSize = UDim2.new(0, 0, 0, (#servers + 1) * 36)
end

local function PopulateHistoryList()
    for _, child in ipairs(PageHistory:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local count = 0
    for jobId, data in pairs(VisitedServers) do
        count = count + 1
        local card = Instance.new("Frame", PageHistory)
        card.Size = UDim2.new(1, 0, 0, 32)
        card.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
        
        local info = Instance.new("TextLabel", card)
        info.Size = UDim2.new(0.5, 0, 1, 0)
        info.Position = UDim2.new(0, 8, 0, 0)
        info.Text = string.format("%s | %s", data.time, string.sub(jobId, 1, 6).."...")
        info.TextColor3 = Color3.fromRGB(220, 220, 220)
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.SourceSans
        info.TextSize = 11
        info.BackgroundTransparency = 1

        local joinBtn = Instance.new("TextButton", card)
        joinBtn.Size = UDim2.new(0.4, 0, 0.7, 0)
        joinBtn.Position = UDim2.new(0.55, 0, 0.15, 0)
        joinBtn.BackgroundColor3 = Color3.fromRGB(45, 90, 150)
        joinBtn.Text = "Vào lại"
        joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        joinBtn.Font = Enum.Font.SourceSansBold
        joinBtn.TextSize = 11
        Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 4)

        joinBtn.MouseButton1Click:Connect(function() SafeTeleport(jobId) end)
    end
    PageHistory.CanvasSize = UDim2.new(0, 0, 0, count * 36)
end

BtnAuto.MouseButton1Click:Connect(function() ShowPage(PageAuto, BtnAuto) end)
BtnList.MouseButton1Click:Connect(function() ShowPage(PageList, BtnList); PopulateServerList() end)
BtnJoin.MouseButton1Click:Connect(function() ShowPage(PageJoin, BtnJoin) end)
BtnInfo.MouseButton1Click:Connect(function() ShowPage(PageInfo, BtnInfo) end)
BtnHistory.MouseButton1Click:Connect(function() ShowPage(PageHistory, BtnHistory); PopulateHistoryList() end)

ShowPage(PageAuto, BtnAuto)

