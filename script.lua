--[[-------------------------------------------------------------------------
  صنع حكومة | EG - تتبع 4 لاعبين
  نسخة نهائية كاملة
  ملاحظات:
    - اكتب أول حرفين أو أكثر من اسم اللاعب (Name) أو لقبه (DisplayName) داخل أي خانة.
    - السكربت يلتقط أول تطابق ويعرض اليوزر/اللقب/صورة البروفايل (مربعة) وعدد دخول/خروج ومدة الجلسة.
    - اضف هذا الملف كـ LocalScript داخل StarterPlayerScripts أو ضعه في StarterGui حسب رغبتك.
----------------------------------------------------------------------------]]

-- خدمات Roblox الأساسية
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- اللاعب المحلي
local LocalPlayer = Players.LocalPlayer

-- ========================
-- إعداد الألوان و الخطوط
-- ========================
local COLORS = {
    BG = Color3.fromRGB(18, 18, 20),
    PANEL = Color3.fromRGB(28, 28, 32),
    HEADER = Color3.fromRGB(22, 22, 26),
    STROKE = Color3.fromRGB(50, 50, 60),
    TEXT = Color3.fromRGB(230, 230, 235),
    ACCENT = Color3.fromRGB(0, 150, 255), -- أزرق الحقوق
    GOOD = Color3.fromRGB(60, 210, 90),   -- دخول
    BAD = Color3.fromRGB(240, 70, 70),    -- خروج
    MUTE = Color3.fromRGB(165, 170, 180), -- نص ثانوي
    HIGHLIGHT = Color3.fromRGB(100, 120, 140)
}

local FONT_BOLD = Enum.Font.GothamBold
local FONT_MED  = Enum.Font.GothamMedium
local FONT_REG  = Enum.Font.Gotham

-- ========================
-- أدوات مساعدة لإنشاء UI
-- ========================
local function New(class, props, children)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            -- حماية من الأخطاء
            local ok, _ = pcall(function() inst[k] = v end)
            if not ok then end
        end
    end
    if children then
        for _, c in ipairs(children) do
            c.Parent = inst
        end
    end
    return inst
end

local function UIStroke(parent, thickness, color, trans)
    local s = Instance.new("UIStroke")
    s.Parent = parent
    s.Thickness = thickness or 1
    s.Color = color or COLORS.STROKE
    s.Transparency = trans or 0.2
    return s
end

local function UICorner(parent, radius)
    local c = Instance.new("UICorner")
    c.Parent = parent
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function UIPadding(parent, top, left, bottom, right)
    local p = Instance.new("UIPadding")
    p.Parent = parent
    p.PaddingTop = UDim.new(0, top or 6)
    p.PaddingLeft = UDim.new(0, left or 6)
    p.PaddingBottom = UDim.new(0, bottom or 6)
    p.PaddingRight = UDim.new(0, right or 6)
    return p
end

local function MakeLabel(parent, props)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.BackgroundTransparency = 1
    lbl.Font = props.Font or FONT_REG
    lbl.TextSize = props.TextSize or 16
    lbl.TextColor3 = props.Color or COLORS.TEXT
    lbl.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
    lbl.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
    lbl.Text = props.Text or ""
    lbl.Size = props.Size or UDim2.new(1,0,0,20)
    lbl.Position = props.Position or UDim2.new(0,0,0,0)
    lbl.RichText = props.RichText or false
    lbl.TextScaled = props.TextScaled or false
    return lbl
end

-- ========================
-- تهيئة الـ ScreenGui
-- ========================
local screenParent = (gethui and gethui()) or game:GetService("CoreGui")
-- لو في نسخة قديمة نزيلها
pcall(function()
    local old = screenParent:FindFirstChild("EG_PlayerTracker_GUI")
    if old then old:Destroy() end
end)

