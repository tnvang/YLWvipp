local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local ADMIN_USERS = {
	["EpicGenAlphaBot109_"] = true,
	["Tvanxviet69depzai_91"] = true
}

local PLAYER_KEYS = {
	["Key128+. Co"] = true,
	["Key1ooann91"] = true,
	["Key192&owp"] = true,
	["Key1+'ondj90"] = true,
	["Key1sjj901!₫"] = true,
	["Key1*992!0\"?_"] = true,
	["Key1**ienn93!\""] = true
}

local ADMIN_KEYS = {
	["KeyAdmin367"] = true
}

local SECURITY_KEYS = {
	["Crack_(+wonz3"] = true,
	["Cracksonnd72?"] = true,
	["Crackzon28!!*9/"] = true,
	["Crackiwnbdkoxl"] = true,
	["Crack20msnl&@"] = true,
	["Crack**sow)/s1"] = true,
	["Crackhentaiz19!"] = true
}

local FINAL_KEYS = {
	["VANDZ-SECURE-8291"] = true,
	["VANDZ-VERIFY-4418"] = true,
	["VANDZ-AUTH-7302"] = true
}

local ADMIN_SECURITY_KEYS = {
	["CrackKeyAdminVandz199#"] = true
}

local ADMIN_FINAL_KEYS = {
	["VANDZ-ADMIN-SECURE-9901"] = true
}

local SCRIPT_CODE = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/tnvang/YLWvipp/main/BananaHubcrack.lua"))()'

local gui = Instance.new("ScreenGui")
gui.Name = "VANDZ_SECURE_ACCESS"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = Player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(450, 430)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 22)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 191, 45)
stroke.Thickness = 1.4
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 38)
title.Position = UDim2.fromOffset(25, 24)
title.BackgroundTransparency = 1
title.Text = "VANDZ SECURITY"
title.TextColor3 = Color3.fromRGB(255, 197, 55)
title.Font = Enum.Font.GothamBold
title.TextSize = 25
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -50, 0, 24)
subtitle.Position = UDim2.fromOffset(25, 63)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Secure access verification"
subtitle.TextColor3 = Color3.fromRGB(145, 145, 155)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

local stepLabel = Instance.new("TextLabel")
stepLabel.Size = UDim2.new(1, -50, 0, 20)
stepLabel.Position = UDim2.fromOffset(25, 91)
stepLabel.BackgroundTransparency = 1
stepLabel.Text = "STEP 1 / 3"
stepLabel.TextColor3 = Color3.fromRGB(95, 95, 105)
stepLabel.Font = Enum.Font.GothamBold
stepLabel.TextSize = 10
stepLabel.TextXAlignment = Enum.TextXAlignment.Left
stepLabel.Parent = main

local function makeButton(text, pos, size)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.BackgroundColor3 = Color3.fromRGB(25, 25, 31)
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.fromRGB(235, 235, 240)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.AutoButtonColor = false
	b.Parent = main

	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 13)

	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(58, 58, 68)
	s.Thickness = 1
	s.Parent = b

	return b
end

local playerButton = makeButton(
	"PLAYER",
	UDim2.fromOffset(25, 125),
	UDim2.fromOffset(190, 52)
)

local adminButton = makeButton(
	"ADMIN",
	UDim2.fromOffset(235, 125),
	UDim2.fromOffset(190, 52)
)

local usernameBox = Instance.new("TextBox")
usernameBox.Size = UDim2.new(1, -50, 0, 50)
usernameBox.Position = UDim2.fromOffset(25, 190)
usernameBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
usernameBox.BorderSizePixel = 0
usernameBox.PlaceholderText = "Roblox username"
usernameBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 90)
usernameBox.TextColor3 = Color3.fromRGB(245, 245, 245)
usernameBox.Text = ""
usernameBox.Font = Enum.Font.Gotham
usernameBox.TextSize = 14
usernameBox.ClearTextOnFocus = false
usernameBox.Parent = main

Instance.new("UICorner", usernameBox).CornerRadius = UDim.new(0, 13)

local usernameStroke = Instance.new("UIStroke")
usernameStroke.Color = Color3.fromRGB(48, 48, 58)
usernameStroke.Parent = usernameBox

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -50, 0, 50)
keyBox.Position = UDim2.fromOffset(25, 252)
keyBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Access key"
keyBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 90)
keyBox.TextColor3 = Color3.fromRGB(245, 245, 245)
keyBox.Text = ""
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.ClearTextOnFocus = false
keyBox.Parent = main

Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 13)

local verifyButton = makeButton(
	"VERIFY",
	UDim2.fromOffset(25, 318),
	UDim2.new(1, -50, 0, 50)
)

verifyButton.BackgroundColor3 = Color3.fromRGB(255, 191, 45)
verifyButton.TextColor3 = Color3.fromRGB(18, 18, 18)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -50, 0, 25)
status.Position = UDim2.fromOffset(25, 382)
status.BackgroundTransparency = 1
status.Text = "Select Player or Admin"
status.TextColor3 = Color3.fromRGB(140, 140, 150)
status.Font = Enum.Font.GothamMedium
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local role = nil
local step = 1
local busy = false
local verifiedUsername = nil

local function statusText(text, success)
	status.Text = text

	if success then
		status.TextColor3 = Color3.fromRGB(75, 220, 135)
	else
		status.TextColor3 = Color3.fromRGB(255, 90, 90)
	end
end

local function selectRole(value)
	role = value

	playerButton.BackgroundColor3 = Color3.fromRGB(25, 25, 31)
	adminButton.BackgroundColor3 = Color3.fromRGB(25, 25, 31)

	if value == "Player" then
		playerButton.BackgroundColor3 = Color3.fromRGB(67, 63, 43)
		statusText("Player mode selected", true)
	else
		adminButton.BackgroundColor3 = Color3.fromRGB(67, 63, 43)
		statusText("Admin mode selected", true)
	end
