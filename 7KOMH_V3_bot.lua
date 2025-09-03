-- V10 Ultra Max AutoTrack – Player Tracker
-- 「👑GS4」العم حكومه🍷

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--==================== UI ====================--
local gui = Instance.new("ScreenGui")
gui.Name = "GS4_Al3mHkoomh_V10"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 620, 0, 640) -- واجهة طويلة وكبيرة
frame.Position = UDim2.new(0.18, 0, 0.12, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, -20, 0, 54)
topBar.Position = UDim2.new(0, 10, 0, 10)
topBar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
topBar.BorderSizePixel = 0
topBar.Parent = frame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -16, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(0, 190, 255) -- أزرق
title.Text = "「👑GS4」العم حكومه🍷 — Player Tracker V10"
title.Parent = topBar

local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Size = UDim2.new(1, -20, 1, -74)
body.Position = UDim2.new(0, 10, 0, 64)
body.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = body

-- شريط البحث (خانة كتابة فقط – AutoTrack)
local tools = Instance.new("Frame")
tools.Size = UDim2.new(1, 0, 0, 48)
tools.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
tools.BorderSizePixel = 0
tools.Parent = body
Instance.new("UICorner", tools).CornerRadius = UDim.new(0, 10)

local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -20, 1, -10)
search.Position = UDim2.new(0, 10, 0, 5)
search.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
search.BorderSizePixel = 0
search.PlaceholderText = "اكتب أول حرفين على الأقل من اليوزر/اللقب… (AutoTrack)"
search.ClearTextOnFocus = false
search.Text = ""
search.TextColor3 = Color3.fromRGB(255, 255, 255)
search.PlaceholderColor3 = Color3.fromRGB(160, 160, 170)
search.Font = Enum.Font.Gotham
search.TextSize = 16
search.Parent = tools
Instance.new("UICorner", search).CornerRadius = UDim.new(0, 8)

-- بطاقة اللاعب
local card = Instance.new("Frame")
card.Size = UDim2.new(1, 0, 0, 160)
card.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
card.BorderSizePixel = 0
card.Parent = body
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 110, 0, 110)
avatar.Position = UDim2.new(0, 14, 0, 14)
avatar.BackgroundTransparency = 1
avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
avatar.Parent = card

local username = Instance.new("TextLabel")
username.BackgroundTransparency = 1
username.Size = UDim2.new(1, -150, 0, 36)
username.Position = UDim2.new(0, 140, 0, 16)
username.Font = Enum.Font.GothamBold
username.TextSize = 20
username.TextXAlignment = Enum.TextXAlignment.Left
username.TextColor3 = Color3.fromRGB(0, 200, 255)
username.Text = "👤 اليوزر: —"
username.Parent = card

local displayName = Instance.new("TextLabel")
displayName.BackgroundTransparency = 1
displayName.Size = UDim2.new(1, -150, 0, 30)
displayName.Position = UDim2.new(0, 140, 0, 54)
displayName.Font = Enum.Font.Gotham
displayName.TextSize = 18
displayName.TextXAlignment = Enum.TextXAlignment.Left
displayName.TextColor3 = Color3.fromRGB(230, 230, 235)
displayName.Text = "🏷️ اللقب: —"
displayName.Parent = card

local times = Instance.new("TextLabel")
times.BackgroundTransparency = 1
times.Size = UDim2.new(1, -150, 0, 30)
times.Position = UDim2.new(0, 140, 0, 90)
times.Font = Enum.Font.Gotham
times.TextSize = 15
times.TextXAlignment = Enum.TextXAlignment.Left
times.TextColor3 = Color3.fromRGB(180, 200, 255)
times.Text = "🕒 دخل: —   |   ⏳ تتبع من: —"
times.Parent = card

-- صندوق السجل (طويل + Scroll)
local logBox = Instance.new("ScrollingFrame")
logBox.Size = UDim2.new(1, 0, 1, -180)
logBox.CanvasSize = UDim2.new(0, 0, 0, 0)
logBox.ScrollBarThickness = 6
logBox.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
logBox.BorderSizePixel = 0
logBox.Parent = body
Instance.new("UICorner", logBox).CornerRadius = UDim.new(0, 10)

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 6)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = logBox

--==================== DATA ====================--
local trackedPlayer = nil
local trackStart = nil
local joinTimes = {} -- userId -> os.time() لوقت الدخول

-- تجهيز الموجودين حالاً
for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		joinTimes[plr.UserId] = joinTimes[plr.UserId] or os.time()
	end
end

