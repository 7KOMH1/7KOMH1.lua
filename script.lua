--[[
    حقوق العم حكومه🍷 — نسخة نهائية قوية (4 تتبع)
    • واجهة حجم متوسط-صغير، مرتبة 2×2.
    • مربعات البحث فاضية (بدون Placeholder)، وتلتقط من أول حرفين فأكثر من الاسم أو اللقب.
    • عرض اسم المستخدم + اللقب + صورة الأفاتار + عداد دخول/خروج.
    • إشعار صوتي ورسالة صغيرة داخل اللوحة عند الدخول/الخروج.
    • زر فتح/إخفاء صغير (3 شرطات) قابل للسحب + اللوحة قابلة للسحب.
    • يعتمد على UserId لضمان تتبع دقيق حتى لو الاسم اتغير.
    • كود محمي بـ pcall لمنع التعطّل لو حصلت أخطاء غير متوقعة.
]]--

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local LocalPlayer  = Players.LocalPlayer

--========================[ ثيم وألوان ]========================
local COLORS = {
    bg      = Color3.fromRGB(15,15,15),
    panel   = Color3.fromRGB(24,24,26),
    panel2  = Color3.fromRGB(28,28,30),
    stroke  = Color3.fromRGB(48,48,54),
    text    = Color3.fromRGB(220,220,220),
    subtle  = Color3.fromRGB(160,160,165),
    blue    = Color3.fromRGB(0,136,255),  -- للحقوق والعناوين
    green   = Color3.fromRGB(0,220,120),
    red     = Color3.fromRGB(240,70,70),
}

--========================[ أدوات UI مساعدة ]========================
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
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function padding(obj, l,t,r,b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, l or 8)
    p.PaddingTop    = UDim.new(0, t or 8)
    p.PaddingRight  = UDim.new(0, r or 8)
    p.PaddingBottom = UDim.new(0, b or 8)
    p.Parent = obj
    return p
end

--========================[ أصوات ]========================
local function makeSound(id, vol, speed)
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = vol or 0.5
    s.PlaybackSpeed = speed or 1.0
    s.Parent = SoundService
    return s
end

local SFX_JOIN  = makeSound("rbxassetid://9118823107", 0.45, 1.08)
local SFX_LEAVE = makeSound("rbxassetid://4590657391", 0.45, 0.96)

local function playSafe(snd)
    pcall(function()
        snd:Play()
    end)
end

--========================[ ScreenGui + زر فتح/إخفاء ]========================
local gui = Instance.new("ScreenGui")
gui.Name = "HKOMA_GS4_Tracker"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- زر صغير قابل للسحب (3 شرطات)
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "Toggle"
toggleBtn.Parent = gui
toggleBtn.Size = UDim2.fromOffset(32,32)
toggleBtn.Position = UDim2.new(0.06,0,0.25,0)
toggleBtn.BackgroundColor3 = COLORS.panel
toggleBtn.Image = "rbxassetid://0"
toggleBtn.AutoButtonColor = true
toggleBtn.ZIndex = 50
corner(toggleBtn, 8); stroke(toggleBtn, 1, COLORS.stroke, 0.25)

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
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = toggleBtn.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging=false end end)
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
root.Size = UDim2.new(0, 720, 0, 430) -- متوسط-صغير
root.Position = UDim2.new(0.5, -360, 0.5, -215)
corner(root, 16); stroke(root, 1, COLORS.stroke, 0.2); padding(root, 12,12,12,12)

-- سحب اللوحة
do
    local dragging, dragStart, startPos
    root.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = root.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging=false end end)
        end
    end)
    root.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- فتح/إخفاء
local isOpen = true
local function setOpen(v)
    isOpen = v
    root.Visible = v
end
toggleBtn.MouseButton1Click:Connect(function() setOpen(not isOpen) end)

--========================[ الهيدر ]========================
local header = Instance.new("Frame")
header.Parent = root
header.BackgroundColor3 = COLORS.panel
header.BorderSizePixel = 0
header.Size = UDim2.new(1,0,0,50)
corner(header, 12); stroke(header, 1, COLORS.stroke, 0.15)

local title = Instance.new("TextLabel")
title.Parent = header
title.BackgroundTransparency = 1
title.Size = UDim2.new(1,-20,1,0)
title.Position = UDim2.new(0,10,0,0)
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Text = "حقوق العم حكومه🍷"
title.TextColor3 = COLORS.blue
title.TextScaled = true

