-- LocalScript داخل StarterGui
-- صنع حكومه | كلان EG - تتبع 4 لاعبين (نسخة مصحّحة: سحب، ترتيب Join/Leave تحت بعض، تحسين واجهة)

local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")
local UserInput     = game:GetService("UserInputService")

local LocalPlayer   = Players.LocalPlayer
local PlayerGui     = LocalPlayer:WaitForChild("PlayerGui")

-- تنسيق وقت hh:mm:ss
local function fmtTime(sec)
	sec = math.max(0, math.floor(sec or 0))
	local h = math.floor(sec/3600)
	local m = math.floor((sec%3600)/60)
	local s = sec%60
	return string.format("%02d:%02d:%02d", h, m, s)
end

-- ============ بناء الواجهة ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name  = "EG_TrackerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- زر فتح/إخفاء (قابل للسحب)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleButton"
ToggleBtn.Size = UDim2.new(0, 160, 0, 36)
ToggleBtn.Position = UDim2.new(0, 16, 0.5, -18)
ToggleBtn.AnchorPoint = Vector2.new(0,0.5)
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
ToggleBtn.Active = true

-- اللوحة الرئيسية (خلفية سوداء)
local Panel = Instance.new("Frame")
Panel.Name = "MainPanel"
Panel.Size = UDim2.new(0, 520, 0, 420)
Panel.Position = UDim2.new(0, -540, 0.5, -210) -- افتراضاً مخفية يسار
Panel.AnchorPoint = Vector2.new(0,0.5)
Panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Panel.BorderSizePixel = 0
Panel.Parent = ScreenGui
Panel.Active = true

-- عنوان/حقوق بالأزرق
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 36)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "صنع حكومه | كلان EG - تتبع 4 لاعبين"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

-- حاوية الخانات (شبكة 2x2)
local Grid = Instance.new("Frame")
Grid.Name = "Grid"
Grid.Size = UDim2.new(1, -20, 1, -60)
Grid.Position = UDim2.new(0, 10, 0, 52)
Grid.BackgroundTransparency = 1
Grid.Parent = Panel

local cellPos = {
	UDim2.new(0, 0,   0, 0),
	UDim2.new(0.5, 10,0, 0),
	UDim2.new(0, 0,   0.5, 10),
	UDim2.new(0.5, 10,0.5, 10),
}

-- ============ حالة التتبع ============
local Slots = {} -- كل فتحة تخزن مراجع الواجهة والحالة

local function isAlreadyAssigned(plr)
	for i=1,4 do
		local S = Slots[i]
		if S and S.Assigned and S.Assigned.UserId == plr.UserId then
			return true
		end
	end
	return false
end

-- تعيين لاعب لفتحة
local function assignPlayerToSlot(index, plr)
	if not plr then return end
	local S = Slots[index]
	if not S then return end
	-- منع التعيين لو اللاعب بالفعل في مكان تاني
	if isAlreadyAssigned(plr) and (not S.Assigned or S.Assigned.UserId ~= plr.UserId) then
		return
	end

	-- لو نفس اللاعب متعيّن، ما نعملش حاجة
	if S.Assigned and S.Assigned.UserId == plr.UserId then
		-- تحديث حالة لو لزم
		return
	end

	S.Assigned = plr
	S.SessionStart = os.clock()
	S.Joins = (S.Joins or 0) + 1
	S.LastEvent = "دخول"
	-- حدث الإنفاذ واجهة
	S.Name.Text = "اللقب: " .. (plr.DisplayName or "—")
	S.User.Text = "@" .. (plr.Name or "—")
	local thumb = ""
	pcall(function()
		thumb = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	S.Img.Image = thumb or ""
	S.JoinLabel.Text = "الدخول: " .. tostring(S.Joins or 0)
	S.LeaveLabel.Text = "الخروج: " .. tostring(S.Leaves or 0)
	S.LastEventLabel.Text = "آخر حدث: " .. (S.LastEvent or "—")
	S.Frame.Visible = true

	-- لمسة أنيميشن
	pcall(function()
		TweenService:Create(S.Frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(10,10,10)}):Play()
		task.delay(0.15, function()
			if S and S.Frame then
				TweenService:Create(S.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(5,5,5)}):Play()
			end
		end)
	end)
end

