-- الحقوق: GS4 | 🍷 العم حكومه
-- نسخة نهائية: قوية / سريعة / مرتبة / 4 تتبع / بحث جزئي (>= حرفين)

--===== Services =====--
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local SoundService   = game:GetService("SoundService")
local RunService     = game:GetService("RunService")

--===== Sounds =====--
local sndJoin = Instance.new("Sound", SoundService)
sndJoin.SoundId = "rbxassetid://6026984224"
sndJoin.Volume   = 0.35

local sndLeave = Instance.new("Sound", SoundService)
sndLeave.SoundId = "rbxassetid://6026984224"
sndLeave.PlaybackSpeed = 0.85
sndLeave.Volume   = 0.35

--===== Helpers =====--
local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$","")) end
local function tolow(s) return string.lower(s or "") end
local function starts(str, sub) return string.sub(str, 1, #sub) == sub end

-- scoring: يبدأ بالحروف > يحتويها
local function matchScore(name, query)
	if #query < 2 then return -1 end
	local ln = tolow(name)
	local q  = tolow(query)
	if starts(ln, q) then return 2 end
	if string.find(ln, q, 1, true) then return 1 end
	return -1
end

local function safeThumb(userId)
	local ok, img = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if ok and img then return img end
	return ("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png"):format(userId)
end

-- إشعار صغير
local function notify(guiParent, msg, color)
	local n = Instance.new("TextLabel")
	n.Parent = guiParent
	n.Size = UDim2.new(0, 260, 0, 36)
	n.Position = UDim2.new(0.5, -130, 0.06, 0)
	n.BackgroundColor3 = Color3.fromRGB(25,25,25)
	n.TextColor3 = color or Color3.new(1,1,1)
	n.Text = msg
	n.Font = Enum.Font.SourceSansBold
	n.TextSize = 20
	n.BorderSizePixel = 0
	n.BackgroundTransparency = 0.2
	n.ZIndex = 50
	TweenService:Create(n, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
	task.wait(1.5)
	TweenService:Create(n, TweenInfo.new(0.25), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
	task.wait(0.25)
	n:Destroy()
end

--===== GUI =====--
local gui = Instance.new("ScreenGui")
gui.Name = "GS4_Tracker_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui")

-- زر فتح/قفل صغير ومتحرّك
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 34, 0, 34)
toggleBtn.Position = UDim2.new(0, 16, 0.22, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
toggleBtn.Text = "≡"
toggleBtn.TextScaled = true
toggleBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = true
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.ZIndex = 100

-- اللوحة (متوسطة الحجم)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 520, 0, 330)
main.Position = UDim2.new(0.5, -260, 0.26, 0)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.BorderSizePixel = 0
main.Visible = true
main.Active = true
main.Draggable = true

-- عنوان
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(0,170,255)
title.Text = "GS4 | 🍷 العم حكومه"

local sep = Instance.new("Frame", main)
sep.Size = UDim2.new(1, -20, 0, 1)
sep.Position = UDim2.new(0, 10, 0, 42)
sep.BackgroundColor3 = Color3.fromRGB(35,35,35)
sep.BorderSizePixel = 0

--===== Trackers (4) =====--
local Trackers = {}
local MAX = 4

local function makeCard(idx)
	local card = Instance.new("Frame", main)
	card.Size = UDim2.new(0.48, 0, 0, 145)
	card.BackgroundColor3 = Color3.fromRGB(22,22,22)
	card.BorderSizePixel = 0
	card.BackgroundTransparency = 0.03

	-- تموضع 2×2
	local col = ((idx-1) % 2)
	local row = math.floor((idx-1) / 2)
	card.Position = UDim2.new(0.02 + col * 0.50, 0, 0.17 + row * 0.40, 0)

	-- مربع كتابة فاضي (بدون Placeholder)
	local box = Instance.new("TextBox", card)
	box.Size = UDim2.new(1, -10, 0, 26)
	box.Position = UDim2.new(0, 5, 0, 6)
	box.BackgroundColor3 = Color3.fromRGB(40,40,40)
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.PlaceholderText = "" -- فاضي
	box.Text = ""
	box.TextColor3 = Color3.new(1,1,1)
	box.TextSize = 18
	box.Font = Enum.Font.SourceSans

	-- صورة بروفايل
	local pfp = Instance.new("ImageLabel", card)
	pfp.BackgroundTransparency = 1
	pfp.Size = UDim2.new(0, 56, 0, 56)
	pfp.Position = UDim2.new(0, 6, 0, 42)
	pfp.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"

	-- Username
	local nameL = Instance.new("TextLabel", card)
	nameL.BackgroundTransparency = 1
	nameL.Size = UDim2.new(1, -74, 0, 24)
	nameL.Position = UDim2.new(0, 70, 0, 44)
	nameL.Font = Enum.Font.SourceSansBold
	nameL.TextSize = 18
	nameL.TextXAlignment = Enum.TextXAlignment.Left
	nameL.TextColor3 = Color3.fromRGB(0,145,255)
	nameL.Text = "Username: -"

	-- DisplayName
	local dispL = Instance.new("TextLabel", card)
	dispL.BackgroundTransparency = 1
	dispL.Size = UDim2.new(1, -74, 0, 22)
	dispL.Position = UDim2.new(0, 70, 0, 70)
	dispL.Font = Enum.Font.SourceSans
	dispL.TextSize = 17
	dispL.TextXAlignment = Enum.TextXAlignment.Left
	dispL.TextColor3 = Color3.fromRGB(0,200,200)
	dispL.Text = "Display: -"

	-- عدادات
	local joinL = Instance.new("TextLabel", card)
	joinL.BackgroundTransparency = 1
	joinL.Size = UDim2.new(0.5, -10, 0, 22)
	joinL.Position = UDim2.new(0, 6, 0, 106)
	joinL.Font = Enum.Font.SourceSansBold
	joinL.TextSize = 16
	joinL.TextXAlignment = Enum.TextXAlignment.Left
	joinL.TextColor3 = Color3.fromRGB(0,255,0)
	joinL.Text = "✅ دخول: 0"

	local leaveL = Instance.new("TextLabel", card)
	leaveL.BackgroundTransparency = 1
	leaveL.Size = UDim2.new(0.5, -10, 0, 22)
	leaveL.Position = UDim2.new(0.5, 0, 0, 106)
	leaveL.Font = Enum.Font.SourceSansBold
	leaveL.TextSize = 16
	leaveL.TextXAlignment = Enum.TextXAlignment.Left
	leaveL.TextColor3 = Color3.fromRGB(255,0,0)
	leaveL.Text = "❌ خروج: 0"

	-- حالة وبيانات
	return {
		card = card,
		box = box,
		pfp = pfp,
		nameL = nameL,
		dispL = dispL,
		joinL = joinL,
		leaveL = leaveL,
		targetUserId = nil,
		targetOnline = false,
		joins = 0,
		leaves = 0
	}
end

for i=1,MAX do
	Trackers[i] = makeCard(i)
end

--===== بحث و اختيار لاعب (جزئي من أي مكان) =====--
local function selectPlayerForTracker(tracker, query)
	query = trim(query or "")
	if query == "" then
		-- مسح
		tracker.targetUserId = nil
		tracker.targetOnline = false
		tracker.joins, tracker.leaves = 0,0
		tracker.pfp.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		tracker.nameL.Text = "Username: -"
		tracker.dispL.Text = "Display: -"
		tracker.joinL.Text = "✅ دخول: 0"
		tracker.leaveL.Text = "❌ خروج: 0"
		return
	end

	local bestPlr, bestScore = nil, -1
	local q = tolow(query)
	for _,plr in ipairs(Players:GetPlayers()) do
		local s1 = matchScore(plr.Name, q)
		local s2 = matchScore(plr.DisplayName, q)
		local sc = math.max(s1, s2)
		if sc > bestScore then
			bestScore = sc
			bestPlr = plr
		end
	end

	if bestPlr and bestScore > 0 then
		tracker.targetUserId = bestPlr.UserId
		tracker.targetOnline = true
		tracker.joins, tracker.leaves = 0, 0 -- نبدأ العد من وقت التتبع
		tracker.nameL.Text = "Username: " .. bestPlr.Name
		tracker.dispL.Text = "Display: " .. bestPlr.DisplayName
		tracker.pfp.Image = safeThumb(bestPlr.UserId)
	else
		notify(gui, "لم يتم العثور على لاعب", Color3.fromRGB(255,80,80))
	end
end

-- Debounce بسيط للبحث (أسرع/أنعم)
for _,t in ipairs(Trackers) do
	local lastInputTick = 0
	t.box:GetPropertyChangedSignal("Text"):Connect(function()
		lastInputTick = tick()
		local thisTick = lastInputTick
		task.delay(0.15, function()
			-- انتظر 150ms بدون تغيير عشان ما نعمل بحث كل حرف
			if thisTick == lastInputTick then
				local txt = t.box.Text
				if #trim(txt) >= 2 then
					selectPlayerForTracker(t, txt)
				end
			end
		end)
	end)
	-- مسح تلقائي لو خلى الخانة فاضية
	t.box.FocusLost:Connect(function()
		if trim(t.box.Text) == "" then
			selectPlayerForTracker(t, "")
		end
	end)
end

--===== تتبع حي باستخدام UserId =====--
local function onJoin(plr)
	for _,t in ipairs(Trackers) do
		if t.targetUserId and plr.UserId == t.targetUserId then
			t.targetOnline = true
			t.joins += 1
			t.joinL.Text = ("✅ دخول: %d"):format(t.joins)
			-- تحديث الاسم/اللقب والصورة عند رجوعه
			t.nameL.Text = "Username: " .. plr.Name
			t.dispL.Text = "Display: " .. plr.DisplayName
			t.pfp.Image = safeThumb(plr.UserId)
			sndJoin:Play()
			notify(gui, "✅ "..plr.DisplayName.." دخل", Color3.fromRGB(0,255,0))
		end
	end
end

local function onLeave(plr)
	for _,t in ipairs(Trackers) do
		if t.targetUserId and plr.UserId == t.targetUserId then
			t.targetOnline = false
			t.leaves += 1
			t.leaveL.Text = ("❌ خروج: %d"):format(t.leaves)
			sndLeave:Play()
			notify(gui, "❌ "..plr.DisplayName.." خرج", Color3.fromRGB(255,0,0))
		end
	end
end

Players.PlayerAdded:Connect(onJoin)
Players.PlayerRemoving:Connect(onLeave)

--===== زر الفتح/القفل =====--
toggleBtn.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)

--===== ضبط تلقائي لحجم الواجهة على الشاشات الصغيرة =====--
local function autoscale()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local vp = cam.ViewportSize
	if vp.X < 900 then
		main.Size = UDim2.new(0, 500, 0, 310)
		title.TextSize = 20
	end
end
autoscale()
RunService:GetPropertyChangedSignal("RenderStepped"):Connect(function() end) -- للحفاظ على استجابة الواجهة
