-- ======================================================
-- صنع حكومة | كلان EG - تتبع 4 لاعبين
-- نسخة نهائية مصغرة ومرتّبة بالعربي
-- ضع هذا الملف LocalScript داخل StarterPlayerScripts أو StarterGui
-- ======================================================

-- خدمات
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- تنظيف أي واجهة قديمة
do
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        local old = pg:FindFirstChild("EG_Tracker_GUI")
        if old then old:Destroy() end
    end)
end

-- ألوان وخيارات تصميم خفيفة
local COLORS = {
    BG      = Color3.fromRGB(20,20,22),
    PANEL   = Color3.fromRGB(30,30,34),
    HEADER  = Color3.fromRGB(24,24,28),
    ACCENT  = Color3.fromRGB(0,150,255),
    TEXT    = Color3.fromRGB(230,230,235),
    MUTED   = Color3.fromRGB(150,155,165),
    GOOD    = Color3.fromRGB(60,210,90),
    BAD     = Color3.fromRGB(240,70,70),
    STROKE  = Color3.fromRGB(45,45,52),
}

-- دوال مساعدة UI
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
    s.Color = color or COLORS.STROKE
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

-- كاش للصور
local AvatarCache = {}
local function FetchAvatar(userId)
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

-- واجهة (مقاس متوسط-صغير)
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = New("ScreenGui", {Name = "EG_Tracker_GUI", ResetOnSpawn = false})
ScreenGui.Parent = playerGui

local Root = New("Frame", {
    Name = "Root",
    Parent = ScreenGui,
    Size = UDim2.new(0, 520, 0, 320), -- صغير/متوسط: لا يملأ الشاشة
    Position = UDim2.new(0.5, -260, 0.5, -160),
    BackgroundColor3 = COLORS.BG,
    BorderSizePixel = 0,
})
UICorner(Root, 12); UIStroke(Root, 1, COLORS.STROKE, 0.2)

-- هيدر فوق مفصول
local Header = New("Frame", {
    Parent = Root,
    Size = UDim2.new(1, -20, 0, 64),
    Position = UDim2.new(0, 10, 0, 8),
    BackgroundColor3 = COLORS.HEADER,
    BorderSizePixel = 0,
})
UICorner(Header, 10); UIStroke(Header, 1, COLORS.STROKE, 0.18)

local Title = New("TextLabel", {
    Parent = Header,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -120, 0.6, 0),
    Position = UDim2.new(0, 12, 0, 6),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = COLORS.ACCENT,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "صنع حكومة | كلان EG - تتبع 4 لاعبين"
})

local Rights = New("TextLabel", {
    Parent = Header,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -120, 0.4, 0),
    Position = UDim2.new(0, 12, 0, 36),
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = COLORS.MUTED,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "العم حكومة  🍷  |  EG"
})

-- زر صغير فتح/إخفاء قابل للسحب
local ToggleBtn = New("TextButton", {
    Parent = Header,
    Size = UDim2.new(0, 92, 0, 36),
    Position = UDim2.new(1, -106, 0, 14),
    BackgroundColor3 = COLORS.PANEL or COLORS.PANEL,
    AutoButtonColor = true,
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = COLORS.TEXT,
    Text = "إخفاء",
    Active = true,
    Selectable = true,
})
UICorner(ToggleBtn, 8); UIStroke(ToggleBtn, 1, COLORS.STROKE, 0.16)
ToggleBtn.Draggable = true

-- خط فاصل
local Line = New("Frame", {
    Parent = Root,
    Size = UDim2.new(1, -20, 0, 2),
    Position = UDim2.new(0, 10, 0, 84),
    BackgroundColor3 = COLORS.ACCENT,
    BorderSizePixel = 0
})

-- شبكة 2x2
local Grid = New("Frame", {
    Parent = Root,
    Size = UDim2.new(1, -20, 1, -108),
    Position = UDim2.new(0, 10, 0, 96),
    BackgroundTransparency = 1
})
local UIGrid = New("UIGridLayout")
UIGrid.Parent = Grid
UIGrid.CellPadding = UDim2.new(0, 10, 0, 10)
UIGrid.CellSize = UDim2.new(0.5, -15, 0.5, -15)
UIGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIGrid.VerticalAlignment = Enum.VerticalAlignment.Top

-- مصنع كارت بسيط وصغير
local CardClass = {}
CardClass.__index = CardClass

