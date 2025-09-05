--[[ 
    📌 حقوق العم حكومه🍷  |  📌 كلان GS4
    نسخة نهائية — تتبع 4 لاعبين | واجهة عربية | استجابة عالية | دقة اعتمادًا على UserId
    • 2×2 خانات تتبع: بحث فوري (من أول حرفين+) باليوزر أو اللقب
    • يظهر اسم المستخدم + اللقب + صورة الأفاتار + عداد دخول/خروج + سجل مصغّر
    • زر فتح/إخفاء صغير قابل للسحب + اللوحة قابلة للسحب
    • توست/رسالة قصيرة عند الدخول/الخروج + أصوات
    • ديباونس للبحث + حماية pcall + تنظيف آمن
]]--

--========================[ خدمات ]========================
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local LocalPlayer  = Players.LocalPlayer

--========================[ ألوان وثيم ]========================
local COLORS = {
    bg      = Color3.fromRGB(16,16,16),
    panel   = Color3.fromRGB(24,24,26),
    panel2  = Color3.fromRGB(32,32,36),
    stroke  = Color3.fromRGB(52,52,58),
    text    = Color3.fromRGB(230,230,235),
    blue    = Color3.fromRGB(0,142,255), -- حقوق/عناوين
    green   = Color3.fromRGB(0,210,120),
    red     = Color3.fromRGB(235,70,70),
    dim     = Color3.fromRGB(160,165,175),
}

--========================[ UI Helpers ]========================
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = obj
    return c
end

local function stroke(obj, th, col, tr)
    local s = Instance.new("UIStroke")
    s.Thickness = th or 1
    s.Color = col or COLORS.stroke
    s.Transparency = tr or 0.15
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function padding(obj, l,t,r,b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, l or 10)
    p.PaddingTop    = UDim.new(0, t or 10)
    p.PaddingRight  = UDim.new(0, r or 10)
    p.PaddingBottom = UDim.New(0, b or 10)
    p.Parent = obj
    return p
end

--========================[ أصوات ]========================
local function makeSound(id, vol, spd)
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = vol or 0.5
    s.PlaybackSpeed = spd or 1
    s.Parent = SoundService
    return s
end
local SFX_JOIN  = makeSound("rbxassetid://9118823107", 0.5, 1.06)
local SFX_LEAVE = makeSound("rbxassetid://4590657391", 0.5, 0.98)
local function playSafe(s) pcall(function() s:Play() end) end

--========================[ ScreenGui + زر التبديل ]========================
local gui = Instance.new("ScreenGui")
gui.Name = "HKOMA_GS4_Tracker"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- زر صغير (3 شرطات) قابل للسحب
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "Toggle"
toggleBtn.Parent = gui
toggleBtn.Size = UDim2.fromOffset(32,32)
toggleBtn.Position = UDim2.new(0.06,0,0.25,0)
toggleBtn.BackgroundColor3 = COLORS.panel2
toggleBtn.Image = "rbxassetid://0"
toggleBtn.AutoButtonColor = true
toggleBtn.ZIndex = 50
corner(toggleBtn, 8)
stroke(toggleBtn, 1, COLORS.stroke, 0.3)

for i=1,3 do
    local bar = Instance.new("Frame")
    bar.Parent = toggleBtn
    bar.BackgroundColor3 = COLORS.text
    bar.BorderSizePixel = 0
    bar.AnchorPoint = Vector2.new(0.5,0.5)
    bar.Position = UDim2.new(0.5,0,(i==1 and 0.3) or (i==2 and 0.5) or 0.7,0)
    bar.Size = UDim2.new(0.65,0,0,2)
    corner(bar, 2)
end

-- سحب الزر
do
    local dragging, dragStart, startPos
    toggleBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos  = toggleBtn.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    toggleBtn.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

--========================[ اللوحة الرئيسية ]========================
local root = Instance.new("Frame")
root.Name = "Root"
root.Parent = gui
root.BackgroundColor3 = COLORS.bg
root.BorderSizePixel = 0
root.Size = UDim2.new(0, 540, 0, 320)  -- متوسط-صغير
root.Position = UDim2.new(0.5, -270, 0.5, -160)
corner(root, 14); stroke(root, 1, COLORS.stroke, 0.22); padding(root, 10,10,10,10)

-- سحب اللوحة
do
    local dragging, dragStart, startPos
    root.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos  = root.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    root.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- إظهار/إخفاء
local isOpen = true
local function setOpen(v) isOpen=v; root.Visible=v end
toggleBtn.MouseButton1Click:Connect(function() setOpen(not isOpen) end)

