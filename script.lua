--[[
    ============================================================
    GS4 | العم حكومه  — لوحة تتبع 4 لاعبين (نهائية • حجم متوسط-صغير)
    ============================================================
    المزايا:
      • 4 خانات تتبع (شبكة 2×2) — كل خانة ببحث مستقل
      • التقاط من أول حرفين (Username أو DisplayName) — فوري وسريع
      • صورة الأفاتار لا تظهر إلا بعد تحديد لاعب فعلي
      • عداد دخول/خروج حقيقي (PlayerAdded/PlayerRemoving)
      • "منذ بدء التتبع" + مدة الجلسة لكل خانة
      • سجل جلسة محفوظ في _G.GS4_TRACK_HISTORY (بدون أزرار إضافية)
      • زر فتح/قفل صغير وقابل للسحب + اللوحة نفسها قابلة للسحب
      • واجهة عربية بالكامل، نصوص واضحة، ألوان هادئة (أسود/أزرق)
      • حجم لوحة متوسط-صغير (يمكن تعديله من PANEL_WIDTH/HEIGHT)

    ملاحظات:
      - امسح النص من الخانة لإيقاف التتبع لها تلقائيًا.
      - يمنع تكرار نفس اللاعب في أكتر من خانة بذكاء.
      - لا يوجد "Placeholder" نصي — الصندوق فاضي كما طلبت.
      - لا توجد أزرار "بدء" — الالتقاط تلقائي عند الكتابة (≥ 2 حروف).
      - زر صغير للفتح/القفل فقط، ومتحرّك (قابل للسحب).

    نسخة: v10 — Final GS4
]]--

--========[ خدمات Roblox ]========--
local Players          = game:GetService("Players")
local StarterGui       = game:GetService("StarterGui")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local ContentProvider  = game:GetService("ContentProvider")
local CoreGui          = game:GetService("CoreGui")

local LP = Players.LocalPlayer

--========[ ضبط الثيم/الألوان ]========--
local THEME = {
    bg           = Color3.fromRGB(18,18,18),
    panel        = Color3.fromRGB(26,26,26),
    header       = Color3.fromRGB(22,22,22),
    stroke       = Color3.fromRGB(60,60,60),
    text         = Color3.fromRGB(230,235,255),
    midText      = Color3.fromRGB(180,190,210),
    blue         = Color3.fromRGB(60,170,255),
    green        = Color3.fromRGB(70,220,110),
    red          = Color3.fromRGB(255,70,80),
    amber        = Color3.fromRGB(255,190,70),
    dotOnline    = Color3.fromRGB(60,220,110),
    dotOffline   = Color3.fromRGB(155,155,155),
    inputBg      = Color3.fromRGB(42,42,42),
    inputText    = Color3.fromRGB(235,240,255),
    hint         = Color3.fromRGB(150,160,180),
    shadow       = Color3.fromRGB(0,0,0),
}

-- مقاسات اللوحة (متوسط-صغير)
local PANEL_WIDTH  = 680
local PANEL_HEIGHT = 420

--========[ أدوات مساعدة ]========--
local function safe(p, f, ...)
    local ok, res = pcall(f, ...)
    if ok then return res end
    return nil
end

local function pad2(n) n = math.floor(n or 0); return (n<10 and ("0"..n) or tostring(n)) end

local function fmtDuration(sec)
    sec = math.max(0, math.floor(sec or 0))
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    if h > 0 then
        return string.format("%d:%s:%s", h, pad2(m), pad2(s))
    else
        return string.format("%s:%s", pad2(m), pad2(s))
    end
end

local function prettyAgo(sinceTick)
    local d = tick() - (sinceTick or tick())
    if d < 1 then return "الآن" end
    local m = math.floor(d / 60)
    local s = math.floor(d % 60)
    if m > 0 then
        return string.format("%d دقيقة و %d ث", m, s)
    else
        return string.format("%d ث", s)
    end
end

