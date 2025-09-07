-- LocalScript داخل StarterGui
-- صنع حكومه | كلان EG - تتبع 4 لاعبين (نسخة نهائية)

-- خدمات
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")

local LocalPlayer   = Players.LocalPlayer
local PlayerGui     = LocalPlayer:WaitForChild("PlayerGui")

-- ============ إعداد الواجهة العامة ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name  = "EG_TrackerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- زر الفتح/الإخفاء (صغير ومتحرك)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleButton"
ToggleBtn.Size = UDim2.new(0, 160, 0, 36)
ToggleBtn.Position = UDim2.new(0, 16, 0.5, -18)
ToggleBtn.Text = "فتح قائمة التتبع"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
ToggleBtn.AutoButtonColor = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = ScreenGui
ToggleBtn.ZIndex = 50
ToggleBtn.BorderSizePixel = 0
ToggleBtn.ClipsDescendants = true
-- لمسة حركة طفيفة دائمة
task.spawn(function()
	while ToggleBtn.Parent do
		TweenService:Create(ToggleBtn, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = ToggleBtn.Position + UDim2.new(0,0,0,2)}):Play()
		task.wait(0.8)
		TweenService:Create(ToggleBtn, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position = ToggleBtn.Position - UDim2.new(0,0,0,2)}):Play()
		task.wait(0.8)
	end
end)

-- اللوحة الرئيسية (خلفية سوداء)
local Panel = Instance.new("Frame")
Panel.Name = "MainPanel"
Panel.Size = UDim2.new(0, 520, 0, 420)
Panel.Position = UDim2.new(0, -540, 0.5, -210) -- مخفية يسار
Panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Panel.BorderSizePixel = 0
Panel.Parent = ScreenGui

-- عنوان/حقوق بالأزرق
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 36)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "صنع حكومه | كلان EG - تتبع 4 لاعبين"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Panel

-- حاوية الخانات (شبكة 2x2)
local Grid = Instance.new("Frame")
Grid.Name = "Grid"
Grid.Size = UDim2.new(1, -20, 1, -60)
Grid.Position = UDim2.new(0, 10, 0, 52)
Grid.BackgroundTransparency = 1
Grid.Parent = Panel

-- تخطيط يدوي 2x2
local cellPos = {
	UDim2.new(0, 0,   0, 0),
	UDim2.new(0.5, 10,0, 0),
	UDim2.new(0, 0,   0.5, 10),
	UDim2.new(0.5, 10,0.5, 10),
}

-- ============ حالة التتبع ============
-- لكل فتحة: تخزين اللاعب، أزمنة التتبع، عدادات الدخول/الخروج
local Slots = {} -- { [i] = {Frame=..., Input=..., Img=..., Name=..., User=..., Time=..., JoinLeave=..., Assigned=nil, SessionStart=0, Joins=0, Leaves=0, LastEvent="—"} }

-- منع تكرار نفس اللاعب في أكثر من خانة
local function isAlreadyAssigned(plr)
	for i=1,4 do
		if Slots[i] and Slots[i].Assigned == plr then
			return true
		end
	end
	return false
end

-- تنسيق وقت hh:mm:ss
local function fmtTime(sec)
	sec = math.max(0, math.floor(sec))
	local h = math.floor(sec/3600)
	local m = math.floor((sec%3600)/60)
	local s = sec%60
	return string.format("%02d:%02d:%02d", h, m, s)
end

-- تعيين لاعب لفتحة
local function assignPlayerToSlot(index, plr)
	local S = Slots[index]
	if not S then return end
	if not plr or isAlreadyAssigned(plr) then return end

	S.Assigned = plr
	S.SessionStart = os.clock()
	S.LastEvent = "دخول"
	S.Joins = (S.Joins or 0) + 1

	-- تحديث الاسم/اليوزر + الصورة
	S.Name.Text = "اللقب: " .. plr.DisplayName
	S.User.Text = "@" .. plr.Name
	local thumb, _ = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	S.Img.Image = thumb

	-- حركة بسيطة عند التعيين
	S.Frame.Visible = true
	TweenService:Create(S.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(10,10,10)}):Play()
	task.delay(0.25, function()
		if S.Frame then
			TweenService:Create(S.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(5,5,5)}):Play()
		end
	end)
end

