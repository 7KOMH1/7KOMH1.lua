--[[ 
 GS4 | العم حكومه 🍷  — لوحة تتبع 4 لاعبين
 ملاحظات:
 - اكتب أول حرفين أو أكثر من اسم اللاعب (Username) أو لقبه (DisplayName) وسيتم التقاطه فوريًا.
 - مسح النص من الخانة = إلغاء التتبع.
 - العدّاد يحسب منذ بدء التتبع الحالي فقط.
 - تنبيه صغير أعلى الشاشة عند دخول/خروج اللاعب المحدد.
 - زر ثلاث شرطات صغير لفتح/قفل اللوحة. اللوحة قابلة للسحب.
]]

--========== الخدمات ==========
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UserInput    = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui   = game:GetService("StarterGui")

local Lp = Players.LocalPlayer

--========== أدوات عامة ==========
local function safe(pcall_result, ...)
	-- يحجب أي خطأ غير متوقع
	return pcall_result and ... or nil
end

local function now()
	return tick()
end

local function formatTime(sec)
	sec = math.max(0, math.floor(sec))
	local m  = math.floor(sec/60)
	local s  = sec % 60
	return string.format("%02d:%02d", m, s)
end

local function toast(msg)
	-- تنبيه صغير (بدون إزعاج)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "تنبيه",
			Text = msg,
			Duration = 2.5
		})
	end)
end

-- أصوات بسيطة (اختيارية). استبدل IDs لو تحب.
local function playSound(id)
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://"..tostring(id)
		s.Volume = 0.6
		s.PlayOnRemove = true
		s.Parent = workspace
		s:Destroy()
	end)
end

local SND_JOIN  = 138087398      -- UI Click (تقريبًا)
local SND_LEAVE = 12222124       -- Click آخر بسيط (بدل لو حاب)

--========== GUI ==========
-- إزالة أي نسخة قديمة
pcall(function() if Lp.PlayerGui:FindFirstChild("GS4_TrackerUI") then Lp.PlayerGui.GS4_TrackerUI:Destroy() end end)

local GUI        = Instance.new("ScreenGui")
GUI.Name         = "GS4_TrackerUI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.Parent       = Lp:WaitForChild("PlayerGui")

-- زر فتح/قفل صغير (ثلاث شرطات)
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "Toggle"
ToggleBtn.Size = UDim2.fromOffset(34, 34)
ToggleBtn.Position = UDim2.new(0, 14, 0.5, -17)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Image = "rbxassetid://3926305904" -- أيقونة
ToggleBtn.ImageRectOffset = Vector2.new(84, 364)
ToggleBtn.ImageRectSize  = Vector2.new(36, 36)
ToggleBtn.Parent = GUI

-- الحاوية الرئيسية
local Root = Instance.new("Frame")
Root.Name = "Root"
Root.Size = UDim2.fromScale(0.58, 0.62)         -- حجم متوسط إلى صغير
Root.Position = UDim2.fromScale(0.5, 0.53)
Root.AnchorPoint = Vector2.new(0.5, 0.5)
Root.BackgroundColor3 = Color3.fromRGB(12,12,14) -- أسود داكن
Root.BorderSizePixel = 0
Root.Visible = true
Root.Parent = GUI

-- ظل بسيط
local UICorner = Instance.new("UICorner", Root)
UICorner.CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", Root)
UIStroke.Color = Color3.fromRGB(30,30,34)
UIStroke.Thickness = 1

-- جعل اللوحة قابلة للسحب
do
	local dragging, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
		                          startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	Root.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Root.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	Root.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

-- رأس العنوان
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, -20, 0, 52)
Header.Position = UDim2.fromOffset(10,10)
Header.BackgroundTransparency = 1
Header.Parent = Root

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "GS4 | العم حكومه  🍷"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.TextColor3 = Color3.fromRGB(80,160,255)  -- أزرق واضح
Title.Parent = Header

-- شبكة 2x2 للبطاقات
local Grid = Instance.new("Frame")
Grid.Name = "Grid"
Grid.BackgroundTransparency = 1
Grid.Position = UDim2.fromOffset(10, 70)
Grid.Size = UDim2.new(1, -20, 1, -80)
Grid.Parent = Root

local UIGrid = Instance.new("UIGridLayout", Grid)
UIGrid.CellPadding = UDim2.fromOffset(12, 12)
UIGrid.CellSize = UDim2.new(0.5, -6, 0.5, -6)
UIGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIGrid.VerticalAlignment   = Enum.VerticalAlignment.Top
UIGrid.SortOrder = Enum.SortOrder.LayoutOrder

