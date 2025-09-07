-- LocalScript (ضعه داخل StarterGui)
-- صنع حكومه | كلان EG - تتبع 4 لاعبين (النسخة النهائية الشاملة)

-- خدمات
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local UserInput    = game:GetService("UserInputService")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

-- دوال مساعدة
local function fmtElapsed(sec)
	sec = math.max(0, math.floor(sec or 0))
	local h = math.floor(sec/3600)
	local m = math.floor((sec%3600)/60)
	local s = sec%60
	return string.format("%02d:%02d:%02d", h, m, s)
end
local function fmtTimeNow()
	return os.date("%Y-%m-%d %H:%M:%S", os.time())
end

-- ========== بناء الـ GUI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EG_Tracker_Final"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- زر الفتح (قابل للسحب)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Text = "فتح قائمة التتبع"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.BackgroundColor3 = Color3.fromRGB(10, 28, 60)
toggleBtn.BorderSizePixel = 0
toggleBtn.Size = UDim2.new(0, 160, 0, 32)
toggleBtn.Position = UDim2.new(0, 12, 0.5, -16)
toggleBtn.AnchorPoint = Vector2.new(0, 0.5)
toggleBtn.ZIndex = 50
toggleBtn.Parent = screenGui
toggleBtn.AutoButtonColor = true
toggleBtn.Active = true

-- لمسة حركة بسيطة دورية للزر (خفيفه)
do
	task.spawn(function()
		local up = true
		while toggleBtn.Parent do
			local delta = (up and 6) or -6
			TweenService:Create(toggleBtn, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = toggleBtn.Position + UDim2.new(0,0,0,delta)}):Play()
			up = not up
			task.wait(0.8)
		end
	end)
end

-- اللوحة الرئيسية (بانل أسود أنيق)
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 640, 0, 460)
panel.Position = UDim2.new(0, -700, 0.5, -230) -- مخفي في اليسار افتراضياً
panel.AnchorPoint = Vector2.new(0, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(6,6,6)
panel.BorderSizePixel = 0
panel.Parent = screenGui
panel.Active = true

-- ظل ناعم (اختياري)
local shadow = Instance.new("UIStroke")
shadow.Parent = panel
shadow.Transparency = 0.9
shadow.Thickness = 1

-- حقوق باللون الأزرق
local title = Instance.new("TextLabel")
title.Parent = panel
title.Size = UDim2.new(1, -24, 0, 36)
title.Position = UDim2.new(0, 12, 0, 10)
title.BackgroundTransparency = 1
title.Text = "صنع حكومه | كلان EG - تتبع 4 لاعبين"
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

-- حاوية شبكة 2x2
local grid = Instance.new("Frame")
grid.Parent = panel
grid.Size = UDim2.new(1, -24, 1, -74)
grid.Position = UDim2.new(0, 12, 0, 54)
grid.BackgroundTransparency = 1

local cellPositions = {
	UDim2.new(0, 0,   0, 0),
	UDim2.new(0.5, 8, 0, 0),
	UDim2.new(0, 0,   0.5, 8),
	UDim2.new(0.5, 8, 0.5, 8),
}

-- جدول الخانات
local Slots = {} -- كل عنصر: Frame, Input, Img, Display, User, Time, Events labels, Assigned, SessionStart, Joins, Leaves

-- منع تكرار نفس اللاعب
local function isAssigned(plr)
	for i=1,4 do
		local s = Slots[i]
		if s and s.Assigned and s.Assigned.UserId == plr.UserId then
			return true
		end
	end
	return false
end

-- البحث في اللاعبين الحاليين (أولوية لبدايات الاسم/اللقب)
local function findPlayerByQuery(q)
	if not q or #q < 2 then return nil end
	q = string.lower(q)
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local dn = string.lower(plr.DisplayName or "")
			local un = string.lower(plr.Name or "")
			if dn:sub(1, #q) == q or un:sub(1, #q) == q or dn:find(q,1,true) or un:find(q,1,true) then
				return plr
			end
		end
	end
	return nil
end

-- تعيين لاعب لخانة
local function assignToSlot(idx, plr)
	if not plr then return end
	local S = Slots[idx]
	if not S then return end
	-- منع التعيين لو اللاعب في خانة تانية
	if isAssigned(plr) and (not S.Assigned or S.Assigned.UserId ~= plr.UserId) then
		-- لو تحب نعرض رسالة صغيرة هنا نقدر
		return
	end

	-- لو نفس اللاعب معطى خلاص نحدّث بس
	if S.Assigned and S.Assigned.UserId == plr.UserId then
		return
	end

	S.Assigned = plr
	S.SessionStart = os.clock()
	S.Joins = (S.Joins or 0) + 1
	S.LastEvent = "دخول"
	S.JoinLabel.Text = "الدخول: " .. tostring(S.Joins)
	S.LastEventLabel.Text = "آخر حدث: " .. tostring(S.LastEvent .. " @ " .. fmtTimeNow())

	-- اسم ولقب
	S.Display.Text = (plr.DisplayName or "—")
	S.User.Text = "@" .. (plr.Name or "—")

	-- صورة (آمنة بواسطة pcall)
	local ok, thumb = pcall(function()
		return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)
	if ok and thumb and thumb ~= "" then
		S.Img.Image = thumb
	else
		S.Img.Image = ""
	end

	-- إظهار الكارد لو كان مخفي
	S.Frame.Visible = true

	-- أنيميشن بسيط للتعيين
	pcall(function()
		local t1 = TweenService:Create(S.Frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(12,12,12)})
		t1:Play()
		task.delay(0.18, function()
			if S and S.Frame then
				TweenService:Create(S.Frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(6,6,6)}):Play()
			end
		end)
	end)
