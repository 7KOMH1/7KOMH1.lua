--[[

    GS4 | العم حكومه 🍷
    نسخة تتبع 4 لاعبين — قوية / واجهة عربية / التقاط فوري / صوت دخول-خروج
    ملاحظات:
      - اكتب أول حرفين أو أكثر من "اسم المستخدم" أو "اللقب" داخل كل خانة
      - عند مسح الحقل بالكامل → يتلغى التتبع للخانة
      - الخانات مرتبة 2×2 مع صورة بروفايل تظهر بعد تحديد لاعب فقط
      - زر فتح/قفل صغير ومتحرك
      - يتم حساب مرات الدخول/الخروج الحقيقية عبر PlayerAdded/PlayerRemoving
      - السجل محفوظ في _G.GS4_TRACK_HISTORY طول الجلسة
      - الألوان: خلفية داكنة، عناوين زرقاء، دخول أخضر، خروج أحمر

]]--

-- =========[ خدمات Roblox ]=========
local Players        = game:GetService("Players")
local HttpService    = game:GetService("HttpService")
local RunService     = game:GetService("RunService")
local StarterGui     = game:GetService("StarterGui")
local CoreGui        = game:GetService("CoreGui")
local TweenService   = game:GetService("TweenService")
local UserInput      = game:GetService("UserInputService")
local Localization   = game:GetService("LocalizationService")
local ContentProvider= game:GetService("ContentProvider")

local LP = Players.LocalPlayer

-- =========[ ثيم وأصول ]=========
local THEME = {
    bg           = Color3.fromRGB(18,18,18),
    panel        = Color3.fromRGB(25,25,25),
    header       = Color3.fromRGB(32,32,32),
    stroke       = Color3.fromRGB(60,60,60),
    text         = Color3.fromRGB(230,230,230),
    midText      = Color3.fromRGB(180,180,180),
    blue         = Color3.fromRGB(60,170,255),
    green        = Color3.fromRGB(70,220,100),
    red          = Color3.fromRGB(255,70,70),
    amber        = Color3.fromRGB(255,190,60),
    onlineDot    = Color3.fromRGB(60, 220, 100),
    offlineDot   = Color3.fromRGB(160, 160, 160),
    searchBox    = Color3.fromRGB(44,44,44)
}

-- أصوات
local SFX = {
    Join  = "rbxassetid://138081500",    -- Ping
    Leave = "rbxassetid://138081519",    -- Click/leave
}

-- =========[ أدوات مساعدة ]=========
local function safeDestroy(o) if o and o.Destroy then pcall(function() o:Destroy() end) end end

local function new(inst,parent,props)
    local o = Instance.new(inst)
    if parent then o.Parent = parent end
    if props then
        for k,v in pairs(props) do
            o[k] = v
        end
    end
    return o
end

local function pad2(n) n = math.floor(n or 0); if n<10 then return "0"..n else return tostring(n) end end

local function fmtDuration(sec)
    sec = math.max(0, math.floor(sec or 0))
    local h = math.floor(sec/3600)
    local m = math.floor((sec%3600)/60)
    local s = sec%60
    if h > 0 then
        return string.format("%d:%s:%s", h, pad2(m), pad2(s))
    else
        return string.format("%s:%s", pad2(m), pad2(s))
    end
end

local function now()
    -- os.clock أدق داخل الجلسة
    return os.clock()
end

local function headshot(userId, size)
    size = size or 180
    return string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=%d&h=%d", userId, size, size)
end

local function toast(txt)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "GS4 | العم حكومه 🍷";
            Text  = txt;
            Duration = 2.5;
        })
    end)
end

local function play(id, vol)
    local s = new("Sound", workspace, {
        SoundId = id, Volume = vol or 0.7, PlaybackSpeed = 1
    })
    s:Play()
    task.delay(4, function() safeDestroy(s) end)
end

