-- ======================================================
-- صنع حكومة | كلان EG - تتبع 4 لاعبين
-- النسخة النهائية (بالعربي) - LocalScript
-- ======================================================

-- خدمات
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- تنظيف أي واجهة سابقة
local parentGui = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
    local old = parentGui:FindFirstChild("EG_Tracker_GUI")
    if old then old:Destroy() end
end)

-- ألوان وخطوط بسيطة
local COLORS = {
    BG = Color3.fromRGB(18,18,20),
    PANEL = Color3.fromRGB(28,28,32),
    HEADER = Color3.fromRGB(24,24,28),
    STROKE = Color3.fromRGB(48,48,56),
    TEXT = Color3.fromRGB(230,230,235),
    ACCENT = Color3.fromRGB(0,150,255),
    GOOD = Color3.fromRGB(60,210,90),
    BAD = Color3.fromRGB(240,70,70),
    MUTED = Color3.fromRGB(160,165,175)
}

-- دوال مساعدة UI
local function New(class, props)
    local inst = Instance.new(class)
    if props then for k,v in pairs(props) do
        pcall(function() inst[k] = v end)
    end end
    return inst
end

local function UICorner(parent, radius)
    local c = Instance.new("UICorner")
    c.Parent = parent
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function UIStroke(parent, thickness, color, transp)
    local s = Instance.new("UIStroke")
    s.Parent = parent
    s.Thickness = thickness or 1
    s.Color = color or COLORS.STROKE
    s.Transparency = transp or 0.2
    return s
end

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$",""))
end