end

-- تفريغ خانة (clear)
local function clearSlot(idx)
	local S = Slots[idx]
	if not S then return end
	S.Assigned = nil
	S.SessionStart = 0
	S.Display.Text = "—"
	S.User.Text = "@—"
	S.TimeLabel.Text = "الوقت: 00:00:00"
	S.JoinLabel.Text = "الدخول: 0"
	S.LeaveLabel.Text = "الخروج: 0"
	S.LastEventLabel.Text = "آخر حدث: —"
	S.Img.Image = ""
	S.Joins = 0
	S.Leaves = 0
	S.LastEvent = "—"
	-- نقدر نخفي الكارد لو تحب، حاليا نحتفظ ظاهر
end

-- إنشاء خانة واحدة
local function createSlot(i)
	local card = Instance.new("Frame")
	card.Name = "Slot"..i
	card.Parent = grid
	card.Size = UDim2.new(0.5, -8, 0.5, -8)
	card.Position = cellPositions[i]
	card.BackgroundColor3 = Color3.fromRGB(6,6,6)
	card.BorderSizePixel = 0
	card.ClipsDescendants = true

	-- مربع البحث الخاص بالخانة
	local input = Instance.new("TextBox")
	input.Parent = card
	input.Size = UDim2.new(1, -12, 0, 32)
	input.Position = UDim2.new(0, 6, 0, 6)
	input.PlaceholderText = "اكتب حرفين أو أكتر لالتقاط لاعب..."
	input.Text = ""
	input.Font = Enum.Font.Gotham
	input.TextSize = 14
	input.TextColor3 = Color3.fromRGB(240,240,240)
	input.BackgroundColor3 = Color3.fromRGB(18,18,18)
	input.ClearTextOnFocus = false

	-- صورة اللاعب
	local img = Instance.new("ImageLabel")
	img.Parent = card
	img.Size = UDim2.new(0, 84, 0, 84)
	img.Position = UDim2.new(0, 8, 0, 48)
	img.BackgroundTransparency = 1
	img.Image = ""

	-- DisplayName
	local display = Instance.new("TextLabel")
	display.Parent = card
	display.Size = UDim2.new(1, -108, 0, 28)
	display.Position = UDim2.new(0, 108, 0, 48)
	display.BackgroundTransparency = 1
	display.Text = "—"
	display.TextColor3 = Color3.fromRGB(230,230,230)
	display.Font = Enum.Font.GothamBold
	display.TextSize = 16
	display.TextXAlignment = Enum.TextXAlignment.Left

	-- Username
	local userlab = Instance.new("TextLabel")
	userlab.Parent = card
	userlab.Size = UDim2.new(1, -108, 0, 22)
	userlab.Position = UDim2.new(0, 108, 0, 78)
	userlab.BackgroundTransparency = 1
	userlab.Text = "@—"
	userlab.TextColor3 = Color3.fromRGB(150,150,150)
	userlab.Font = Enum.Font.Gotham
	userlab.TextSize = 14
	userlab.TextXAlignment = Enum.TextXAlignment.Left

	-- الوقت (عداد حي)
	local timeLbl = Instance.new("TextLabel")
	timeLbl.Parent = card
	timeLbl.Size = UDim2.new(1, -12, 0, 22)
	timeLbl.Position = UDim2.new(0, 6, 0, 140)
	timeLbl.BackgroundTransparency = 1
	timeLbl.Text = "الوقت: 00:00:00"
	timeLbl.TextColor3 = Color3.fromRGB(120, 220, 150)
	timeLbl.Font = Enum.Font.Gotham
	timeLbl.TextSize = 13
	timeLbl.TextXAlignment = Enum.TextXAlignment.Left

	-- فاصل
	local sep = Instance.new("Frame")
	sep.Parent = card
	sep.Size = UDim2.new(1, -12, 0, 1)
	sep.Position = UDim2.new(0, 6, 0, 166)
	sep.BackgroundColor3 = Color3.fromRGB(24,24,24)
	sep.BorderSizePixel = 0

	-- سطور الدخول/الخروج/آخر حدث (تحت بعض)
	local joinLabel = Instance.new("TextLabel")
	joinLabel.Parent = card
	joinLabel.Size = UDim2.new(1, -12, 0, 18)
	joinLabel.Position = UDim2.new(0, 6, 0, 172)
	joinLabel.BackgroundTransparency = 1
	joinLabel.Text = "الدخول: 0"
	joinLabel.TextColor3 = Color3.fromRGB(150,180,255)
	joinLabel.Font = Enum.Font.Gotham
	joinLabel.TextSize = 13
	joinLabel.TextXAlignment = Enum.TextXAlignment.Left

	local leaveLabel = Instance.new("TextLabel")
	leaveLabel.Parent = card
	leaveLabel.Size = UDim2.new(1, -12, 0, 18)
	leaveLabel.Position = UDim2.new(0, 6, 0, 190)
	leaveLabel.BackgroundTransparency = 1
	leaveLabel.Text = "الخروج: 0"
	leaveLabel.TextColor3 = Color3.fromRGB(150,180,255)
	leaveLabel.Font = Enum.Font.Gotham
	leaveLabel.TextSize = 13
	leaveLabel.TextXAlignment = Enum.TextXAlignment.Left

	local lastEventLabel = Instance.new("TextLabel")
	lastEventLabel.Parent = card
	lastEventLabel.Size = UDim2.new(1, -12, 0, 18)
	lastEventLabel.Position = UDim2.new(0, 6, 0, 208)
	lastEventLabel.BackgroundTransparency = 1
	lastEventLabel.Text = "آخر حدث: —"
	lastEventLabel.TextColor3 = Color3.fromRGB(200,200,200)
	lastEventLabel.Font = Enum.Font.Gotham
	lastEventLabel.TextSize = 13
	lastEventLabel.TextXAlignment = Enum.TextXAlignment.Left

	Slots[i] = {
		Frame = card,
		Input = input,
		Img = img,
		Display = display,
		User = userlab,
		TimeLabel = timeLbl,
		JoinLabel = joinLabel,
		LeaveLabel = leaveLabel,
		LastEventLabel = lastEventLabel,
		Assigned = nil,
		SessionStart = 0,
		Joins = 0,
		Leaves = 0,
		LastEvent = "—",
	}

	-- تفاعل البحث: أول ما يكتب ≥2 حرف يلتقط اللاعب
	input:GetPropertyChangedSignal("Text"):Connect(function()
		local txt = input.Text
		if #txt >= 2 then
			local plr = findPlayerByQuery(txt)
			if plr then
				assignToSlot(i, plr)
			end
		elseif #txt == 0 then
			-- لو حذفت كل النص، نفرغ الخانة بعد قليل
			clearSlot(i)
		end
	end)