-- عنصر بطاقة لاعب
local function createCard(index:number)
	local Card = Instance.new("Frame")
	Card.Name = "Card"..index
	Card.BackgroundColor3 = Color3.fromRGB(18,18,20)
	Card.BorderSizePixel = 0
	Card.Parent = Grid
	local c = Instance.new("UICorner", Card); c.CornerRadius = UDim.new(0,10)
	local s = Instance.new("UIStroke", Card); s.Color = Color3.fromRGB(36,36,42); s.Thickness = 1

	-- حقل إدخال (بدون Placeholder)
	local Search = Instance.new("TextBox")
	Search.Name = "Search"
	Search.BackgroundColor3 = Color3.fromRGB(26,26,30)
	Search.Size = UDim2.new(1, -20, 0, 34)
	Search.Position = UDim2.fromOffset(10, 10)
	Search.ClearTextOnFocus = false
	Search.Text = ""          -- بلا كلمة "اكتب اسم"
	Search.PlaceholderText = "" 
	Search.TextXAlignment = Enum.TextXAlignment.Left
	Search.TextSize = 19
	Search.Font = Enum.Font.GothamSemibold
	Search.TextColor3 = Color3.fromRGB(220,230,255)
	local sc = Instance.new("UICorner", Search); sc.CornerRadius = UDim.new(0,8)
	local ss = Instance.new("UIStroke", Search); ss.Color = Color3.fromRGB(40,40,46); ss.Thickness = 1
	Search.Parent = Card

	-- صورة الأفاتار
	local Avatar = Instance.new("ImageLabel")
	Avatar.Name = "Avatar"
	Avatar.BackgroundTransparency = 1
	Avatar.Size = UDim2.fromOffset(64,64)
	Avatar.Position = UDim2.fromOffset(14, 56)
	Avatar.Image = "rbxassetid://0" -- فاضي لحد ما نلتقط
	Avatar.Parent = Card
	local ac = Instance.new("UICorner", Avatar); ac.CornerRadius = UDim.new(1,0)
	local ast = Instance.new("UIStroke", Avatar); ast.Color = Color3.fromRGB(60,60,70); ast.Thickness = 1

	-- اسم المستخدم واللقب (يظهروا بعد الالتقاط)
	local NameL = Instance.new("TextLabel")
	NameL.BackgroundTransparency = 1
	NameL.Position = UDim2.fromOffset(90, 58)
	NameL.Size = UDim2.new(1, -100, 0, 28)
	NameL.Font = Enum.Font.GothamBold
	NameL.TextSize = 20
	NameL.TextColor3 = Color3.fromRGB(90,180,255)
	NameL.TextXAlignment = Enum.TextXAlignment.Left
	NameL.Text = "اسم المستخدم : -"
	NameL.Parent = Card

	local DispL = Instance.new("TextLabel")
	DispL.BackgroundTransparency = 1
	DispL.Position = UDim2.fromOffset(90, 86)
	DispL.Size = UDim2.new(1, -100, 0, 24)
	DispL.Font = Enum.Font.GothamMedium
	DispL.TextSize = 18
	DispL.TextColor3 = Color3.fromRGB(100,255,230)
	DispL.TextXAlignment = Enum.TextXAlignment.Left
	DispL.Text = "اللقب : -"
	DispL.Parent = Card

	-- عدادات أسفل البطاقة
	local StatBar = Instance.new("Frame")
	StatBar.Name = "StatBar"
	StatBar.Position = UDim2.new(0, 10, 1, -38)
	StatBar.Size = UDim2.new(1, -20, 0, 26)
	StatBar.BackgroundTransparency = 1
	StatBar.Parent = Card

	local JoinL = Instance.new("TextLabel")
	JoinL.BackgroundTransparency = 1
	JoinL.Size = UDim2.new(0.5, -6, 1, 0)
	JoinL.Font = Enum.Font.GothamSemibold
	JoinL.TextSize = 18
	JoinL.TextXAlignment = Enum.TextXAlignment.Left
	JoinL.TextColor3 = Color3.fromRGB(30,220,90)
	JoinL.Text = "دخول: 0"
	JoinL.Parent = StatBar

	local LeaveL = Instance.new("TextLabel")
	LeaveL.BackgroundTransparency = 1
	LeaveL.Position = UDim2.new(0.5, 6, 0, 0)
	LeaveL.Size = UDim2.new(0.5, -6, 1, 0)
	LeaveL.Font = Enum.Font.GothamSemibold
	LeaveL.TextSize = 18
	LeaveL.TextXAlignment = Enum.TextXAlignment.Right
	LeaveL.TextColor3 = Color3.fromRGB(235,70,70)
	LeaveL.Text = "خروج: 0"
	LeaveL.Parent = StatBar

	-- وقت البدء + المدة (صغير ومش مزعج)
	local TimeBar = Instance.new("TextLabel")
	TimeBar.BackgroundTransparency = 1
	TimeBar.Position = UDim2.fromOffset(12, 126)
	TimeBar.Size = UDim2.new(1, -24, 0, 18)
	TimeBar.Font = Enum.Font.Gotham
	TimeBar.TextSize = 14
	TimeBar.TextColor3 = Color3.fromRGB(170,170,180)
	TimeBar.TextXAlignment = Enum.TextXAlignment.Left
	TimeBar.Text = "منذ بدء التتبع: 00:00 | المدة: 00:00"
	TimeBar.Parent = Card

	-- بيانات داخلية
	local state = {
		target = nil,          -- اللاعب المتتبع (Instance)
		startTick = 0,         -- وقت بدء التتبع
		joins = 0, leaves = 0, -- عدادات
		lastLookup = 0,        -- لتقليل البحث
	}

	return Card, state
