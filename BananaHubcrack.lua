local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local rng = Random.new()

local YELLOW = Color3.fromRGB(255, 198, 35)
local LIGHT = Color3.fromRGB(255, 226, 110)
local DARK = Color3.fromRGB(9, 8, 5)
local PANEL = Color3.fromRGB(18, 16, 10)
local MUTED = Color3.fromRGB(145, 137, 113)
local DIM = Color3.fromRGB(78, 72, 54)
local GREEN = Color3.fromRGB(105, 255, 135)

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local function stroke(obj, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency
    s.Thickness = thickness
    s.Parent = obj
    return s
end

local function label(parent, size, position, text, color, font)
    local l = Instance.new("TextLabel")
    l.Size = size
    l.Position = position
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color
    l.Font = font
    l.TextScaled = true
    l.Parent = parent
    return l
end

local function hex(n)
    return string.format("%0" .. n .. "X", rng:NextInteger(0, 16 ^ n - 1))
end

local gui = Instance.new("ScreenGui")
gui.Name = "CRACK_BANANA_HUB🍌"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local dim = Instance.new("Frame")
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 1
dim.BorderSizePixel = 0
dim.ZIndex = 1
dim.Parent = gui

tween(dim, TweenInfo.new(0.7), {
    BackgroundTransparency = 0.88
})

local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromScale(0.58, 0.50)
main.BackgroundColor3 = PANEL
main.BackgroundTransparency = 0.025
main.BorderSizePixel = 0
main.ZIndex = 10
main.Parent = gui
corner(main, 18)
stroke(main, YELLOW, 0.58, 1)

local scale = Instance.new("UIScale")
scale.Scale = 0.82
scale.Parent = main

tween(scale, TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Scale = 1
})

local topGlow = Instance.new("Frame")
topGlow.Size = UDim2.fromScale(0.72, 0.012)
topGlow.Position = UDim2.fromScale(0.14, 0)
topGlow.BackgroundColor3 = YELLOW
topGlow.BorderSizePixel = 0
topGlow.ZIndex = 20
topGlow.Parent = main
corner(topGlow, 100)

local header = Instance.new("Frame")
header.Size = UDim2.fromScale(0.90, 0.17)
header.Position = UDim2.fromScale(0.05, 0.045)
header.BackgroundTransparency = 1
header.ZIndex = 15
header.Parent = main

local logo = Instance.new("Frame")
logo.Size = UDim2.fromScale(0.11, 0.78)
logo.Position = UDim2.fromScale(0, 0.1)
logo.BackgroundColor3 = Color3.fromRGB(38, 32, 12)
logo.BorderSizePixel = 0
logo.ZIndex = 16
logo.Parent = header
corner(logo, 12)
stroke(logo, YELLOW, 0.3, 1)

local logoText = label(
    logo,
    UDim2.fromScale(1, 1),
    UDim2.fromScale(0, 0),
    "B",
    LIGHT,
    Enum.Font.GothamBlack
)
logoText.ZIndex = 17

local title = label(
    header,
    UDim2.fromScale(0.58, 0.42),
    UDim2.fromScale(0.145, 0.05),
    "BANANA CORE",
    LIGHT,
    Enum.Font.GothamBold
)
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 16

local sub = label(
    header,
    UDim2.fromScale(0.65, 0.32),
    UDim2.fromScale(0.145, 0.49),
    "BỘ XÁC THỰC KEY",
    MUTED,
    Enum.Font.Code
)
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.ZIndex = 16

local online = label(
    header,
    UDim2.fromScale(0.28, 0.35),
    UDim2.fromScale(0.72, 0.08),
    "● ĐANG CHẠY",
    GREEN,
    Enum.Font.Code
)
online.TextXAlignment = Enum.TextXAlignment.Right
online.ZIndex = 16

local session = label(
    header,
    UDim2.fromScale(0.38, 0.3),
    UDim2.fromScale(0.62, 0.54),
    "PHIÊN " .. hex(6),
    DIM,
    Enum.Font.Code
)
session.TextXAlignment = Enum.TextXAlignment.Right
session.ZIndex = 16

local terminalBox = Instance.new("Frame")
terminalBox.Size = UDim2.fromScale(0.90, 0.42)
terminalBox.Position = UDim2.fromScale(0.05, 0.235)
terminalBox.BackgroundColor3 = Color3.fromRGB(8, 8, 6)
terminalBox.BackgroundTransparency = 0.05
terminalBox.BorderSizePixel = 0
terminalBox.ZIndex = 15
terminalBox.Parent = main
corner(terminalBox, 11)
stroke(terminalBox, Color3.fromRGB(70, 64, 43), 0.72, 1)