local function formatTimeHM(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    if h > 0 then
        if m > 0 then
            return string.format("%d ساعة %d دقيقة", h, m)
        else
            return string.format("%d ساعة", h)
        end
    else
        return string.format("%d دقيقة", m)
    end
end

local function formatClock(ts)
    -- ts: os.time() or os.date("*t")
    local t = type(ts) == "number" and os.date("*t", ts) or ts
    if not t then return "-" end
    local hour = t.hour
    local min = t.min
    local suffix = (hour >= 12) and "م" or "ص"
    local displayHour = hour % 12
    if displayHour == 0 then displayHour = 12 end
    return string.format("%02d:%02d %s", displayHour, min, suffix)
end

-- جلب صورة البروفايل مربعة (كاش)
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

-- بحث ذكي من أول حرفين (يوزر أو DisplayName)
local function findPlayerByPrefix(q)
    q = tostring(q or "")
    q = trim(q:lower())
    if #q < 2 then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        local un = (p.Name or ""):lower()
        local dn = (p.DisplayName or ""):lower()
        if un:sub(1, #q) == q or dn:sub(1, #q) == q then
            return p
        end
    end
    return nil
end

-- بناء الواجهة
local ScreenGui = New("ScreenGui")
ScreenGui.Name = "EG_Tracker_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

-- Root
local Root = New("Frame")
Root.Name = "Root"
Root.Parent = ScreenGui
Root.Size = UDim2.new(0, 760, 0, 420)
Root.Position = UDim2.new(0.5, -380, 0.5, -210)
Root.BackgroundColor3 = COLORS.BG
Root.BorderSizePixel = 0
UICorner(Root, 14)
UIStroke(Root, 1, COLORS.STROKE, 0.2)

-- Header (العنوان والحقوق)
local Header = New("Frame")
Header.Parent = Root
Header.Size = UDim2.new(1, -40, 0, 74)
Header.Position = UDim2.new(0, 20, 0, 16)
Header.BackgroundColor3 = COLORS.HEADER
Header.BorderSizePixel = 0
UICorner(Header, 12)
UIStroke(Header, 1, COLORS.STROKE, 0.18)

local TitleLabel = New("TextLabel")
TitleLabel.Parent = Header
TitleLabel.AnchorPoint = Vector2.new(0,0)
TitleLabel.Size = UDim2.new(1, -160, 0.6, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 22
TitleLabel.TextColor3 = COLORS.ACCENT
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "صنع حكومة | كلان EG - تتبع 4 لاعبين"

local RightsLabel = New("TextLabel")
RightsLabel.Parent = Header
RightsLabel.AnchorPoint = Vector2.new(0,0)
RightsLabel.Size = UDim2.new(1, -160, 0.35, 0)
RightsLabel.Position = UDim2.new(0, 16, 0, 38)
RightsLabel.BackgroundTransparency = 1
RightsLabel.Font = Enum.Font.Gotham
RightsLabel.TextSize = 14
RightsLabel.TextColor3 = COLORS.MUTED
RightsLabel.TextXAlignment = Enum.TextXAlignment.Left
RightsLabel.Text = "العم حكومة 🍷  |  EG"

-- زر صغير للفتح/القفل (قابل للسحب)
local ToggleBtn = New("TextButton")
ToggleBtn.Parent = Header
ToggleBtn.Size = UDim2.new(0, 96, 0, 34)
ToggleBtn.Position = UDim2.new(1, -112, 0, 20)
ToggleBtn.BackgroundColor3 = COLORS.PANEL
ToggleBtn.AutoButtonColor = true
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.TextSize = 16
ToggleBtn.TextColor3 = COLORS.TEXT
ToggleBtn.Text = "إخفاء"
ToggleBtn.Active = true
ToggleBtn.Selectable = true
ToggleBtn.Draggable = true
UICorner(ToggleBtn, 8)
UIStroke(ToggleBtn, 1, COLORS.STROKE, 0.18)

-- خط فاصل تحت الهيدر
local Line = New("Frame")
Line.Parent = Root
Line.Size = UDim2.new(1, -40, 0, 2)
Line.Position = UDim2.new(0, 20, 0, 110)
Line.BackgroundColor3 = COLORS.ACCENT
Line.BorderSizePixel = 0

-- Grid container 2x2
local Grid = New("Frame")
Grid.Parent = Root
Grid.Size = UDim2.new(1, -40, 1, -150)
Grid.Position = UDim2.new(0, 20, 0, 124)
Grid.BackgroundTransparency = 1

local GridLayout = New("UIGridLayout")
GridLayout.Parent = Grid
GridLayout.CellPadding = UDim2.new(0, 14, 0, 14)
GridLayout.CellSize = UDim2.new(0.5, -21, 0.5, -21)
GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
GridLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- مصنع كارت اللاعب
local CardProto = {}
CardProto.__index = CardProto

function CardProto.new()
    local self = setmetatable({}, CardProto)
    -- card frame
    local frame = New("Frame")
    frame.Parent = Grid
    frame.BackgroundColor3 = COLORS.PANEL
    frame.BorderSizePixel = 0
    UICorner(frame, 10)
    UIStroke(frame, 1, COLORS.STROKE, 0.18)
    self.Frame = frame

    -- Search box أعلى الكارد (فاضي)
    local search = New("TextBox")
    search.Parent = frame
    search.BackgroundColor3 = COLORS.BG
    search.ClearTextOnFocus = false
    search.PlaceholderText = ""
    search.Text = ""
    search.Font = Enum.Font.Gotham
    search.TextSize = 18
    search.TextColor3 = COLORS.TEXT
    search.Size = UDim2.new(1, -12, 0, 36)
    search.Position = UDim2.new(0, 6, 0, 6)
    UICorner(search, 8)
    UIStroke(search, 1, COLORS.STROKE, 0.14)
    self.Search = search

    -- content area
    local content = New("Frame")
    content.Parent = frame
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -12, 1, -108)
    content.Position = UDim2.new(0, 6, 0, 48)

    -- avatar (مربعة)
    local avatar = New("ImageLabel")
    avatar.Parent = content
    avatar.BackgroundColor3 = COLORS.HEADER
    avatar.Size = UDim2.new(0, 84, 0, 84)
    avatar.Position = UDim2.new(0, 0, 0, 0)
    avatar.ScaleType = Enum.ScaleType.Crop
    avatar.Image = "rbxassetid://0"
    UICorner(avatar, 8)
    UIStroke(avatar, 1, COLORS.STROKE, 0.18)
    self.Avatar = avatar

    -- تحت الصورة: بداية التتبع ومدة التتبع (نص صغير)
    local meta = New("Frame")
    meta.Parent = content
    meta.BackgroundTransparency = 1
    meta.Size = UDim2.new(1, -100, 0, 84)
    meta.Position = UDim2.new(0, 100, 0, 0)

    local nameLbl = New("TextLabel")
    nameLbl.Parent = meta
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 18
    nameLbl.TextColor3 = COLORS.TEXT
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Size = UDim2.new(1, 0, 0, 26)
    nameLbl.Position = UDim2.new(0, 0, 0, 0)
    nameLbl.Text = "-"

    local startLbl = New("TextLabel")
    startLbl.Parent = meta
    startLbl.BackgroundTransparency = 1
    startLbl.Font = Enum.Font.Gotham
    startLbl.TextSize = 14
    startLbl.TextColor3 = COLORS.MUTED
    startLbl.TextXAlignment = Enum.TextXAlignment.Left
    startLbl.Size = UDim2.new(1, 0, 0, 20)
    startLbl.Position = UDim2.new(0, 0, 0, 30)
    startLbl.Text = "بداية التتبع: -"

    local durationLbl = New("TextLabel")
    durationLbl.Parent = meta
    durationLbl.BackgroundTransparency = 1
    durationLbl.Font = Enum.Font.Gotham
    durationLbl.TextSize = 14
    durationLbl.TextColor3 = COLORS.MUTED
    durationLbl.TextXAlignment = Enum.TextXAlignment.Left
    durationLbl.Size = UDim2.new(1, 0, 0, 20)
    durationLbl.Position = UDim2.new(0, 0, 0, 50)
    durationLbl.Text = "المدة: 0 ساعة 0 دقيقة"

    -- bottom stats: اسم او نص حالة مع ايقونات دخول/خروج
    local bottom = New("Frame")
    bottom.Parent = frame
    bottom.Size = UDim2.new(1, -12, 0, 48)
    bottom.Position = UDim2.new(0, 6, 1, -54)
    bottom.BackgroundColor3 = COLORS.BG
    bottom.BorderSizePixel = 0
    UICorner(bottom, 8)
    UIStroke(bottom, 1, COLORS.STROKE, 0.12)

    local stateLbl = New("TextLabel")
    stateLbl.Parent = bottom
    stateLbl.BackgroundTransparency = 1
    stateLbl.Font = Enum.Font.GothamBold
    stateLbl.TextSize = 16
    stateLbl.TextColor3 = COLORS.TEXT
    stateLbl.TextXAlignment = Enum.TextXAlignment.Left
    stateLbl.Size = UDim2.new(0.6, 0, 1, 0)
    stateLbl.Position = UDim2.new(0, 8, 0, 0)
    stateLbl.Text = "-"

    local joinCnt = New("TextLabel")
    joinCnt.Parent = bottom
    joinCnt.BackgroundTransparency = 1
    joinCnt.Font = Enum.Font.Gotham
    joinCnt.TextSize = 14
    joinCnt.TextColor3 = COLORS.GOOD
    joinCnt.TextXAlignment = Enum.TextXAlignment.Right
    joinCnt.Size = UDim2.new(0.2, -8, 1, 0)
    joinCnt.Position = UDim2.new(0.6, 0, 0, 0)
    joinCnt.Text = "دخول: 0"

    local leaveCnt = New("TextLabel")
    leaveCnt.Parent = bottom
    leaveCnt.BackgroundTransparency = 1
    leaveCnt.Font = Enum.Font.Gotham
    leaveCnt.TextSize = 14
    leaveCnt.TextColor3 = COLORS.BAD
    leaveCnt.TextXAlignment = Enum.TextXAlignment.Right
    leaveCnt.Size = UDim2.new(0.2, -8, 1, 0)
    leaveCnt.Position = UDim2.new(0.8, 0, 0, 0)
    leaveCnt.Text = "خروج: 0"

    -- الحالة الافتراضية في الجدول
    self.Player = nil
    self.SearchBox = search
    self.Avatar = avatar
    self.NameLabel = nameLbl
    self.StartLabel = startLbl
    self.DurationLabel = durationLbl
    self.StateLabel = stateLbl
    self.JoinLabel = joinCnt
    self.LeaveLabel = leaveCnt
    self._connections = {}
    self._timerToken = nil

    return self
end

-- ربط/فك الربط للكارت
function CardProto:bind(plr)
    -- فك الربط لو فيه سابق
    self:unbind()

    if not plr then
        -- إعادة الحالة الافتراضية
        self.Player = nil
        self.NameLabel.Text = "-"
        self.StartLabel.Text = "بداية التتبع: -"
        self.DurationLabel.Text = "المدة: 0 ساعة 0 دقيقة"
        self.Avatar.Image = "rbxassetid://0"
        self.StateLabel.Text = "-"
        self.JoinLabel.Text = "دخول: 0"
        self.LeaveLabel.Text = "خروج: 0"
        return
    end

    self.Player = plr
    self.NameLabel.Text = plr.DisplayName or plr.Name or "-"
    -- صورة البروفايل مربعة
    spawn(function()
        local img = FetchAvatar(plr.UserId)
        if img and self.Avatar and typeof(img) == "string" then
            pcall(function() self.Avatar.Image = img end)
        end
    end)

    -- سجل بداية التتبع (التوقيت الفعلي)
    local startTime = os.time()
    self.StartLabel.Text = "بداية التتبع: " .. formatClock(startTime)
    self._startTime = startTime
    self.JoinLabel.Text = "دخول: 0"
    self.LeaveLabel.Text = "خروج: 0"
    self.StateLabel.Text = "الحالة: متصل؟"
    self.StateLabel.TextColor3 = COLORS.MUTED

    -- internal handlers
    local function onCharAdded(char)
        -- سجل دخول
        self.JoinLabel.Text = "دخول: " .. (tonumber(self.JoinLabel.Text:match("%d+")) or 0) + 1
        self.StateLabel.Text = "الحالة: داخل"
        self.StateLabel.TextColor3 = COLORS.GOOD
        pcall(function() -- صوت أو Notify لو حبّيت تضيف لاحقًا end)
        end
    end
    local function onCharRemoving()
        self.LeaveLabel.Text = "خروج: " .. (tonumber(self.LeaveLabel.Text:match("%d+")) or 0) + 1
        self.StateLabel.Text = "الحالة: خارج"
        self.StateLabel.TextColor3 = COLORS.BAD
    end

    -- وصل الأحداث
    if plr.Character then
        onCharAdded(plr.Character)
    end
    table.insert(self._connections, plr.CharacterAdded:Connect(onCharAdded))
    if plr.CharacterRemoving then
        table.insert(self._connections, plr.CharacterRemoving:Connect(onCharRemoving))
    end

    -- تحديث المدة كل دقيقة (نظراً لطلبك عرض الساعات والدقائق)
    local token = HttpService:GenerateGUID(false)
    self._timerToken = token
    spawn(function()
        while self._timerToken == token do
            if self._startTime then
                local elapsed = os.time() - self._startTime
                local h = math.floor(elapsed / 3600)
                local m = math.floor((elapsed % 3600) / 60)
                self.DurationLabel.Text = string.format("المدة: %d ساعة %d دقيقة", h, m)
            end
            wait(1) -- تحديث كل ثانية لكن العرض يهتم بالساعات والدقائق
        end
    end)
end

function CardProto:unbind()
    if self._timerToken then
        self._timerToken = nil
    end
    for _, c in ipairs(self._connections) do
        if c and c.Disconnect then
            pcall(function() c:Disconnect() end)
        end
    end
    self._connections = {}
    self.Player = nil
end

function CardProto:destroy()
    self:unbind()
    if self.Frame and self.Frame.Destroy then
        pcall(function() self.Frame:Destroy() end)
    end
end

-- إنشاء 4 كروت
local cards = {}
for i = 1, 4 do
    local card = CardProto.new()
    cards[i] = card
end

-- تكوين سلوك البحث لكل كارت (يلتقط من أول حرفين)
for _, card in ipairs(cards) do
    local last = ""
    card.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = trim(card.SearchBox.Text or "")
        if txt == last then return end
        last = txt
        if #txt >= 2 then
            local found = findPlayerByPrefix(txt)
            if found then
                card:bind(found)
            end
        else
            card:unbind()
            -- إعادة العرض الافتراضي
            card.NameLabel.Text = "-"
            card.StartLabel.Text = "بداية التتبع: -"
            card.DurationLabel.Text = "المدة: 0 ساعة 0 دقيقة"
            card.Avatar.Image = "rbxassetid://0"
            card.StateLabel.Text = "-"
            card.JoinLabel.Text = "دخول: 0"
            card.LeaveLabel.Text = "خروج: 0"
        end
    end)
end

-- عند خروج أي لاعب، لو أحد الكروت متربط باللاعب يحدث خروج
Players.PlayerRemoving:Connect(function(plr)
    for _, card in ipairs(cards) do
        if card.Player and card.Player == plr then
            -- نزيد عدد الخروج ونعرضه
            local cur = tonumber(card.LeaveLabel.Text:match("%d+")) or 0
            card.LeaveLabel.Text = "خروج: " .. (cur + 1)
            card.StateLabel.Text = "الحالة: خارج"
            card.StateLabel.TextColor3 = COLORS.BAD
            card:unbind() -- نتركه مفصول لإعادة ربط لاحقًا
        end
    end
end)

-- زر الإخفاء/الإظهار المتحرك
ToggleBtn.MouseButton1Click:Connect(function()
    local visible = Root.Visible
    Root.Visible = not visible
    ToggleBtn.Text = visible and "إظهار" or "إخفاء"
end)

-- سحب Root (Draggable) - سلوك يدوي لأن بعض العناصر لا تدعم Draggable مباشرة
do
    local dragging = false
    local dragStart = Vector2.new(0,0)
    local startPos = Root.Position
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

-- حفظ موضع الواجهة محليًا (Attributes)
local posKey = "EG_TRACKER_POS"
local function savePos()
    pcall(function()
        local data = HttpService:JSONEncode({x = Root.Position.X.Offset, y = Root.Position.Y.Offset})
        LocalPlayer:SetAttribute(posKey, data)
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
Root:GetPropertyChangedSignal("Position"):Connect(function() savePos() end)
loadPos()

-- تلميح أولي
local function showTemp(msg, sec)
    sec = sec or 3
    local t = New("TextLabel")
    t.Parent = Root
    t.Size = UDim2.new(0.6, 0, 0, 36)
    t.Position = UDim2.new(0.2, 0, 1, -46)
    t.BackgroundColor3 = COLORS.PANEL
    t.TextColor3 = COLORS.TEXT
    t.Font = Enum.Font.Gotham
    t.TextSize = 16
    t.Text = msg
    UICorner(t, 8)
    UIStroke(t, 1, COLORS.STROKE, 0.16)
    delay(sec, function() pcall(function() t:Destroy() end) end)
end

showTemp("اكتب أول حرفين أو أكثر داخل أي خانة لربط لاعب وبدء التتبع", 4)

-- جاهز
