--========================================================--
--  سكربت الحكومة المتكامل (كود واحد) - Transform + Skin Copy + Avatar + Rejoin
--  Government All-in-One - حقوق العم حكومه 😁🍷
--========================================================--

--================= Services =================
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local TeleportService  = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")

local LP        = Players.LocalPlayer
local PlayerGui = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui")

--================= Utils ====================
local function notify(txt, dur)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title="حكومة 😁🍷", Text=tostring(txt), Duration=dur or 3})
	end)
end

local function rgbCycle(step)
	local h = 0
	return function()
		h = (h + (step or 0.01)) % 1
		return Color3.fromHSV(h, 1, 1)
	end
end

local function getHumanoid(plr)
	local ch = plr.Character or plr.CharacterAdded:Wait()
	return ch:FindFirstChildOfClass("Humanoid")
end

local function withHumanoid(descFn)
	local hum = getHumanoid(Players.LocalPlayer)
	if not hum then return false, "nohum" end
	local ok, res = pcall(descFn, hum)
	return ok and res ~= false, ok and res or "pcall"
end

local function safeApplyDescription(desc)
	if not desc then return false end
	return withHumanoid(function(hum)
		hum:ApplyDescriptionReset(desc)
		return true
	end)
end

local function getCurrentDescription()
	local hum = getHumanoid(LP)
	if not hum then return nil end
	local ok, d = pcall(function() return hum:GetAppliedDescription() end)
	return ok and d or nil
end

local function cloneDescription(desc)
	if not desc then return nil end
	local new = Instance.new("HumanoidDescription")
	for _,prop in ipairs({
		"HeadColor","LeftArmColor","RightArmColor","TorsoColor","LeftLegColor","RightLegColor",
		"HeightScale","WidthScale","DepthScale","HeadScale","BodyTypeScale","ProportionScale",
		"GraphicTShirt","Shirt","Pants","Face","Head","Torso","RightArm","LeftArm","RightLeg","LeftLeg",
		"AccessoryBlob","EmotesData",
		"ClimbAnimation","FallAnimation","IdleAnimation","JumpAnimation","RunAnimation","SwimAnimation","WalkAnimation",
		"FaceAccessory","NeckAccessory","ShouldersAccessory","FrontAccessory","BackAccessory","WaistAccessory","EmoteEnabled","OutfitId"
	}) do
		pcall(function() new[prop] = desc[prop] end)
	end
	return new
end

local function setAllBodyColors(desc, c3)
	if not desc then return end
	desc.HeadColor     = c3
	desc.TorsoColor    = c3
	desc.LeftArmColor  = c3
	desc.RightArmColor = c3
	desc.LeftLegColor  = c3
	desc.RightLegColor = c3
end

--================= Language Picker =================
local Lang = "AR" -- AR / EN
do
	local LangGui = Instance.new("ScreenGui")
	LangGui.Name = "GOV_LangPick"
	LangGui.ResetOnSpawn = false
	LangGui.Parent = PlayerGui

	local F = Instance.new("Frame", LangGui)
	F.Size = UDim2.fromOffset(420, 236)
	F.Position = UDim2.new(.5,-210,.5,-118)
	F.BackgroundColor3 = Color3.fromRGB(24,24,24)
	F.Active = true; F.Draggable = true
	Instance.new("UICorner", F).CornerRadius = UDim.new(0,14)
	local st = Instance.new("UIStroke", F) st.Thickness = 1.5
	local cyc = rgbCycle(0.006)
	task.spawn(function() while st.Parent do st.Color = cyc(); task.wait(0.06) end end)

	local T = Instance.new("TextLabel", F)
	T.Size = UDim2.new(1,0,0,56)
	T.BackgroundTransparency = 1
	T.Font = Enum.Font.GothamBlack
	T.TextSize = 22
	T.TextColor3 = Color3.new(1,1,1)
	T.Text = "اختر اللغة / Choose Language"

	local AR = Instance.new("TextButton", F)
	AR.Size = UDim2.new(.45,0,0,48)
	AR.Position = UDim2.new(.05,0,.65,0)
	AR.BackgroundColor3 = Color3.fromRGB(42,120,62)
	AR.TextColor3 = Color3.new(1,1,1)
	AR.Font = Enum.Font.GothamBold
	AR.TextSize = 20
	AR.Text = "🇪🇬 العربية"
	Instance.new("UICorner", AR).CornerRadius = UDim.new(0,12)

	local EN = Instance.new("TextButton", F)
	EN.Size = UDim2.new(.45,0,0,48)
	EN.Position = UDim2.new(.5,0,.65,0)
	EN.BackgroundColor3 = Color3.fromRGB(62,62,140)
	EN.TextColor3 = Color3.new(1,1,1)
	EN.Font = Enum.Font.GothamBold
	EN.TextSize = 20
	EN.Text = "🇬🇧 English"
	Instance.new("UICorner", EN).CornerRadius = UDim.new(0,12)

	local chosen=false
	AR.MouseButton1Click:Connect(function() Lang="AR"; chosen=true end)
	EN.MouseButton1Click:Connect(function() Lang="EN"; chosen=true end)
	repeat task.wait() until chosen
	TweenService:Create(F, TweenInfo.new(.25), {Size=UDim2.fromOffset(420,0)}):Play()
	task.wait(.27)
	LangGui:Destroy()