local terminalHeader = label(
    terminalBox,
    UDim2.fromScale(0.9, 0.16),
    UDim2.fromScale(0.05, 0.04),
    "DỮ LIỆU XÁC THỰC CRACK",
    YELLOW,
    Enum.Font.GothamBold
)
terminalHeader.TextXAlignment = Enum.TextXAlignment.Left
terminalHeader.ZIndex = 16

local terminalState = label(
    terminalBox,
    UDim2.fromScale(0.3, 0.16),
    UDim2.fromScale(0.65, 0.04),
    "ĐANG CHẠY",
    GREEN,
    Enum.Font.Code
)
terminalState.TextXAlignment = Enum.TextXAlignment.Right
terminalState.ZIndex = 16

local terminal = Instance.new("ScrollingFrame")
terminal.Size = UDim2.fromScale(0.90, 0.68)
terminal.Position = UDim2.fromScale(0.05, 0.22)
terminal.BackgroundTransparency = 1
terminal.BorderSizePixel = 0
terminal.ScrollBarThickness = 1
terminal.ScrollBarImageColor3 = YELLOW
terminal.AutomaticCanvasSize = Enum.AutomaticSize.Y
terminal.CanvasSize = UDim2.fromScale(0, 0)
terminal.ZIndex = 16
terminal.Parent = terminalBox

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.Parent = terminal

local progressText = label(
    main,
    UDim2.fromScale(0.3, 0.055),
    UDim2.fromScale(0.05, 0.68),
    "ĐANG XÁC THỰC",
    MUTED,
    Enum.Font.Code
)
progressText.TextXAlignment = Enum.TextXAlignment.Left
progressText.ZIndex = 16

local percent = label(
    main,
    UDim2.fromScale(0.22, 0.075),
    UDim2.fromScale(0.73, 0.665),
    "0%",
    LIGHT,
    Enum.Font.GothamBold
)
percent.TextXAlignment = Enum.TextXAlignment.Right
percent.ZIndex = 16

local barBack = Instance.new("Frame")
barBack.Size = UDim2.fromScale(0.90, 0.055)
barBack.Position = UDim2.fromScale(0.05, 0.745)
barBack.BackgroundColor3 = Color3.fromRGB(45, 39, 22)
barBack.BorderSizePixel = 0
barBack.ZIndex = 16
barBack.Parent = main
corner(barBack, 100)

local bar = Instance.new("Frame")
bar.Size = UDim2.fromScale(0, 1)
bar.BackgroundColor3 = YELLOW
bar.BorderSizePixel = 0
bar.ZIndex = 17
bar.Parent = barBack
corner(bar, 100)

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(181, 124, 8)),
    ColorSequenceKeypoint.new(0.5, LIGHT),
    ColorSequenceKeypoint.new(1, YELLOW)
})
gradient.Parent = bar

local scan = Instance.new("Frame")
scan.Size = UDim2.fromScale(0.025, 1)
scan.BackgroundColor3 = Color3.new(1, 1, 1)
scan.BackgroundTransparency = 0.35
scan.BorderSizePixel = 0
scan.Parent = bar