end

-- انشاء 4 خانات
for i=1,4 do createSlot(i) end

-- ========== Drag (سحب) للـ panel و toggleBtn ==========
local function makeDraggable(gui)
	gui.Active = true
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					dragInput = nil
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

makeDraggable(panel)
makeDraggable(toggleBtn)

-- حفظ آخر مكان ظاهر للبانل (عشان toggle يرجع له)
local lastPanelPos = UDim2.new(0, 12, 0.5, -230)
panel.Position = UDim2.new(lastPanelPos.X.Scale, lastPanelPos.X.Offset - (panel.Size.X.Offset + 40), lastPanelPos.Y.Scale, lastPanelPos.Y.Offset)

-- ========== فتح/اغلاق بالانيميشن ==========
local opened = false
local function togglePanel()
	opened = not opened
	if opened then
		-- إظهار: نعيده للمكان الأخير
		local goal = lastPanelPos
		TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goal}):Play()
		toggleBtn.Text = "إخفاء قائمة التتبع"
	else
		-- إخفاء: نحركه لليسار بحيث يختفي
		local hidePos = UDim2.new(lastPanelPos.X.Scale, lastPanelPos.X.Offset - (panel.Size.X.Offset + 40), lastPanelPos.Y.Scale, lastPanelPos.Y.Offset)
		TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = hidePos}):Play()
		toggleBtn.Text = "فتح قائمة التتبع"
	end