-- حفظ تاريخ الجلسة
_G.GS4_TRACK_HISTORY = _G.GS4_TRACK_HISTORY or {}
local SESSION_ID = _G.GS4_SESSION_ID or HttpService:GenerateGUID(false)
_G.GS4_SESSION_ID = SESSION_ID

-- =========[ إنشاء الواجهة ]=========
local gui = new("ScreenGui", CoreGui, { Name = "GS4_GovTrack_UI", ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn=false })
local root = new("Frame", gui, {
    BackgroundColor3 = THEME.bg,
    BorderSizePixel  = 0,
    AnchorPoint      = Vector2.new(0.5,0),
    Position         = UDim2.fromScale(0.5, 0.18),
    Size             = UDim2.fromOffset(920, 540),
    Visible          = true
})
new("UICorner", root, { CornerRadius = UDim.new(0,16) })
new("UIStroke", root, { Thickness = 1, Color = THEME.stroke, Transparency = 0.3 })

-- شريط العنوان
local header = new("Frame", root, {
    Size = UDim2.new(1,0,0,56), BackgroundColor3 = THEME.header, BorderSizePixel=0
})
new("UICorner", header, { CornerRadius = UDim.new(0,16) })

local title = new("TextLabel", header, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1,-120,1,0),
    Position = UDim2.new(0,60,0,0),
    Font = Enum.Font.GothamBold,
    Text = "GS4 | العم حكومه  🍷",
    TextColor3 = THEME.blue, TextScaled = true
})

-- أيقونة
local emblem = new("ImageLabel", header, {
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(38,38),
    Position = UDim2.new(0,10,0,9),
    Image = "rbxassetid://15776015260"
})
new("UICorner", emblem, { CornerRadius = UDim.new(0,12) })

-- زر فتح/قفل صغير ومتحرك
local miniToggle = new("ImageButton", gui, {
    Name = "MiniToggle",
    BackgroundColor3 = THEME.header,
    Size = UDim2.fromOffset(36,36),
    Position = UDim2.new(1,-54,0,110),
    Image = "rbxassetid://3926305904",
    ImageRectOffset = Vector2.new(884,284),
    ImageRectSize   = Vector2.new(36,36)
})
new("UICorner", miniToggle, { CornerRadius = UDim.new(1,0) })
new("UIStroke", miniToggle, { Thickness=1, Color=THEME.stroke, Transparency=0.2 })

