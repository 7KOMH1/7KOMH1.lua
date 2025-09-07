-- EG Tracker — نسخة مصححة ومرتّبة بالعربي
-- احفظ كـ LocalScript داخل StarterPlayerScripts أو StarterGui
-- العنوان: صنع حكومة | كلان EG - تتبع 4 لاعبين
-- خلفية: سوداء، 4 كروت، صورة مربعة، بحث من أول حرفين، تتبع حقيقي

-- Services
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- تنظيف واجهة سابقة
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local old = pg:FindFirstChild("EG_Tracker_GUI")
        if old then old:Destroy() end
    end
end)

-- دوال مساعدة
local function New(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

local function UICorner(parent, radius)
    local c = Instance.new("UICorner")
    c.Parent = parent
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function UIStroke(parent, thickness, color, trans)
    local s = Instance.new("UIStroke")
    s.Parent = parent
    s.Thickness = thickness or 1
    s.Color = color or Color3.fromRGB(40,40,48)
    s.Transparency = trans or 0.2
    return s
end

local function trim(s) return (s or ""):gsub("^%s+", ""):gsub("%s+$", "") end

local function formatHM(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    if h > 0 then
        if m > 0 then return string.format("%d ساعة %d دقيقة", h, m) end
        return string.format("%d ساعة", h)
    else
        return string.format("%d دقيقة", m)
    end
end

local function formatClock(ts)
    local t = type(ts) == "number" and os.date("*t", ts) or ts
    if not t then return "-" end
    local hour = t.hour
    local min = t.min
    local suffix = (hour >= 12) and "م" or "ص"
    local displayHour = hour % 12
    if displayHour == 0 then displayHour = 12 end
    return string.format("%02d:%02d %s", displayHour, min, suffix)
end

-- Avatar cache
local AvatarCache = {}
local function SafeGetThumbnail(userId)
    if not userId or userId <= 0 then return "rbxassetid://0" end
    if AvatarCache[userId] then return AvatarCache[userId] end
    local ok, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    if ok and typeof(thumb) == "string" and thumb ~= "" then
        AvatarCache[userId] = thumb
        pcall(function() ContentProvider:PreloadAsync({thumb}) end)
        return thumb
    end
    return "rbxassetid://0"
end

-- ألوان
local COLORS = {
    BG = Color3.fromRGB(10,10,10),
    PANEL = Color3.fromRGB(26,26,28),
    HEADER = Color3.fromRGB(18,18,18),
    ACCENT = Color3.fromRGB(0,150,255),
    TEXT = Color3.fromRGB(230,230,235),
    MUTED = Color3.fromRGB(150,155,165),
    GOOD = Color3.fromRGB(60,200,90),
    BAD = Color3.fromRGB(220,70,70),
    STROKE = Color3.fromRGB(45,45,52),
}

-- بناء الـ GUI
local pg = LocalPlayer:WaitForChild("PlayerGui")
local GUI = New("ScreenGui", {Name = "EG_Tracker_GUI", ResetOnSpawn = false, Parent = pg})

local Root = New("Frame", {
    Parent = GUI,
    Name = "Root",
    Size = UDim2.new(0, 480, 0, 320), -- متوسط ومناسب
    Position = UDim2.new(0, 24, 0.35, -160),
    BackgroundColor3 = COLORS.BG,
    BorderSizePixel = 0,
})
UICorner(Root, 12); UIStroke(Root, 1, COLORS.STROKE, 0.18)

-- Header (الهيدر ثابت)
local Header = New("Frame", {Parent = Root, BackgroundColor3 = COLORS.HEADER, Size = UDim2.new(1, -16, 0, 70), Position = UDim2.new(0,8,0,8)})
UICorner(Header, 10); UIStroke(Header, 1, COLORS.STROKE, 0.15)

local Title = New("TextLabel", {
    Parent = Header, BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = COLORS.ACCENT,
    Size = UDim2.new(0.8,0,0.6,0), Position = UDim2.new(0,10,0,6),
    Text = "صنع حكومة | كلان EG - تتبع 4 لاعبين",
    TextXAlignment = Enum.TextXAlignment.Left
})
local Rights = New("TextLabel", {
    Parent = Header, BackgroundTransparency = 1,
    Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = COLORS.MUTED,
    Size = UDim2.new(0.8,0,0.4,0), Position = UDim2.new(0,10,0,38),
    Text = "حقوق: حكومه", TextXAlignment = Enum.TextXAlignment.Left
})

local ToggleBtn = New("TextButton", {
    Parent = Header, Size = UDim2.new(0,86,0,36), Position = UDim2.new(1,-98,0,18),
    BackgroundColor3 = COLORS.PANEL, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = COLORS.TEXT, Text = "إخفاء"
})
UICorner(ToggleBtn, 8); UIStroke(ToggleBtn, 1, COLORS.STROKE, 0.12)
ToggleBtn.Active = true; ToggleBtn.Selectable = true; ToggleBtn.Draggable = true

-- separator الخط الازرق
local Sep = New("Frame", {Parent = Root, BackgroundColor3 = COLORS.ACCENT, Size = UDim2.new(1, -16, 0, 2), Position = UDim2.new(0,8,0,86)})

-- ContentFrame (المحتوى القابل للإخفاء) — Toggle يخفي هذا الإطار فقط
local ContentFrame = New("Frame", {Parent = Root, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, -108), Position = UDim2.new(0,8,0,96)})
-- grid داخل ContentFrame
local Grid = New("Frame", {Parent = ContentFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0)})
local GridLayout = New("UIGridLayout")
GridLayout.Parent = Grid
GridLayout.CellPadding = UDim2.new(0,10,0,10)
GridLayout.CellSize = UDim2.new(0.5, -12, 0.5, -12)
GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
GridLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Card class
local Card = {}
Card.__index = Card

