--!strict
--========================================================
-- 🍷 العم حكومه | كلان EG 🍷  — شاشة تتبع 4 لاعبين (نسخة نهائية)
--========================================================

-- خدمات Roblox
local Players        = game:GetService("Players")
local StarterGui     = game:GetService("StarterGui")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local HttpService    = game:GetService("HttpService")
local ContentProvider= game:GetService("ContentProvider")

local LocalPlayer    = Players.LocalPlayer

--========================
-- إعداد ألوان وخطوط
--========================
local COLOR_BG       = Color3.fromRGB(16, 16, 18)
local COLOR_PANEL    = Color3.fromRGB(28, 28, 32)
local COLOR_STROKE   = Color3.fromRGB(50, 50, 60)
local COLOR_TEXT     = Color3.fromRGB(210, 220, 255)
local COLOR_DIM      = Color3.fromRGB(170, 180, 200)
local COLOR_ACCENT   = Color3.fromRGB(0, 162, 255) -- أزرق حقوق
local COLOR_GOOD     = Color3.fromRGB(60, 220, 90) -- ✅
local COLOR_BAD      = Color3.fromRGB(255, 70, 70) -- ❌
local COLOR_MUTE     = Color3.fromRGB(120, 130, 145)

local FONT_TITLE     = Enum.Font.GothamBold
local FONT_NORMAL    = Enum.Font.GothamSemibold
local FONT_LIGHT     = Enum.Font.Gotham

--========================
-- دوال صغيرة مفيدة
--========================
local function New(inst, props, children)
	local obj = Instance.new(inst)
	for k,v in pairs(props or {}) do obj[k]=v end
	for _,ch in ipairs(children or {}) do ch.Parent = obj end
	return obj
end

local function uiStroke(parent, thickness, color, transparency)
	return New("UIStroke", {
		Parent = parent,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = thickness or 1,
		Color = color or COLOR_STROKE,
		Transparency = transparency or 0.1
	})
end

local function uiCorner(parent, radius)
	return New("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 12)})
end

local function pad(parent, p)
	return New("UIPadding", {
		Parent = parent,
		PaddingTop = UDim.new(0, p), PaddingBottom = UDim.new(0, p),
		PaddingLeft= UDim.new(0, p), PaddingRight = UDim.new(0, p)
	})
end

local function tween(o, t, data) TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), data):Play() end

local function formatTime(sec:number):string
	sec = math.max(0, math.floor(sec))
	local m = math.floor(sec/60)
	local s = sec%60
	return string.format("%02d:%02d", m, s)
end

--========================
-- شاشة رئيسية + هيدر حقوق منفصل
--========================
local screenGui = New("ScreenGui", {
	Name = "EG_Tracker_UI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Global
})

-- شريط الحقوق العلوي (منفصل وبينه وبين اللوحة مسافة)
local topBar = New("Frame", {
	Name = "TopBar",
	Parent = screenGui,
	BackgroundColor3 = COLOR_BG,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 44),
	Position = UDim2.new(0,0,0,0)
}, {
	uiStroke(nil,1, COLOR_STROKE, 0.2),
})

pad(topBar, 8)
uiCorner(topBar, 0)

local rightsLbl = New("TextLabel", {
	Parent = topBar,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -16, 1, 0),
	Position = UDim2.new(0,8,0,0),
	Text = "🍷 العم حكومه | كلان EG 🍷",
	Font = FONT_TITLE,
	TextColor3 = COLOR_ACCENT,
	TextScaled = true,
	RichText = true
})

-- زر فتح/قفل يطفّي/يظهر اللوحة
local toggleBtn = New("TextButton", {
	Parent = topBar,
	BackgroundColor3 = COLOR_PANEL,
	Size = UDim2.new(0, 110, 1, -12),
	Position = UDim2.new(1, -120, 0, 6),
	Text = "إظهار اللوحة",
	Font = FONT_NORMAL,
	TextScaled = true,
	TextColor3 = COLOR_TEXT,
	AutoButtonColor = true
})
uiCorner(toggleBtn, 10)
uiStroke(toggleBtn, 1, COLOR_STROKE, 0.2)

-- اللوحة الرئيسية (حجم متوسط-صغير + قابلة للسحب)
local main = New("Frame", {
	Name = "Main",
	Parent = screenGui,
	BackgroundColor3 = COLOR_BG,
	BorderSizePixel = 0,
	Size = UDim2.new(0, 820, 0, 470), -- متوسط إلى صغير
	Position = UDim2.new(0.5, -410, 0, 66)
}, {
	uiStroke(nil,1, COLOR_STROKE, 0.2),
})
uiCorner(main, 14)
pad(main, 10)

