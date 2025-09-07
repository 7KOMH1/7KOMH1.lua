-- LocalScript في StarterGui
-- صنع حكومه | كلان EG - تتبع 4 لاعبين --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrackingGUI"
screenGui.Parent = playerGui

-- زر فتح/إغلاق
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 140, 0, 35)
toggleButton.Position = UDim2.new(0, 20, 0.5, -20)
toggleButton.Text = "فتح قائمة التتبع"
toggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggleButton.TextColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = screenGui
toggleButton.ZIndex = 10

-- الإطار الرئيسي
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0, -360, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- الحقوق
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 30)
credits.BackgroundTransparency = 1
credits.Text = "صنع حكومه | كلان EG - تتبع 4 لاعبين"
credits.TextColor3 = Color3.fromRGB(0, 170, 255)
credits.Font = Enum.Font.GothamBold
credits.TextSize = 14
credits.Parent = mainFrame

-- دوال مساعده
local function formatTime()
	local t = os.date("*t")
	return string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
end

-- إعداد 4 خانات
local slots = {}
for i = 1, 4 do
	local slot = Instance.new("Frame")
	slot.Size = UDim2.new(1, -20, 0, 100)
	slot.Position = UDim2.new(0, 10, 0, 40 + (i - 1) * 110)
	slot.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	slot.Parent = mainFrame

	local searchBox = Instance.new("TextBox")
	searchBox.Size = UDim2.new(0.6, -10, 0, 30)
	searchBox.Position = UDim2.new(0, 5, 0, 5)
	searchBox.PlaceholderText = "اكتب اسم اللاعب..."
	searchBox.Text = ""
	searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 14
	searchBox.Parent = slot

	local thumb = Instance.new("ImageLabel")
	thumb.Size = UDim2.new(0, 60, 0, 60)
	thumb.Position = UDim2.new(1, -70, 0, 5)
	thumb.BackgroundTransparency = 1
	thumb.Image = ""
	thumb.Parent = slot

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.6, -10, 0, 25)
	nameLabel.Position = UDim2.new(0, 5, 0, 40)
	nameLabel.Text = "الاسم: ..."
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextSize = 14
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = slot

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, -10, 0, 20)
	statusLabel.Position = UDim2.new(0, 5, 0, 70)
	statusLabel.Text = "آخر تحديث: ..."
	statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 12
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.BackgroundTransparency = 1
	statusLabel.Parent = slot

	slots[i] = {
		searchBox = searchBox,
		thumb = thumb,
		nameLabel = nameLabel,
		statusLabel = statusLabel,
		player = nil
	}
end

-- تحديث خانة
local function updateSlot(slot, plr)
	if not plr then
		slot.nameLabel.Text = "الاسم: ..."
		slot.thumb.Image = ""
		slot.statusLabel.Text = "آخر تحديث: ..."
		slot.player = nil
		return
	end

	local thumbUrl, _ = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	slot.thumb.Image = thumbUrl
	slot.nameLabel.Text = "الاسم: " .. plr.DisplayName .. "(@" .. plr.Name .. ")"
	slot.statusLabel.Text = "آخر تحديث: " .. formatTime()
	slot.player = plr
end

-- البحث
for _, slot in ipairs(slots) do
	slot.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = slot.searchBox.Text
		if #text >= 2 then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and (string.find(string.lower(plr.Name), string.lower(text)) or string.find(string.lower(plr.DisplayName), string.lower(text))) then
					updateSlot(slot, plr)
					return
				end
			end
		else
			updateSlot(slot, nil)
		end
	end)
end

-- تتبع الدخول والخروج
Players.PlayerAdded:Connect(function(plr)
	for _, slot in ipairs(slots) do
		if slot.player == plr then
			updateSlot(slot, plr)
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	for _, slot in ipairs(slots) do
		if slot.player == plr then
			slot.statusLabel.Text = "خرج في: " .. formatTime()
		end
	end
end)

-- زر فتح/إغلاق
local opened = false
toggleButton.MouseButton1Click:Connect(function()
	opened = not opened
	local goal = {}
	if opened then
		goal.Position = UDim2.new(0, 20, 0.5, -250)
	else
		goal.Position = UDim2.new(0, -360, 0.5, -250)
	end
	TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end)
