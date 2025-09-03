-- V11 Ultra Grid Final
-- 「👑GS4」العم حكومه🍷

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GS4_V11_Grid"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 760, 0, 420) -- واجهة طويلة وعريضة
main.Position = UDim2.new(0.5, -380, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
main.Active = true
main.Draggable = true
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -20, 0, 44)
header.Position = UDim2.new(0, 10, 0, 8)
header.BackgroundTransparency = 1
header.Font = Enum.Font.GothamBold
header.TextSize = 20
header.TextXAlignment = Enum.TextXAlignment.Left
header.TextColor3 = Color3.fromRGB(0, 190, 255)
header.Text = "「👑GS4」العم حكومه🍷 — Player Tracker V11 (Grid x4)"
header.Parent = main

local gridHolder = Instance.new("Frame")
gridHolder.Size = UDim2.new(1, -20, 1, -64)
gridHolder.Position = UDim2.new(0, 10, 0, 56)
gridHolder.BackgroundTransparency = 1
gridHolder.Parent = main

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, 360, 0, 170)  -- 2×2
grid.CellPadding = UDim2.new(0, 10, 0, 10)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = gridHolder

----------------------------------------------------------------
-- بيانات التتبع
----------------------------------------------------------------
local MAX_SLOTS = 4
local slots = {}
local userIdToSlot = {}   -- userId -> slotIndex

local function fmtTime(t) return os.date("%H:%M:%S", t) end

local function setAvatar(imgLabel, userId)
	local ok, url = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if ok and url then imgLabel.Image = url end
end

local function secToHMS(sec)
	local h = math.floor(sec/3600)
	local m = math.floor((sec%3600)/60)
	local s = sec%60
	return string.format("%02d:%02d:%02d", h, m, s)
end

----------------------------------------------------------------
-- إنشاء خانة
----------------------------------------------------------------
local function createSlot(index)
	local card = Instance.new("Frame")
	card.Name = "Slot"..index
	card.BackgroundColor3 = Color3.fromRGB(18,18,22)
	card.BorderSizePixel = 0
	card.Parent = gridHolder
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(0, 64, 0, 64)
	avatar.Position = UDim2.new(0, 12, 0, 12)
	avatar.BackgroundTransparency = 1
	avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	avatar.Parent = card

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -88, 0, 26)
	title.Position = UDim2.new(0, 84, 0, 10)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(0, 200, 255)
	title.Text = "غير مُخصص"
	title.Parent = card

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -88, 0, 22)
	sub.Position = UDim2.new(0, 84, 0, 38)
	sub.BackgroundTransparency = 1
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 16
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.TextColor3 = Color3.fromRGB(230, 230, 235)
	sub.Text = "—"
	sub.Parent = card

	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, -24, 0, 1)
	line.Position = UDim2.new(0, 12, 0, 80)
	line.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
	line.BorderSizePixel = 0
	line.Parent = card

	local info1 = Instance.new("TextLabel")
	info1.Size = UDim2.new(1, -24, 0, 20)
	info1.Position = UDim2.new(0, 12, 0, 92)
	info1.BackgroundTransparency = 1
	info1.Font = Enum.Font.Gotham
	info1.TextSize = 15
	info1.TextXAlignment = Enum.TextXAlignment.Left
	info1.TextColor3 = Color3.fromRGB(180, 200, 255)
	info1.Text = "🕒 دخل: — | ⏳ تتبع من: —"
	info1.Parent = card

	local info2 = Instance.new("TextLabel")
	info2.Size = UDim2.new(1, -24, 0, 20)
	info2.Position = UDim2.new(0, 12, 0, 116)
	info2.BackgroundTransparency = 1
	info2.Font = Enum.Font.Gotham
	info2.TextSize = 15
	info2.TextXAlignment = Enum.TextXAlignment.Left
	info2.TextColor3 = Color3.fromRGB(200, 255, 225)
	info2.Text = "⏲️ المدة: 00:00:00 | الحالة: —"
	info2.Parent = card

	local info3 = Instance.new("TextLabel")
	info3.Size = UDim2.new(1, -24, 0, 20)
	info3.Position = UDim2.new(0, 12, 0, 140)
	info3.BackgroundTransparency = 1
	info3.Font = Enum.Font.Gotham
	info3.TextSize = 15
	info3.TextXAlignment = Enum.TextXAlignment.Left
	info3.TextColor3 = Color3.fromRGB(120, 255, 140)
	info3.Text = "✅ دخول: 0 | ❌ خروج: 0 | 🚪 آخر خروج: —"
	info3.Parent = card

	slots[index] = {
		card = card,
		avatar = avatar,
		title = title,         -- اسم العرض + اليوزر
		sub = sub,             -- اللقب المزخرف
		info1 = info1,         -- (دخل | تتبع من)
		info2 = info2,         -- (المدة | الحالة)
		info3 = info3,         -- (عداد الدخول/الخروج وآخر خروج)
		userId = nil,
		username = "",
		displayName = "",
		joinTime = nil,
		trackStart = nil,
		online = false,
		joins = 0,
		leaves = 0,
		lastLeave = nil,
	}