function CardClass.new()
    local self = setmetatable({}, CardClass)
    -- إطار الكارت
    local frame = New("Frame", {
        Parent = Grid,
        BackgroundColor3 = COLORS.PANEL,
        BorderSizePixel = 0,
    })
    UICorner(frame, 8); UIStroke(frame, 1, COLORS.STROKE, 0.14)
    self.Frame = frame

    -- search box فوق (من غير placeholder)
    local search = New("TextBox", {
        Parent = frame,
        BackgroundColor3 = COLORS.BG,
        ClearTextOnFocus = false,
        PlaceholderText = "",
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextColor3 = COLORS.TEXT,
        Size = UDim2.new(1, -12, 0, 30),
        Position = UDim2.new(0, 6, 0, 6),
    })
    UICorner(search, 6); UIStroke(search, 1, COLORS.STROKE, 0.12)
    self.Search = search

    -- content area
    local content = New("Frame", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 1, -86),
        Position = UDim2.new(0, 6, 0, 44),
    })

    -- avatar مربع صغير
    local avatar = New("ImageLabel", {
        Parent = content,
        BackgroundColor3 = COLORS.HEADER,
        Size = UDim2.new(0, 72, 0, 72),
        Position = UDim2.new(0, 0, 0, 0),
        ScaleType = Enum.ScaleType.Crop,
        Image = "rbxassetid://0"
    })
    UICorner(avatar, 6); UIStroke(avatar, 1, COLORS.STROKE, 0.16)
    self.Avatar = avatar

    -- meta info بجانب الصورة (صغير) — الاسم فوق، ثم بداية التتبع، ثم المدة
    local meta = New("Frame", {
        Parent = content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -86, 1, 0),
        Position = UDim2.new(0, 86, 0, 0),
    })

    local nameLbl = New("TextLabel", {
        Parent = meta,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = COLORS.TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "-",
    })
    self.NameLbl = nameLbl

    local startLbl = New("TextLabel", {
        Parent = meta,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = COLORS.MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 30),
        Text = "بداية التتبع: -",
    })
    self.StartLbl = startLbl

    local durLbl = New("TextLabel", {
        Parent = meta,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = COLORS.MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 50),
        Text = "المدة: 0 ساعة 0 دقيقة",
    })
    self.DurLbl = durLbl

    -- bottom row for status & counts (صغير)
    local bottom = New("Frame", {
        Parent = frame,
        BackgroundColor3 = COLORS.BG,
        Size = UDim2.new(1, -12, 0, 40),
        Position = UDim2.new(0, 6, 1, -46),
    })
    UICorner(bottom, 6); UIStroke(bottom, 1, COLORS.STROKE, 0.12)

    local stateLbl = New("TextLabel", {
        Parent = bottom,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = COLORS.MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Text = "-",
    })
    self.StateLbl = stateLbl

    local joinLbl = New("TextLabel", {
        Parent = bottom,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = COLORS.GOOD,
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.new(0.2, -8, 1, 0),
        Position = UDim2.new(0.6, 0, 0, 0),
        Text = "دخول: 0",
    })
    self.JoinLbl = joinLbl

    local leaveLbl = New("TextLabel", {
        Parent = bottom,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = COLORS.BAD,
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.new(0.2, -8, 1, 0),
        Position = UDim2.new(0.8, 0, 0, 0),
        Text = "خروج: 0",
    })
    self.LeaveLbl = leaveLbl

    -- حالة داخلية
    self.Player = nil
    self._conns = {}
    self._timerToken = nil
    self._startTime = nil

    return self
end

function CardClass:bind(player)
    -- فك ربط سابق
    self:unbind()

    if not player then
        -- إعادة افتراضي
        self.Player = nil
        self.NameLbl.Text = "-"
        self.StartLbl.Text = "بداية التتبع: -"
        self.DurLbl.Text = "المدة: 0 ساعة 0 دقيقة"
        self.Avatar.Image = "rbxassetid://0"
        self.StateLbl.Text = "-"
        self.JoinLbl.Text = "دخول: 0"
        self.LeaveLbl.Text = "خروج: 0"
        return
    end

    self.Player = player
    self.NameLbl.Text = player.DisplayName or player.Name or "-"
    -- صورة
    spawn(function()
        local img = FetchAvatar(player.UserId)
        if img and typeof(img) == "string" then
            pcall(function() self.Avatar.Image = img end)
        end
    end)

    -- بداية التتبع
    local startTime = os.time()
    self._startTime = startTime
    self.StartLbl.Text = "بداية التتبع: " .. formatClock(startTime)
    self.JoinLbl.Text = "دخول: 0"
    self.LeaveLbl.Text = "خروج: 0"
    self.StateLbl.Text = "الحالة: غير معروف"
    self.StateLbl.TextColor3 = COLORS.MUTED

    -- handlers
    local function onCharAdded(char)
        local cur = tonumber(self.JoinLbl.Text:match("%d+")) or 0
        self.JoinLbl.Text = "دخول: " .. (cur + 1)
        self.StateLbl.Text = "الحالة: داخل"
        self.StateLbl.TextColor3 = COLORS.GOOD
    end
    local function onCharRemoving()
        local cur = tonumber(self.LeaveLbl.Text:match("%d+")) or 0
        self.LeaveLbl.Text = "خروج: " .. (cur + 1)
        self.StateLbl.Text = "الحالة: خارج"
        self.StateLbl.TextColor3 = COLORS.BAD
    end

    -- وصل الأحداث
    table.insert(self._conns, player.CharacterAdded:Connect(onCharAdded))
    if player.CharacterRemoving then
        table.insert(self._conns, player.CharacterRemoving:Connect(onCharRemoving))
    end

    -- لو فيه شخصية الآن نحسب دخول مباشرة
    if player.Character then onCharAdded(player.Character) end

    -- تحديث المدة كل ثانية (نحن نعرض ساعات+دقائق)
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

