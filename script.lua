-- صنع حكومه | كلان EG
-- Player Tracker GUI (Final Colored Version)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- جداول تخزين البيانات
local JoinCount, LeaveCount, PlayData = {}, {}, {}

-- زرار التوجيل (إظهار/إخفاء)
local ToggleGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ToggleGui.Name = "ToggleTracker"

local ToggleButton = Instance.new("TextButton")
ToggleButton.Text = "إظهار التتبع"
ToggleButton.Size = UDim2.new(0, 120, 0, 35)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- أسود
ToggleButton.TextColor3 = Color3.fromRGB(230, 230, 230) -- أبيض
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Draggable = true
ToggleButton.Active = true
ToggleButton.Parent = ToggleGui

-- الواجهة الرئيسية
local ScreenGui = Instance.new("ScreenGui", ToggleGui)
ScreenGui.Name = "ClanEG_Tracker"
ScreenGui.Enabled = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 320)
MainFrame.Position = UDim2.new(0.5, -300, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true

-- عنوان
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "صنع حكومه | كلان EG - تتبع اللاعبين"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(230, 230, 230)

-- كونتينر للمربعات
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -40)
Container.Position = UDim2.new(0, 10, 0, 35)
Container.BackgroundTransparency = 1

local UIGrid = Instance.new("UIGridLayout", Container)
UIGrid.CellSize = UDim2.new(0, 280, 0, 130)
UIGrid.CellPadding = UDim2.new(0, 10, 0, 10)

-- تهيئة بيانات لاعب
local function InitPlayer(plr)
	if not PlayData[plr.UserId] then
		PlayData[plr.UserId] = {TotalTime = 0, SessionStart = tick(), Online = true}
		JoinCount[plr.UserId] = 1
		LeaveCount[plr.UserId] = 0
	else
		local data = PlayData[plr.UserId]
		data.SessionStart = tick()
		data.Online = true
		JoinCount[plr.UserId] = (JoinCount[plr.UserId] or 0) + 1
	end
end

-- تحديث عند الخروج
local function StopPlayer(plr)
	local data = PlayData[plr.UserId]
	if data and data.Online then
		data.TotalTime = data.TotalTime + (tick() - data.SessionStart)
		data.Online = false
		LeaveCount[plr.UserId] = (LeaveCount[plr.UserId] or 0) + 1
	end
end

-- حساب وقت اللعب الحالي
local function GetPlaytime(plr)
	local data = PlayData[plr.UserId]
	if not data then return 0 end
	if data.Online then
		return data.TotalTime + (tick() - data.SessionStart)
	else
		return data.TotalTime
	end
end

-- تحويل وقت ل دقايق:ثواني
local function FormatTime(seconds)
	local mins = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%d دقيقة %02d ثانية", mins, secs)
end