end
local function L(ar,en) return (Lang=="AR") and ar or en end
notify(L(("منوّر يا %s ✨ في سكربت الحكومة 😁🍷"):format(Players.LocalPlayer.DisplayName), ("Welcome %s ✨ to Government Script 😁🍷"):format(Players.LocalPlayer.DisplayName)), 3)

--================= GUI (Main) =================
local GUI = Instance.new("ScreenGui")
GUI.Name = "GOV_Main"
GUI.ResetOnSpawn = false
GUI.Parent = PlayerGui

-- Toggle button (bottom-left)
local ToggleBtn = Instance.new("TextButton", GUI)
ToggleBtn.Size = UDim2.fromOffset(150,34)
ToggleBtn.Position = UDim2.new(0,10,1,-44)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Text = L("إظهار/إخفاء (P)","Show/Hide (P)")
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,10)
local TBStroke = Instance.new("UIStroke", ToggleBtn) TBStroke.Thickness=1

-- Watermark (small, RGB)
do
	local wm = Instance.new("TextLabel", GUI)
	wm.Size = UDim2.fromOffset(190,20)
	wm.Position = UDim2.new(1,-200,1,-24)
	wm.BackgroundTransparency = 1
	wm.Font = Enum.Font.Gotham
	wm.TextSize = 14
	wm.Text = L("حكومة بيمسي 😁🍷","Gov Bimsy 😁🍷")
	local cyc = rgbCycle(0.01)
	task.spawn(function() while wm.Parent do wm.TextColor3 = cyc(); task.wait(0.05) end end)
end

-- Window
local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.fromOffset(620, 460)
Main.Position = UDim2.new(.5,-310,.5,-230)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)
local MainStroke = Instance.new("UIStroke", Main) MainStroke.Thickness = 1.5
local cycMain = rgbCycle(0.004)
task.spawn(function() while Main.Parent do MainStroke.Color = cycMain(); TBStroke.Color = MainStroke.Color; task.wait(0.06) end end)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,-20,0,46)
Title.Position = UDim2.new(0,10,0,8)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(240,240,240)
Title.Text = L("👑 سكربت الحكومة المتطور - تحوّلات و نسخ سكن 👑", "👑 Government Advanced - Transforms & Skin 👑")

-- Tabs
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(1,-20,0,36)
Tabs.Position = UDim2.new(0,10,0,54)
Tabs.BackgroundTransparency = 1
local function mkTab(txt, x)
	local b = Instance.new("TextButton", Tabs)
	b.Size = UDim2.fromOffset(190,34)
	b.Position = UDim2.new(0,x,0,0)
	b.BackgroundColor3 = Color3.fromRGB(38,38,38)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 14
	b.Text = txt
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	local s = Instance.new("UIStroke", b) s.Thickness = 1
	task.spawn(function() local c = rgbCycle(0.007 + (x%3)*0.001) while b.Parent do s.Color = c(); task.wait(0.07) end end)
	return b