end

-- إنشاء أربع بطاقات
local Cards = {}
for i=1,4 do
	local card, st = createCard(i)
	Cards[i] = {ui = card, st = st}
end

-- إظهار/إخفاء اللوحة
local visible = true
local function setVisible(v)
	visible = v
	if v then
		Root.Visible = true
		Root.BackgroundTransparency = 1
		TweenService:Create(Root, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
	else
		TweenService:Create(Root, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
		task.delay(0.16, function() Root.Visible = false end)
	end
end
ToggleBtn.MouseButton1Click:Connect(function() setVisible(not visible) end)

--========== منطق الالتقاط ==========
local function getHeadshot(userId:number)
	-- صورة رأس 150x150
	local ok, content = pcall(Players.GetUserThumbnailAsync, Players, userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	return ok and content or ""
end

local function findPlayerByPrefix(txt)
	if not txt or txt == "" or #txt < 2 then return nil end
	local L = string.lower(txt)
	-- أفضلية: تطابق البداية لاسم المستخدم ثم اللقب
	local best = nil
	for _,plr in ipairs(Players:GetPlayers()) do
		local u = string.lower(plr.Name)
		if string.sub(u,1,#L) == L then
			best = plr; break
		end
	end
	if best then return best end
	for _,plr in ipairs(Players:GetPlayers()) do
		local d = string.lower(plr.DisplayName or "")
		if string.sub(d,1,#L) == L then
			return plr
		end
	end
	return nil
end

local function applyTarget(card, st, plr)
	st.target = plr
	st.joins, st.leaves = 0, 0
	st.startTick = now()

	-- UI تحديث
	card.Search.Text = plr and "" or card.Search.Text
	local avatar = card:FindFirstChild("Avatar")
	local nameL  = card:FindFirstChild("Avatar") and card.Parent and nil
	local NameL  = card:FindFirstChild("Avatar") and card:FindFirstChild("Avatar").Parent and card:FindFirstChild("Avatar").Parent:FindFirstChild("NameL")
	-- (هنجيب العناصر مباشرة من card)
	local Avatar = card:FindFirstChild("Avatar")
	local NameLabel = card:FindFirstChild("NameL") or card:FindFirstChild("Avatar").Parent:FindFirstChild("NameL")
	local DispLabel = card:FindFirstChild("DispL") or card:FindFirstChild("Avatar").Parent:FindFirstChild("DispL")
	local JoinL = card.StatBar:FindFirstChildOfClass("TextLabel")
	local LeaveL = card.StatBar:FindFirstChildWhichIsA("TextLabel", true)

	-- لأننا سميناهم سابقًا بالترتيب، نجيبهم بوضوح:
	for _,child in ipairs(card:GetDescendants()) do
		if child:IsA("TextLabel") and child.Text:find("اسم المستخدم") then NameLabel = child end
		if child:IsA("TextLabel") and child.Text:find("اللقب") then DispLabel = child end
		if child:IsA("TextLabel") and child.Text:match("^دخول") then JoinL = child end
		if child:IsA("TextLabel") and child.Text:match("^خروج") then LeaveL = child end
	end
	local TimeBar = card:FindFirstChild("TimeBar", true)
	if not TimeBar then
		for _,child in ipairs(card:GetDescendants()) do
			if child.Name == "TimeBar" then TimeBar = child end
		end
	end

	if plr then
		local head = getHeadshot(plr.UserId)
		card.Avatar.Image = head
		NameLabel.Text = ("اسم المستخدم : %s"):format(plr.Name)
		DispLabel.Text = ("اللقب : %s"):format(plr.DisplayName)
		JoinL.Text = "دخول: 0"
		LeaveL.Text = "خروج: 0"
		TimeBar.Text = "منذ بدء التتبع: 00:00 | المدة: 00:00"
	else
		card.Avatar.Image = "rbxassetid://0"
		NameLabel.Text = "اسم المستخدم : -"
		DispLabel.Text = "اللقب : -"
		JoinL.Text = "دخول: 0"
		LeaveL.Text = "خروج: 0"
		TimeBar.Text = "منذ بدء التتبع: 00:00 | المدة: 00:00"
	end
end

-- تجهيز مراجع عناصر النص لكل بطاقة (مرة واحدة)
for _,pkt in ipairs(Cards) do
	local card = pkt.ui
	card.NameL = nil; card.DispL = nil
	for _,child in ipairs(card:GetDescendants()) do
		if child:IsA("TextLabel") and child.Text:find("اسم المستخدم") then card.NameL = child end
		if child:IsA("TextLabel") and child.Text:find("اللقب") then card.DispL = child end
	end
end

-- ربط الإدخال لكل بطاقة
for _,pkt in ipairs(Cards) do
	local card, st = pkt.ui, pkt.st
	local Search = card:FindFirstChild("Search")
	local NameL  = card.NameL
	local DispL  = card.DispL
	local JoinL, LeaveL, TimeBar
	for _,child in ipairs(card:GetDescendants()) do
		if child:IsA("TextLabel") and child.Text:match("^دخول") then JoinL = child end
		if child:IsA("TextLabel") and child.Text:match("^خروج") then LeaveL = child end
		if child.Name == "TimeBar" then TimeBar = child end
	end

	local function clearTracking()
		st.target = nil
		st.joins, st.leaves = 0, 0
		st.startTick = 0
		card.Avatar.Image = "rbxassetid://0"
		NameL.Text = "اسم المستخدم : -"
		DispL.Text = "اللقب : -"
		JoinL.Text = "دخول: 0"
		LeaveL.Text = "خروج: 0"
		TimeBar.Text = "منذ بدء التتبع: 00:00 | المدة: 00:00"
	end

	-- التحديث الدوري للمدة
	RunService.Heartbeat:Connect(function()
		if st.target and st.startTick > 0 then
			local since = now() - st.startTick
			TimeBar.Text = ("منذ بدء التتبع: %s | المدة: %s"):format(formatTime(since), formatTime(since))
		end
	end)

	-- عند تغيير النص: نلتقط بسرعة شديدة (debounce بسيط)
	Search:GetPropertyChangedSignal("Text"):Connect(function()
		local txt = Search.Text
		if txt == "" then
			if st.target then
				clearTracking()
				toast("تم إيقاف تتبع البطاقة")
			end
			return
		end
		if #txt < 2 then return end
		local t = now()
		if t - st.lastLookup < 0.08 then return end
		st.lastLookup = t

		local plr = findPlayerByPrefix(txt)
		if plr and plr ~= st.target then
			applyTarget(card, st, plr)
			toast(("متابعة: %s"):format(plr.DisplayName))
			playSound(SND_JOIN)
		end
	end)

	-- أحداث الدخول/الخروج الحقيقية
	Players.PlayerAdded:Connect(function(plr)
		if st.target and plr.UserId == st.target.UserId then
			st.joins += 1
			JoinL.Text = ("دخول: %d"):format(st.joins)
			toast(("دخول: %s"):format(plr.DisplayName))
			playSound(SND_JOIN)
		end
	end)
	Players.PlayerRemoving:Connect(function(plr)
		if st.target and plr.UserId == st.target.UserId then
			st.leaves += 1
			LeaveL.Text = ("خروج: %d"):format(st.leaves)
			toast(("خروج: %s"):format(plr.DisplayName or plr.Name))
			playSound(SND_LEAVE)
		end
	end)
end

-- مزيد من تجميل النصوص (محاذاة عربية جيدة)
for _,pkt in ipairs(Cards) do
	local card = pkt.ui
	for _,lb in ipairs(card:GetDescendants()) do
		if lb:IsA("TextLabel") then
			lb.RichText = false
		elseif lb:IsA("TextBox") then
			lb.TextEditable = true
		end
	end
end

-- حماية بسيطة من تمدد اللوحة لو دقة الشاشة اتغيرت
local function clampRoot()
	local s = GUI.AbsoluteSize
	local w = math.clamp(s.X*0.58, 520, 820)
	local h = math.clamp(s.Y*0.62, 360, 540)
	Root.Size = UDim2.fromOffset(w, h)
end
clampRoot()
GUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(clampRoot)

-- لمسة ظهور أولي
do
	Root.BackgroundTransparency = 1
	Root.Visible = true
	TweenService:Create(Root, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
end

-- انتهى. استمتع 🌟