-- عنوان داخلي صغير
local title = New("TextLabel", {
	Parent = main,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 36),
	Text = "لوحة تتبع اللاعبين (4)",
	Font = FONT_TITLE,
	TextColor3 = COLOR_TEXT,
	TextScaled = true,
	TextXAlignment = Enum.TextXAlignment.Center
})

-- منطقة الشبكة 2×2
local grid = New("Frame", {
	Parent = main,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, -48),
	Position = UDim2.new(0, 0, 0, 40)
})
local UIGrid = New("UIGridLayout", {
	Parent = grid,
	CellSize = UDim2.new(0.5, -12, 0.5, -12),
	CellPadding = UDim2.new(0, 12, 0, 12),
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	SortOrder = Enum.SortOrder.LayoutOrder
})

-- سحب اللوحة
do
	local dragging=false; local dragStart; local startPos
	main.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true; dragStart=input.Position; startPos=main.Position
			input.Changed:Connect(function()
				if input.UserInputState==Enum.UserInputState.End then dragging=false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
			local delta=input.Position-dragStart
			main.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
		end
	end)
end

-- صوت صغير عند دخول/خروج
local sndIn = New("Sound", {Parent=screenGui, SoundId="rbxassetid://9118823100", Volume=0.35})
local sndOut= New("Sound", {Parent=screenGui, SoundId="rbxassetid://12221967", Volume=0.35})
pcall(function() ContentProvider:PreloadAsync({sndIn, sndOut}) end)

-- زر الفتح/القفل
local isOpen = true
local function setOpen(open:boolean)
	isOpen = open
	tween(main, 0.25, {GroupTransparency = open and 0 or 1})
	main.Visible = open
	toggleBtn.Text = open and "إخفاء اللوحة" or "إظهار اللوحة"
end
toggleBtn.MouseButton1Click:Connect(function() setOpen(not isOpen) end)
setOpen(true)

--========================
-- عنصر تتبع مفرد (كارت)
--========================
export type Tracked = {
	Root: Frame,
	Input: TextBox,
	NameLbl: TextLabel,
	DisplayLbl: TextLabel,
	Avatar: ImageLabel,
	InLbl: TextLabel,
	OutLbl: TextLabel,
	TimeLbl: TextLabel,

	Player: Player?,
	SessionStart: number,
	JoinCount: number,
	LeaveCount: number,
	ConnAdded: RBXScriptConnection?,
	ConnRemoving: RBXScriptConnection?,
}