end
local Tab1 = mkTab(L("التحوّلات","Transforms"), 0)
local Tab2 = mkTab(L("نسخ السكن","Skin Copier"), 205)
local Tab3 = mkTab(L("أدوات","Utilities"),      410)

-- Pages
local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1,-20,1,-112)
Pages.Position = UDim2.new(0,10,0,96)
Pages.BackgroundColor3 = Color3.fromRGB(18,18,18)
Instance.new("UICorner", Pages).CornerRadius = UDim.new(0,12)
local function mkPage()
	local p = Instance.new("ScrollingFrame", Pages)
	p.Size = UDim2.fromScale(1,1)
	p.BackgroundTransparency = 1
	p.CanvasSize = UDim2.new(0,0,0,0)
	p.ScrollBarThickness = 6
	p.Visible = false
	return p
end
local P1, P2, P3 = mkPage(), mkPage(), mkPage()
local function show(p) for _,c in ipairs(Pages:GetChildren()) do if c:IsA("ScrollingFrame") then c.Visible=false end end p.Visible=true end
show(P1)
Tab1.MouseButton1Click:Connect(function() show(P1) end)
Tab2.MouseButton1Click:Connect(function() show(P2) end)
Tab3.MouseButton1Click:Connect(function() show(P3) end)

-- Status
local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1,-20,0,24)
Status.Position = UDim2.new(0,10,1,-30)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.GothamSemibold
Status.TextSize = 14
	Status.TextColor3 = Color3.fromRGB(220,220,220)
Status.Text = L("جاهز ✅","Ready ✅")

-- Toggle
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
UserInputService.InputBegan:Connect(function(i,g) if not g and i.KeyCode==Enum.KeyCode.P then Main.Visible = not Main.Visible end end)

--================= TRANSFORMS (20 presets) =================
local Presets = {
	{AR="سليندر مان",     EN="Slenderman",     P={H=1.35,W=.78,D=.92,  HS=.95, B=0.0, PR=1.05, C=Color3.fromRGB(10,10,10)}},
	{AR="رأس الصراخ",     EN="Siren Head",     P={H=1.45,W=.82,D=1.0,  HS=.8,  B=0.1, PR=.95,  C=Color3.fromRGB(30,30,30)}},
	{AR="الوحش الظل",     EN="Shadow Monster", P={H=1.28,W=.86,D=1.02, HS=.9,  B=0.0, PR=1.0,  C=Color3.fromRGB(5,5,5)}},
	{AR="زومبي",          EN="Zombie",         P={H=1.0, W=1.0,D=1.0,  HS=1.0, B=.3,  PR=1.0,  C=Color3.fromRGB(60,120,60)}},
	{AR="شيطان أحمر",     EN="Red Demon",      P={H=1.18,W=1.05,D=1.05,HS=.95, B=.2,  PR=1.0,  C=Color3.fromRGB(140,20,20)}},
	{AR="هيكل عظمي عملاق",EN="Giant Skeleton", P={H=1.40,W=.86,D=.92, HS=.88, B=0.0, PR=1.0,  C=Color3.fromRGB(220,220,220)}},
	{AR="المهرج القاتل",  EN="Killer Clown",   P={H=1.1, W=1.0,D=1.0,  HS=1.1, B=.4,  PR=1.0,  C=Color3.fromRGB(230,230,230)}},
	{AR="وحش البحر",      EN="Sea Monster",    P={H=1.22,W=1.08,D=1.1, HS=1.0, B=.3,  PR=1.0,  C=Color3.fromRGB(20,80,120)}},
	{AR="المسخ الأسود",   EN="Dark Mutant",    P={H=1.18,W=1.08,D=1.14,HS=.9,  B=.2,  PR=1.0,  C=Color3.fromRGB(15,15,15)}},
	{AR="وحش الجبال",     EN="Mountain Beast", P={H=1.26,W=1.18,D=1.18,HS=1.0, B=.4,  PR=1.0,  C=Color3.fromRGB(100,80,60)}},
	{AR="الروح الشريرة",  EN="Evil Spirit",    P={H=1.32,W=.82,D=.9,  HS=.84, B=0.0, PR=1.08, C=Color3.fromRGB(240,240,255)}},
	{AR="الغول العملاق",  EN="Ogre Giant",     P={H=1.36,W=1.22,D=1.22,HS=1.08,B=.7,  PR=.92, C=Color3.fromRGB(80,140,80)}},
	{AR="الزاحف الليلي",  EN="Night Crawler",  P={H=1.2, W=.9, D=1.04,HS=.9,  B=.1,  PR=1.0,  C=Color3.fromRGB(20,20,40)}},
	{AR="المستذئب",       EN="Werewolf",       P={H=1.23,W=1.14,D=1.1, HS=1.0, B=.5,  PR=1.0,  C=Color3.fromRGB(90,70,50)}},
	{AR="مومياء",         EN="Mummy",          P={H=1.1, W=1.0,D=1.0,  HS=1.0, B=.2,  PR=1.0,  C=Color3.fromRGB(230,220,200)}},
	{AR="القاتل المقنع",  EN="Masked Killer",  P={H=1.14,W=1.0,D=1.0,  HS=1.0, B=.3,  PR=1.0,  C=Color3.fromRGB(35,35,35)}},
	{AR="وحش النيران",    EN="Fire Monster",   P={H=1.2, W=1.04,D=1.04,HS=1.0, B=.4,  PR=1.0,  C=Color3.fromRGB(200,70,30)}},
	{AR="شبح أبيض",       EN="White Ghost",    P={H=1.24,W=.84,D=.9,  HS=.9,  B=0.0, PR=1.08, C=Color3.fromRGB(245,245,245)}},
	{AR="التنين الأسود",  EN="Black Dragon",   P={H=1.30,W=1.08,D=1.08,HS=.95, B=.6,  PR=1.0,  C=Color3.fromRGB(10,10,10)}},
	{AR="الدمية المرعبة", EN="Creepy Doll",    P={H=.92, W=.9, D=.9,  HS=1.18,B=.4,  PR=1.0,  C=Color3.fromRGB(240,220,220)}},
}