-- جعل زر التبديل صغير قابل للسحب
do
    local dragging = false
    local dragStart, startPos
    miniToggle.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = io.Position
            startPos = miniToggle.Position
            io.Changed:Connect(function()
                if io.UserInputState == Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    UserInput.InputChanged:Connect(function(io)
        if dragging and (io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch) then
            local delta = io.Position - dragStart
            miniToggle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- حركة فتح/قفل
local PANEL_OPEN = true
local function togglePanel(show)
    PANEL_OPEN = (show==nil) and not PANEL_OPEN or show
    local target = PANEL_OPEN and 1 or 0
    root.Visible = true
    root.BackgroundTransparency = 1 - target
    header.BackgroundTransparency = 1 - target
    local goalPos = PANEL_OPEN and UDim2.fromScale(0.5,0.18) or UDim2.fromScale(0.5,-0.55)
    TweenService:Create(root, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position=goalPos}):Play()
end

miniToggle.MouseButton1Click:Connect(function() togglePanel() end)

-- الشبكة 2×2
local grid = new("Frame", root, {BackgroundTransparency=1, Position=UDim2.new(0,14,0,70), Size=UDim2.new(1,-28,1,-84)})
local uiGrid = new("UIGridLayout", grid, {
    CellPadding = UDim2.fromOffset(16,16),
    CellSize    = UDim2.new(0.5,-12,0.5,-12),
    FillDirectionMaxCells = 2,
    SortOrder   = Enum.SortOrder.LayoutOrder
})

-- =========[ حالة كل خانة ]=========
export type CardState = {
    index: number,
    frame: Frame,
    search: TextBox,
    nameL: TextLabel,
    displayL: TextLabel,
    joinL: TextLabel,
    leaveL: TextLabel,
    sinceL: TextLabel,
    elapsedL: TextLabel,
    pfp: ImageLabel,
    dot: Frame,

    targetId: number?,
    targetName: string?,
    targetDisplay: string?,
    joins: number,
    leaves: number,
    online: boolean,
    startedAt: number?,
    lastSeen: number?,
}

-- =========[ إنشاء خانة ]=========
local CARDS : {CardState} = {}

local function makeCard(i: number): CardState
    local card = new("Frame", grid, {
        BackgroundColor3 = THEME.panel, BorderSizePixel=0
    })
    new("UICorner", card, {CornerRadius = UDim.new(0,12)})
    new("UIStroke", card, {Color=THEME.stroke, Transparency=0.25})

    -- ترويسة صغيرة + صندوق البحث
    local head = new("Frame", card, {BackgroundColor3=THEME.header, BorderSizePixel=0, Size=UDim2.new(1,0,0,44)})
    new("UICorner", head, {CornerRadius = UDim.new(0,12)})

    local search = new("TextBox", head, {
        BackgroundColor3 = THEME.searchBox,
        PlaceholderText = "",
        Text = "",
        Font = Enum.Font.GothamMedium,
        TextColor3 = THEME.text,
        TextSize = 18,
        ClearTextOnFocus = false,
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.5),
        Size = UDim2.new(1,-20,1,-12)
    })
    new("UICorner", search, {CornerRadius = UDim.new(0,8)})

    -- الصورة + الدوت
    local pfp = new("ImageLabel", card, {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(64,64),
        Position = UDim2.new(0,12,0,56),
        ImageTransparency = 0,
        Visible = false
    })
    new("UICorner", pfp, {CornerRadius=UDim.new(0,12)})

    local dot = new("Frame", pfp, {
        Size = UDim2.fromOffset(10,10),
        Position = UDim2.new(1,-12,0,2),
        BackgroundColor3 = THEME.offlineDot, BorderSizePixel=0, Visible=false
    })
    new("UICorner", dot, {CornerRadius=UDim.new(1,0)})

    -- نصوص الاسم/اللقب
    local nameL = new("TextLabel", card, {
        BackgroundTransparency = 1,
        Position = UDim2.new(0,88,0,58),
        Size = UDim2.new(1,-100,0,24),
        Font = Enum.Font.GothamBold, TextSize=20,
        TextColor3 = THEME.blue, TextXAlignment=Enum.TextXAlignment.Left,
        Visible=false, Text = ""
    })
    local displayL = new("TextLabel", card, {
        BackgroundTransparency = 1,
        Position = UDim2.new(0,88,0,82),
        Size = UDim2.new(1,-100,0,22),
        Font = Enum.Font.Gotham, TextSize=18,
        TextColor3 = THEME.midText, TextXAlignment=Enum.TextXAlignment.Left,
        Visible=false, Text = ""
    })

    -- عدادات
    local joinL = new("TextLabel", card, {
        BackgroundTransparency = 1, Text = "0 :دخول",
        TextColor3 = THEME.green, Font=Enum.Font.GothamSemibold, TextSize=20,
        Position = UDim2.new(0,14,0,126), Size = UDim2.fromOffset(160,24)
    })
    local leaveL = new("TextLabel", card, {
        BackgroundTransparency = 1, Text = "0 :خروج",
        TextColor3 = THEME.red, Font=Enum.Font.GothamSemibold, TextSize=20,
        Position = UDim2.new(0,190,0,126), Size = UDim2.fromOffset(160,24)
    })

    local sinceL = new("TextLabel", card, {
        BackgroundTransparency=1, Text="", TextColor3=THEME.midText,
        Font=Enum.Font.Gotham, TextSize=16, Position=UDim2.new(0,14,0,156),
        Size=UDim2.fromOffset(280,20)
    })
    local elapsedL = new("TextLabel", card, {
        BackgroundTransparency=1, Text="", TextColor3=THEME.midText,
        Font=Enum.Font.Gotham, TextSize=16, Position=UDim2.new(0,14,0,176),
        Size=UDim2.fromOffset(280,20)
    })

    return {
        index=i, frame=card, search=search,
        nameL=nameL, displayL=displayL, joinL=joinL, leaveL=leaveL,
        sinceL=sinceL, elapsedL=elapsedL, pfp=pfp, dot=dot,
        targetId=nil, targetName=nil, targetDisplay=nil,
        joins=0, leaves=0, online=false, startedAt=nil, lastSeen=nil
    }