function Card.new()
    local self = setmetatable({}, Card)
    local frame = New("Frame", {Parent = Grid, BackgroundColor3 = COLORS.PANEL, BorderSizePixel = 0})
    UICorner(frame, 8); UIStroke(frame, 1, COLORS.STROKE, 0.10)
    self.Frame = frame

    -- Search box (فارغ)
    local search = New("TextBox", {Parent = frame, BackgroundColor3 = COLORS.BG, ClearTextOnFocus = false, PlaceholderText = "", Text = "", Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = COLORS.TEXT, Size = UDim2.new(1, -12, 0, 30), Position = UDim2.new(0,6,0,6)})
    UICorner(search, 6); UIStroke(search, 1, COLORS.STROKE, 0.08)
    self.Search = search

    -- content area
    local content = New("Frame", {Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 1, -92), Position = UDim2.new(0,6,0,44)})
    -- avatar مربع صغير
    local avatar = New("ImageLabel", {Parent = content, BackgroundColor3 = COLORS.HEADER, Size = UDim2.new(0,64,0,64), Position = UDim2.new(0,0,0,0), ScaleType = Enum.ScaleType.Crop, Image = "rbxassetid://0"})
    UICorner(avatar, 6); UIStroke(avatar, 1, COLORS.STROKE, 0.10)
    self.Avatar = avatar

    -- meta info
    local meta = New("Frame", {Parent = content, BackgroundTransparency = 1, Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0,80,0,0)})
    self.NameLbl = New("TextLabel", {Parent = meta, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = COLORS.TEXT, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1,0,0,22), Position = UDim2.new(0,0,0,0), Text = "-"})
    self.TimeLbl = New("TextLabel", {Parent = meta, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = COLORS.MUTED, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1,0,0,18), Position = UDim2.new(0,0,0,28), Text = "الوقت: -"})
    self.DurLbl = New("TextLabel", {Parent = meta, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = COLORS.MUTED, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1,0,0,18), Position = UDim2.new(0,0,0,46), Text = "المدة: 0 ساعة 0 دقيقة"})

    -- bottom (دخول/خروج)
    local bottom = New("Frame", {Parent = frame, BackgroundColor3 = COLORS.BG, Size = UDim2.new(1, -12, 0, 36), Position = UDim2.new(0, 6, 1, -42)})
    UICorner(bottom, 6); UIStroke(bottom, 1, COLORS.STROKE, 0.08)
    self.StateLbl = New("TextLabel", {Parent = bottom, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = COLORS.MUTED, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.6,0,1,0), Position = UDim2.new(0,8,0,0), Text = "-"})
    self.JoinLbl = New("TextLabel", {Parent = bottom, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = COLORS.GOOD, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0.2,-6,1,0), Position = UDim2.new(0.6,0,0,0), Text = "دخول: 0"})
    self.LeaveLbl = New("TextLabel", {Parent = bottom, BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = COLORS.BAD, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0.2,-6,1,0), Position = UDim2.new(0.8,0,0,0), Text = "خروج: 0"})

    -- internal
    self.Player = nil
    self._conns = {}
    self._timerToken = nil
    self._startTime = nil

    return self