local function applyPreset(P)
	local base = getCurrentDescription()
	if not base then return false end
	local d = cloneDescription(base)
	if not d then return false end
	if P.H  then d.HeightScale     = P.H  end
	if P.W  then d.WidthScale      = P.W  end
	if P.D  then d.DepthScale      = P.D  end
	if P.HS then d.HeadScale       = P.HS end
	if P.B  then d.BodyTypeScale   = P.B  end
	if P.PR then d.ProportionScale = P.PR end
	if P.C  then setAllBodyColors(d, P.C) end
	return safeApplyDescription(d)
end

do
	local pad = Instance.new("UIPadding", P1)
	pad.PaddingLeft  = UDim.new(0,10)
	pad.PaddingTop   = UDim.new(0,10)
	local grid = Instance.new("UIGridLayout", P1)
	grid.CellPadding = UDim2.fromOffset(10,10)
	grid.CellSize    = UDim2.new(0,290,0,38)

	for i,data in ipairs(Presets) do
		local B = Instance.new("TextButton", P1)
		B.BackgroundColor3 = Color3.fromRGB(36,36,36)
		B.TextColor3 = Color3.new(1,1,1)
		B.Font = Enum.Font.GothamSemibold
		B.TextSize = 14
		B.Text = (Lang=="AR") and data.AR or data.EN
		Instance.new("UICorner", B).CornerRadius = UDim.new(0,10)
		local s = Instance.new("UIStroke", B) s.Thickness = 1
		task.spawn(function() local c = rgbCycle(0.008+(i%5)*0.001) while s.Parent do s.Color = c(); task.wait(0.06) end end)

		B.MouseButton1Click:Connect(function()
			if applyPreset(data.P) then
				Status.Text = L("تم التحوّل إلى: ","Transformed to: ") .. ((Lang=="AR") and data.AR or data.EN) .. " ✅"
			else
				Status.Text = L("تعذر التحوّل ❌","Transform failed ❌")
			end
		end)
	end
end

--================= SKIN COPIER (prefix + avatar) =================
local AvatarImg
local NameBox