local ScreenGui = New("ScreenGui", {
    Name = "EG_PlayerTracker_GUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
ScreenGui.Parent = screenParent

-- ========================
-- الصوتيات للإشعارات (اختياري)
-- ========================
local function MakeSound(parent, id, vol)
    local s = Instance.new("Sound")
    s.Parent = parent
    s.SoundId = id
    s.Volume = vol or 0.4
    s.PlayOnRemove = false
    return s
end

local sndJoin = MakeSound(ScreenGui, "rbxassetid://9118823100", 0.35) -- يمكن تغييره
local sndLeave = MakeSound(ScreenGui, "rbxassetid://12221967", 0.35)

-- ========================
-- البناء البصري (Header + Board)
-- ========================

-- الخلفية الرئيسية (مركز الشاشة، حجم متوسط)
local Root = New("Frame", {
    Parent = ScreenGui,
    Name = "Root",
    BackgroundColor3 = COLORS.BG,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 980, 0, 560),
    Position = UDim2.new(0.5, -490, 0.5, -280),
})
UICorner(Root, 16)
UIStroke(Root, 1, COLORS.STROKE, 0.22)

-- شريط العنوان العلوي (مفصول بمساحة)
local TopHeader = New("Frame", {
    Parent = Root,
    Name = "TopHeader",
    BackgroundColor3 = COLORS.HEADER,
    Size = UDim2.new(1, -40, 0, 72),
    Position = UDim2.new(0, 20, 0, 20),
})
UICorner(TopHeader, 12)
UIStroke(TopHeader, 1, COLORS.STROKE, 0.18)
UIPadding(TopHeader, 10, 16, 10, 16)

-- عنوان كبير (أزرق)
local TitleLabel = MakeLabel(TopHeader, {
    Font = FONT_BOLD,
    TextSize = 28,
    Color = COLORS.ACCENT,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "صنع حكومة | EG - تتبع 4 لاعبين",
    TextScaled = false,
    Size = UDim2.new(1, -140, 1, 0),
    Position = UDim2.new(0, 12, 0, 6)
})

-- وصف/معلومة صغيرة تحت العنوان
local DescLabel = MakeLabel(TopHeader, {
    Font = FONT_REG,
    TextSize = 15,
    Color = COLORS.MUTE,
    Text = "اكتب أول حرفين على الأقل داخل أي خانة للربط التلقائي",
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.new(0, 12, 0, 40),
    Size = UDim2.new(1, -140, 0, 22)
})

-- زر إظهار / إخفاء صغير على الشريط
local ToggleBtn = New("TextButton", {
    Parent = TopHeader,
    Name = "ToggleBtn",
    BackgroundColor3 = COLORS.PANEL,
    AutoButtonColor = true,
    Text = "إخفاء",
    Font = FONT_MED,
    TextSize = 18,
    TextColor3 = COLORS.TEXT,
    Size = UDim2.new(0, 108, 0, 36),
    Position = UDim2.new(1, -120, 0, 18)
})
UICorner(ToggleBtn, 8)
UIStroke(ToggleBtn, 1, COLORS.STROKE, 0.18)

-- منطقة محتوى الشبكة 2×2
local GridContainer = New("Frame", {
    Parent = Root,
    Name = "GridContainer",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -40, 1, -140),
    Position = UDim2.new(0, 20, 0, 100),
})
local GridLayout = New("UIGridLayout", {
    Parent = GridContainer,
    CellPadding = UDim2.new(0, 14, 0, 14),
    CellSize = UDim2.new(0.5, -21, 0.5, -21),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Top,
})

-- فوتر بسيط (الحقوق منفصلة داخل الهيدر فوق كما طلبت)
local Footer = MakeLabel(Root, {
    Text = "حقوق: العم حكومة 🍷 | EG",
    Font = FONT_MED,
    TextSize = 16,
    Color = COLORS.ACCENT,
    TextXAlignment = Enum.TextXAlignment.Center,
    Position = UDim2.new(0, 0, 1, -36),
    Size = UDim2.new(1, 0, 0, 28),
})