local function toast(txt, dur)
    safe(true, function()
        StarterGui:SetCore("SendNotification", {
            Title = "GS4 | العم حكومه  🍷",
            Text  = txt,
            Duration = dur or 2.0
        })
    end)
end

local function getHeadshot(userId)
    local ok, content = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and content then return content end
    return ""
end

local function normalize(s)
    if not s then return "" end
    s = tostring(s)
    -- إزالة مسافات زائدة
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    return s
end

local function findMatch(prefix)
    prefix = normalize(prefix)
    if #prefix < 2 then return nil end
    local low = prefix:lower()
    -- أولوية: اسم المستخدم
    for _,p in ipairs(Players:GetPlayers()) do
        if p and p.Name and p.DisplayName then
            local n = p.Name:lower()
            if n:sub(1, #low) == low then
                return p
            end
        end
    end
    -- ثم اللقب
    for _,p in ipairs(Players:GetPlayers()) do
        if p and p.DisplayName then
            local d = p.DisplayName:lower()
            if d:sub(1, #low) == low then
                return p
            end
        end
    end
    return nil
end

--========[ حفظ سجل الجلسة ]========--
_G.GS4_TRACK_HISTORY = _G.GS4_TRACK_HISTORY or {}
local SESSION_ID = _G.GS4_SESSION_ID or HttpService:GenerateGUID(false)
_G.GS4_SESSION_ID = SESSION_ID

local function logEvent(userId, name, display, kind)
    table.insert(_G.GS4_TRACK_HISTORY, {
        sid = SESSION_ID,
        t   = tick(),
        userId = userId,
        name   = name,
        display= display,
        kind   = kind -- "join" / "leave" / "set" / "clear"
    })
end

--========[ إنشاء الواجهة ]========--
local gui = Instance.new("ScreenGui")
gui.Name = "GS4_Gov_Tracker_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = CoreGui

-- ظل أسود خفيف
local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.BackgroundColor3 = THEME.shadow
shadow.BackgroundTransparency = 0.4
shadow.Size = UDim2.fromOffset(PANEL_WIDTH + 16, PANEL_HEIGHT + 16)
shadow.AnchorPoint = Vector2.new(0.5, 0)
shadow.Position = UDim2.fromScale(0.5, 0.20)
shadow.Active = true
shadow.Parent = gui

-- اللوحة الأساسية
local root = Instance.new("Frame")
root.Name = "Root"
root.BackgroundColor3 = THEME.bg
root.BorderSizePixel = 0
root.Size = UDim2.fromOffset(PANEL_WIDTH, PANEL_HEIGHT)
root.Position = UDim2.new(0, 8, 0, 8)
root.Parent = shadow

local cornerRoot = Instance.new("UICorner")
cornerRoot.CornerRadius = UDim.new(0, 12)
cornerRoot.Parent = root

local strokeRoot = Instance.new("UIStroke")
strokeRoot.Thickness = 1
strokeRoot.Color = THEME.stroke
strokeRoot.Transparency = 0.3
strokeRoot.Parent = root

-- شريط العنوان
local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = THEME.header
header.BorderSizePixel = 0
header.Size = UDim2.new(1, 0, 0, 56)
header.Parent = root

local cornerHeader = Instance.new("UICorner")
cornerHeader.CornerRadius = UDim.new(0, 12)
cornerHeader.Parent = header

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextColor3 = THEME.blue
title.Text = "GS4 | العم حكومه  🍷"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = header

-- جعل اللوحة قابلة للسحب من الهيدر
do
    local dragging = false
    local dragStart, startPos
    header.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = io.Position
            startPos = shadow.Position
            io.Changed:Connect(function()
                if io.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(io)
        if dragging and (io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch) then
            local delta = io.Position - dragStart
            shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- زر فتح/قفل صغير ومتحرّك
local mini = Instance.new("ImageButton")
mini.Name = "GS4_Toggle"
mini.BackgroundColor3 = THEME.header
mini.AutoButtonColor = true
mini.Size = UDim2.fromOffset(36,36)
mini.Position = UDim2.new(1, -54, 0, 110)
mini.Image = "rbxassetid://3926305904"
mini.ImageRectOffset = Vector2.new(884, 284)   -- أيقونة "قائمة"
mini.ImageRectSize   = Vector2.new(36, 36)
mini.Parent = gui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = mini

local miniStroke = Instance.new("UIStroke")
miniStroke.Thickness = 1
miniStroke.Color = THEME.stroke
miniStroke.Transparency = 0.2
miniStroke.Parent = mini

-- جعل زر التبديل قابل للسحب
do
    local dragging = false
    local dragStart, startPos
    mini.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = io.Position
            startPos = mini.Position
            io.Changed:Connect(function()
                if io.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(io)
        if dragging and (io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch) then
            local delta = io.Position - dragStart
            mini.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- حركة فتح/قفل
local PANEL_OPEN = true
local function togglePanel(show)
    PANEL_OPEN = (show == nil) and not PANEL_OPEN or show
    local yPos = PANEL_OPEN and 0.20 or -0.60
    root.Visible = true
    shadow.Visible = true
    TweenService:Create(shadow, TweenInfo.new(0.30, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {Position = UDim2.fromScale(0.5, yPos)}):Play()
end

mini.MouseButton1Click:Connect(function()
    togglePanel()
end)

-- شبكة 2×2
local grid = Instance.new("Frame")
grid.BackgroundTransparency = 1
grid.Size = UDim2.new(1, -20, 1, -76)
grid.Position = UDim2.new(0, 10, 0, 66)
grid.Parent = root

local UIGrid = Instance.new("UIGridLayout")
UIGrid.CellPadding = UDim2.fromOffset(12, 12)
UIGrid.CellSize    = UDim2.new(0.5, -6, 0.5, -6)
UIGrid.FillDirectionMaxCells = 2
UIGrid.SortOrder   = Enum.SortOrder.LayoutOrder
UIGrid.Parent = grid

--========[ نوع حالة الخانة ]========--
-- (تعريف وصفي بالتعليقات لتوضيح البنية)
-- state = {
--   Frame, Input, Avatar, NameL, DisplayL, JoinL, LeaveL, SinceL, ElapsedL, Dot
--   target          = Player?
--   targetId        = number?
--   joins, leaves   = number
--   since, started  = tick()
--   online          = boolean
--   lastInput       = string
--   conAdded        = RBXScriptConnection?
--   conRemoved      = RBXScriptConnection?
--   hb              = RBXScriptConnection?
-- }

--========[ أدوات الخانة ]========--
local function makeLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = props.Font or Enum.Font.Gotham
    l.TextColor3 = props.Color or THEME.text
    l.TextScaled = true
    l.Text = props.Text or ""
    l.Size = props.Size or UDim2.new(0,100,0,20)
    l.Position = props.Position or UDim2.new(0,0,0,0)
    l.Parent = parent
    return l
end

local function makeCard(index)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = THEME.panel
    card.BorderSizePixel = 0
    local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0,10); cr.Parent = card
    local st = Instance.new("UIStroke"); st.Color = THEME.stroke; st.Transparency=0.25; st.Parent = card

    -- ترويسة مع الإدخال
    local head = Instance.new("Frame")
    head.BackgroundColor3 = THEME.inputBg
    head.BorderSizePixel = 0
    head.Size = UDim2.new(1, -20, 0, 46)
    head.Position = UDim2.new(0, 10, 0, 10)
    head.Parent = card
    local ch = Instance.new("UICorner"); ch.CornerRadius = UDim.new(0,8); ch.Parent = head

    local input = Instance.new("TextBox")
    input.BackgroundTransparency = 1
    input.Size = UDim2.new(1, -16, 1, -12)
    input.Position = UDim2.new(0, 8, 0, 6)
    input.Text = ""                 -- بدون Placeholder
    input.TextColor3 = THEME.inputText
    input.ClearTextOnFocus = false
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Font = Enum.Font.Gotham
    input.TextScaled = true
    input.Parent = head

    -- جسم الخانة
    local body = Instance.new("Frame")
    body.BackgroundTransparency = 1
    body.Size = UDim2.new(1, -20, 1, -76)
    body.Position = UDim2.new(0, 10, 0, 60)
    body.Parent = card

    -- صورة أفاتار
    local avatar = Instance.new("ImageLabel")
    avatar.BackgroundColor3 = THEME.stroke
    avatar.Image = ""
    avatar.Visible = false
    avatar.Size = UDim2.fromOffset(86, 86)
    avatar.Position = UDim2.new(0, 6, 0, 6)
    avatar.ScaleType = Enum.ScaleType.Fit
    local avc = Instance.new("UICorner"); avc.CornerRadius = UDim.new(1,0); avc.Parent = avatar
    avatar.Parent = body

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(10,10)
    dot.Position = UDim2.new(0, 86-12, 0, 6)
    dot.BackgroundColor3 = THEME.dotOffline
    dot.Visible = false
    local dotc = Instance.new("UICorner"); dotc.CornerRadius = UDim.new(1,0); dotc.Parent = dot
    dot.Parent = body

    -- نصوص
    local labels = Instance.new("Frame")
    labels.BackgroundTransparency = 1
    labels.Size = UDim2.new(1, -100, 0, 60)
    labels.Position = UDim2.new(0, 100, 0, 8)
    labels.Parent = body

    local nameL = makeLabel(labels, {
        Text = "اسم المستخدم: -", Color = THEME.blue,
        Font = Enum.Font.GothamBold, Size = UDim2.new(1,0,0.5,0), Position = UDim2.new(0,0,0,0)
    })
    local displayL = makeLabel(labels, {
        Text = "اللقب: -", Color = THEME.midText,
        Font = Enum.Font.Gotham, Size = UDim2.new(1,0,0.5,0), Position = UDim2.new(0,0,0.5,0)
    })

    local counters = Instance.new("Frame")
    counters.BackgroundTransparency = 1
    counters.Size = UDim2.new(1, -16, 0, 44)
    counters.Position = UDim2.new(0, 8, 0, 98)
    counters.Parent = body

    local joinL = makeLabel(counters, {
        Text = "مرات الدخول: 0", Color = THEME.green,
        Size = UDim2.new(0.5,-4,1,0), Position = UDim2.new(0,0,0,0)
    })
    local leaveL = makeLabel(counters, {
        Text = "مرات الخروج: 0", Color = THEME.red,
        Size = UDim2.new(0.5,-4,1,0), Position = UDim2.new(0.5,8,0,0)
    })
    leaveL.TextXAlignment = Enum.TextXAlignment.Right

    local sinceL = makeLabel(body, {
        Text = "منذ بدء التتبع: -", Color = THEME.midText,
        Size = UDim2.fromOffset(260, 22), Position = UDim2.new(0, 8, 1, -52)
    })
    local elapsedL = makeLabel(body, {
        Text = "المدة: 00:00", Color = THEME.midText,
        Size = UDim2.fromOffset(200, 22), Position = UDim2.new(0, 8, 1, -28)
    })

    -- حالة
    local state = {
        Frame = card, Input = input, Avatar = avatar, NameL = nameL, DisplayL = displayL,
        JoinL = joinL, LeaveL = leaveL, SinceL = sinceL, ElapsedL = elapsedL, Dot = dot,

        target   = nil,
        targetId = nil,
        joins    = 0,
        leaves   = 0,
        since    = nil,
        started  = nil,
        online   = false,
        lastInput= "",
        conAdded = nil,
        conRemoved = nil,
        hb = nil
    }

    -- دوال داخلية
    local function setOnline(on)
        state.online = on and true or false
        state.Dot.Visible = true
        state.Dot.BackgroundColor3 = on and THEME.dotOnline or THEME.dotOffline
    end

    local function refresh()
        if state.target then
            state.NameL.Text    = ("اسم المستخدم: %s"):format(state.target.Name)
            state.DisplayL.Text = ("اللقب: %s"):format(state.target.DisplayName or "-")
            state.JoinL.Text    = ("مرات الدخول: %d"):format(state.joins)
            state.LeaveL.Text   = ("مرات الخروج: %d"):format(state.leaves)
            state.SinceL.Text   = ("منذ بدء التتبع: %s"):format(prettyAgo(state.since or tick()))
        else
            state.NameL.Text    = "اسم المستخدم: -"
            state.DisplayL.Text = "اللقب: -"
            state.JoinL.Text    = "مرات الدخول: 0"
            state.LeaveL.Text   = "مرات الخروج: 0"
            state.SinceL.Text   = "منذ بدء التتبع: -"
        end
    end

    local function clear()
        if state.conAdded then state.conAdded:Disconnect() end
        if state.conRemoved then state.conRemoved:Disconnect() end
        state.conAdded, state.conRemoved = nil, nil
        state.target, state.targetId = nil, nil
        state.joins, state.leaves = 0, 0
        state.since, state.started = nil, nil
        state.online = false
        state.Avatar.Visible = false
        state.Avatar.Image = ""
        state.Dot.Visible = false
        refresh()
        logEvent(0, "-", "-", "clear")
    end

    local function applyPlayer(plr)
        clear()
        state.target   = plr
        state.targetId = plr.UserId
        state.since    = tick()
        state.started  = tick()
        state.joins, state.leaves = 0, 0

        -- صورة
        local url = getHeadshot(plr.UserId)
        if url and #url > 0 then
            state.Avatar.Image = url
            ContentProvider:PreloadAsync({state.Avatar})
            state.Avatar.Visible = true
        end
        setOnline(true)
        refresh()
        toast(("تم تحديد: %s"):format(plr.DisplayName), 1.2)
        logEvent(plr.UserId, plr.Name, plr.DisplayName, "set")

        -- وصلات
        state.conAdded = Players.PlayerAdded:Connect(function(p)
            if state.target and p.UserId == state.targetId then
                state.joins += 1
                setOnline(true)
                refresh()
                toast(("دخول: %s"):format(p.DisplayName), 1.0)
                logEvent(p.UserId, p.Name, p.DisplayName, "join")
            end
        end)
        state.conRemoved = Players.PlayerRemoving:Connect(function(p)
            if state.target and p.UserId == state.targetId then
                state.leaves += 1
                setOnline(false)
                refresh()
                toast(("خروج: %s"):format(p.DisplayName), 1.0)
                logEvent(p.UserId, p.Name, p.DisplayName, "leave")
            end
        end)
    end

    -- تحديث الزمن المنقضي كل نبضة
    state.hb = RunService.Heartbeat:Connect(function()
        if state.started then
            local sec = tick() - state.started
            state.ElapsedL.Text = ("المدة: %s"):format(fmtDuration(sec))
        else
            state.ElapsedL.Text = "المدة: 00:00"
        end
        if state.target and state.since then
            state.SinceL.Text = ("منذ بدء التتبع: %s"):format(prettyAgo(state.since))
        end
    end)

    -- منع تكرار لاعب بنفس الوقت عبر الخانات
    local function isDuplicate(userId)
        for _,other in ipairs(_G.__GS4_SLOTS or {}) do
            if other ~= state and other.targetId and other.targetId == userId then
                return true
            end
        end
        return false
    end

    -- مراقبة النص (التقاط فوري ≥ حرفين)
    input:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = normalize(input.Text)
        if #txt == 0 then
            if state.target then toast("تم إيقاف التتبع لهذه الخانة", 1.1) end
            clear()
            state.lastInput = ""
            return
        end
        if txt == state.lastInput then return end
        state.lastInput = txt

        if #txt >= 2 then
            local pl = findMatch(txt)
            if pl then
                if isDuplicate(pl.UserId) then
                    -- لا نعيّن، لأن الخانة الأخرى سبقته
                    toast("هذا اللاعب متتبع بخانة أخرى", 1.0)
                    return
                end
                if (not state.targetId) or (state.targetId ~= pl.UserId) then
                    applyPlayer(pl)
                end
            end
        end
    end)

    -- إعادة إظهار حالة الاتصال لو اللاعب موجود أصلًا
    task.defer(function()
        if state.targetId then
            local p = Players:GetPlayerByUserId(state.targetId)
            setOnline(p ~= nil)
            refresh()
        end
    end)

    card.Parent = grid
    return state
end

-- إنشاء 4 خانات
_G.__GS4_SLOTS = {}
for i=1,4 do
    table.insert(_G.__GS4_SLOTS, makeCard(i))
end

-- نبضة حركة دخول اللوحة
do
    shadow.Position = UDim2.fromScale(0.5, 0.16)
    TweenService:Create(shadow, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {Position = UDim2.fromScale(0.5, 0.20)}):Play()
end

-- تحسين الالتقاط عند دخول لاعب جديد للسيرفر
Players.PlayerAdded:Connect(function()
    for _,slot in ipairs(_G.__GS4_SLOTS) do
        local txt = normalize(slot.Input.Text)
        if #txt >= 2 then
            local p = findMatch(txt)
            if p and (not slot.targetId or slot.targetId ~= p.UserId) then
                -- تحقق عدم تكرار
                local duplicate = false
                for _,other in ipairs(_G.__GS4_SLOTS) do
                    if other ~= slot and other.targetId == p.UserId then duplicate = true break end
                end
                if not duplicate then
                    -- عيّن
                    local ok = pcall(function() slot.Input.Text = txt end)
                    ok = ok and true
                    slot.lastInput = ""  -- للسماح بإعادة الالتقاط
                    slot.Input.Text = txt
                end
            end
        end
    end
end)

-- رسالة تلميح خفيفة أول مرة
task.delay(0.2, function()
    toast("اكتب أول حرفين أو أكثر من اسم اللاعب (يوزر/لقب) داخل أي خانة.")
end)

--======[ قسم إضافي: وظائف اختيارية صغيرة لزيادة المتانة ]======--
-- إعادة تحجيم اللوحة (لو حبّيت تعدّل بسرعة)
local function setPanelSize(w, h)
    w = math.max(540, math.min(900, math.floor(w or PANEL_WIDTH)))
    h = math.max(360, math.min(620, math.floor(h or PANEL_HEIGHT)))
    PANEL_WIDTH, PANEL_HEIGHT = w, h
    shadow.Size = UDim2.fromOffset(PANEL_WIDTH + 16, PANEL_HEIGHT + 16)
    root.Size   = UDim2.fromOffset(PANEL_WIDTH, PANEL_HEIGHT)
end

-- حماية من إنشاء نسخة مزدوجة من الواجهة
do
    for _, child in ipairs(CoreGui:GetChildren()) do
        if child ~= gui and child:IsA("ScreenGui") and child.Name == gui.Name then
            -- لو لقيت نسخة قديمة بنفس الاسم، دمّرها
            child:Destroy()
        end
    end
end

-- مساعدة: تفريغ كل الخانات (لا يوجد زر، فقط وظيفة داخلية لو احتجتها من السطر)
local function clearAll()
    for _,slot in ipairs(_G.__GS4_SLOTS) do
        if slot.Input then
            slot.Input.Text = ""
        end
    end
end

-- تركيز تلقائي على الخانة الأولى لمّا تفتح اللوحة
task.delay(0.3, function()
    local first = _G.__GS4_SLOTS[1]
    if first and first.Input then
        pcall(function() first.Input:CaptureFocus() end)
    end
end)

-- ربط مفتاح "M" لفتح/قفل اللوحة (اختياري)
UserInputService.InputBegan:Connect(function(io, gp)
    if gp then return end
    if io.KeyCode == Enum.KeyCode.M then
        togglePanel()
    end
end)

-- تحسين Preload لصور الأفاتار عند التعيين
for _,slot in ipairs(_G.__GS4_SLOTS) do
    slot.Avatar:GetPropertyChangedSignal("Image"):Connect(function()
        if slot.Avatar.Image and #slot.Avatar.Image > 0 then
            safe(true, function() ContentProvider:PreloadAsync({slot.Avatar}) end)
        end
    end)
end

-- ضمان عدم تجاوز السرعة — بدون Debounce لأنك طلبت أسرع استجابة
-- لكن نضمن إن الHeartbeat ما يعملش تحديثات غير لازمة
local hbLimiter = 0
RunService.Heartbeat:Connect(function(dt)
    hbLimiter += dt
    if hbLimiter > 1.0 then
        hbLimiter = 0
        -- ممكن نحط فحوصات دورية خفيفة هنا لو احتجنا
    end
end)

-- وظائف لعرض إحصائيات بسيطة من السجل (بدون واجهة)
local function countHistory(kind)
    local c = 0
    for _,r in ipairs(_G.GS4_TRACK_HISTORY) do
        if r.kind == kind then c += 1 end
    end
    return c
end

-- سجّل بداية الجلسة
table.insert(_G.GS4_TRACK_HISTORY, {
    sid = SESSION_ID, t = tick(), userId = 0, name = "_", display = "_", kind = "session_start"
})

-- وظيفة مساعدة: الحصول على اسم اللاعب من UserId (آمنة)
local function nameFromId(id)
    local ok, nm = pcall(function() return Players:GetNameFromUserIdAsync(id) end)
    return ok and nm or ("UserId:"..tostring(id))
end

-- حماية إضافية: لو تغيرت اللغة/الخط عند اللاعب، حافظ على الاتساق
local function enforceFonts()
    local fonts = {Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold, Enum.Font.GothamSemibold}
    local function applyFont(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("TextButton") then
            -- تجاهل لو فعلا أحد خطوط Gotham
            local isOk = false
            for _,f in ipairs(fonts) do
                if obj.Font == f then isOk = true break end
            end
            if not isOk then obj.Font = Enum.Font.Gotham end
        end
        for _,ch in ipairs(obj:GetChildren()) do
            applyFont(ch)
        end
    end
    applyFont(root)
end
enforceFonts()

-- لمسة جمالية بسيطة: وميض حدود عند تحديد لاعب جديد
local function flashBorder()
    strokeRoot.Transparency = 0.0
    TweenService:Create(strokeRoot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {Transparency = 0.3}):Play()
end

-- ربط الوميض بالتحديد عبر مراقبة السجل
local lastLogCount = #_G.GS4_TRACK_HISTORY
RunService.Heartbeat:Connect(function()
    local n = #_G.GS4_TRACK_HISTORY
    if n > lastLogCount then
        local rec = _G.GS4_TRACK_HISTORY[n]
        if rec and rec.kind == "set" then
            flashBorder()
        end
        lastLogCount = n
    end
end)

-- ضمان بقاء الزر الصغير ظاهر حتى مع واجهات أخرى
mini.ZIndex = 10
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- حماية من التفكيك العشوائي: دوال تدمير آمنة (غير مستخدمة حاليًا لكن جاهزة)
local destroyed = false
local function destroyUI()
    if destroyed then return end
    destroyed = true
    safe(true, function()
        if gui then gui:Destroy() end
    end)
end

-- مراقبة بسيطة: لو الـ CoreGui اتقفل (نادرًا مع بعض الإكسيكيوترز)
task.defer(function()
    if not gui or not gui.Parent then
        -- محاولة ربط تاني (لن يحدث غالبًا)
        gui.Parent = CoreGui
    end
end)

-- تذكير خفيف أخير
task.delay(0.9, function()
    toast("تلميح: اضغط M لفتح/إخفاء اللوحة. والسحب مُتاح من الشريط العلوي.")
end)

-- نهاية — استمتع ✨