end

playerButton.MouseButton1Click:Connect(function()
	if not busy then
		selectRole("Player")
	end
end)

adminButton.MouseButton1Click:Connect(function()
	if not busy then
		selectRole("Admin")
	end
end)

local function validUsername()
	local username = usernameBox.Text

	if username == "" then
		return false
	end

	if role == "Admin" then
		return ADMIN_USERS[username] == true
	end

	return true
end

local function validKey()
	if role == "Admin" then
		if step == 1 then
			return ADMIN_KEYS[keyBox.Text] == true
		elseif step == 2 then
			return ADMIN_SECURITY_KEYS[keyBox.Text] == true
		else
			return ADMIN_FINAL_KEYS[keyBox.Text] == true
		end
	end

	if step == 1 then
		return PLAYER_KEYS[keyBox.Text] == true
	elseif step == 2 then
		return SECURITY_KEYS[keyBox.Text] == true
	else
		return FINAL_KEYS[keyBox.Text] == true
	end
end

local function createSecurityCheck(callback)
	if busy then
		return
	end

	busy = true

	usernameBox.Visible = false
	keyBox.Visible = false
	verifyButton.Visible = false

	title.Text = "BOT SECURITY"
	subtitle.Text = "Complete the verification below"

	status.Position = UDim2.fromOffset(25, 370)
	statusText("Click the square to start", true)

	local box = Instance.new("TextButton")
	box.Size = UDim2.fromOffset(58, 58)
	box.Position = UDim2.fromOffset(196, 220)
	box.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	box.BorderSizePixel = 0
	box.Text = ""
	box.AutoButtonColor = false
	box.Parent = main

	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Color3.fromRGB(255, 191, 45)
	boxStroke.Thickness = 2
	boxStroke.Parent = box

	local mark = Instance.new("TextLabel")
	mark.Size = UDim2.fromScale(1, 1)
	mark.BackgroundTransparency = 1
	mark.Text = "□"
	mark.TextColor3 = Color3.fromRGB(255, 191, 45)
	mark.Font = Enum.Font.GothamBold
	mark.TextSize = 30
	mark.Parent = box

	local clicked = false

	box.MouseButton1Click:Connect(function()
		if clicked then
			return
		end

		clicked = true
		box.Active = false

		mark.Text = "..."
		mark.TextColor3 = Color3.fromRGB(255, 191, 45)

		local duration = math.random(8, 14)

		for remaining = duration, 1, -1 do
			statusText(
				"Security verification • " .. remaining .. "s",
				true
			)

			task.wait(1)
		end

		mark.Text = "✓"
		mark.TextColor3 = Color3.fromRGB(75, 220, 135)

		statusText("Human verification completed", true)

		task.wait(0.8)

		box:Destroy()

		callback()
	end)
end

local function setupStep(nextStep)
	step = nextStep

	stepLabel.Text = "STEP " .. step .. " / 3"

	usernameBox.Visible = true
	keyBox.Visible = true
	verifyButton.Visible = true

	usernameBox.Position = UDim2.fromOffset(25, 190)
	keyBox.Position = UDim2.fromOffset(25, 252)
	verifyButton.Position = UDim2.fromOffset(25, 318)

	usernameBox.Text = verifiedUsername or usernameBox.Text
	keyBox.Text = ""

	if step == 2 then
		title.Text = "SECURITY CHECK"
		subtitle.Text = "Enter the second verification key"
		keyBox.PlaceholderText = "Security key"
		verifyButton.Text = "VERIFY SECURITY"
	elseif step == 3 then
		title.Text = "FINAL AUTHORIZATION"
		subtitle.Text = "Complete the final authorization"
		keyBox.PlaceholderText = "Final authorization key"
		verifyButton.Text = "AUTHORIZE"
	end

	statusText("Verification layer " .. step .. " ready", true)
end

local function finish()
	title.Text = "ACCESS GRANTED"
	subtitle.Text = "All security layers completed"

	usernameBox.Visible = false
	keyBox.Visible = false
	status.Visible = false

	verifyButton.Position = UDim2.fromOffset(25, 210)
	verifyButton.Size = UDim2.new(1, -50, 0, 58)
	verifyButton.Text = "COPY SCRIPT"
	verifyButton.Visible = true

	verifyButton.MouseButton1Click:Connect(function()
		if busy then
			return
		end

		busy = true
		verifyButton.Text = "PREPARING..."

		task.wait(1)

		if setclipboard then
			setclipboard(SCRIPT_CODE)
		elseif toclipboard then
			toclipboard(SCRIPT_CODE)
		else
			verifyButton.Text = "CLIPBOARD UNAVAILABLE"
			busy = false
			return
		end

		verifyButton.Text = "COPIED ✓"
		verifyButton.BackgroundColor3 = Color3.fromRGB(70, 205, 125)
		verifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)
end

verifyButton.MouseButton1Click:Connect(function()
	if busy then
		return
	end

	if not role then
		statusText("Select Player or Admin first", false)
		return
	end

	if usernameBox.Text == "" then
		statusText("Enter your Roblox username", false)
		return
	end

	if not validUsername() then
		statusText("This account is not authorized for Admin mode", false)
		return
	end

	if keyBox.Text == "" then
		statusText("Enter your security key", false)
		return
	end

	if not validKey() then
		statusText("Invalid key", false)
		keyBox.Text = ""
		return
	end

	verifiedUsername = usernameBox.Text

	createSecurityCheck(function()
		if step < 3 then
			setupStep(step + 1)
		else
			finish()
		end

		busy = false
	end)
end)