-- ====================================
-- إنشاء كارت تتبع (مربع واحد في 2×2)
-- ====================================
-- نعمل مصنع (factory) للكروت؛ نكرر 4 مرات
local AvatarCache = {} -- كاش للصور: userId -> url

-- جلب صورة مربعة (HeadShot) بأمان
local function FetchAvatar(userId)
    if not userId or userId <= 0 then return "rbxassetid://0" end
    if AvatarCache[userId] then return AvatarCache[userId] end
    local ok, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    if ok and typeof(thumb) == "string" and thumb ~= "" then
        AvatarCache[userId] = thumb
        -- نحاول عمل Preload لتحسين الأداء
        pcall(function() ContentProvider:PreloadAsync({thumb}) end)
        return thumb
    end
    return "rbxassetid://0"
end

-- هيكل داخل Lua يمثل حالة كل كارت
local Card = {}
Card.__index = Card

function Card.new(index)
    local self = setmetatable({}, Card)
    -- إطار الكارت
    local cardFrame = New("Frame", {
        Parent = GridContainer,
        BackgroundColor3 = COLORS.PANEL,
        BorderSizePixel = 0,
        Name = "Card_" .. tostring(index)
    })
    UICorner(cardFrame, 10)
    UIStroke(cardFrame, 1, COLORS.STROKE, 0.18)
    UIPadding(cardFrame, 8, 10, 8, 10)

    -- شريط بحث في أعلى كل كارت (بدون placeholder)
    local searchBox = New("TextBox", {
        Parent = cardFrame,
        BackgroundColor3 = COLORS.BG,
        ClearTextOnFocus = false,
        Text = "",
        PlaceholderText = "",
        Font = FONT_REG,
        TextSize = 18,
        TextColor3 = COLORS.TEXT,
        Size = UDim2.new(1, 0, 0, 36),
        Name = "SearchBox"
    })
    UICorner(searchBox, 8)
    UIStroke(searchBox, 1, COLORS.STROKE, 0.16)

    -- إطار المحتوى: أفاتار + معلومات
    local content = New("Frame", {
        Parent = cardFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -120),
        Position = UDim2.new(0, 0, 0, 46)
    })

    -- أفاتار مربع
    local avatar = New("ImageLabel", {
        Parent = content,
        BackgroundColor3 = COLORS.HEADER,
        Size = UDim2.new(0, 84, 0, 84),
        Position = UDim2.new(0, 0, 0, 6),
        ScaleType = Enum.ScaleType.Crop,
        Image = "rbxassetid://0",
        Name = "Avatar"
    })
    UICorner(avatar, 8)
    UIStroke(avatar, 1, COLORS.STROKE, 0.2)

    -- نقطة حالة (اونلاين/اوفلاين)
    local statusDot = New("Frame", {
        Parent = content,
        BackgroundColor3 = COLORS.MUTE,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 84 - 12, 0, 6),
        Name = "StatusDot"
    })
    UICorner(statusDot, 10)

    -- يوزر ولقب
    local nameLabel = MakeLabel(content, {
        Font = FONT_BOLD,
        TextSize = 18,
        Color = COLORS.ACCENT,
        Text = "يوزر: -",
        Size = UDim2.new(1, -100, 0, 26),
        Position = UDim2.new(0, 100, 0, 6),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local displayLabel = MakeLabel(content, {
        Font = FONT_MED,
        TextSize = 16,
        Color = COLORS.TEXT,
        Text = "لقب: -",
        Size = UDim2.new(1, -100, 0, 24),
        Position = UDim2.new(0, 100, 0, 34),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- صف الإحصائيات: دخول وخروج ووقت
    local statsFrame = New("Frame", {
        Parent = cardFrame,
        BackgroundColor3 = COLORS.BG,
        Size = UDim2.new(1, 0, 0, 54),
        Position = UDim2.new(0, 0, 1, -64),
        Name = "Stats"
    })
    UICorner(statsFrame, 8)
    UIStroke(statsFrame, 1, COLORS.STROKE, 0.14)
    UIPadding(statsFrame, 8, 10, 8, 10)

    local joinLabel = MakeLabel(statsFrame, {
        Text = "دخول: 0 ✅",
        Font = FONT_MED, TextSize = 16, Color = COLORS.GOOD,
        Size = UDim2.new(0.33, 0, 1, 0), Position = UDim2.new(0, 6, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local leaveLabel = MakeLabel(statsFrame, {
        Text = "خروج: 0 ❌",
        Font = FONT_MED, TextSize = 16, Color = COLORS.BAD,
        Size = UDim2.new(0.33, 0, 1, 0), Position = UDim2.new(0.33, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local timeLabel = MakeLabel(statsFrame, {
        Text = "المدة: 00:00 ⏱️",
        Font = FONT_REG, TextSize = 15, Color = COLORS.MUTE,
        Size = UDim2.new(0.34, -12, 1, 0), Position = UDim2.new(0.66, 6, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right
    })

    -- الحقل الداخلي للحالة
    self.frame = cardFrame
    self.searchBox = searchBox
    self.avatar = avatar
    self.statusDot = statusDot
    self.nameLabel = nameLabel
    self.displayLabel = displayLabel
    self.joinLabel = joinLabel
    self.leaveLabel = leaveLabel
    self.timeLabel = timeLabel

    -- بيانات الحالة
    self.boundPlayer = nil
    self.joinCount = 0
    self.leaveCount = 0
    self.joinTick = 0
    self.running = false
    self._timerToken = nil
    self._connections = {} -- لتخزين الاتصالات حتى نغلقها
    return self
end

-- دوال لربط وفك الربط باللاعب
function Card:bindPlayer(plr)
    -- فك الربط السابق أولًا
    if self.boundPlayer then
        self:unbindPlayer()
    end
    if not plr then
        -- إعادة الحالة الافتراضية
        self.boundPlayer = nil
        self.nameLabel.Text = "يوزر: -"
        self.displayLabel.Text = "لقب: -"
        self.avatar.Image = "rbxassetid://0"
        self.statusDot.BackgroundColor3 = COLORS.MUTE
        self.joinLabel.Text = "دخول: 0 ✅"
        self.leaveLabel.Text = "خروج: 0 ❌"
        self.timeLabel.Text = "المدة: 00:00 ⏱️"
        self.joinCount, self.leaveCount = 0, 0
        self.running = false
        return
    end

    self.boundPlayer = plr
    self.nameLabel.Text = "يوزر: " .. (plr.Name or "-")
    self.displayLabel.Text = "لقب: " .. (plr.DisplayName or "-")

    -- جلب الصورة بشكل آمن
    spawn(function()
        local img = FetchAvatar(plr.UserId)
        if img and self.avatar then
            self.avatar.Image = img
        end
    end)

    -- إعداد العدّاد والوقت
    self.joinCount = 0
    self.leaveCount = 0
    self.joinTick = 0
    self.running = false

    -- حالة وجود الشخصية الآن
    local function onCharacterAdded()
        self.joinCount = self.joinCount + 1
        self.joinLabel.Text = ("دخول: %d ✅"):format(self.joinCount)
        self.joinTick = os.clock()
        self.running = true
        self.statusDot.BackgroundColor3 = COLORS.GOOD
        pcall(function() sndJoin:Play() end)
    end
    local function onCharacterRemoving()
        -- لا تعتمد فقط على CharacterRemoving؛ PlayerRemoving سيتعامل مع الخروج التام
        self.leaveCount = self.leaveCount + 1
        self.leaveLabel.Text = ("خروج: %d ❌"):format(self.leaveCount)
        self.running = false
        self.statusDot.BackgroundColor3 = COLORS.BAD
        pcall(function() sndLeave:Play() end)
    end

    -- وصل الحدث
    if plr.Character then
        onCharacterAdded()
    else
        -- لو ما عنده شخصية، نبقى جاهزين لحدث CharacterAdded
    end

    -- ربط الاتصالات
    self._connections = {}
    table.insert(self._connections, plr.CharacterAdded:Connect(onCharacterAdded))
    -- CharacterRemoving ممكن لا يتوفر في بعض الحالات، لذلك نعتمد ايضا على PlayerRemoving
    table.insert(self._connections, plr.CharacterRemoving and plr.CharacterRemoving:Connect(onCharacterRemoving) or nil)

    -- حدث خروج اللاعب من السيرفر (PlayerRemoving) نراقب في مستوى الأعلى
    -- تشغيل تايمر محلي لتحديث الواجهة كل ثانية
    local myToken = HttpService:GenerateGUID(false)
    self._timerToken = myToken
    spawn(function()
        while self._timerToken == myToken do
            if self.running and self.joinTick > 0 then
                local elapsed = os.clock() - self.joinTick
                if self.timeLabel then
                    self.timeLabel.Text = ("المدة: %02d:%02d ⏱️"):format(math.floor(elapsed/60), math.floor(elapsed%60))
                end
            end
            wait(1)
            if not self.boundPlayer then break end
        end
    end)
end

function Card:unbindPlayer()
    -- فك كل الاتصالات
    if self._timerToken then
        self._timerToken = nil
    end
    for _, conn in ipairs(self._connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    self._connections = {}
    -- لا نمسح النصوص هنا لأن الدالة bindPlayer أو setEmpty تقوم بذلك
    self.boundPlayer = nil
    self.running = false
end

function Card:destroy()
    self:unbindPlayer()
    if self.frame and self.frame.Destroy then
        pcall(function() self.frame:Destroy() end)
    end
end

-- ====================================
-- إعداد وإنشاء 4 كروت
-- ====================================
local cards = {}
for i = 1, 4 do
    local c = Card.new(i)
    cards[i] = c
end

-- ====================================
-- وظائف البحث والربط التلقائي (أول حرفين)
-- ====================================
-- بحث ذكي من أول حرفين أو أكثر (يوزر أو DisplayName)
local function findPlayerByPrefix(prefix)
    if not prefix or #prefix < 2 then return nil end
    local q = string.lower(prefix)
    for _, p in ipairs(Players:GetPlayers()) do
        local un = string.lower(p.Name or "")
        local dn = string.lower(p.DisplayName or "")
        if un:sub(1, #q) == q or dn:sub(1, #q) == q then
            return p
        end
    end
    return nil
end

-- دالة لتهيئة سلوك كل مربع (ربط البحث)
for _, c in ipairs(cards) do
    -- ضبط حجم/موقع الإطار تم إنشاؤه سابقًا
    -- السلوك: كلما تغير النص في searchBox، لو طول النص >=2 نبحث ونربط أول تطابق
    c.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = tostring(c.searchBox.Text or "")
        txt = txt:gsub("^%s+", ""):gsub("%s+$", "") -- trim
        if #txt >= 2 then
            local m = findPlayerByPrefix(txt)
            if m then
                c:bindPlayer(m)
            end
        else
            -- لو خانة البحث فاضية أو أقل من حرفين، نفك الربط
            if c.boundPlayer then
                c:unbindPlayer()
                -- إعادة عرض الحقول لافتراضي
                c.nameLabel.Text = "يوزر: -"
                c.displayLabel.Text = "لقب: -"
                c.avatar.Image = "rbxassetid://0"
                c.joinLabel.Text = "دخول: 0 ✅"
                c.leaveLabel.Text = "خروج: 0 ❌"
                c.timeLabel.Text = "المدة: 00:00 ⏱️"
                c.statusDot.BackgroundColor3 = COLORS.MUTE
            end
        end
    end)
end

-- ====================================
-- إدارة أحداث دخول وخروج اللاعبين (على مستوى عام)
-- ====================================
-- عند دخول لاعب جديد للسيرفر
Players.PlayerAdded:Connect(function(plr)
    -- لا نفعل ربط تلقائي هنا لأن الربط يتم من خلال كتابة الاسم في الخانات
    -- لكن إذا أحد الكروت مرتبط بنفس اللاعب بطريقة يدوية نريد أن يحدث JoinCount حين دخول الشخصية
    for _, c in ipairs(cards) do
        if c.boundPlayer and c.boundPlayer == plr then
            -- لو لديه شخصية بالفعل فحدث "دخول"
            -- (CharacterAdded سيعالج ذلك عادة على مستوى الكارت)
        end
    end
end)

-- عند خروج لاعب من السيرفر
Players.PlayerRemoving:Connect(function(plr)
    for _, c in ipairs(cards) do
        if c.boundPlayer and c.boundPlayer == plr then
            -- عدّ الخروج
            c.leaveCount = (c.leaveCount or 0) + 1
            c.leaveLabel.Text = ("خروج: %d ❌"):format(c.leaveCount)
            c.statusDot.BackgroundColor3 = COLORS.BAD
            c.running = false
            -- نترك bindPlayer للتعامل لاحقاً إن كتب المستخدم نفس الاسم مجددًا
            -- (لا نفك الربط تلقائيًا لعرض الإحصاءات)
        end
    end
end)

-- ====================================
-- زر إظهار/إخفاء و سحب اللوحة
-- ====================================
local boardVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
    boardVisible = not boardVisible
    Root.Visible = boardVisible
    ToggleBtn.Text = boardVisible and "إخفاء" or "إظهار"
end)

-- سحب الروت
do
    local dragging = false
    local dragStart = Vector2.new(0,0)
    local startPos = UDim2.new(0,0,0,0)
    Root.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- حفظ موضع Root محليًا (بسمات بسيطة باستخدام Attributes)
local function savePosition()
    local ok, data = pcall(function()
        return HttpService:JSONEncode({x = Root.Position.X.Offset, y = Root.Position.Y.Offset})
    end)
    if ok then
        LocalPlayer:SetAttribute("EG_Tracker_Pos", data)
    end
end

local function loadPosition()
    local raw = LocalPlayer:GetAttribute("EG_Tracker_Pos")
    if type(raw) == "string" and #raw > 0 then
        local ok, dat = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and dat and dat.x and dat.y then
            Root.Position = UDim2.new(0, dat.x, 0, dat.y)
        end
    end
end

Root:GetPropertyChangedSignal("Position"):Connect(function() savePosition() end)
loadPosition()

-- ====================================
-- إشعارات بصرية خفيفة (داخل اللعبة)
-- ====================================
local function SmallNotify(text, duration)
    duration = duration or 2
    -- كتلة بسيطة للعرض داخل الـ Root
    local notif = New("TextLabel", {
        Parent = Root,
        BackgroundColor3 = COLORS.PANEL,
        BackgroundTransparency = 0,
        Text = text,
        Font = FONT_MED,
        TextSize = 16,
        TextColor3 = COLORS.TEXT,
        Size = UDim2.new(0, 360, 0, 36),
        Position = UDim2.new(0.5, -180, 1, -46),
    })
    UICorner(notif, 8)
    UIStroke(notif, 1, COLORS.STROKE, 0.18)
    tween = TweenService:Create(notif, TweenInfo.new(0.18), {Position = notif.Position - UDim2.new(0,0,0,10)} )
    pcall(function() tween:Play() end)
    delay(duration, function() pcall(function() notif:Destroy() end) end)
end

-- ====================================
-- تحسينات صغيرة للأداء
-- ====================================
-- نحمّل الصور عند الحاجة ونبقي الكاش
-- (FetchAvatar يقوم بذلك فعليًا باستخدام ContentProvider:PreloadAsync)

-- ====================================
-- جاهزية السكربت / تلميحة للمستخدم
-- ====================================
-- رسالة أولية
SmallNotify("النسخة النهائية جاهزة — اكتب أول حرفين لربط لاعب في أي خانة.", 3)

-- نهاية السكربت
-- (يمكنك تعديل الستايل، الألوان، أو رفعه إلى GitHub كما تريد)
