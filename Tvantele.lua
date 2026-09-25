local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

for _, name in ipairs({"MeowTargetTrackerGui", "TVanDzWatermarkGui", "TVanDzNotifyGui"}) do
    local old = PlayerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

local CONFIG = {
    Brand = "TVANCTE",
    Title = "TVÀN DZ HUB",
    Subtitle = "ULTIMATE PRO MAX",
    Version = "v3.1",
    PrimaryColor = Color3.fromRGB(138, 43, 226),
    SecondaryColor = Color3.fromRGB(75, 0, 130),
    AccentColor = Color3.fromRGB(0, 229, 255),
    GoldColor = Color3.fromRGB(255, 200, 60),
    SuccessColor = Color3.fromRGB(0, 255, 150),
    DangerColor = Color3.fromRGB(255, 60, 90),
    WarnColor = Color3.fromRGB(255, 160, 40),
    BgDark = Color3.fromRGB(12, 10, 20),
    BgPanel = Color3.fromRGB(20, 16, 32),
    BgElement = Color3.fromRGB(32, 26, 48),
    TextMain = Color3.fromRGB(240, 240, 255),
    TextDim = Color3.fromRGB(160, 150, 190),
}

local State = {
    TargetPlayer = nil,
    IsFlying = false,
    FlySpeed = 50,
    MinSpeed = 1,
    MaxSpeed = 100000,
    AntiCheckEnabled = true,
    AntiRaycastEnabled = true,
    AntiInputEnabled = true,
    AntiChecksumEnabled = true,
    FlyConnection = nil,
    AntiCheckConnection = nil,
    AntiRaycastConn = nil,
    AntiInputConn = nil,
    AntiChecksumConn = nil,
    DistanceUpdateConn = nil,
    PlayerAddedConn = nil,
    PlayerRemovingConn = nil,
    CharAddedConn = nil,
    PlayerButtons = {},
    IsDraggingSlider = false,
    IsMinimized = false,
    RaycastBlocked = 0,
    ChecksumBlocked = 0,
    InputBlocked = 0,
    LastValidPos = nil,
    LastValidCF = nil,
    FakeVelocity = Vector3.zero,
    SmoothPos = nil,
}

-- Khai báo trước các hàm để không bị lỗi Scope
local stopFly, startFly, setSpeed
local speedInput, sliderFill, sliderKnob -- Khai báo UI element cho Slider

local function getRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
end

local function createCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function createStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.PrimaryColor
    s.Thickness = thickness or 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function createGradient(parent, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function formatNumber(n)
    if n >= 1000000 then
        return string.format("%.1fM", n / 1000000)
    elseif n >= 1000 then
        return string.format("%.0fK", n / 1000)
    end
    return tostring(n)
end

local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "TVanDzNotifyGui"
NotifyGui.ResetOnSpawn = false
NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifyGui.IgnoreGuiInset = true
NotifyGui.DisplayOrder = 999
NotifyGui.Parent = PlayerGui

local function Notify(title, message, notifType, duration)
    notifType = notifType or "info"
    duration = duration or 3

    local colors = {
        info = CONFIG.AccentColor,
        success = CONFIG.SuccessColor,
        warn = CONFIG.WarnColor,
        error = CONFIG.DangerColor,
    }
    local icons = {
        info = "ℹ️",
        success = "✅",
        warn = "⚠️",
        error = "❌",
    }

    local color = colors[notifType] or CONFIG.AccentColor
    local icon = icons[notifType] or "ℹ️"

    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 300, 0, 60)
    notifFrame.Position = UDim2.new(1, 320, 0, 20)
    notifFrame.BackgroundColor3 = CONFIG.BgPanel
    notifFrame.BorderSizePixel = 0
    notifFrame.Parent = NotifyGui
    createCorner(notifFrame, 10)
    createStroke(notifFrame, color, 1.5)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, -12)
    accent.Position = UDim2.new(0, 6, 0, 6)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    accent.Parent = notifFrame
    createCorner(accent, 2)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 16, 0, 8)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 18
    iconLabel.Parent = notifFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 0, 20)
    titleLabel.Position = UDim2.new(0, 50, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = color
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notifFrame

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -60, 0, 24)
    msgLabel.Position = UDim2.new(0, 50, 0, 28)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = CONFIG.TextMain
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.TextSize = 11
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.Parent = notifFrame

    TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -320, 0, 20)}):Play()

    task.delay(duration, function()
        if notifFrame and notifFrame.Parent then
            local tween = TweenService:Create(notifFrame, TweenInfo.new(0.3),
                {Position = UDim2.new(1, 320, 0, 20)})
            tween:Play()
            tween.Completed:Connect(function() notifFrame:Destroy() end)
        end
    end)
