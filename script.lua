-- صنع حكومه | كلان EG
-- سكربت تتبع لاعبين كامل بالعربي + وقت HH:MM:SS

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- شاشة رئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrackerGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- زرار إظهار/إخفاء
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0, 200)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "إظهار التتبع"
ToggleButton.Parent = ScreenGui
ToggleButton.Active = true
ToggleButton.Draggable = true

-- القايمة
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 600, 0, 320)
Frame.Position = UDim2.new(0.5, -300, 0.5, -160)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.Visible = false
Frame.Parent = ScreenGui
Frame.Active = true
Frame.Draggable = true

-- بيانات اللاعبين
local playerData = {}

-- فورمات الوقت HH:MM:SS
local function formatTime(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", h, m, s)
end

-- إنشاء مربع لاعب
local function createPlayerBox(index)
	local Box = Instance.new("Frame")
	Box.Size = UDim2.new(0, 280, 0, 70)
	Box.Position = UDim2.new(0, (index % 2) * 300 + 10, 0, math.floor(index / 2) * 80 + 10)
	Box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Box.Parent = Frame

	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0, 60, 0, 60)
	Avatar.Position = UDim2.new(0, 5, 0, 5)
	Avatar.BackgroundTransparency = 1
	Avatar.Parent = Box

	local Username = Instance.new("TextLabel")
	Username.Size = UDim2.new(0, 200, 0, 20)
	Username.Position = UDim2.new(0, 70, 0, 5)
	Username.TextColor3 = Color3.fromRGB(255, 255, 255)
	Username.TextXAlignment = Enum.TextXAlignment.Left
	Username.BackgroundTransparency = 1
	Username.Text = "اليوزر: -"
	Username.Parent = Box

	local DisplayName = Instance.new("TextLabel")
	DisplayName.Size = UDim2.new(0, 200, 0, 20)
	DisplayName.Position = UDim2.new(0, 70, 0, 25)
	DisplayName.TextColor3 = Color3.fromRGB(255, 255, 255)
	DisplayName.TextXAlignment = Enum.TextXAlignment.Left
	DisplayName.BackgroundTransparency = 1
	DisplayName.Text = "اللقب: -"
	DisplayName.Parent = Box

	local JoinLabel = Instance.new("TextLabel")
	JoinLabel.Size = UDim2.new(0, 200, 0, 20)
	JoinLabel.Position = UDim2.new(0, 70, 0, 45)
	JoinLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	JoinLabel.TextXAlignment = Enum.TextXAlignment.Left
	JoinLabel.BackgroundTransparency = 1
	JoinLabel.Text = "دخول: 0"
	JoinLabel.Parent = Box

	local LeaveLabel = Instance.new("TextLabel")
	LeaveLabel.Size = UDim2.new(0, 100, 0, 20)
	LeaveLabel.Position = UDim2.new(0, 170, 0, 45)
	LeaveLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	LeaveLabel.TextXAlignment = Enum.TextXAlignment.Left
	LeaveLabel.BackgroundTransparency = 1
	LeaveLabel.Text = "خروج: 0"
	LeaveLabel.Parent = Box

	local TimeLabel = Instance.new("TextLabel")
	TimeLabel.Size = UDim2.new(0, 100, 0, 20)
	TimeLabel.Position = UDim2.new(0, 70, 0, 65)
	TimeLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
	TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
	TimeLabel.BackgroundTransparency = 1
	TimeLabel.Text = "الوقت: 00:00:00"
	TimeLabel.Parent = Box

	return {
		Box = Box,
		Avatar = Avatar,
		Username = Username,
		DisplayName = DisplayName,
		JoinLabel = JoinLabel,
		LeaveLabel = LeaveLabel,
		TimeLabel = TimeLabel,
		Player = nil
	}
end

-- إنشاء المربعات الأربعة
for i = 0, 3 do
	playerData[i] = createPlayerBox(i)
end

-- زرار الإظهار/الإخفاء
ToggleButton.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
	if Frame.Visible then
		ToggleButton.Text = "إخفاء التتبع"
	else
		ToggleButton.Text = "إظهار التتبع"
	end
end)

-- متابعة اللاعبين
local trackedPlayers = {}

local function trackPlayer(box, player)
	if not player then return end

	-- بيانات اللاعب
	if not trackedPlayers[player.UserId] then
		trackedPlayers[player.UserId] = {
			JoinCount = 0,
			LeaveCount = 0,
			TotalTime = 0,
			SessionStart = nil
		}
	end

	local data = trackedPlayers[player.UserId]

	-- دخول فعلي
	data.JoinCount = data.JoinCount + 1
	data.SessionStart = tick()

	-- تحديث المربع
	box.Player = player
	box.Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=60&height=60&format=png"
	box.Username.Text = "اليوزر: " .. player.Name
	box.DisplayName.Text = "اللقب: " .. player.DisplayName
	box.JoinLabel.Text = "دخول: " .. data.JoinCount
	box.LeaveLabel.Text = "خروج: " .. data.LeaveCount

	-- لما يخرج
	player.AncestryChanged:Connect(function(_, parent)
		if not parent then
			if data.SessionStart then
				data.TotalTime = data.TotalTime + (tick() - data.SessionStart)
				data.SessionStart = nil
			end
			data.LeaveCount = data.LeaveCount + 1
			box.LeaveLabel.Text = "خروج: " .. data.LeaveCount
		end
	end)
end

-- تحديث الوقت
game:GetService("RunService").RenderStepped:Connect(function()
	for _, box in pairs(playerData) do
		if box.Player and trackedPlayers[box.Player.UserId] then
			local data = trackedPlayers[box.Player.UserId]
			local total = data.TotalTime
			if data.SessionStart then
				total = total + (tick() - data.SessionStart)
			end
			box.TimeLabel.Text = "الوقت: " .. formatTime(total)
		end
	end
end)

-- مثال: تتبع أول 4 لاعبين يدخلوا
Players.PlayerAdded:Connect(function(player)
	for _, box in pairs(playerData) do
		if not box.Player then
			trackPlayer(box, player)
			break
		end
	end
end)