--========================[ الهيدر ]========================
local header = Instance.new("Frame")
header.Parent = root
header.BackgroundColor3 = COLORS.panel2
header.BorderSizePixel = 0
header.Size = UDim2.new(1,0,0,56)
corner(header, 12); stroke(header, 1, COLORS.stroke, 0.18)

local rights = Instance.new("TextLabel")
rights.Parent = header
rights.BackgroundTransparency = 1
rights.Size = UDim2.new(1,-20,0.5,0)
rights.Position = UDim2.new(0,10,0,0)
rights.Font = Enum.Font.GothamBold
rights.TextXAlignment = Enum.TextXAlignment.Center
rights.Text = "حقوق العم حكومه🍷"
rights.TextColor3 = COLORS.blue
rights.TextScaled = true

local clan = Instance.new("TextLabel")
clan.Parent = header
clan.BackgroundTransparency = 1
clan.Size = UDim2.new(1,-20,0.5,0)
clan.Position = UDim2.new(0,10,0.5,0) -- فاصل واضح
clan.Font = Enum.Font.GothamBold
clan.TextXAlignment = Enum.TextXAlignment.Center
clan.Text = "كلان GS4"
clan.TextColor3 = COLORS.blue
clan.TextScaled = true

--========================[ شبكة 2×2 ]========================
local grid = Instance.new("Frame")
grid.Parent = root
grid.BackgroundTransparency = 1
grid.Size = UDim2.new(1,0,1,-(56+8))
grid.Position = UDim2.new(0,0,0,56+8)

local uiGrid = Instance.new("UIGridLayout")
uiGrid.Parent = grid
uiGrid.CellPadding = UDim2.fromOffset(8,8)
uiGrid.CellSize   = UDim2.new(0.5, -8, 0.5, -8)
uiGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiGrid.VerticalAlignment   = Enum.VerticalAlignment.Top
uiGrid.SortOrder = Enum.SortOrder.LayoutOrder