end

local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "TVanDzWatermarkGui"
WatermarkGui.ResetOnSpawn = false
WatermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
WatermarkGui.IgnoreGuiInset = true
WatermarkGui.DisplayOrder = 998
WatermarkGui.Parent = PlayerGui

local function createWatermark(position, anchorPoint, alignX, alignY)
    local wm = Instance.new("TextLabel")
    wm.Size = UDim2.new(0, 200, 0, 30)
    wm.Position = position
    wm.AnchorPoint = anchorPoint
    wm.BackgroundTransparency = 0.35
    wm.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    wm.Text = CONFIG.Brand
    wm.TextColor3 = CONFIG.AccentColor
    wm.Font = Enum.Font.GothamBlack
    wm.TextSize = 16
    wm.TextXAlignment = alignX
    wm.TextYAlignment = alignY
    wm.TextStrokeTransparency = 0.3
    wm.TextStrokeColor3 = CONFIG.PrimaryColor
    wm.Parent = WatermarkGui
    createCorner(wm, 6)
    createStroke(wm, CONFIG.PrimaryColor, 1)

    local pulseTween = TweenService:Create(wm, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {TextColor3 = CONFIG.PrimaryColor})
    pulseTween:Play()

    return wm
end

createWatermark(UDim2.new(0, 10, 0, 10), Vector2.new(0, 0), Enum.TextXAlignment.Left, Enum.TextYAlignment.Top)
createWatermark(UDim2.new(1, -10, 0, 10), Vector2.new(1, 0), Enum.TextXAlignment.Right, Enum.TextYAlignment.Top)
createWatermark(UDim2.new(0, 10, 1, -10), Vector2.new(0, 1), Enum.TextXAlignment.Left, Enum.TextYAlignment.Bottom)
createWatermark(UDim2.new(1, -10, 1, -10), Vector2.new(1, 1), Enum.TextXAlignment.Right, Enum.TextYAlignment.Bottom)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeowTargetTrackerGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 997
ScreenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 360, 0, 590)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -295)
mainFrame.BackgroundColor3 = CONFIG.BgDark
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = ScreenGui
createCorner(mainFrame, 16)

local mainStroke = createStroke(mainFrame, CONFIG.PrimaryColor, 2)

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.BgDark),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 12, 32)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 18, 48)),
})
bgGradient.Rotation = 135
bgGradient.Parent = mainFrame

task.spawn(function()
    while mainFrame and mainFrame.Parent do
        TweenService:Create(mainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Color = CONFIG.AccentColor}):Play()
        task.wait(2)
        TweenService:Create(mainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Color = CONFIG.PrimaryColor}):Play()
        task.wait(2)
    end
end)

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = CONFIG.SecondaryColor
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
createCorner(topBar, 16)

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 15)
topBarFix.Position = UDim2.new(0, 0, 1, -15)
topBarFix.BackgroundColor3 = CONFIG.SecondaryColor
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

local topGradient = Instance.new("UIGradient")
topGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.PrimaryColor),
    ColorSequenceKeypoint.new(0.5, CONFIG.SecondaryColor),
    ColorSequenceKeypoint.new(1, CONFIG.PrimaryColor),
})
topGradient.Rotation = 0
topGradient.Parent = topBar