end

for i=1,4 do table.insert(CARDS, makeCard(i)) end

-- =========[ منطق التتبع ]=========
local function clearCard(T: CardState)
    T.targetId, T.targetName, T.targetDisplay = nil, nil, nil
    T.joins, T.leaves = 0,0
    T.online = false
    T.startedAt, T.lastSeen = nil,nil
    T.nameL.Visible, T.displayL.Visible = false, false
    T.pfp.Visible = false
    T.dot.Visible  = false
    T.joinL.Text = "0 :دخول";  T.leaveL.Text = "0 :خروج"
    T.sinceL.Text, T.elapsedL.Text = "", ""
end

local function setCard(T: CardState, plr: Player)
    T.targetId = plr.UserId
    T.targetName = plr.Name
    T.targetDisplay = plr.DisplayName
    T.joins, T.leaves = 0,0
    T.online = true
    T.startedAt = now()
    T.lastSeen  = now()

    T.pfp.Image = headshot(plr.UserId, 150)
    T.pfp.Visible = true
    T.dot.Visible = true
    T.dot.BackgroundColor3 = THEME.onlineDot

    T.nameL.Text = "اسم المستخدم: " .. plr.Name
    T.displayL.Text = "اللقب: " .. plr.DisplayName
    T.nameL.Visible, T.displayL.Visible = true, true

    T.joinL.Text  = "0 :دخول"
    T.leaveL.Text = "0 :خروج"
    T.sinceL.Text = "بدأ التتبع الآن"
    T.elapsedL.Text = "المدة: 00:00"

    toast(("تم تحديد %s"):format(plr.DisplayName))
end