end

function Card:bind(player)
    self:unbind()
    if not player then return end
    self.Player = player
    self.NameLbl.Text = player.DisplayName or player.Name or "-"
    -- تحميل الصورة بأمان
    spawn(function()
        local img = SafeGetThumbnail(player.UserId)
        if img then
            pcall(function() self.Avatar.Image = img end)
        end
    end)
    -- البداية والعدادات
    local st = os.time()
    self._startTime = st
    self.TimeLbl.Text = "الوقت: " .. formatClock(st)
    self.JoinLbl.Text = "دخول: 0"; self.LeaveLbl.Text = "خروج: 0"
    self.StateLbl.Text = "الحالة: -"; self.StateLbl.TextColor3 = COLORS.MUTED

    local function onAdded(char)
        local cur = tonumber(self.JoinLbl.Text:match("%d+")) or 0
        self.JoinLbl.Text = "دخول: " .. (cur + 1)
        self.StateLbl.Text = "الحالة: داخل"; self.StateLbl.TextColor3 = COLORS.GOOD
    end
    local function onRemoving()
        local cur = tonumber(self.LeaveLbl.Text:match("%d+")) or 0
        self.LeaveLbl.Text = "خروج: " .. (cur + 1)
        self.StateLbl.Text = "الحالة: خارج"; self.StateLbl.TextColor3 = COLORS.BAD
    end

    -- وصل الأحداث بحذر وفك الربط لاحقًا
    if player.Character then onAdded(player.Character) end
    table.insert(self._conns, player.CharacterAdded:Connect(onAdded))
    if player.CharacterRemoving then table.insert(self._conns, player.CharacterRemoving:Connect(onRemoving)) end

    -- مؤقت لتحديث المدة
    local token = HttpService:GenerateGUID(false)
    self._timerToken = token
    spawn(function()
        while self._timerToken == token do
            if self._startTime then
                local elapsed = os.time() - self._startTime
                self.DurLbl.Text = "المدة: " .. formatHM(elapsed)
            end
            wait(1)
        end
    end)
end

function Card:unbind()
    self._startTime = nil
    self._timerToken = nil
    for _,c in ipairs(self._conns) do
        if c and c.Disconnect then
            pcall(function() c:Disconnect() end)
        end
    end
    self._conns = {}
    self.Player = nil
    -- reset UI
    pcall(function()
        self.NameLbl.Text = "-"
        self.TimeLbl.Text = "الوقت: -"
        self.DurLbl.Text = "المدة: 0 ساعة 0 دقيقة"
        self.Avatar.Image = "rbxassetid://0"
        self.StateLbl.Text = "-"
        self.JoinLbl.Text = "دخول: 0"
        self.LeaveLbl.Text = "خروج: 0"
    end)