tween(
    scan,
    TweenInfo.new(1.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    {Position = UDim2.fromScale(0.975, 0)}
)

local phase = label(
    main,
    UDim2.fromScale(0.55, 0.065),
    UDim2.fromScale(0.05, 0.825),
    "ĐANG KHỞI TẠO HỆ THỐNG",
    MUTED,
    Enum.Font.Code
)
phase.TextXAlignment = Enum.TextXAlignment.Left
phase.ZIndex = 16

local counter = label(
    main,
    UDim2.fromScale(0.35, 0.065),
    UDim2.fromScale(0.60, 0.825),
    "0 YÊU CẦU",
    DIM,
    Enum.Font.Code
)
counter.TextXAlignment = Enum.TextXAlignment.Right
counter.ZIndex = 16

local footer = label(
    main,
    UDim2.fromScale(0.9, 0.055),
    UDim2.fromScale(0.05, 0.915),
    "Crack No Key • Banana Hub🍌",
    DIM,
    Enum.Font.Code
)
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 16

local function addLog(text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 17)
    l.BackgroundTransparency = 1
    l.Text = os.date("%H:%M:%S") .. "  " .. text
    l.TextColor3 = color or MUTED
    l.Font = Enum.Font.Code
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 17
    l.Parent = terminal

    task.defer(function()
        terminal.CanvasPosition = Vector2.new(
            0,
            math.max(0, terminal.AbsoluteCanvasSize.Y - terminal.AbsoluteSize.Y)
        )
    end)
end

local phases = {
    {0.00, "ĐANG KHỞI TẠO HỆ THỐNG"},
    {0.09, "ĐANG THIẾT LẬP KẾT NỐI"},
    {0.20, "ĐANG QUÉT DỮ LIỆU CRACK KEY"},
    {0.34, "ĐANG PHÂN TÍCH CHUỖI KEY"},
    {0.49, "ĐANG XỬ LÝ CÁC KHỐI XÁC THỰC"},
    {0.64, "ĐANG KIỂM TRA CHECKSUM"},
    {0.78, "ĐANG ĐỐI CHIẾU DỮ LIỆU"},
    {0.90, "ĐANG HOÀN TẤT XÁC THỰC"}
}

local messages = {
    "khởi tạo lõi xác thực",
    "đang tải bảng dữ liệu " .. hex(6),
    "đã tạo khối kiểm tra độ tương thích " .. hex(8),
    "đang phân tích mẫu dữ liệu " .. hex(5),
    "đã nhận checksum " .. hex(6),
    "đang xử lý gói xác thực " .. hex(7),
    "đang crack no key " .. hex(5),
    "đang đồng bộ tiến trình",
    "đang cập nhật cửa sổ xác thực",
    "đang kiểm tra cấu trúc script",
    "đang xử lý yêu cầu tiếp theo",
    "đang làm mới bộ nhớ xác thực"
}

addLog("> KHỞI ĐỘNG HỆ THỐNG", YELLOW)
addLog("> KẾT NỐI KEY SERVER: KHÔNG KẾT NỐI", DIM)
addLog("> BỘ XÁC THỰC CỤC BỘ: SẴN SÀNG", GREEN)

local duration = 90
local start = os.clock()
local nextLog = 0
local requests = 0
local phaseIndex = 1

while os.clock() - start < duration do
    local elapsed = os.clock() - start
    local progress = math.clamp(elapsed / duration, 0, 1)

    bar.Size = UDim2.fromScale(progress, 1)
    percent.Text = math.floor(progress * 100) .. "%"

    while phaseIndex < #phases and progress >= phases[phaseIndex + 1][1] do
        phaseIndex += 1
    end

    phase.Text = phases[phaseIndex][2]

    requests += rng:NextInteger(1, 5)
    counter.Text = tostring(requests) .. " YÊU CẦU"

    if elapsed >= nextLog then
        addLog(
            "> " .. messages[rng:NextInteger(1, #messages)],
            rng:NextNumber() > 0.78 and YELLOW or MUTED
        )

        nextLog = elapsed + rng:NextNumber(0.25, 0.7)
    end

    task.wait(0.08)
end

bar.Size = UDim2.fromScale(1, 1)
percent.Text = "100%"
phase.Text = "XÁC THỰC HOÀN TẤT"
counter.Text = tostring(requests) .. " YÊU CẦU"
terminalState.Text = "Thành Công ✅"
terminalState.TextColor3 = GREEN

addLog("> ĐÃ HOÀN TẤT QUÁ TRÌNH XÁC THỰC", GREEN)
addLog("> ĐÃ HOÀN TẤT KIỂM TRA DỮ LIỆU", YELLOW)
addLog("> TRUY CẬP KEY THẬT", DIM)

task.wait(2)

local result = Instance.new("Frame")
result.AnchorPoint = Vector2.new(0.5, 0.5)
result.Position = UDim2.fromScale(0.5, 0.5)
result.Size = UDim2.fromScale(0.42, 0.29)
result.BackgroundColor3 = PANEL
result.BorderSizePixel = 0
result.ZIndex = 40
result.Parent = gui
corner(result, 16)
stroke(result, YELLOW, 0.45, 1)

local resultScale = Instance.new("UIScale")
resultScale.Scale = 0.7
resultScale.Parent = result

tween(
    resultScale,
    TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Scale = 1}
)

local resultTitle = label(
    result,
    UDim2.fromScale(0.86, 0.23),
    UDim2.fromScale(0.07, 0.13),
    "HỆ THỐNG KHÔNG THỂ TẢI TƯƠNG THÍCH",
    LIGHT,
    Enum.Font.GothamBlack
)

local resultInfo = label(
    result,
    UDim2.fromScale(0.84, 0.30),
    UDim2.fromScale(0.08, 0.40),
    "Hệ thống máy của bạn hiện không tương thích được giao diện.\nXin lỗi nhé!",
    MUTED,
    Enum.Font.Gotham
)

local resultTag = label(
    result,
    UDim2.fromScale(0.84, 0.13),
    UDim2.fromScale(0.08, 0.76),
    "TVÀN • BANANA HUB🍌",
    DIM,
    Enum.Font.Code
)

task.wait(4)

if player and player.Parent then
    player:Kick(
        "Hệ thống máy của bạn hiện không tương thích giao diện.\n\nXin lỗi nhé!"
    )
end