local function findMatch(prefix: string): Player?
    if not prefix or #prefix < 2 then return nil end
    prefix = prefix:lower()
    local found: Player? = nil
    for _,p in ipairs(Players:GetPlayers()) do
        local n = p.Name:lower()
        local d = p.DisplayName:lower()
        if n:sub(1,#prefix) == prefix or d:sub(1,#prefix) == prefix then
            found = p; break
        end
    end
    return found
end

-- تحديث زمن المدة
RunService.Heartbeat:Connect(function()
    for _,T in ipairs(CARDS) do
        if T.targetId and T.startedAt then
            T.elapsedL.Text = "المدة: " .. fmtDuration(now() - T.startedAt)
        end
    end
end)

-- البحث الفوري لكل خانة
for _,T in ipairs(CARDS) do
    T.search:GetPropertyChangedSignal("Text"):Connect(function()
        local text = T.search.Text
        if text == nil then text = "" end
        if #text == 0 then
            clearCard(T)
            return
        end
        if #text >= 2 then
            local plr = findMatch(text)
            if plr and (not T.targetId or T.targetId ~= plr.UserId) then
                setCard(T, plr)
            end
        end
    end)
end

-- تحديث النقطة الخضراء حسب وجود اللاعب
local function setOnline(T: CardState, online: boolean)
    T.online = online
    if T.dot then
        T.dot.BackgroundColor3 = online and THEME.onlineDot or THEME.offlineDot
    end
end

-- تسجيل حدث للسجل
local function logEvent(userId, kind, when)
    local rec = {
        userId=userId, kind=kind, t=when or now(), sid=SESSION_ID
    }
    table.insert(_G.GS4_TRACK_HISTORY, rec)
end

-- لمّا لاعب يدخل
Players.PlayerAdded:Connect(function(plr)
    for _,T in ipairs(CARDS) do
        if T.targetId == plr.UserId then
            T.joins += 1
            T.joinL.Text = (tostring(T.joins).." :دخول")
            setOnline(T, true)
            T.lastSeen = now()
            play(SFX.Join, 0.8)
            toast(("دخل %s"):format(plr.DisplayName))
            logEvent(plr.UserId, "join")
        end
    end
end)

-- لمّا لاعب يخرج
Players.PlayerRemoving:Connect(function(plr)
    for _,T in ipairs(CARDS) do
        if T.targetId == plr.UserId then
            T.leaves += 1
            T.leaveL.Text = (tostring(T.leaves).." :خروج")
            setOnline(T, false)
            T.lastSeen = now()
            play(SFX.Leave, 0.8)
            toast(("خرج %s"):format(plr.DisplayName))
            logEvent(plr.UserId, "leave")
        end
    end
end)

-- مزامنة أولية لو كان اللاعب already في السيرفر
task.defer(function()
    for _,T in ipairs(CARDS) do
        if T.targetId then
            local p = Players:GetPlayerByUserId(T.targetId)
            setOnline(T, p ~= nil)
        end
    end
end)

-- =========[ تحريك اللوحة كلها ]=========
do
    local dragging = false
    local dragStart, startPos
    header.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = io.Position
            startPos = root.Position
            io.Changed:Connect(function()
                if io.UserInputState == Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    UserInput.InputChanged:Connect(function(io)
        if dragging and (io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch) then
            local delta = io.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- =========[ مفاتيح سريعة ]=========
-- M: إظهار/إخفاء اللوحة
UserInput.InputBegan:Connect(function(io, gp)
    if gp then return end
    if io.KeyCode == Enum.KeyCode.M then
        togglePanel()
    end
end)

-- =========[ نصائح سريعة مرّة واحدة ]=========
task.delay(0.2, function()
    toast("اكتب أول حرفين أو أكثر من اسم اللاعب (يوزر أو لقب) داخل كل خانة.")
end)

-- =========[ تحسينات تحميل الصورة ]=========
-- نجرب تحميل الصورة بعد التعيين لضمان الظهور السريع
for _,T in ipairs(CARDS) do
    T.pfp:GetPropertyChangedSignal("Image"):Connect(function()
        local ok = pcall(function() ContentProvider:PreloadAsync({T.pfp}) end)
        if not ok then -- تجاهل
        end
    end)
end

-- =========[ حماية من التكرار (اسم مستخدم واحد في أكثر من خانة) ]=========
local function preventDuplicate(targetId, ownerIndex)
    for _,T in ipairs(CARDS) do
        if T.index ~= ownerIndex and T.targetId == targetId then
            -- نفرغ الأقدم (هنا نفضي الحالية الجديدة بدل القديمة)؟ هنخلّي الأقدم محفوظة
            -- نفضي الجديدة:
            local cur = CARDS[ownerIndex]
            if cur then
                clearCard(cur)
                toast("هذا اللاعب متتبع في خانة أخرى.")
            end
            return true
        end
    end
    return false
end

-- ربط منع التكرار مع التعيين
for _,T in ipairs(CARDS) do
    T.search:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = T.search.Text
        if txt and #txt >= 2 then
            local p = findMatch(txt)
            if p then
                if preventDuplicate(p.UserId, T.index) then return end
                if not T.targetId or T.targetId ~= p.UserId then
                    setCard(T, p)
                end
            end
        end
    end)
end

-- =========[ نهاية ]=========
-- الكود خلص. استمتع ✨