local function makeCard(index:number):Tracked
	local card = New("Frame", {
		BackgroundColor3 = COLOR_PANEL,
		BorderSizePixel = 0
	})
	uiCorner(card, 12)
	uiStroke(card, 1, COLOR_STROKE, 0.3)
	pad(card, 10)

	-- خانة البحث (فاضية) — يلقط من أول حرفين
	local input = New("TextBox", {
		Parent = card,
		BackgroundColor3 = COLOR_BG,
		Text = "",
		PlaceholderText = "",
		ClearTextOnFocus = false,
		Font = FONT_TITLE,
		TextColor3 = COLOR_TEXT,
		TextSize = 20,
		Size = UDim2.new(1, 0, 0, 38)
	})
	uiCorner(input, 10)
	uiStroke(input, 1, COLOR_STROKE, 0.25)
	pad(input, 8)

	-- صف معلومات
	local body = New("Frame", {
		Parent = card,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,1,-90),
		Position = UDim2.new(0,0,0,50)
	})
	local list = New("UIListLayout", {
		Parent = body,
		Padding = UDim.new(0, 8)
	})

	-- سطر الاسماء
	local row1 = New("Frame", {Parent=body, BackgroundTransparency=1, Size=UDim2.new(1,0,0,32)})
	local nameLbl = New("TextLabel", {
		Parent=row1, BackgroundTransparency=1, Size=UDim2.new(1, -56, 1, 0), Position=UDim2.new(0,56,0,0),
		Text="يوزر: -", Font=FONT_NORMAL, TextColor3=COLOR_TEXT, TextXAlignment=Enum.TextXAlignment.Left, TextScaled=true
	})
	local avatar = New("ImageLabel", {
		Parent=row1, BackgroundColor3=COLOR_BG, Size=UDim2.new(0,44,0,44), Position=UDim2.new(0,0,0,-6),
		ScaleType=Enum.ScaleType.Crop, Image="rbxassetid://0"
	})
	uiCorner(avatar, 6)
	uiStroke(avatar, 1, COLOR_STROKE, 0.35)

	local row2 = New("Frame", {Parent=body, BackgroundTransparency=1, Size=UDim2.new(1,0,0,28)})
	local displayLbl = New("TextLabel", {
		Parent=row2, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
		Text="لقب: -", Font=FONT_NORMAL, TextColor3=COLOR_DIM, TextXAlignment=Enum.TextXAlignment.Left, TextScaled=true
	})

	-- عدادات
	local row3 = New("Frame", {Parent=body, BackgroundTransparency=1, Size=UDim2.new(1,0,0,28)})
	local inLbl = New("TextLabel", {
		Parent=row3, BackgroundTransparency=1, Size=UDim2.new(0.5,-6,1,0),
		Text="دخول: 0 ✅", Font=FONT_NORMAL, TextColor3=COLOR_GOOD, TextXAlignment=Enum.TextXAlignment.Left, TextScaled=true
	})
	local outLbl = New("TextLabel", {
		Parent=row3, BackgroundTransparency=1, Size=UDim2.new(0.5,-6,1,0), Position=UDim2.new(0.5,6,0,0),
		Text="خروج: 0 ❌", Font=FONT_NORMAL, TextColor3=COLOR_BAD, TextXAlignment=Enum.TextXAlignment.Left, TextScaled=true
	})

	local row4 = New("Frame", {Parent=body, BackgroundTransparency=1, Size=UDim2.new(1,0,0,26)})
	local timeLbl = New("TextLabel", {
		Parent=row4, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
		Text="الوقت: 00:00 ⏱️", Font=FONT_LIGHT, TextColor3=COLOR_MUTE, TextXAlignment=Enum.TextXAlignment.Left, TextScaled=true
	})

	local tracked:Tracked = {
		Root = card, Input = input,
		NameLbl = nameLbl, DisplayLbl = displayLbl, Avatar = avatar,
		InLbl = inLbl, OutLbl = outLbl, TimeLbl = timeLbl,
		Player=nil, SessionStart=0, JoinCount=0, LeaveCount=0,
		ConnAdded=nil, ConnRemoving=nil
	}
	return tracked
end

-- اصنع 4 كروت
local CARDS : {Tracked} = {}
for i=1,4 do
	local c = makeCard(i); c.Root.Parent = grid; table.insert(CARDS, c)
end

--========================
-- منطق الالتقاط والاسناد
--========================
local function findMatchByText(q:string): Player?
	q = string.lower(q)
	if #q < 2 then return nil end -- لازم حرفين على الأقل
	local best:Player? = nil
	for _,p in ipairs(Players:GetPlayers()) do
		local un = string.lower(p.Name)
		local dn = string.lower(p.DisplayName or "")
		if string.find(un, q, 1, true) or string.find(dn, q, 1, true) then
			best = p; break
		end
	end
	return best
end

local function applyPlayerToCard(card:Tracked, plr:Player?)
	-- فك الارتباط القديم
	if card.ConnAdded then card.ConnAdded:Disconnect(); card.ConnAdded = nil end
	if card.ConnRemoving then card.ConnRemoving:Disconnect(); card.ConnRemoving = nil end
	card.Player = nil; card.SessionStart = 0
	card.JoinCount = 0; card.LeaveCount = 0

	if not plr then
		card.NameLbl.Text    = "يوزر: -"
		card.DisplayLbl.Text = "لقب: -"
		card.Avatar.Image    = "rbxassetid://0"
		card.InLbl.Text      = "دخول: 0 ✅"
		card.OutLbl.Text     = "خروج: 0 ❌"
		card.TimeLbl.Text    = "الوقت: 00:00 ⏱️"
		return
	end

	card.Player = plr
	card.NameLbl.Text    = ("يوزر: %s"):format(plr.Name)
	card.DisplayLbl.Text = ("لقب: %s"):format(plr.DisplayName or "-")

	-- صورة بروفايل مربعة (thumbnail 420×420)
	task.spawn(function()
		local ok, id = pcall(function()
			local thumbId = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			return thumbId
		end)
		if ok and typeof(id)=="string" and id~="" then
			card.Avatar.Image = id
		else
			card.Avatar.Image = "rbxassetid://0"
		end
	end)

	-- تتبع دخول/خروج (الشخصية)
	local function onAdded()
		card.JoinCount += 1
		card.InLbl.Text = ("دخول: %d ✅"):format(card.JoinCount)
		card.SessionStart = os.clock()
		sndIn:Play()
	end
	local function onRemoving()
		card.LeaveCount += 1
		card.OutLbl.Text = ("خروج: %d ❌"):format(card.LeaveCount)
		sndOut:Play()
	end

	card.ConnAdded = plr.CharacterAdded:Connect(function() onAdded() end)
	card.ConnRemoving = plr.CharacterRemoving:Connect(function() onRemoving() end)

	-- لو اللاعب عنده شخصية الآن اعتبرها دخول فوري
	if plr.Character then onAdded() end