--========================[ شبكة 2×2 للبطاقات ]========================
local grid = Instance.new("Frame")
grid.Parent = root
grid.BackgroundTransparency = 1
grid.Size = UDim2.new(1,0,1,-(50+10))
grid.Position = UDim2.new(0,0,0,50+10)

local uiGrid = Instance.new("UIGridLayout")
uiGrid.Parent = grid
uiGrid.CellPadding = UDim2.fromOffset(10,10)
uiGrid.CellSize   = UDim2.new(0.5, -10, 0.5, -10)
uiGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiGrid.VerticalAlignment   = Enum.VerticalAlignment.Top
uiGrid.SortOrder = Enum.SortOrder.LayoutOrder

--========================[ توست/رسالة مصغّرة ]========================
local function toast(msg, color)
    local t = Instance.new("TextLabel")
    t.Parent = root
    t.BackgroundColor3 = COLORS.panel2
    t.BorderSizePixel = 0
    t.AnchorPoint = Vector2.new(0.5,1)
    t.Position = UDim2.new(0.5,0,1,-10)
    t.Size = UDim2.fromOffset(460,32)
    t.Text = msg
    t.TextColor3 = color or COLORS.text
    t.TextScaled = true
    t.Font = Enum.Font.GothamSemibold
    t.TextTransparency = 1
    corner(t, 10); stroke(t, 1, COLORS.stroke, 0.35)
    TweenService:Create(t, TweenInfo.new(0.16), {TextTransparency = 0, BackgroundTransparency = 0.04}):Play()
    task.delay(1.25, function()
        TweenService:Create(t, TweenInfo.new(0.22), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.delay(0.24, function() t:Destroy() end)
    end)
end

--========================[ قناع إدخال سريع (ديباونس) ]========================
local function makeDebouncer(waitSec)
    local lastTick = 0
    return function(cb)
        local now = tick()
        if now - lastTick >= (waitSec or 0.06) then
            lastTick = now
            cb()
        end
    end
end

--========================[ قالب بطاقة التتبع ]========================
local Slot = {}
Slot.__index = Slot

function Slot.new(index)
    local self = setmetatable({}, Slot)
    self.index = index
    self.targetUserId = nil
    self.targetName   = nil
    self.targetDisp   = nil
    self.joins = 0
    self.leaves = 0

    -- بطاقة
    local card = Instance.new("Frame")
    card.Name = "Slot"..index
    card.Parent = grid
    card.BackgroundColor3 = COLORS.panel
    card.BorderSizePixel = 0
    corner(card, 12); stroke(card, 1, COLORS.stroke, 0.2); padding(card, 10,10,10,10)
    self.card = card

    -- شريط علوي: صندوق إدخال (فاضي)
    local top = Instance.new("Frame")
    top.Parent = card
    top.BackgroundColor3 = COLORS.panel2
    top.BorderSizePixel = 0
    top.Size = UDim2.new(1,0,0,38)
    corner(top, 10); stroke(top, 1, COLORS.stroke, 0.12)

    local input = Instance.new("TextBox")
    input.Parent = top
    input.BackgroundTransparency = 1
    input.ClearTextOnFocus = false
    input.Size = UDim2.new(1,-12,1,0)
    input.Position = UDim2.new(0,6,0,0)
    input.Text = ""  -- فاضي
    input.PlaceholderText = ""
    input.Font = Enum.Font.GothamSemibold
    input.TextColor3 = COLORS.text
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.TextScaled = true
    self.input = input

    -- جسم البطاقة
    local body = Instance.new("Frame")
    body.Parent = card
    body.BackgroundTransparency = 1
    body.Size = UDim2.new(1,0,1,-(38+8))
    body.Position = UDim2.new(0,0,0,38+8)

    local hList = Instance.new("UIListLayout")
    hList.Parent = body
    hList.FillDirection = Enum.FillDirection.Horizontal
    hList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    hList.VerticalAlignment   = Enum.VerticalAlignment.Top
    hList.Padding = UDim.new(0,10)

    -- يسار: أفاتار
    local left = Instance.new("Frame")
    left.Parent = body
    left.BackgroundTransparency = 1
    left.Size = UDim2.new(0,90,1,0)

    local avatar = Instance.new("ImageLabel")
    avatar.Parent = left
    avatar.BackgroundColor3 = COLORS.panel2
    avatar.BorderSizePixel = 0
    avatar.Size = UDim2.fromOffset(90,90)
    avatar.Image = "rbxassetid://0"
    corner(avatar, 12); stroke(avatar, 1, COLORS.stroke, 0.2)
    self.avatar = avatar

    -- يمين: معلومات + عداد
    local right = Instance.new("Frame")
    right.Parent = body
    right.BackgroundTransparency = 1
    right.Size = UDim2.new(1, -100, 1, 0)

    local info = Instance.new("Frame")
    info.Parent = right
    info.BackgroundColor3 = COLORS.panel2
    info.BorderSizePixel = 0
    info.Size = UDim2.new(1,0,0,64)
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
    stats.Size = UDim2.new(1,0,0,30)
    stats.Position = UDim2.new(0,0,0,64+8)

    local joinLbl = Instance.new("TextLabel")
    joinLbl.Parent = stats
    joinLbl.BackgroundTransparency = 1
    joinLbl.TextScaled = true
    joinLbl.Font = Enum.Font.GothamBold
    joinLbl.TextXAlignment = Enum.TextXAlignment.Left
    joinLbl.TextColor3 = COLORS.green
    joinLbl.Size = UDim2.new(0.5,-6,1,0)
    joinLbl.Position = UDim2.new(0,0,0,0)
    joinLbl.Text = "دخول: 0"
    self.joinLbl = joinLbl

    local leaveLbl = Instance.new("TextLabel")
    leaveLbl.Parent = stats
    leaveLbl.BackgroundTransparency = 1
    leaveLbl.TextScaled = true
    leaveLbl.Font = Enum.Font.GothamBold
    leaveLbl.TextXAlignment = Enum.TextXAlignment.Right
    leaveLbl.TextColor3 = COLORS.red
    leaveLbl.Size = UDim2.new(0.5,-6,1,0)
    leaveLbl.Position = UDim2.new(0.5,6,0,0)
    leaveLbl.Text = "خروج: 0"
    self.leaveLbl = leaveLbl

    -- وظائف داخلية
    local function reset()
        self.targetUserId = nil
        self.targetName   = nil
        self.targetDisp   = nil
        self.joins, self.leaves = 0, 0
        self.userLbl.Text = "اسم المستخدم: -"
        self.dispLbl.Text = "اللقب: -"
        self.joinLbl.Text = "دخول: 0"
        self.leaveLbl.Text = "خروج: 0"
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
        self.userLbl.Text = "اسم المستخدم: "..self.targetName
        self.dispLbl.Text = "اللقب: "..self.targetDisp

        task.spawn(function()
            local ok, content = pcall(function()
                return Players:GetUserThumbnailAsync(self.targetUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and content then
                self.avatar.Image = content
            else
                self.avatar.Image = "rbxassetid://0"
            end
        end)
    end
    self.setTarget = setTarget

    local function findPlayerByPrefix(prefix)
        local q = (prefix or ""):gsub("^%s+",""):gsub("%s+$","")
        if #q < 2 then return nil end
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

    -- ديباونس للالتقاط السريع
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
        if txt == "" then
            reset()
        else
            local plr = findPlayerByPrefix(txt)
            if plr then setTarget(plr) end
        end
    end)

    -- تحديث عداد
    function self:updateCounters()
        self.joinLbl.Text  = "دخول: "..tostring(self.joins)
        self.leaveLbl.Text = "خروج: "..tostring(self.leaves)
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

RunService.Heartbeat:Connect(function()
    rebuildIndex()
end)

--========================[ أحداث دخول/خروج ]========================
Players.PlayerAdded:Connect(function(plr)
    local s = watchByUserId[plr.UserId]
    if s then
        s.joins += 1
        s:updateCounters()
        playSafe(SFX_JOIN)
        toast("دخل: "..(plr.DisplayName or plr.Name).." ("..plr.Name..")", COLORS.green)
        -- تحديث الأفاتار احتياطًا
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
        s.leaves += 1
        s:updateCounters()
        playSafe(SFX_LEAVE)
        toast("خرج: "..(plr.DisplayName or plr.Name).." ("..plr.Name..")", COLORS.red)
    end
end)

-- تهيئة أولية
for _,s in ipairs(slots) do
    s:updateCounters()
end