end

function Card:destroy()
    self:unbind()
    pcall(function() if self.Frame then self.Frame:Destroy() end end)
end

-- أنشئ 4 كروت
local Cards = {}
for i = 1, 4 do Cards[i] = Card.new() end

-- البحث: يلتقط من أول حرفين ويستجيب بسرعة
for _,c in ipairs(Cards) do
    local debounce = false
    local last = ""
    c.Search:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = trim(c.Search.Text or "")
        if txt == last then return end
        last = txt
        if debounce then return end
        debounce = true
        spawn(function()
            wait(0.06) -- وقت قصير لتجنب تحريك سريع جداً
            if #txt >= 2 then
                local q = txt:lower()
                local found = nil
                for _,p in ipairs(Players:GetPlayers()) do
                    local un = (p.Name or ""):lower()
                    local dn = (p.DisplayName or ""):lower()
                    if un:sub(1,#q) == q or dn:sub(1,#q) == q then found = p; break end
                end
                if found then c:bind(found) else c:unbind() end
            else
                c:unbind()
            end
            debounce = false
        end)
    end)
    -- للتوافق في حالة ترك الحقل
    c.Search.FocusLost:Connect(function(enter)
        local txt = trim(c.Search.Text or "")
        if #txt < 2 then c:unbind() end
    end)
end

-- عند خروج لاعب: حدث عام يحدث في الكارت المرتبط إن وجد
Players.PlayerRemoving:Connect(function(plr)
    for _,c in ipairs(Cards) do
        if c.Player and c.Player == plr then
            local cur = tonumber(c.LeaveLbl.Text:match("%d+")) or 0
            c.LeaveLbl.Text = "خروج: " .. (cur + 1)
            c.StateLbl.Text = "الحالة: خارج"
            c.StateLbl.TextColor3 = COLORS.BAD
            c:unbind()
        end
    end
end)

-- Toggle: يخفي محتوى الكروت فقط (ContentFrame) وليس الهيدر
ToggleBtn.MouseButton1Click:Connect(function()
    ContentFrame.Visible = not ContentFrame.Visible
    ToggleBtn.Text = ContentFrame.Visible and "إخفاء" or "إظهار"
end)

-- سحب اللوحة: الهيدر فقط (أمان لعدم تحريك عناصر اللعبة)
do
    local dragging = false
    local dragStart = Vector2.new(0,0)
    local startPos = Root.Position
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Root.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- حفظ/تحميل موضع
local posKey = "EG_TRACKER_POS"
local function savePos()
    pcall(function()
        local raw = HttpService:JSONEncode({x = Root.Position.X.Offset, y = Root.Position.Y.Offset})
        LocalPlayer:SetAttribute(posKey, raw)
    end)
end
local function loadPos()
    pcall(function()
        local raw = LocalPlayer:GetAttribute(posKey)
        if type(raw) == "string" and #raw > 0 then
            local ok, dat = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok and dat and dat.x and dat.y then
                Root.Position = UDim2.new(0, dat.x, 0, dat.y)
            end
        end
    end)
end
Root:GetPropertyChangedSignal("Position"):Connect(savePos)
loadPos()

-- تلميح سريع عند التشغيل
do
    local hint = New("TextLabel", {Parent = Root, BackgroundTransparency = 1, Size = UDim2.new(0.9,0,0,22), Position = UDim2.new(0.05,0,1,-36), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = COLORS.MUTED, Text = "اكتب أول حرفين أو أكثر داخل أي خانة لربط لاعب وبدء التتبع"})
    delay(4, function() pcall(function() hint:Destroy() end) end)
end

-- انتهى — نسخة مصححة. لو في أي حاجة: صورة شاشة مع المناطق اللي بتتداخل أو نص خطأ، هعدّل فورًا.