end

for i = 1, MAX_SLOTS do createSlot(i) end

----------------------------------------------------------------
-- إسناد لاعب إلى خانة
----------------------------------------------------------------
local function findFreeSlot()
	for i = 1, MAX_SLOTS do
		if not slots[i].userId then
			return i
		end
	end
	return nil
end

local function updateSlotUI(s)
	if not s.userId then
		s.title.Text = "غير مُخصص"
		s.sub.Text   = "—"
		s.info1.Text = "🕒 دخل: — | ⏳ تتبع من: —"
		s.info2.Text = "⏲️ المدة: 00:00:00 | الحالة: —"
		s.info3.Text = "✅ دخول: 0 | ❌ خروج: 0 | 🚪 آخر خروج: —"
		s.avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		return
	end

	local nameLine = string.format("%s (%s)", s.displayName ~= "" and s.displayName or s.username, s.username)
	s.title.Text = nameLine
	s.sub.Text   = "🏷️ 「👑GS4」العم حكومه🍷"

	local joinTxt = s.joinTime and fmtTime(s.joinTime) or "—"
	local trackTxt = s.trackStart and fmtTime(s.trackStart) or "—"
	s.info1.Text = "🕒 دخل: " .. joinTxt .. " | ⏳ تتبع من: " .. trackTxt

	local now = os.time()
	local dur = (s.trackStart and (now - s.trackStart)) or 0
	local status = s.online and "أونلاين" or "أوفلاين"
	s.info2.Text = "⏲️ المدة: " .. secToHMS(dur) .. " | الحالة: " .. status

	local lastLeaveTxt = s.lastLeave and fmtTime(s.lastLeave) or "—"
	s.info3.Text = string.format("✅ دخول: %d | ❌ خروج: %d | 🚪 آخر خروج: %s", s.joins, s.leaves, lastLeaveTxt)
end

local function attachPlayerToSlot(plr, slotIndex)
	local s = slots[slotIndex]
	s.userId = plr.UserId
	s.username = plr.Name
	s.displayName = plr.DisplayName or plr.Name
	s.joinTime = os.time()
	s.trackStart = os.time()
	s.online = true
	s.joins = s.joins + 1

	userIdToSlot[plr.UserId] = slotIndex
	setAvatar(s.avatar, plr.UserId)
	updateSlotUI(s)
end

----------------------------------------------------------------
-- أحداث الدخول/الخروج
----------------------------------------------------------------
local function onPlayerAdded(plr)
	-- لو له خانة قديمة (كان خارج ورجع)
	local oldSlotIndex = userIdToSlot[plr.UserId]
	if oldSlotIndex then
		local s = slots[oldSlotIndex]
		s.online = true
		s.joinTime = os.time()
		s.joins = s.joins + 1
		setAvatar(s.avatar, plr.UserId)
		updateSlotUI(s)
		return
	end

	-- لو مفيش خانة، جرّب تخصّص له خانة فاضية
	local idx = findFreeSlot()
	if idx then
		attachPlayerToSlot(plr, idx)
	end
end

local function onPlayerRemoving(plr)
	local idx = userIdToSlot[plr.UserId]
	if idx then
		local s = slots[idx]
		s.online = false
		s.leaves = s.leaves + 1
		s.lastLeave = os.time()
		updateSlotUI(s)
		-- مـنـسـيـبـش الخانة فاضية؛ نحتفظ بالسجل والاسم والصورة (زي ما طلبت)
	end
end

----------------------------------------------------------------
-- تشغيل أولي على الموجودين حالًا
----------------------------------------------------------------
for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		onPlayerAdded(plr)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

----------------------------------------------------------------
-- تحديث كل ثانية لعرض مدة التتبع في الـ UI
----------------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(1)
		for i = 1, MAX_SLOTS do
			local s = slots[i]
			if s.userId then
				updateSlotUI(s)
			end
		end
	end
end)