end

-- تحديث الوقت كل ثانية
task.spawn(function()
	while true do
		for _,c in ipairs(CARDS) do
			if c.Player and c.SessionStart>0 and (c.Player.Character ~= nil) then
				local t = os.clock() - c.SessionStart
				c.TimeLbl.Text = ("الوقت: %s ⏱️"):format(formatTime(t))
			else
				-- بدون شخصية يرجع الوقت صفر (للشكل فقط)
				-- مابنصفرش SessionStart إلا عند الخروج
			end
		end
		task.wait(1)
	end
end)

-- البحث الفوري بالحروف (يلتقط أول تطابق بعد حرفين)
for _,c in ipairs(CARDS) do
	local lastQuery = ""
	c.Input:GetPropertyChangedSignal("Text"):Connect(function()
		local q = c.Input.Text
		if q == lastQuery then return end
		lastQuery = q
		local m = findMatchByText(q)
		if m then
			applyPlayerToCard(c, m)
		end
	end)
end

-- تنظيف عند خروج أي لاعب: لو كان متتبع نحدّث العدادات
Players.PlayerRemoving:Connect(function(p)
	for _,c in ipairs(CARDS) do
		if c.Player == p then
			-- هيتكوّن حدث CharacterRemoving غالبًا قبل المغادرة
			-- لكن نضمن تحديث العرض هنا أيضًا
			c.LeaveCount += 1
			c.OutLbl.Text = ("خروج: %d ❌"):format(c.LeaveCount)
		end
	end
end)

-- فتح اللوحة تلقائيًا عند بدء اللعبة (مع فاصل واضح تحت الحقوق)
main.Position = UDim2.new(0.5, -410, 0, topBar.AbsoluteSize.Y + 12)

-- استجابة أسرع للموبايل: اضغط خارج اللوحة لإخفائها، وداخلها لإظهارها (اختياري)
screenGui.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		if not main.AbsolutePosition then return end
		-- لو اللمسة خارج حدود اللوحة
		local pos = input.Position
		local x, y = pos.X, pos.Y
		local mpos, msize = main.AbsolutePosition, main.AbsoluteSize
		local inside = (x>=mpos.X and x<=mpos.X+msize.X and y>=mpos.Y and y<=mpos.Y+msize.Y)
		if not inside and isOpen then setOpen(false) end
	end
end)

-- حفظ موضع اللوحة (بسيط)
local saveKey = "EG_TRACKER_POS"
local function savePos()
	pcall(function()
		LocalPlayer:SetAttribute(saveKey, HttpService:JSONEncode({
			x = main.Position.X.Offset, y = main.Position.Y.Offset
		}))
	end)
end
local function loadPos()
	pcall(function()
		local raw = LocalPlayer:GetAttribute(saveKey)
		if typeof(raw)=="string" and #raw>0 then
			local data = HttpService:JSONDecode(raw)
			if data and tonumber(data.x) and tonumber(data.y) then
				main.Position = UDim2.new(0, data.x, 0, math.max(topBar.AbsoluteSize.Y + 12, data.y))
			end
		end
	end)
end
loadPos()
main:GetPropertyChangedSignal("Position"):Connect(savePos)

-- تلميح صغير تحت العنوان
local hint = New("TextLabel", {
	Parent = main, BackgroundTransparency=1,
	Size = UDim2.new(1,0,0,18), Position = UDim2.new(0,0,1,-20),
	Text = "اكتب أول حرفين من يوزر/لقب اللاعب داخل كل مربع وسيتم الالتقاط تلقائيًا ⚡",
	TextColor3 = COLOR_MUTE, Font=FONT_LIGHT, TextScaled=true
})

-- جاهزين ✅
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