local function findPlayerByPrefix(prefix)
	if not prefix or #prefix < 2 then return nil end
	prefix = prefix:lower()
	for _,p in ipairs(Players:GetPlayers()) do
		local n1 = (p.DisplayName or ""):lower()
		local n2 = (p.Name or ""):lower()
		if n1:sub(1,#prefix)==prefix or n2:sub(1,#prefix)==prefix then
			return p
		end
	end
	return nil
end

local function copyFromPrefix(prefix)
	local target = findPlayerByPrefix(prefix)
	if not target or target == LP then return false, "notfound" end
	local ok1, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(target.UserId) end)
	if not ok1 or not desc then return false, "desc" end
	local ok2 = safeApplyDescription(desc)
	if not ok2 then return false, "apply" end
	if AvatarImg then
		local ok3, url, ready = pcall(function()
			local u, r = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			return u, r
		end)
		if ok3 then AvatarImg.Image = url end
	end
	return true, "ok"
end

do
	local pad = Instance.new("UIPadding", P2)
	pad.PaddingLeft = UDim.new(0,10)
	pad.PaddingTop  = UDim.new(0,10)

	local Lbl = Instance.new("TextLabel", P2)
	Lbl.Size = UDim2.new(1,-20,0,24)
	Lbl.BackgroundTransparency = 1
	Lbl.Font = Enum.Font.GothamSemibold
	Lbl.TextSize = 14
	Lbl.TextColor3 = Color3.fromRGB(230,230,230)
	Lbl.Text = L("اكتب أول 2-5 حروف من اسم اللاعب:","Type first 2–5 letters of player name:")

	NameBox = Instance.new("TextBox", P2)
	NameBox.Size = UDim2.new(0,260,0,36)
	NameBox.Position = UDim2.new(0,0,0,28)
	NameBox.BackgroundColor3 = Color3.fromRGB(34,34,34)
	NameBox.TextColor3 = Color3.new(1,1,1)
	NameBox.PlaceholderText = L("مثال: abo / ah","e.g. abo / ah")
	NameBox.Font = Enum.Font.Gotham; NameBox.TextSize = 16
	NameBox.ClearTextOnFocus = false
	Instance.new("UICorner", NameBox).CornerRadius = UDim.new(0,10)

	local Btn = Instance.new("TextButton", P2)
	Btn.Size = UDim2.new(0,140,0,36)
	Btn.Position = UDim2.new(0,270,0,28)
	Btn.BackgroundColor3 = Color3.fromRGB(52,52,90)
	Btn.TextColor3 = Color3.new(1,1,1)
	Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 16
	Btn.Text = L("نسخ الآن","Copy Now")
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,10)

	AvatarImg = Instance.new("ImageLabel", P2)
	AvatarImg.Size = UDim2.new(0,100,0,100)
	AvatarImg.Position = UDim2.new(0,0,0,74)
	AvatarImg.BackgroundColor3 = Color3.fromRGB(28,28,28)
	AvatarImg.ScaleType = Enum.ScaleType.Fit
	Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(0,10)

	local info = Instance.new("TextLabel", P2)
	info.Size = UDim2.new(1,-20,0,22)
	info.Position = UDim2.new(0,0,0,182)
	info.BackgroundTransparency = 1
	info.Font = Enum.Font.Gotham
	info.TextSize = 12
	info.TextColor3 = Color3.fromRGB(200,200,200)
	info.Text = L("تلميح: يفضّل أن تكتب 3-4 حروف لتحديد اللاعب الصحيح.","Hint: Use 3-4 letters for better match.")

	Btn.MouseButton1Click:Connect(function()
		local txt = (NameBox.Text or ""):gsub("%s+","")
		if #txt < 2 then
			Status.Text = L("اكتب 2 حروف على الأقل ❗","Type at least 2 letters ❗")
			return
		end
		local ok, why = copyFromPrefix(txt)
		if ok then
			Status.Text = L("تم النسخ ✅","Copied ✅")
			notify(L("تم نسخ سكن اللاعب ✅","Player skin copied ✅"), 2)
		else
			if why=="notfound" then
				Status.Text = L("لاعب غير موجود ❌","Player not found ❌")
			else
				Status.Text = L("فشل النسخ ❌","Copy failed ❌")
			end
		end
	end)