-- إزالة لاعب من فتحة (تفريغ)
local function clearSlot(index)
	local S = Slots[index]
	if not S then return end
	S.Assigned = nil
	S.SessionStart = 0
	S.Name.Text = "اللقب: —"
	S.User.Text = "@—"
	S.Time.Text = "الوقت: 00:00:00"
	S.JoinLeave.Text = "الدخول: 0 | الخروج: 0 | آخر حدث: —"
	S.Img.Image = ""
end

-- البحث داخل اللاعبين الحاليين
local function findPlayerByQuery(q)
	if not q or #q < 2 then return nil end
	q = string.lower(q)
	-- أولوية: يبدأ بالبحث في DisplayName ثم Username
	local best
	for _,plr in ipairs(Players:GetPlayers()) do
		local dn = string.lower(plr.DisplayName or "")
		local un = string.lower(plr.Name or "")
		if dn:sub(1, #q) == q or un:sub(1, #q) == q or dn:find(q, 1, true) or un:find(q, 1, true) then
			best = plr
			break
		end
	end
	return best
end

-- إنشاء فتحة GUI واحدة
local function createSlot(index)
	local Cell = Instance.new("Frame")
	Cell.Size = UDim2.new(0.5, -10, 0.5, -10)
	Cell.Position = cellPos[index]
	Cell.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
	Cell.BorderSizePixel = 0
	Cell.Parent = Grid

	-- مربع البحث (لكل خانة مستقل)
	local Input = Instance.new("TextBox")
	Input.Size = UDim2.new(1, -10, 0, 30)
	Input.Position = UDim2.new(0, 5, 0, 5)
	Input.PlaceholderText = "اكتب حرفين أو أكتر للبحث عن لاعب..."
	Input.Text = ""
	Input.TextSize = 14
	Input.Font = Enum.Font.Gotham
	Input.TextColor3 = Color3.fromRGB(255, 255, 255)
	Input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Input.ClearTextOnFocus = false
	Input.Parent = Cell

	-- صورة اللاعب
	local Img = Instance.new("ImageLabel")
	Img.Size = UDim2.new(0, 64, 0, 64)
	Img.Position = UDim2.new(0, 5, 0, 45)
	Img.BackgroundTransparency = 1
	Img.Image = ""
	Img.Parent = Cell

	-- الاسم/اللقب
	local Name = Instance.new("TextLabel")
	Name.Size = UDim2.new(1, -80, 0, 28)
	Name.Position = UDim2.new(0, 75, 0, 45)
	Name.BackgroundTransparency = 1
	Name.Text = "اللقب: —"
	Name.TextColor3 = Color3.fromRGB(220, 220, 220)
	Name.Font = Enum.Font.Gotham
	Name.TextSize = 16
	Name.TextXAlignment = Enum.TextXAlignment.Left
	Name.Parent = Cell

	-- اليوزر
	local User = Instance.new("TextLabel")
	User.Size = UDim2.new(1, -80, 0, 22)
	User.Position = UDim2.new(0, 75, 0, 75)
	User.BackgroundTransparency = 1
	User.Text = "@—"
	User.TextColor3 = Color3.fromRGB(150, 150, 150)
	User.Font = Enum.Font.Gotham
	User.TextSize = 14
	User.TextXAlignment = Enum.TextXAlignment.Left
	User.Parent = Cell

	-- الوقت (حقيقي)
	local TimeLbl = Instance.new("TextLabel")
	TimeLbl.Size = UDim2.new(1, -10, 0, 22)
	TimeLbl.Position = UDim2.new(0, 5, 0, 110)
	TimeLbl.BackgroundTransparency = 1
	TimeLbl.Text = "الوقت: 00:00:00"
	TimeLbl.TextColor3 = Color3.fromRGB(0, 200, 120)
	TimeLbl.Font = Enum.Font.GothamBold
	TimeLbl.TextSize = 14
	TimeLbl.TextXAlignment = Enum.TextXAlignment.Left
	TimeLbl.Parent = Cell

	-- سطر دخول/خروج
	local JL = Instance.new("TextLabel")
	JL.Size = UDim2.new(1, -10, 0, 20)
	JL.Position = UDim2.new(0, 5, 0, 136)
	JL.BackgroundTransparency = 1
	JL.Text = "الدخول: 0 | الخروج: 0 | آخر حدث: —"
	JL.TextColor3 = Color3.fromRGB(120, 160, 255)
	JL.Font = Enum.Font.Gotham
	JL.TextSize = 13
	JL.TextXAlignment = Enum.TextXAlignment.Left
	JL.Parent = Cell

	-- خط فاصل خفيف
	local Sep = Instance.new("Frame")
	Sep.Size = UDim2.new(1, -10, 0, 1)
	Sep.Position = UDim2.new(0, 5, 0, 162)
	Sep.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Sep.BorderSizePixel = 0
	Sep.Parent = Cell

	Slots[index] = {
		Frame = Cell,
		Input = Input,
		Img = Img,
		Name = Name,
		User = User,
		Time = TimeLbl,
		JoinLeave = JL,
		Assigned = nil,
		SessionStart = 0,
		Joins = 0,
		Leaves = 0,
		LastEvent = "—",
	}

	-- تفاعل البحث لكل خانة
	Input:GetPropertyChangedSignal("Text"):Connect(function()
		local txt = Input.Text
		if #txt >= 2 then
			local plr = findPlayerByQuery(txt)
			if plr and not isAlreadyAssigned(plr) then
				assignPlayerToSlot(index, plr)
			end
		end
		-- مسح خانة لو فضيت الكتابة
		if #txt == 0 then
			clearSlot(index)
		end
	end)
end

-- إنشاء الـ 4 خانات
for i=1,4 do
	createSlot(i)
end

-- ============ أنيميشن فتح/غلق اللوحة ============
local opened = false
local function togglePanel()
	opened = not opened
	local goal = {}
	if opened then
		goal.Position = UDim2.new(0, 16, 0.5, -210) -- تظهر من اليسار
		ToggleBtn.Text = "إخفاء قائمة التتبع"
	else
		goal.Position = UDim2.new(0, -540, 0.5, -210) -- تختفي يسار
		ToggleBtn.Text = "فتح قائمة التتبع"
	end
	local tween = TweenService:Create(Panel, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
	tween:Play()
	-- نبضة زر لطيفة
	TweenService:Create(ToggleBtn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 170, 0, 40)}):Play()
	task.delay(0.18, function()
		if ToggleBtn then
			TweenService:Create(ToggleBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 160, 0, 36)}):Play()
		end
	end)