local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0, 32, 0, 32)
logoFrame.Position = UDim2.new(0, 12, 0.5, -16)
logoFrame.BackgroundColor3 = CONFIG.AccentColor
logoFrame.BorderSizePixel = 0
logoFrame.Parent = topBar
createCorner(logoFrame, 10)

local logoGradient = Instance.new("UIGradient")
logoGradient.Color = ColorSequence.new(CONFIG.AccentColor, CONFIG.PrimaryColor)
logoGradient.Rotation = 45
logoGradient.Parent = logoFrame

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "★"
logoText.TextColor3 = CONFIG.BgDark
logoText.Font = Enum.Font.GothamBlack
logoText.TextSize = 20
logoText.Parent = logoFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -130, 0, 20)
titleLabel.Position = UDim2.new(0, 52, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = CONFIG.Title
titleLabel.TextColor3 = CONFIG.TextMain
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local subTitleLabel = Instance.new("TextLabel")
subTitleLabel.Size = UDim2.new(1, -130, 0, 16)
subTitleLabel.Position = UDim2.new(0, 52, 0, 26)
subTitleLabel.BackgroundTransparency = 1
subTitleLabel.Text = CONFIG.Subtitle .. " • " .. CONFIG.Version
subTitleLabel.TextColor3 = CONFIG.GoldColor
subTitleLabel.Font = Enum.Font.GothamBold
subTitleLabel.TextSize = 9
subTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subTitleLabel.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -66, 0.5, -13)
minBtn.BackgroundColor3 = CONFIG.BgElement
minBtn.TextColor3 = CONFIG.TextMain
minBtn.Text = "−"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.AutoButtonColor = false
minBtn.Parent = topBar
createCorner(minBtn, 7)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = CONFIG.DangerColor
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.AutoButtonColor = false
closeBtn.Parent = topBar
createCorner(closeBtn, 7)

local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, 0, 1, -50)
contentContainer.Position = UDim2.new(0, 0, 0, 50)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -20, 0, 28)
statusBar.Position = UDim2.new(0, 10, 0, 8)
statusBar.BackgroundColor3 = CONFIG.BgPanel
statusBar.BorderSizePixel = 0
statusBar.Parent = contentContainer
createCorner(statusBar, 8)
createStroke(statusBar, Color3.fromRGB(50, 40, 70), 1)

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(0, 12, 0.5, -4)
statusDot.BackgroundColor3 = CONFIG.SuccessColor
statusDot.BorderSizePixel = 0
statusDot.Parent = statusBar
createCorner(statusDot, 4)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -40, 1, 0)
statusLabel.Position = UDim2.new(0, 28, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Sẵn sàng"
statusLabel.TextColor3 = CONFIG.SuccessColor
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusBar

local targetInfo = Instance.new("Frame")
targetInfo.Size = UDim2.new(1, -20, 0, 36)
targetInfo.Position = UDim2.new(0, 10, 0, 42)
targetInfo.BackgroundColor3 = CONFIG.BgPanel
targetInfo.BorderSizePixel = 0
targetInfo.Parent = contentContainer
createCorner(targetInfo, 8)
createStroke(targetInfo, Color3.fromRGB(50, 40, 70), 1)

local targetIcon = Instance.new("TextLabel")
targetIcon.Size = UDim2.new(0, 24, 1, 0)
targetIcon.Position = UDim2.new(0, 8, 0, 0)
targetIcon.BackgroundTransparency = 1
targetIcon.Text = "🎯"
targetIcon.TextSize = 15
targetIcon.Parent = targetInfo

local targetInfoLabel = Instance.new("TextLabel")
targetInfoLabel.Size = UDim2.new(1, -40, 1, 0)
targetInfoLabel.Position = UDim2.new(0, 34, 0, 0)
targetInfoLabel.BackgroundTransparency = 1
targetInfoLabel.Text = "Chưa chọn mục tiêu"
targetInfoLabel.TextColor3 = CONFIG.TextDim
targetInfoLabel.Font = Enum.Font.GothamBold
targetInfoLabel.TextSize = 11
targetInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
targetInfoLabel.Parent = targetInfo

local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -20, 0, 16)
listLabel.Position = UDim2.new(0, 10, 0, 84)
listLabel.BackgroundTransparency = 1
listLabel.Text = "👥 DANH SÁCH NGƯỜI CHƠI"
listLabel.TextColor3 = CONFIG.AccentColor
listLabel.Font = Enum.Font.GothamBold
listLabel.TextSize = 10
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = contentContainer

