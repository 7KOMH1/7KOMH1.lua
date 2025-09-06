--[[ 
  تتبّع 4 لاعبين — واجهة متوسطة/صغيرة + بحث من أول حرفين
  العنوان: EG | حكومه     الحقوق: العم حكومه 🍷 (أزرق)
  المزايا:
    • التقاط من أول حرفين لاسم المستخدم أو اللقب (DisplayName)
    • قائمة اقتراحات سريعة لكل خانة
    • صورة أفاتار فورية بدقة متوسطة
    • عدّاد دخول/خروج + ✅❌
    • مؤقّت للمدة منذ آخر دخول
    • أصوات عند الدخول/الخروج
    • تنظيف اتصالات + أداء خفيف
  ضع السكربت كـ LocalScript داخل StarterPlayerScripts
]]--

----------------------------
-- الخدمات والخامات
----------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

----------------------------
-- إعداد واجهة
----------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "EGTrackerUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ألوان
local col = {
  bg = Color3.fromRGB(18,18,20),
  panel = Color3.fromRGB(28,28,32),
  header = Color3.fromRGB(24,24,28),
  stroke = Color3.fromRGB(60,60,68),
  txt = Color3.fromRGB(230,230,235),
  accent = Color3.fromRGB(35,140,255), -- أزرق
  good = Color3.fromRGB(45, 200, 90),
  bad  = Color3.fromRGB(220, 60, 70),
  dim  = Color3.fromRGB(160,160,170),
}

-- إطار رئيسي (متوسط-صغير)
local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5,0.5)
root.Size = UDim2.new(0, 940, 0, 520) -- عرض وارتفاع مناسبين
root.Position = UDim2.new(0.5,0,0.5,0)
root.BackgroundColor3 = col.bg
root.BorderSizePixel = 0
root.Parent = gui

local rootCorner = Instance.new("UICorner", root)
rootCorner.CornerRadius = UDim.new(0,18)

local rootStroke = Instance.new("UIStroke", root)
rootStroke.Thickness = 1
rootStroke.Color = col.stroke
rootStroke.Transparency = 0.2

-- رأس علوي (العنوان)
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, -24, 0, 58)
header.Position = UDim2.new(0, 12, 0, 12)
header.BackgroundColor3 = col.header
header.BorderSizePixel = 0
header.Parent = root
Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)
local hStroke = Instance.new("UIStroke", header)
hStroke.Thickness = 1
hStroke.Color = col.stroke
hStroke.Transparency = 0.25

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "EG | حكومه  🍷"
title.Font = Enum.Font.GothamBold
title.TextSize = 30
title.TextColor3 = col.accent
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- سطر الحقوق تحت العنوان مع فاصل
local rightsBar = Instance.new("Frame")
rightsBar.Name = "RightsBar"
rightsBar.Size = UDim2.new(1, -24, 0, 36)
rightsBar.Position = UDim2.new(0, 12, 0, 12+58+8)
rightsBar.BackgroundColor3 = col.header
rightsBar.BorderSizePixel = 0
rightsBar.Parent = root
Instance.new("UICorner", rightsBar).CornerRadius = UDim.new(0,12)
local rStroke = Instance.new("UIStroke", rightsBar)
rStroke.Thickness = 1
rStroke.Color = col.stroke
rStroke.Transparency = 0.25

local rightsLbl = Instance.new("TextLabel")
rightsLbl.BackgroundTransparency = 1
rightsLbl.Size = UDim2.new(1, -20, 1, 0)
rightsLbl.Position = UDim2.new(0, 10, 0, 0)
rightsLbl.Font = Enum.Font.GothamMedium
rightsLbl.TextSize = 20
rightsLbl.TextColor3 = col.accent
rightsLbl.TextXAlignment = Enum.TextXAlignment.Left
rightsLbl.Text = "العم حكومه 🍷"
rightsLbl.Parent = rightsBar

-- شبكة البطاقات 2×2
local grid = Instance.new("Frame")
grid.Name = "Grid"
grid.BackgroundTransparency = 1
grid.Size = UDim2.new(1, -24, 1, -(12+58+8+36+18))
grid.Position = UDim2.new(0, 12, 0, 12+58+8+36+8)
grid.Parent = root

local uiGrid = Instance.new("UIGridLayout", grid)
uiGrid.CellPadding = UDim2.new(0, 14, 0, 14)
uiGrid.CellSize = UDim2.new(0.5, -7, 0.5, -7)

----------------------------
-- أصوات دخول/خروج
----------------------------
local sndJoin = Instance.new("Sound")
sndJoin.SoundId = "rbxassetid://8214392736" -- نغمة خفيفة
sndJoin.Volume = 0.4
sndJoin.Parent = gui