function CardClass:unbind()
    self._startTime = nil
    if self._timerToken then self._timerToken = nil end
    for _, c in ipairs(self._conns) do
        if c and c.Disconnect then
            pcall(function() c:Disconnect() end)
        end
    end
    self._conns = {}
    self.Player = nil
end

function CardClass:destroy()
    self:unbind()
    pcall(function() if self.Frame then self.Frame:Destroy() end end)
end

-- أنشئ 4 كروت
local Cards = {}
for i = 1, 4 do
    local card = CardClass.new()
    Cards[i] = card
end

-- سلوك البحث (يلتقط من أول حرفين)
for _, card in ipairs(Cards) do
    local last = ""
    card.Search:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = trim(card.Search.Text or "")
        if txt == last then return end
        last = txt
        if #txt >= 2 then
            local q = txt:lower()
            local found = nil
            for _, p in ipairs(Players:GetPlayers()) do
                local un = (p.Name or ""):lower()
                local dn = (p.DisplayName or ""):lower()
                if un:sub(1, #q) == q or dn:sub(1, #q) == q then
                    found = p
                    break
                end
            end
            if found then card:bind(found) end
        else
            card:unbind()
            -- عرض افتراضي
            card.NameLbl.Text = "-"
            card.StartLbl.Text = "بداية التتبع: -"
            card.DurLbl.Text = "المدة: 0 ساعة 0 دقيقة"
            card.Avatar.Image = "rbxassetid://0"
            card.StateLbl.Text = "-"
            card.JoinLbl.Text = "دخول: 0"
            card.LeaveLbl.Text = "خروج: 0"
        end
    end)
end

-- عند خروج لاعب: حدث على مستوى الكارت يحدث الخروج إذا كان مرتبطاً
Players.PlayerRemoving:Connect(function(plr)
    for _, card in ipairs(Cards) do
        if card.Player and card.Player == plr then
            local cur = tonumber(card.LeaveLbl.Text:match("%d+")) or 0
            card.LeaveLbl.Text = "خروج: " .. (cur + 1)
            card.StateLbl.Text = "الحالة: خارج"
            card.StateLbl.TextColor3 = COLORS.BAD
            card:unbind()
        end
    end
end)

-- زر الإخفاء/الإظهار
ToggleBtn.MouseButton1Click:Connect(function()
    Root.Visible = not Root.Visible
    ToggleBtn.Text = Root.Visible and "إخفاء" or "إظهار"
end)

-- سحب Root (يدعم الماوس)
do
    local dragging = false
    local startPos = Root.Position
    local dragStart = Vector2.new(0,0)
    Root.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Root.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- حفظ موضع الواجهة محلياً باستخدام Attributes
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
        if typeof(raw) == "string" and #raw > 0 then
            local ok, dat = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok and dat and dat.x and dat.y then
                Root.Position = UDim2.new(0, dat.x, 0, dat.y)
            end
        end
    end)
end
Root:GetPropertyChangedSignal("Position"):Connect(savePos)
loadPos()

-- رسالة تلميح أولية
do
    local hint = New("TextLabel", {
        Parent = Root,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.8, 0, 0, 28),
        Position = UDim2.new(0.1, 0, 1, -40),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = COLORS.MUTED,
        Text = "اكتب أول حرفين أو أكثر داخل أي خانة لربط لاعب وبدء التتبع"
    })
    delay(4, function() pcall(function() hint:Destroy() end) end)
end

-- انتهى -- السكربت جاهز للاستخدام والرفع على GitHub