local scrollList = Instance.new("ScrollingFrame")
scrollList.Size = UDim2.new(1, -20, 0, 110)
scrollList.Position = UDim2.new(0, 10, 0, 102)
scrollList.BackgroundColor3 = CONFIG.BgPanel
scrollList.BorderSizePixel = 0
scrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollList.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollList.ScrollBarThickness = 4
scrollList.ScrollBarImageColor3 = CONFIG.PrimaryColor
scrollList.Parent = contentContainer
createCorner(scrollList, 8)
createStroke(scrollList, Color3.fromRGB(50, 40, 70), 1)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollList

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 5)
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.PaddingLeft = UDim.new(0, 5)
listPadding.PaddingRight = UDim.new(0, 5)
listPadding.Parent = scrollList

local btnRow = Instance.new("Frame")
btnRow.Size = UDim2.new(1, -20, 0, 40)
btnRow.Position = UDim2.new(0, 10, 0, 220)
btnRow.BackgroundTransparency = 1
btnRow.Parent = contentContainer

local teleBtn = Instance.new("TextButton")
teleBtn.Size = UDim2.new(0.5, -5, 1, 0)
teleBtn.BackgroundColor3 = CONFIG.PrimaryColor
teleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleBtn.Text = "⚡ TELEPORT"
teleBtn.Font = Enum.Font.GothamBlack
teleBtn.TextSize = 12
teleBtn.AutoButtonColor = false
teleBtn.Parent = btnRow
createCorner(teleBtn, 9)
createGradient(teleBtn, CONFIG.PrimaryColor, CONFIG.SecondaryColor, 90)

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0.5, -5, 1, 0)
flyBtn.Position = UDim2.new(0.5, 5, 0, 0)
flyBtn.BackgroundColor3 = CONFIG.BgElement
flyBtn.TextColor3 = CONFIG.TextMain
flyBtn.Text = "🚀 BAY: OFF"
flyBtn.Font = Enum.Font.GothamBlack
flyBtn.TextSize = 12
flyBtn.AutoButtonColor = false
flyBtn.Parent = btnRow
createCorner(flyBtn, 9)
createStroke(flyBtn, CONFIG.AccentColor, 1.5)

local toggleGrid = Instance.new("Frame")
toggleGrid.Size = UDim2.new(1, -20, 0, 74)
toggleGrid.Position = UDim2.new(0, 10, 0, 268)
toggleGrid.BackgroundTransparency = 1
toggleGrid.Parent = contentContainer

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0.5, -3, 0, 34)
gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = toggleGrid

local function createToggle(parent, label, defaultOn, callback)
    local row = Instance.new("Frame")
    row.BackgroundColor3 = CONFIG.BgPanel
    row.BorderSizePixel = 0
    row.Parent = parent
    createCorner(row, 8)
    createStroke(row, Color3.fromRGB(50, 40, 70), 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = CONFIG.TextMain
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 34, 0, 18)
    bg.Position = UDim2.new(1, -42, 0.5, -9)
    bg.BackgroundColor3 = defaultOn and CONFIG.SuccessColor or Color3.fromRGB(60, 50, 70)
    bg.BorderSizePixel = 0
    bg.Parent = row
    createCorner(bg, 9)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defaultOn and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = bg
    createCorner(knob, 7)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = bg

    local state = defaultOn
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.SuccessColor}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 50, 70)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
        end
        callback(state)
    end)
end

createToggle(toggleGrid, "🛡️ Anti-Check", true, function(v)
    State.AntiCheckEnabled = v
    Notify("Anti-Check", v and "Đã BẬT" or "Đã TẮT", v and "success" or "warn", 2)
end)