--==================== HELPERS ====================--
local function fmt(t)
	return os.date("%X", t)
end

local function addLog(text, color3)
	local line = Instance.new("TextLabel")
	line.BackgroundTransparency = 1
	line.Font = Enum.Font.Code
	line.TextSize = 15
	line.TextXAlignment = Enum.TextXAlignment.Left
	line.TextYAlignment = Enum.TextYAlignment.Center
	line.TextWrapped = true
	line.Text = "[" .. os.date("%X") .. "] " .. text
	line.Size = UDim2.new(1, -14, 0, 22)
	line.TextColor3 = color3 or Color3.fromRGB(220, 255, 235)
	line.Parent = logBox
	task.wait()
	logBox.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 20)
	logBox.CanvasPosition = Vector2.new(0, math.max(0, logBox.CanvasSize.Y.Offset - logBox.AbsoluteWindowSize.Y))
end

local function bestMatch(query)
	query = (query or ""):lower()
	if #query < 2 then return nil end -- من أول حرفين
	local best, rank
	local function score(plr)
		local n, d = plr.Name:lower(), plr.DisplayName:lower()
		if n:sub(1, #query) == query then return 1 end
		if d:sub(1, #query) == query then return 2 end
		if string.find(n, query, 1, true) then return 3 end
		if string.find(d, query, 1, true) then return 4 end
		return math.huge
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local s = score(plr)
			if s < math.huge and (not best or s < rank) then
				best, rank = plr, s
			end
		end
	end
	return best
end

local function setAvatar(userId)
	local ok, url, _ = pcall(Players.GetUserThumbnailAsync, Players, userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	if ok and url then
		avatar.Image = url
	end
end

local function updateCard(plr)
	if not plr then
		username.Text = "👤 اليوزر: —"
		displayName.Text = "🏷️ اللقب: —"
		times.Text = "🕒 دخل: —   |   ⏳ تتبع من: —"
		avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		return
	end
	username.Text = "👤 اليوزر: " .. plr.Name
	displayName.Text = "🏷️ اللقب: " .. (plr.DisplayName or "—")
	local jt = joinTimes[plr.UserId]
	local ts = trackStart
	times.Text = string.format("🕒 دخل: %s   |   ⏳ تتبع من: %s", jt and fmt(jt) or "—", ts and fmt(ts) or "—")
	setAvatar(plr.UserId)
end

local function startTracking(plr)
	if trackedPlayer ~= plr then
		trackedPlayer = plr
		trackStart = os.time()
		updateCard(plr)
		addLog("بدء تتبع: " .. plr.Name, Color3.fromRGB(120, 255, 120))
	end
end

--==================== AUTOTRACK ====================--
local lastQ = ""
local typingDebounce = false

local function onQueryChanged()
	if typingDebounce then return end
	typingDebounce = true
	task.delay(0.08, function() typingDebounce = false end)

	local q = search.Text or ""
	if q == lastQ then return end
	lastQ = q

	local plr = bestMatch(q)
	if plr then startTracking(plr) end
end

search:GetPropertyChangedSignal("Text"):Connect(onQueryChanged)
search.FocusLost:Connect(function(enter) if enter then onQueryChanged() end end)

--==================== EVENTS ====================--
Players.PlayerAdded:Connect(function(plr)
	joinTimes[plr.UserId] = os.time()
	addLog("دخول: " .. plr.Name, Color3.fromRGB(0, 200, 255))
	if trackedPlayer and plr.Name == trackedPlayer.Name then
		updateCard(plr)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	addLog("خروج: " .. plr.Name, Color3.fromRGB(255, 90, 90))
	if trackedPlayer and plr.Name == trackedPlayer.Name then
		times.Text = (times.Text .. "   |   🚪 خرج: " .. os.date("%X"))
	end
end)

-- عدّاد زمن التتبع الظاهر على البطاقة
local acc = 0
RunService.Heartbeat:Connect(function(dt)
	acc += dt
	if acc >= 1 then
		acc = 0
		if trackedPlayer and trackStart then
			local elapsed = os.time() - trackStart
			local h = math.floor(elapsed / 3600)
			local m = math.floor((elapsed % 3600) / 60)
			local s = elapsed % 60
			local jt = joinTimes[trackedPlayer.UserId]
			times.Text = string.format("🕒 دخل: %s   |   ⏳ تتبع من: %s   |   ⏲️ %02d:%02d:%02d",
				jt and fmt(jt) or "—",
				fmt(trackStart),
				h, m, s
			)
		end
	end
end)