-- تفريغ فتحة
local function clearSlot(index)
	local S = Slots[index]
	if not S then return end
	S.Assigned = nil
	S.SessionStart = 0
	S.Name.Text = "اللقب: —"
	S.User.Text = "@—"
	S.Time.Text = "الوقت: 00:00:00"
	S.JoinLabel.Text = "الدخول: 0"
	S.LeaveLabel.Text = "الخروج: 0"
	S.LastEventLabel.Text = "آخر حدث: —"
	S.Img.Image = ""
	S.Joins = 0
	S.Leaves = 0
	S.LastEvent = "—"
end

-- البحث داخل اللاعبين الحاليين (اول حرفين او اكتر)
local function findPlayerByQuery(q)
	if not q or #q < 2 then return nil end
	q = string.lower(q)
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		local dn = string.lower(plr.DisplayName or "")
		local un = string.lower(plr.Name or "")
		-- اولوية للبدايات
		if dn:sub(1, #q) == q or un:sub(1, #q) == q or dn:find(q, 1, true) or un:find(q, 1, true) then
			return plr
		end
	end
	return nil
end

-- إنشاء فتحة GUI واحدة (مع TextBox مستقل)
local function createSlot(index)
	local Cell = Instance.new("Frame")
	Cell.Size = UDim2.new(0.5, -10, 0.5, -10)
	Cell.Position = cellPos[index]
	Cell.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
	Cell.BorderSizePixel = 0
	Cell.Parent = Grid
	Cell.Visible = true

	-- مربع البحث لكل خانة
	local Input = Instance.new("TextBox")
	Input.Size = UDim2.new(1, -10, 0, 30)
	Input.Position = UDim2.new(0, 5, 0, 5)
	Input.PlaceholderText = "اكتب حرفين أو أكتر للبحث..."
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

	-- فاصل خفيف
	local Sep = Instance.new("Frame")
	Sep.Size = UDim2.new(1, -10, 0, 1)
	Sep.Position = UDim2.new(0, 5, 0, 136)
	Sep.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Sep.BorderSizePixel = 0
	Sep.Parent = Cell

	-- الآن: عرض الدخول / الخروج / آخر حدث كل واحد تحت التاني
	local JoinLabel = Instance.new("TextLabel")
	JoinLabel.Size = UDim2.new(1, -10, 0, 18)
	JoinLabel.Position = UDim2.new(0, 5, 0, 142)
	JoinLabel.BackgroundTransparency = 1
	JoinLabel.Text = "الدخول: 0"
	JoinLabel.TextColor3 = Color3.fromRGB(120, 160, 255)
	JoinLabel.Font = Enum.Font.Gotham
	JoinLabel.TextSize = 13
	JoinLabel.TextXAlignment = Enum.TextXAlignment.Left
	JoinLabel.Parent = Cell

	local LeaveLabel = Instance.new("TextLabel")
	LeaveLabel.Size = UDim2.new(1, -10, 0, 18)
	LeaveLabel.Position = UDim2.new(0, 5, 0, 160)
	LeaveLabel.BackgroundTransparency = 1
	LeaveLabel.Text = "الخروج: 0"
	LeaveLabel.TextColor3 = Color3.fromRGB(120, 160, 255)
	LeaveLabel.Font = Enum.Font.Gotham
	LeaveLabel.TextSize = 13
	LeaveLabel.TextXAlignment = Enum.TextXAlignment.Left
	LeaveLabel.Parent = Cell

	local LastEventLabel = Instance.new("TextLabel")
	LastEventLabel.Size = UDim2.new(1, -10, 0, 18)
	LastEventLabel.Position = UDim2.new(0, 5, 0, 178)
	LastEventLabel.BackgroundTransparency = 1
	LastEventLabel.Text = "آخر حدث: —"
	LastEventLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	LastEventLabel.Font = Enum.Font.Gotham
	LastEventLabel.TextSize = 13
	LastEventLabel.TextXAlignment = Enum.TextXAlignment.Left
	LastEventLabel.Parent = Cell

	Slots[index] = {
		Frame = Cell,
		Input = Input,
		Img = Img,
		Name = Name,
		User = User,
		Time = TimeLbl,
		JoinLabel = JoinLabel,
		LeaveLabel = LeaveLabel,
		LastEventLabel = LastEventLabel,
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
			if plr then
				assignPlayerToSlot(index, plr)
			end
		elseif #txt == 0 then
			-- لو فضيت النص: مسح الخانة
			clearSlot(index)
		end
	end)
end

-- انشاء 4 خانات
for i=1,4 do createSlot(i) end

-- ============ سحب (Drag) للـ ToggleBtn و Panel ============
local lastShownPanelPos = Panel.Position

local function makeDraggable(gui, onDragEnd)
	gui.Active = true
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					dragInput = nil
					if onDragEnd then pcall(onDragEnd) end
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInput.InputChanged:Connect(function(input)
		if input == dragInput and dragging and dragStart and startPos then
			local delta = input.Position - dragStart
			local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			gui.Position = newPos
		end
	end)
end

-- لما نسحب البانل نحدّث lastShownPanelPos (عشان toggle يشتغل صح بعد السحب)
makeDraggable(Panel, function()
	lastShownPanelPos = Panel.Position
end)
-- نقدر نسحب زر الفتح برضه
makeDraggable(ToggleBtn)

-- ============ فتح/اغلاق البانل (بناء على lastShownPanelPos) ============
local opened = false
local function togglePanel()
	opened = not opened
	local shiftX = Panel.AbsoluteSize.X + 40
	local goalPos
	if opened then
		-- نظرًا لأن lastShownPanelPos هو المكان اللي عايز أرجع له
		goalPos = lastShownPanelPos
		ToggleBtn.Text = "إخفاء قائمة التتبع"
	else
		-- نخفيه بمقدار عرضه للجهة اليسار
		goalPos = UDim2.new(lastShownPanelPos.X.Scale, lastShownPanelPos.X.Offset - shiftX, lastShownPanelPos.Y.Scale, lastShownPanelPos.Y.Offset)
		ToggleBtn.Text = "فتح قائمة التتبع"
	end
	TweenService:Create(Panel, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goalPos}):Play()