createToggle(toggleGrid, "🎯 Anti-Ray", true, function(v)
    State.AntiRaycastEnabled = v
    Notify("Anti-Raycast", v and "Đã BẬT" or "Đã TẮT", v and "success" or "warn", 2)
end)

createToggle(toggleGrid, "⌨️ Anti-Input", true, function(v)
    State.AntiInputEnabled = v
    Notify("Anti-Input", v and "Đã BẬT" or "Đã TẮT", v and "success" or "warn", 2)
end)

createToggle(toggleGrid, "🔐 Anti-Checksum", true, function(v)
    State.AntiChecksumEnabled = v
    Notify("Anti-Checksum", v and "Đã BẬT" or "Đã TẮT", v and "success" or "warn", 2)
end)

-- Tạo phần UI cho Tốc độ bay (Slider & TextBox)
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 16)
speedLabel.Position = UDim2.new(0, 10, 0, 350)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "🚀 TỐC ĐỘ BAY"
speedLabel.TextColor3 = CONFIG.AccentColor
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = contentContainer

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -90, 0, 6)
sliderBg.Position = UDim2.new(0, 10, 0, 374)
sliderBg.BackgroundColor3 = Color3.fromRGB(60, 50, 70)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = contentContainer
createCorner(sliderBg, 3)

sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.05, 0, 1, 0)
sliderFill.BackgroundColor3 = CONFIG.PrimaryColor
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg
createCorner(sliderFill, 3)

sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.Position = UDim2.new(1, -8, 0.5, -8)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderFill
createCorner(sliderKnob, 8)

speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0, 60, 0, 24)
speedInput.Position = UDim2.new(1, -70, 0, 365)
speedInput.BackgroundColor3 = CONFIG.BgPanel
speedInput.TextColor3 = CONFIG.TextMain
speedInput.Text = tostring(State.FlySpeed)
speedInput.Font = Enum.Font.GothamBold
speedInput.TextSize = 11
speedInput.Parent = contentContainer
createCorner(speedInput, 6)
createStroke(speedInput, Color3.fromRGB(50, 40, 70), 1)

-- Cập nhật Slider Tốc độ bay
local function updateSlider(value)
    value = math.clamp(tonumber(value) or State.MinSpeed, State.MinSpeed, State.MaxSpeed)
    State.FlySpeed = value
    speedInput.Text = tostring(value)
    
    -- Cho slider hiển thị max là 1000 để kéo mượt
    local visualMax = 1000 
    local percent = math.clamp((value - State.MinSpeed) / (visualMax - State.MinSpeed), 0, 1)
    TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
end

sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.IsDraggingSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.IsDraggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if State.IsDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
        local percent = relativeX / sliderBg.AbsoluteSize.X
        local visualMax = 1000
        local newValue = math.floor(State.MinSpeed + (visualMax - State.MinSpeed) * percent)
        updateSlider(newValue)
    end
end)

speedInput.FocusLost:Connect(function()
    updateSlider(speedInput.Text)
end)

-- Chức năng Bay (Fly)
function startFly()
    local char = LocalPlayer.Character
    local root = getRoot(char)
    if not root then return end

    State.IsFlying = true
    flyBtn.Text = "🚀 BAY: ON"
    TweenService:Create(flyBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.SuccessColor, TextColor3 = CONFIG.BgDark}):Play()
    
    local bg = Instance.new("BodyGyro", root)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = root.CFrame
    
    local bv = Instance.new("BodyVelocity", root)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    State.FlyConnection = RunService.RenderStepped:Connect(function()
        if not char or not char.Parent or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
            stopFly()
            return
        end
        
        local cam = Workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        bg.CFrame = cam.CFrame
        if moveDir.Magnitude > 0 then
            bv.Velocity = moveDir.Unit * State.FlySpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    Notify("Fly", "Đã bật chế độ Bay", "success", 2)
end

function stopFly()
    State.IsFlying = false
    flyBtn.Text = "🚀 BAY: OFF"
    TweenService:Create(flyBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.BgElement, TextColor3 = CONFIG.TextMain}):Play()
    
    if State.FlyConnection then State.FlyConnection:Disconnect() end
    local char = LocalPlayer.Character
    local root = getRoot(char)
    if root then
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
    Notify("Fly", "Đã tắt chế độ Bay", "warn", 2)