end
ToggleBtn.MouseButton1Click:Connect(togglePanel)

-- ============ تحديث الوقت في كل إطار ============
RunService.RenderStepped:Connect(function()
	for i=1,4 do
		local S = Slots[i]
		if S.Assigned and S.SessionStart and S.SessionStart > 0 then
			local elapsed = os.clock() - S.SessionStart
			S.Time.Text = "الوقت: " .. fmtTime(elapsed)
			S.JoinLeave.Text = string.format("الدخول: %d | الخروج: %d | آخر حدث: %s", S.Joins or 0, S.Leaves or 0, S.LastEvent or "—")
		end
	end
end)

-- ============ تتبع دخول/خروج حقيقي ============
Players.PlayerAdded:Connect(function(plr)
	-- لو اللاعب متعيّن في أي خانة (نفس الاسم/اليوزر) نعتبره رجع
	for i=1,4 do
		local S = Slots[i]
		if S.Assigned and S.Assigned.UserId == plr.UserId then
			S.Assigned = plr
			S.SessionStart = os.clock()
			S.LastEvent = "دخول"
			S.Joins = (S.Joins or 0) + 1
			-- تحديث الصورة عند الرجوع
			local thumb, _ = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			S.Img.Image = thumb
			S.Name.Text = "اللقب: " .. plr.DisplayName
			S.User.Text = "@" .. plr.Name
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	for i=1,4 do
		local S = Slots[i]
		if S.Assigned and S.Assigned.UserId == plr.UserId then
			-- سجل خروج (نحتفظ بالاسم والصورة، ونوقف عداد الجلسة)
			S.LastEvent = "خروج"
			S.Leaves = (S.Leaves or 0) + 1
			S.Assigned = nil
			S.SessionStart = 0
			-- ما بنمسحش البيانات النصية فورًا عشان تقدر تشوف آخر حالة
			-- لو تحب نفرّغها بالكامل بعد ثانيتين:
			task.delay(2, function()
				if S and S.Assigned == nil then
					S.Name.Text = "اللقب: —"
					S.User.Text = "@—"
					S.Time.Text = "الوقت: 00:00:00"
					S.Img.Image = ""
				end
			end)
		end
	end
end)

-- (اختياري) فتح القائمة افتراضيًا أول مرة
togglePanel()