-- فانكشن تعمل المربع
local function CreatePlayerBox(index)
	local Box = Instance.new("Frame")
	Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Box.BorderSizePixel = 2
	
	local Input = Instance.new("TextBox", Box)
	Input.Size = UDim2.new(1, -110, 0, 25)
	Input.Position = UDim2.new(0, 5, 0, 5)
	Input.PlaceholderText = ""
	Input.TextColor3 = Color3.fromRGB(230, 230, 230)
	Input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Input.ClearTextOnFocus = false
	Input.Font = Enum.Font.SourceSans
	Input.TextSize = 18
	
	local Avatar = Instance.new("ImageLabel", Box)
	Avatar.Size = UDim2.new(0, 100, 0, 100)
	Avatar.Position = UDim2.new(1, -105, 0, 5)
	Avatar.BackgroundTransparency = 1
	
	-- Labels ملونة
	local UsernameLabel = Instance.new("TextLabel", Box)
	UsernameLabel.Size = UDim2.new(1, -110, 0, 20)
	UsernameLabel.Position = UDim2.new(0, 5, 0, 35)
	UsernameLabel.TextColor3 = Color3.fromRGB(230, 230, 230) -- أبيض
	UsernameLabel.BackgroundTransparency = 1
	UsernameLabel.Font = Enum.Font.SourceSans
	UsernameLabel.TextSize = 16
	UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	local DisplayLabel = Instance.new("TextLabel", Box)
	DisplayLabel.Size = UDim2.new(1, -110, 0, 20)
	DisplayLabel.Position = UDim2.new(0, 5, 0, 55)
	DisplayLabel.TextColor3 = Color3.fromRGB(230, 230, 230) -- أبيض
	DisplayLabel.BackgroundTransparency = 1
	DisplayLabel.Font = Enum.Font.SourceSans
	DisplayLabel.TextSize = 16
	DisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	local PlaytimeLabel = Instance.new("TextLabel", Box)
	PlaytimeLabel.Size = UDim2.new(1, -110, 0, 20)
	PlaytimeLabel.Position = UDim2.new(0, 5, 0, 75)
	PlaytimeLabel.TextColor3 = Color3.fromRGB(230, 230, 230) -- أبيض
	PlaytimeLabel.BackgroundTransparency = 1
	PlaytimeLabel.Font = Enum.Font.SourceSans
	PlaytimeLabel.TextSize = 16
	PlaytimeLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	local JoinLabel = Instance.new("TextLabel", Box)
	JoinLabel.Size = UDim2.new(1, -110, 0, 20)
	JoinLabel.Position = UDim2.new(0, 5, 0, 95)
	JoinLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- أخضر
	JoinLabel.BackgroundTransparency = 1
	JoinLabel.Font = Enum.Font.SourceSans
	JoinLabel.TextSize = 16
	JoinLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	local LeaveLabel = Instance.new("TextLabel", Box)
	LeaveLabel.Size = UDim2.new(1, -110, 0, 20)
	LeaveLabel.Position = UDim2.new(0, 5, 0, 115)
	LeaveLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- أحمر
	LeaveLabel.BackgroundTransparency = 1
	LeaveLabel.Font = Enum.Font.SourceSans
	LeaveLabel.TextSize = 16
	LeaveLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	-- تحديث المربع
	local function UpdateBox()
		local txt = Input.Text:lower()
		if #txt >= 2 then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.Name:lower():sub(1, #txt) == txt or plr.DisplayName:lower():sub(1, #txt) == txt then
					local userId = plr.UserId
					local thumb = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
					Avatar.Image = thumb
					
					UsernameLabel.Text = "Username: " .. plr.Name
					DisplayLabel.Text = "Display: " .. plr.DisplayName
					PlaytimeLabel.Text = "Playtime: " .. FormatTime(GetPlaytime(plr))
					JoinLabel.Text = "دخول: " .. tostring(JoinCount[plr.UserId] or 0)
					LeaveLabel.Text = "خروج: " .. tostring(LeaveCount[plr.UserId] or 0)
					return
				end
			end
		end
		Avatar.Image = ""
		UsernameLabel.Text = ""
		DisplayLabel.Text = ""
		PlaytimeLabel.Text = ""
		JoinLabel.Text = ""
		LeaveLabel.Text = ""
	end
	
	Input:GetPropertyChangedSignal("Text"):Connect(UpdateBox)
	RunService.Heartbeat:Connect(UpdateBox)
	
	return Box
end

-- نعمل ٤ مربعات
for i = 1,4 do
	CreatePlayerBox(i).Parent = Container
end

-- تتبع الدخول والخروج
Players.PlayerAdded:Connect(function(plr)
	InitPlayer(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
	StopPlayer(plr)
end)

-- تهيئة الموجودين من الأول
for _, plr in ipairs(Players:GetPlayers()) do
	InitPlayer(plr)
end

-- زرار إظهار/إخفاء
ToggleButton.MouseButton1Click:Connect(function()
	ScreenGui.Enabled = not ScreenGui.Enabled
	if ScreenGui.Enabled then
		ToggleButton.Text = "إخفاء التتبع"
	else
		ToggleButton.Text = "إظهار التتبع"
	end
end)