end

flyBtn.MouseButton1Click:Connect(function()
    if State.IsFlying then stopFly() else startFly() end
end)

-- Chức năng Danh sách & Dịch chuyển (Teleport)
local function selectTarget(player)
    State.TargetPlayer = player
    if player then
        targetInfoLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        targetInfoLabel.TextColor3 = CONFIG.SuccessColor
        Notify("Mục tiêu", "Đã chọn: " .. player.Name, "info", 1.5)
    else
        targetInfoLabel.Text = "Chưa chọn mục tiêu"
        targetInfoLabel.TextColor3 = CONFIG.TextDim
    end
end

local function updatePlayerList()
    for _, btn in pairs(State.PlayerButtons) do btn:Destroy() end
    State.PlayerButtons = {}
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(40, 32, 55)
            btn.BorderSizePixel = 0
            btn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            btn.TextColor3 = CONFIG.TextMain
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 11
            btn.Parent = scrollList
            createCorner(btn, 6)
            
            btn.MouseButton1Click:Connect(function() selectTarget(p) end)
            table.insert(State.PlayerButtons, btn)
        end
    end
end

State.PlayerAddedConn = Players.PlayerAdded:Connect(updatePlayerList)
State.PlayerRemovingConn = Players.PlayerRemoving:Connect(function(p)
    if State.TargetPlayer == p then selectTarget(nil) end
    updatePlayerList()
end)
updatePlayerList()

teleBtn.MouseButton1Click:Connect(function()
    if not State.TargetPlayer or not State.TargetPlayer.Character then
        Notify("Lỗi", "Mục tiêu không hợp lệ hoặc chưa xuất hiện!", "error", 2)
        return
    end
    local myRoot = getRoot(LocalPlayer.Character)
    local targetRoot = getRoot(State.TargetPlayer.Character)
    
    if myRoot and targetRoot then
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
        Notify("Teleport", "Đã dịch chuyển đến " .. State.TargetPlayer.Name, "success", 2)
    else
        Notify("Lỗi", "Không tìm thấy HumanoidRootPart", "error", 2)
    end
end)

-- Chức năng Kéo thả Window (Drag UI)
local draggingUI, dragStartUI, startPosUI
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingUI = true
        dragStartUI = input.Position
        startPosUI = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingUI = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingUI and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartUI
        mainFrame.Position = UDim2.new(
            startPosUI.X.Scale, startPosUI.X.Offset + delta.X,
            startPosUI.Y.Scale, startPosUI.Y.Offset + delta.Y
        )
    end
end)

minBtn.MouseButton1Click:Connect(function()
    State.IsMinimized = not State.IsMinimized
    contentContainer.Visible = not State.IsMinimized
    if State.IsMinimized then
        mainFrame.Size = UDim2.new(0, 360, 0, 50)
        minBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 360, 0, 590)
        minBtn.Text = "−"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    if State.IsFlying then stopFly() end
    if State.PlayerAddedConn then State.PlayerAddedConn:Disconnect() end
    if State.PlayerRemovingConn then State.PlayerRemovingConn:Disconnect() end
    ScreenGui:Destroy()
    WatermarkGui:Destroy()
    NotifyGui:Destroy()
end)

pcall(function()
    local gmt = getrawmetatable(game)
    local oldNamecall = gmt.__namecall
    setreadonly(gmt, false)
    
    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() then
            if State.AntiCheckEnabled and (method == "Kick" or method == "kick") then
                return nil
            end
            if State.AntiRaycastEnabled and method == "Raycast" then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(gmt, true)
end)

Notify("Khởi động", CONFIG.Title .. " " .. CONFIG.Version .. " đã tải thành công!", "success", 4)