end

toggleBtn.MouseButton1Click:Connect(togglePanel)

-- لو سحب المستخدم البانل نحدّث lastPanelPos لما يوقف السحب (نراقب تغيّر الموضع ويحدث)
do
	local lastCheck = panel.Position
	spawn(function()
		while panel.Parent do
			if panel.Position ~= lastCheck then
				lastCheck = panel.Position
				lastPanelPos = lastCheck
			end
			task.wait(0.2)
		end
	end)
end

-- ========== تحديث الوقت لكل خانة (Realtime) ==========
RunService.RenderStepped:Connect(function()
	for i=1,4 do
		local S = Slots[i]
		if S and S.Assigned and S.SessionStart and S.SessionStart > 0 then
			local elapsed = os.clock() - S.SessionStart
			S.TimeLabel.Text = "الوقت: " .. fmtElapsed(elapsed)
		end
	end
end)

-- ========== تتبع دخول وخروج حقيقي مع طوابع زمن ==========
Players.PlayerAdded:Connect(function(plr)
	for i=1,4 do
		local S = Slots[i]
		if S and S.Assigned and S.Assigned.UserId == plr.UserId then
			-- رجع اللاعب
			S.Assigned = plr
			S.SessionStart = os.clock()
			S.LastEvent = "دخول"
			S.Joins = (S.Joins or 0) + 1
			S.JoinLabel.Text = "الدخول: " .. tostring(S.Joins)
			S.LastEventLabel.Text = "آخر حدث: " .. tostring(S.LastEvent .. " @ " .. fmtTimeNow())
			-- تحديث الصورة والاسم
			pcall(function()
				local thumb = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
				S.Img.Image = thumb
			end)
			S.Display.Text = (plr.DisplayName or "—")
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
			S.LeaveLabel.Text = "الخروج: " .. tostring(S.Leaves)
			S.LastEventLabel.Text = "آخر حدث: " .. tostring(S.LastEvent .. " @ " .. fmtTimeNow())
			-- نوقف الجلسة لكن نحتفظ بالبيانات لثواني عشان تشوف الحدث
			S.Assigned = nil
			S.SessionStart = 0
			-- نفرّغ بعد 6 ثوان لو ما رجعش
			task.delay(6, function()
				if S and not S.Assigned then
					clearSlot(i)
				end
			end)
		end
	end
end)

-- افتح البانل افتراضياً
togglePanel()

-- === انتهى ===