end

--================= UTILITIES (Rejoin + Reset to Default) =================
do
	local y = 10

	local Rejoin = Instance.new("TextButton", P3)
	Rejoin.Size = UDim2.new(0,220,0,40)
	Rejoin.Position = UDim2.new(0,10,0,y)
	Rejoin.BackgroundColor3 = Color3.fromRGB(58,58,58)
	Rejoin.TextColor3 = Color3.new(1,1,1)
	Rejoin.Font = Enum.Font.GothamBold
	Rejoin.TextSize = 16
	Rejoin.Text = L("إعادة دخول السيرفر","Rejoin Same Server")
	Instance.new("UICorner", Rejoin).CornerRadius = UDim.new(0,10)
	y = y + 50

	Rejoin.MouseButton1Click:Connect(function()
		Status.Text = L("جاري إعادة الدخول…","Rejoining…")
		local ok = pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
		end)
		if not ok then
			TeleportService:Teleport(game.PlaceId, LP)
		end
	end)

	local ResetBtn = Instance.new("TextButton", P3)
	ResetBtn.Size = UDim2.new(0,220,0,40)
	ResetBtn.Position = UDim2.new(0,10,0,y)
	ResetBtn.BackgroundColor3 = Color3.fromRGB(58,58,58)
	ResetBtn.TextColor3 = Color3.new(1,1,1)
	ResetBtn.Font = Enum.Font.GothamBold
	ResetBtn.TextSize = 16
	ResetBtn.Text = L("رجوع للمظهر الحالي","Re-apply Current Look")
	Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0,10)
	y = y + 50

	ResetBtn.MouseButton1Click:Connect(function()
		local d = getCurrentDescription()
		if d then
			safeApplyDescription(d)
			Status.Text = L("تمت الإعادة ✅","Re-applied ✅")
		else
			Status.Text = L("لا يوجد وصف حالي ❌","No current description ❌")
		end
	end)

	local Hint = Instance.new("TextLabel", P3)
	Hint.Size = UDim2.new(1,-20,0,40)
	Hint.Position = UDim2.new(0,10,0,y)
	Hint.BackgroundTransparency = 1
	Hint.Font = Enum.Font.Gotham
	Hint.TextSize = 12
	Hint.TextColor3 = Color3.fromRGB(200,200,200)
	Hint.TextWrapped = true
	Hint.Text = L("ملاحظة: بعض الألعاب قد تمنع التغييرات. لو زر النسخ/التحول ماشتغلش جرّب تاني.","Note: Some experiences may restrict changes. If copy/transform fails, try again.")
end

--================= Splash (small) =================
do
	local Splash = Instance.new("Frame", Main)
	Splash.Size = UDim2.fromScale(1,1)
	Splash.BackgroundColor3 = Color3.fromRGB(10,10,10)
	Splash.BackgroundTransparency = .1
	Splash.ZIndex = 3
	Instance.new("UICorner", Splash).CornerRadius = UDim.new(0,16)

	local Txt = Instance.new("TextLabel", Splash)
	Txt.BackgroundTransparency = 1
	Txt.Size = UDim2.new(1,0,0,60)
	Txt.Position = UDim2.new(0,0,.44,-30)
	Txt.Font = Enum.Font.GothamBlack
	Txt.TextSize = 24
	Txt.TextColor3 = Color3.fromRGB(255,255,255)
	Txt.TextWrapped = true
	Txt.Text = L(("منوّر يا %s ✨\nسكربت الحكومة لتحوّلات ونسخ السكن 😁🍷"):format(LP.DisplayName),
	              ("Welcome %s ✨\nGovernment Transform & Skin 😁🍷"):format(LP.DisplayName))
	local cyc = rgbCycle(0.01)
	task.spawn(function() for _=1,40 do Txt.TextColor3 = cyc(); task.wait(0.05) end end)
	TweenService:Create(Splash, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 1.2), {BackgroundTransparency=1}):Play()
	task.wait(1.3)
	Splash:Destroy()
end

print("✅ Government Script Loaded - حقوق العم حكومه 😁🍷")
--========================================================--
```0