--========================[ توست مصغّر ]========================
local function toast(msg, color)
    local t = Instance.new("TextLabel")
    t.Parent = root
    t.BackgroundColor3 = COLORS.panel2
    t.BorderSizePixel = 0
    t.AnchorPoint = Vector2.new(0.5,1)
    t.Position = UDim2.new(0.5,0,1,-6)
    t.Size = UDim2.fromOffset(460,28)
    t.Text = msg
    t.TextColor3 = color or COLORS.text
    t.TextScaled = true
    t.Font = Enum.Font.GothamSemibold
    t.TextTransparency = 1
    corner(t, 10); stroke(t, 1, COLORS.stroke, 0.35)
    TweenService:Create(t, TweenInfo.new(0.15), {TextTransparency = 0, BackgroundTransparency = 0.05}):Play()
    task.delay(1.2, function()
        TweenService:Create(t, TweenInfo.new(0.2), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.delay(0.22, function() t:Destroy() end)
    end)
end

--========================[ ديباونس إدخال ]========================
local function makeDebouncer(waitSec)
    local last = 0
    return function(cb)
        local now = tick()
        if now - last >= (waitSec or 0.06) then
            last = now
            cb()
        end
    end
end

--========================[ كيان خانة تتبع ]========================
local Slot = {}
Slot.__index = Slot

function Slot.new(idx)
    local self = setmetatable({}, Slot)
    self.index = idx
    self.targetUserId = nil
    self.targetName   = nil
    self.targetDisp   = nil
    self.joins, self.leaves = 0, 0
    self.startedAt = nil
    self.sessionLog = {} -- سجل بسيط للاستعراض

    -- البطاقة
    local card = Instance.new("Frame")
    card.Name = "Slot"..idx
    card.Parent = grid
    card.BackgroundColor3 = COLORS.panel
    card.BorderSizePixel = 0
    corner(card, 12); stroke(card, 1, COLORS.stroke, 0.2); padding(card, 8,8,8,8)
    self.card = card

    -- الشريط العلوي: إدخال (فاضي)
    local top = Instance.new("Frame")
    top.Parent = card
    top.BackgroundColor3 = COLORS.panel2
    top.BorderSizePixel = 0
    top.Size = UDim2.new(1,0,0,34)
    corner(top, 10); stroke(top, 1, COLORS.stroke, 0.12)

    local input = Instance.new("TextBox")
    input.Parent = top
    input.BackgroundTransparency = 1
    input.ClearTextOnFocus = false
    input.Size = UDim2.new(1,-10,1,0)
    input.Position = UDim2.new(0,5,0,0)
    input.Text = "" -- فاضي
    input.PlaceholderText = ""
    input.TextColor3 = COLORS.text
    input.Font = Enum.Font.GothamSemibold
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.TextScaled = true
    self.input = input

    -- جسم البطاقة
    local body = Instance.new("Frame")
    body.Parent = card
    body.BackgroundTransparency = 1
    body.Size = UDim2.new(1,0,1,-(34+6))
    body.Position = UDim2.new(0,0,0,34+6)

    local layout = Instance.new("UIListLayout")
    layout.Parent = body
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment   = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0,8)

    -- يسار: أفاتار
    local left = Instance.new("Frame")
    left.Parent = body
    left.BackgroundTransparency = 1
    left.Size = UDim2.new(0,86,1,0)

    local avatar = Instance.new("ImageLabel")
    avatar.Parent = left
    avatar.BackgroundColor3 = COLORS.panel2
    avatar.BorderSizePixel = 0
    avatar.Size = UDim2.fromOffset(86,86)
    avatar.Image = "rbxassetid://0"
    corner(avatar, 10); stroke(avatar, 1, COLORS.stroke, 0.18)
    self.avatar = avatar

    -- يمين: بيانات
    local right = Instance.new("Frame")
    right.Parent = body
    right.BackgroundTransparency = 1
    right.Size = UDim2.new(1, -96, 1, 0)

    local info = Instance.new("Frame")
    info.Parent = right
    info.BackgroundColor3 = COLORS.panel2
    info.BorderSizePixel = 0
    info.Size = UDim2.new(1,0,0,56)
    corner(info, 10); stroke(info, 1, COLORS.stroke, 0.12)
    padding(info, 8,6,8,6)

    local userLbl = Instance.new("TextLabel")
    userLbl.Parent = info
    userLbl.BackgroundTransparency = 1
    userLbl.Size = UDim2.new(1,0,0.5,0)
    userLbl.Position = UDim2.new(0,0,0,0)
    userLbl.Font = Enum.Font.GothamBold
    userLbl.TextScaled = true
    userLbl.TextXAlignment = Enum.TextXAlignment.Left
    userLbl.TextColor3 = COLORS.blue
    userLbl.Text = "اسم المستخدم: -"
    self.userLbl = userLbl

    local dispLbl = Instance.new("TextLabel")
    dispLbl.Parent = info
    dispLbl.BackgroundTransparency = 1
    dispLbl.Size = UDim2.new(1,0,0.5,0)
    dispLbl.Position = UDim2.new(0,0,0.5,0)
    dispLbl.Font = Enum.Font.GothamSemibold
    dispLbl.TextScaled = true
    dispLbl.TextXAlignment = Enum.TextXAlignment.Left
    dispLbl.TextColor3 = COLORS.text
    dispLbl.Text = "اللقب: -"
    self.dispLbl = dispLbl

    local stats = Instance.new("Frame")
    stats.Parent = right
    stats.BackgroundTransparency = 1
    stats.Size = UDim2.new(1,0,0,28)
    stats.Position = UDim2.new(0,0,0,56+6)

    local joinLbl = Instance.new("TextLabel")
    joinLbl.Parent = stats
    joinLbl.BackgroundTransparency = 1
    joinLbl.Font = Enum.Font.GothamBold
    joinLbl.TextScaled = true
    joinLbl.TextXAlignment = Enum.TextXAlignment.Left
    joinLbl.TextColor3 = COLORS.green
    joinLbl.Size = UDim2.new(0.5,-4,1,0)
    joinLbl.Position = UDim2.new(0,0,0,0)
    joinLbl.Text = "دخول: 0"
    self.joinLbl = joinLbl

    local leaveLbl = Instance.new("TextLabel")
    leaveLbl.Parent = stats
    leaveLbl.BackgroundTransparency = 1
    leaveLbl.Font = Enum.Font.GothamBold
    leaveLbl.TextScaled = true
    leaveLbl.TextXAlignment = Enum.TextXAlignment.Right
    leaveLbl.TextColor3 = COLORS.red
    leaveLbl.Size = UDim2.new(0.5,-4,1,0)
    leaveLbl.Position = UDim2.new(0.5,8,0,0)
    leaveLbl.Text = "خروج: 0"
    self.leaveLbl = leaveLbl

    -- سجل مصغر
    local logBox = Instance.new("TextLabel")
    logBox.Parent = right
    logBox.BackgroundColor3 = COLORS.panel2
    logBox.BorderSizePixel = 0
    logBox.Size = UDim2.new(1,0,0,28)
    logBox.Position = UDim2.new(0,0,0,56+6+28+4)
    logBox.Text = "السجل: -"
    logBox.TextScaled = true
    logBox.Font = Enum.Font.Gotham
    logBox.TextColor3 = COLORS.dim
    logBox.TextXAlignment = Enum.TextXAlignment.Left
    corner(logBox, 10); stroke(logBox,1,COLORS.stroke,0.12)
    padding(logBox, 8,4,8,4)
    self.logBox = logBox

    -- وظائف داخلية
    local function updateLog(msg)
        table.insert(self.sessionLog, msg)
        if #self.sessionLog > 3 then table.remove(self.sessionLog,1) end
        self.logBox.Text = "السجل: " .. table.concat(self.sessionLog, "  |  ")
    end
    self.updateLog = updateLog

    local function reset()
        self.targetUserId = nil
        self.targetName   = nil
        self.targetDisp   = nil
        self.joins, self.leaves = 0, 0
        self.startedAt = nil
        self.sessionLog = {}
        self.userLbl.Text = "اسم المستخدم: -"
        self.dispLbl.Text = "اللقب: -"
        self.joinLbl.Text = "دخول: 0"
        self.leaveLbl.Text= "خروج: 0"
        self.logBox.Text  = "السجل: -"
        self.avatar.Image = "rbxassetid://0"
    end
    self.reset = reset
    reset()

    local function setTarget(plr)
        if not plr then reset(); return end
        self.targetUserId = plr.UserId
        self.targetName   = plr.Name
        self.targetDisp   = plr.DisplayName or plr.Name
        self.joins, self.leaves = 0, 0
        self.startedAt = os.time()
        self.userLbl.Text = "اسم المستخدم: "..self.targetName
        self.dispLbl.Text = "اللقب: "..self.targetDisp
        self.joinLbl.Text = "دخول: 0"
        self.leaveLbl.Text= "خروج: 0"
        self.sessionLog = {}
        self.logBox.Text = "السجل: بدأ التتبع"

        task.spawn(function()
            local ok, content = pcall(function()
                return Players:GetUserThumbnailAsync(self.targetUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and content and self.targetUserId then
                self.avatar.Image = content
            else
                self.avatar.Image = "rbxassetid://0"
            end
        end)
    end
    self.setTarget = setTarget

    local function findPlayerByPrefix(prefix)
        local q = (prefix or ""):gsub("^%s+",""):gsub("%s+$","")
        if #q < 2 then return nil end -- من أول حرفين
        q = q:lower()
        for _,plr in ipairs(Players:GetPlayers()) do
            local uname = plr.Name:lower()
            local dname = (plr.DisplayName or ""):lower()
            if uname:sub(1,#q)==q or dname:sub(1,#q)==q then
                return plr
            end
        end
        return nil
    end

    local debounced = makeDebouncer(0.06)
    self.input:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = self.input.Text
        if txt == "" then
            reset()
            return
        end
        debounced(function()
            local plr = findPlayerByPrefix(txt)
            if plr then setTarget(plr) end
        end)
    end)

    self.input.FocusLost:Connect(function()
        local txt = self.input.Text
        if txt == "" then reset() return end
        local plr = findPlayerByPrefix(txt)
        if plr then setTarget(plr) end
    end)

    function self:onJoin()
        self.joins += 1
        self.joinLbl.Text = "دخول: "..self.joins
        local label = (self.targetDisp or self.targetName or "?")
        self.updateLog("دخل: "..label)
    end

    function self:onLeave()
        self.leaves += 1
        self.leaveLbl.Text = "خروج: "..self.leaves
        local label = (self.targetDisp or self.targetName or "?")
        self.updateLog("خرج: "..label)
    end

    return self
end

--========================[ إنشاء 4 خانات ]========================
local slots = {
    Slot.new(1),
    Slot.new(2),
    Slot.new(3),
    Slot.new(4),
}

--========================[ فهرس سريع بحسب UserId ]========================
local watchByUserId = {}
local function rebuildIndex()
    table.clear(watchByUserId)
    for _,s in ipairs(slots) do
        if s.targetUserId then
            watchByUserId[s.targetUserId] = s
        end
    end
end
RunService.Heartbeat:Connect(rebuildIndex)

--========================[ إشعارات دخول/خروج ]========================
Players.PlayerAdded:Connect(function(plr)
    local s = watchByUserId[plr.UserId]
    if s then
        s:onJoin()
        playSafe(SFX_JOIN)
        toast("دخل: "..(plr.DisplayName or plr.Name).." ("..plr.Name..")", COLORS.green)
        -- تحديث الأفاتار احتياطيًا
        task.spawn(function()
            local ok, content = pcall(function()
                return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and content and s.targetUserId == plr.UserId then
                s.avatar.Image = content
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    local s = watchByUserId[plr.UserId]
    if s then
        s:onLeave()
        playSafe(SFX_LEAVE)
        toast("خرج: "..(plr.DisplayName or plr.Name).." ("..plr.Name..")", COLORS.red)
    end
end)

-- تهيئة أولية
for _,s in ipairs(slots) do
    s.joinLbl.Text  = "دخول: 0"
    s.leaveLbl.Text = "خروج: 0"
end