local sndLeave = Instance.new("Sound")
sndLeave.SoundId = "rbxassetid://6403362031" -- نقرة خفيفة
sndLeave.Volume = 0.45
sndLeave.Parent = gui

----------------------------
-- أدوات مساعدة
----------------------------
local function smallLabel(parent, text, sz, color)
  local l = Instance.new("TextLabel")
  l.BackgroundTransparency = 1
  l.Font = Enum.Font.GothamMedium
  l.TextXAlignment = Enum.TextXAlignment.Left
  l.TextYAlignment = Enum.TextYAlignment.Center
  l.Text = text or ""
  l.TextSize = sz or 18
  l.TextColor3 = color or col.txt
  l.Parent = parent
  return l
end

local function makeStroke(inst)
  local s = Instance.new("UIStroke", inst)
  s.Thickness = 1
  s.Color = col.stroke
  s.Transparency = 0.25
  return s
end

local function getAvatarAsync(userId)
  local ok, img, isReady = pcall(function()
    return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
  end)
  if ok and img then
    return img
  end
  return "rbxassetid://0"
end

-- فلترة سريعة: من أول حرفين أو أكثر, على Username أو DisplayName
local function searchPlayers(query)
  local results = {}
  if not query or #query < 2 then
    return results
  end
  local q = string.lower(query)
  for _, plr in ipairs(Players:GetPlayers()) do
    local u = string.lower(plr.Name or "")
    local d = string.lower(plr.DisplayName or "")
    if string.find(u, q, 1, true) or string.find(d, q, 1, true) then
      table.insert(results, plr)
    end
  end
  return results
end

----------------------------
-- إنشاء بطاقة لاعب
----------------------------
local Card = {}
Card.__index = Card