end

ToggleBtn.MouseButton1Click:Connect(togglePanel)

-- افتح البانل افتراضياً (لو عايب)
togglePanel()

-- ============ تحديث الوقت (RenderStepped) ============
RunService.RenderStepped:Connect(function()
	for i=1,4 do
		local S = Slots[i]
		if S and S.Assigned and S.SessionStart and S.SessionStart > 0 then
			local elapsed = os.clock() - S.SessionStart
			S.Time.Text = "الوقت: " .. fmtTime(elapsed)
		end
	end
end)

-- ============ تتبع دخول/خروج حقيقي ============
Players.PlayerAdded:Connect(function(plr)
	for i=1,4 do
		local S = Slots[i]
		if S and S.Assigned and S.Assigned.UserId == plr.UserId then
			-- رجع اللاعب => تحديث
			S.Assigned = plr
			S.SessionStart = os.clock()
			S.LastEvent = "دخول"
			S.Joins = (S.Joins or 0) + 1
			S.JoinLabel.Text = "الدخول: " .. tostring(S.Joins or 0)
			S.LastEventLabel.Text = "آخر حدث: " .. tostring(S.LastEvent or "—")
			-- تحديث الصورة والاسم
			pcall(function()
				local thumb = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				S.Img.Image = thumb
			end)
			S.Name.Text = "اللقب: " .. (plr.DisplayName or "—")
			S.User.Text = "@" .. (plr.Name or "—")
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	for i=1,4 do
		local S = Slots[i]
		if S and S.Assigned and S.Assigned.UserId == plr.UserId then
			S.LastEvent = "خروج"
			S.Leaves = (S.Leaves or 0) + 1
			S.LeaveLabel.Text = "الخروج: " .. tostring(S.Leaves or 0)
			S.LastEventLabel.Text = "آخر حدث: " .. tostring(S.LastEvent or "—")
			-- نفصل الجلسة (نحتفظ بالمعلومة شوية قبل المسح)
			S.Assigned = nil
			S.SessionStart = 0
			-- نعاير التفريغ بعد ثانيتين لو ما رجعش
			task.delay(2, function()
				if S and not S.Assigned then
					-- مسح العناصر مرن
					S.Name.Text = "اللقب: —"
					S.User.Text = "@—"
					S.Time.Text = "الوقت: 00:00:00"
					S.Img.Image = ""
				end
			end)
		end
	end
end)