function Card.new(id)
  local self = setmetatable({}, Card)
  self.id = id
  self.boundPlayer = nil
  self.connections = {}
  self.joins = 0
  self.leaves = 0
  self.lastJoinTick = 0
  self.running = false

  local card = Instance.new("Frame")
  card.Name = "Card"..id
  card.BackgroundColor3 = col.panel
  card.BorderSizePixel = 0
  card.Parent = grid
  Instance.new("UICorner", card).CornerRadius = UDim.new(0,14)
  makeStroke(card)

  -- شريط علوي صغير للبحث + الاسم المختار
  local top = Instance.new("Frame")
  top.Name = "Top"
  top.BackgroundColor3 = col.bg
  top.BorderSizePixel = 0
  top.Size = UDim2.new(1, -16, 0, 44)
  top.Position = UDim2.new(0, 8, 0, 8)
  top.Parent = card
  Instance.new("UICorner", top).CornerRadius = UDim.new(0,10)
  makeStroke(top)

  local search = Instance.new("TextBox")
  search.Name = "Search"
  search.BackgroundTransparency = 1
  search.Size = UDim2.new(1, -12, 1, 0)
  search.Position = UDim2.new(0, 6, 0, 0)
  search.Font = Enum.Font.Gotham
  search.TextSize = 20
  search.TextColor3 = col.txt
  search.PlaceholderText = "" -- فاضي زي طلبك
  search.Text = ""
  search.ClearTextOnFocus = false
  search.Parent = top

  -- قائمة اقتراحات
  local suggest = Instance.new("Frame")
  suggest.Name = "Suggest"
  suggest.Visible = false
  suggest.BackgroundColor3 = col.header
  suggest.BorderSizePixel = 0
  suggest.Size = UDim2.new(1, -16, 0, 150)
  suggest.Position = UDim2.new(0, 8, 0, 8+44+6)
  suggest.Parent = card
  Instance.new("UICorner", suggest).CornerRadius = UDim.new(0,10)
  makeStroke(suggest)

  local list = Instance.new("UIListLayout", suggest)
  list.Padding = UDim.new(0,6)
  list.FillDirection = Enum.FillDirection.Vertical
  list.SortOrder = Enum.SortOrder.LayoutOrder

  -- محتوى البطاقة
  local content = Instance.new("Frame")
  content.Name = "Content"
  content.BackgroundTransparency = 1
  content.Size = UDim2.new(1, -16, 1, - (8+44+8+54)) -- اترك مساحة للأسفل للعداد والوقت
  content.Position = UDim2.new(0, 8, 0, 8+44+8)
  content.Parent = card

  local avatar = Instance.new("ImageLabel")
  avatar.Name = "Avatar"
  avatar.Size = UDim2.new(0, 60, 0, 60)
  avatar.Position = UDim2.new(0, 10, 0, 6)
  avatar.BackgroundColor3 = col.bg
  avatar.BorderSizePixel = 0
  avatar.Parent = content
  Instance.new("UICorner", avatar).CornerRadius = UDim.new(1,0)
  makeStroke(avatar)

  local dot = Instance.new("Frame")
  dot.Size = UDim2.new(0,10,0,10)
  dot.Position = UDim2.new(0, 60+14, 0, 8)
  dot.BackgroundColor3 = Color3.fromRGB(0,200,80)
  dot.BorderSizePixel = 0
  dot.Parent = content
  Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

  local userLbl = smallLabel(content, " - يوزر:", 22, col.accent)
  userLbl.Position = UDim2.new(0, 60+30, 0, 4)
  userLbl.Size = UDim2.new(1, - (60+40), 0, 26)

  local dispLbl = smallLabel(content, " - لقب:", 22, col.accent)
  dispLbl.Position = UDim2.new(0, 60+30, 0, 34)
  dispLbl.Size = UDim2.new(1, - (60+40), 0, 26)

  -- شريط سفلي: دخول/خروج + وقت
  local bottom = Instance.new("Frame")
  bottom.Name = "Bottom"
  bottom.BackgroundColor3 = col.bg
  bottom.BorderSizePixel = 0
  bottom.Size = UDim2.new(1, -16, 0, 48)
  bottom.Position = UDim2.new(0, 8, 1, - (48+8))
  bottom.Parent = card
  Instance.new("UICorner", bottom).CornerRadius = UDim.new(0,10)
  makeStroke(bottom)

  local joinLbl = smallLabel(bottom, "0 :دخول ✅", 20, col.good)
  joinLbl.Position = UDim2.new(0, 10, 0, 4)
  joinLbl.Size = UDim2.new(0.33, -10, 1, -8)

  local leaveLbl = smallLabel(bottom, "0 :خروج ❌", 20, col.bad)
  leaveLbl.Position = UDim2.new(0.33, 0, 0, 4)
  leaveLbl.Size = UDim2.new(0.33, -10, 1, -8)

  local timeLbl = smallLabel(bottom, "الوقت: 00:00 ⏱️", 20, col.txt)
  timeLbl.Position = UDim2.new(0.66, 0, 0, 4)
  timeLbl.Size = UDim2.new(0.34, -10, 1, -8)
  timeLbl.TextXAlignment = Enum.TextXAlignment.Right

  -- حفظ المراجع
  self.card = card
  self.search = search
  self.suggest = suggest
  self.avatar = avatar
  self.userLbl = userLbl
  self.dispLbl = dispLbl
  self.joinLbl = joinLbl
  self.leaveLbl = leaveLbl
  self.timeLbl = timeLbl
  self.dot = dot

  -- تفاعل البحث
  local function clearSuggest()
    for _, ch in ipairs(suggest:GetChildren()) do
      if ch:IsA("TextButton") then ch:Destroy() end
    end
  end

  local lastQuery = ""
  local function refreshSuggest()
    local q = search.Text or ""
    if #q < 2 then
      suggest.Visible = false
      clearSuggest()
      return
    end
    if q == lastQuery then return end
    lastQuery = q
    clearSuggest()
    local results = searchPlayers(q)
    for i, plr in ipairs(results) do
      if i > 6 then break end
      local btn = Instance.new("TextButton")
      btn.BackgroundColor3 = col.panel
      btn.AutoButtonColor = true
      btn.Size = UDim2.new(1, -8, 0, 30)
      btn.TextXAlignment = Enum.TextXAlignment.Left
      btn.Font = Enum.Font.Gotham
      btn.TextSize = 18
      btn.TextColor3 = col.txt
      btn.Text = string.format("  %s  -  %s", plr.DisplayName, plr.Name)
      btn.Parent = suggest
      Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
      makeStroke(btn)

      btn.MouseButton1Click:Connect(function()
        suggest.Visible = false
        self:BindToPlayer(plr)
      end)
    end
    suggest.Visible = (#results > 0)
  end

  table.insert(self.connections, search:GetPropertyChangedSignal("Text"):Connect(refreshSuggest))
  table.insert(self.connections, search.Focused:Connect(refreshSuggest))
  table.insert(self.connections, search.FocusLost:Connect(function(enter)
    task.defer(function() suggest.Visible = false end)
  end))

  return self
end

-- تنسيق الوقت mm:ss
local function formatTime(secs)
  secs = math.max(0, math.floor(secs))
  local m = math.floor(secs / 60)
  local s = secs % 60
  return string.format("%02d:%02d", m, s)
end

function Card:Unbind()
  self.boundPlayer = nil
  self.userLbl.Text = " - يوزر:"
  self.dispLbl.Text = " - لقب:"
  self.avatar.Image = ""
  self.joins = 0
  self.leaves = 0
  self.joinLbl.Text = "0 :دخول ✅"
  self.leaveLbl.Text = "0 :خروج ❌"
  self.timeLbl.Text = "الوقت: 00:00 ⏱️"
  self.dot.BackgroundColor3 = Color3.fromRGB(120,120,120)
  for _, c in ipairs(self.connections) do
    -- نترك اتصالات البحث؛ نفصل اتصالات اللاعب فقط
  end
  if self.charConn then self.charConn:Disconnect() self.charConn = nil end
  if self.remConn then self.remConn:Disconnect() self.remConn = nil end
  self.running = false
end

function Card:BindToPlayer(plr)
  if self.boundPlayer == plr then return end
  self:Unbind()
  self.boundPlayer = plr
  self.search.Text = plr.Name
  self.userLbl.Text = " - يوزر:  " .. (plr.Name or "-")
  self.dispLbl.Text = " - لقب:  " .. (plr.DisplayName or "-")

  -- صورة
  task.spawn(function()
    local img = getAvatarAsync(plr.UserId)
    self.avatar.Image = img
  end)

  -- حالة متصل؟
  local function updatePresence(isOnline)
    self.dot.BackgroundColor3 = isOnline and Color3.fromRGB(0,200,80) or Color3.fromRGB(170,60,60)
  end

  updatePresence(true)

  -- عداد دخول/خروج ووقت
  local function onJoin()
    self.joins += 1
    self.lastJoinTick = os.clock()
    self.joinLbl.Text = string.format("%d :دخول ✅", self.joins)
    sndJoin:Play()
    updatePresence(true)
    self.running = true
  end

  local function onLeave()
    self.leaves += 1
    self.leaveLbl.Text = string.format("%d :خروج ❌", self.leaves)
    sndLeave:Play()
    updatePresence(false)
    self.running = false
  end

  -- اعتبره "دخل" لو عنده شخصية الآن
  if plr.Character then onJoin() end

  -- وصل/فصل شخصية
  self.charConn = plr.CharacterAdded:Connect(onJoin)

  -- لو اللاعب خرج من السيرفر
  self.remConn = Players.PlayerRemoving:Connect(function(p)
    if self.boundPlayer and p == self.boundPlayer then
      onLeave()
    end
  end)

  -- تحديث الوقت كل ثانية
  task.spawn(function()
    local myToken = HttpService:GenerateGUID(false)
    self._timerToken = myToken
    while self._timerToken == myToken do
      if self.running then
        local t = os.clock() - (self.lastJoinTick or os.clock())
        self.timeLbl.Text = "الوقت: " .. formatTime(t) .. " ⏱️"
      end
      task.wait(1)
      if not self.boundPlayer then break end
    end
  end)
end

function Card:Destroy()
  self:Unbind()
  for _, c in ipairs(self.connections) do
    c:Disconnect()
  end
  self.card:Destroy()
end

----------------------------
-- إنشاء الأربع بطاقات
----------------------------
local cards = {}
for i=1,4 do
  cards[i] = Card.new(i)
end

----------------------------
-- متابعة تغيرات قائمة اللاعبين (لتسريع الاقتراحات)
----------------------------
local rosterChanged = Instance.new("BoolValue")
rosterChanged.Value = false

local function pokeRoster()
  rosterChanged.Value = not rosterChanged.Value
end

Players.PlayerAdded:Connect(function()
  pokeRoster()
end)
Players.PlayerRemoving:Connect(function()
  pokeRoster()
end)

-- تلميحة بسيطة عند أول تشغيل
do
  local tip = Instance.new("TextLabel")
  tip.BackgroundTransparency = 1
  tip.Text = "اكتب أول حرفين من اسم اللاعب أو لقبه داخل أي مربع للربط السريع"
  tip.Font = Enum.Font.Gotham
  tip.TextSize = 16
  tip.TextColor3 = col.dim
  tip.Position = UDim2.new(0.5,0,1,-22)
  tip.AnchorPoint = Vector2.new(0.5,1)
  tip.Parent = root
  tip.Visible = true
  task.delay(5, function() if tip then tip:Destroy() end end)
end

-- حركة دخول بسيطة للواجهة
root.Position = UDim2.new(0.5,0,0.5,10)
root.Visible = true
TweenService:Create(root, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,0,0.5,0)}):Play()
