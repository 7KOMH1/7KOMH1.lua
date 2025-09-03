--[[
    الحقوق: GS4 | العم حكومه 🍷
    نسخة عربية مطوّرة (حوالي 540 سطر)
    - 4 تتبعات (2×2)
    - التقاط سريع جدًا من أول حرفين لأي جزء بالاسم أو اللقب
    - عربي كامل (واجهة/نصوص)
    - إظهار (اسم المستخدم + اللقب) بعد الالتقاط فقط (بدون إيموجي في العناوين)
    - صورة بروفايل
    - عدادات دخول/خروج
    - مؤشر حالة (نقطة خضراء/رمادية)
    - إشعارات وصوت دخول/خروج
    - وقت بداية التتبع + مدة التتبع حيًا
    - زر فتح/قفل صغير وقابل للسحب
    - تسجيل جلسة في الذاكرة (سجل بسيط)
--]]

--========================= الخدمات =========================
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local SoundService   = game:GetService("SoundService")
local RunService     = game:GetService("RunService")
local CoreGui        = game:GetService("CoreGui")

local LP = Players.LocalPlayer

--========================= إعدادات عامة =====================
local THEME = {
    bg           = Color3.fromRGB(14,14,14),
    panel        = Color3.fromRGB(22,22,22),
    field        = Color3.fromRGB(40,40,40),
    line         = Color3.fromRGB(36,36,36),
    text         = Color3.fromRGB(235,235,235),
    blue         = Color3.fromRGB(0,170,255),
    blue2        = Color3.fromRGB(0,145,255),
    cyan         = Color3.fromRGB(0,200,200),
    green        = Color3.fromRGB(0,255,0),
    red          = Color3.fromRGB(255,0,0),
    notifBG      = Color3.fromRGB(22,22,22),
    toggleBG     = Color3.fromRGB(18,18,18),
    onlineDot    = Color3.fromRGB(60,200,90),
    offlineDot   = Color3.fromRGB(120,120,120),
}

-- يمكن تعديل هذه القيم لو عايز الواجهة أكبر/أصغر
local UI_SIZE = Vector2.new(560, 360)     -- حجم اللوحة
local CARD_H  = 154                       -- ارتفاع الكارت
local FONT_H1 = 22
local FONT_H2 = 18
local FONT_H3 = 17
local SEARCH_DEBOUNCE = 0.10              -- لتخفيف البحث الفوري

--========================= أصوات ===========================
local SndJoin = Instance.new("Sound", SoundService)
SndJoin.SoundId = "rbxassetid://6026984224"
SndJoin.Volume  = 0.35

local SndLeave = Instance.new("Sound", SoundService)
SndLeave.SoundId = "rbxassetid://6026984224"
SndLeave.PlaybackSpeed = 0.85
SndLeave.Volume  = 0.35

--========================= مساعدات نصية ====================
local function trim(s) return (s:gsub("^%s+",""):gsub("%s+$","")) end
local function low(s)  return string.lower(s or "") end
local function starts(a,b) return a:sub(1,#b)==b end

-- مطابقة مرجّحة: يبدأ > يحتوي (2 نقاط للبداية، 1 للاحتواء)
local function scoreMatch(name, query)
    if #query < 2 then return -1 end
    local n, q = low(name), low(query)
    if starts(n,q) then return 2 end
    if n:find(q, 1, true) then return 1 end
    return -1
end

local function bestMatch(query)
    local best, bestScore = nil, -1
    local q = low(query)
    for _,plr in ipairs(Players:GetPlayers()) do
        local s1 = scoreMatch(plr.Name, q)
        local s2 = scoreMatch(plr.DisplayName, q)
        local sc = math.max(s1, s2)
        if sc > bestScore then bestScore, best = sc, plr end
    end
    return (bestScore > 0) and best or nil
end

-- صورة مصغّرة آمنة
local function headshot(userId)
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and img then return img end
    return ("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png"):format(userId)
end

-- تنسيق مدة (ثواني) → "س:د:ث"
local function fmtDuration(seconds)
    seconds = math.max(0, math.floor(seconds))
    local h = math.floor(seconds/3600)
    local m = math.floor((seconds%3600)/60)
    local s = seconds%60
    if h > 0 then
        return string.format("%02d:%02d:%02d", h, m, s)
    else
        return string.format("%02d:%02d", m, s)
    end
end

--========================= إشعار بسيط ======================
local function notify(gui, msg, color)
    local n = Instance.new("TextLabel")
    n.Parent = gui
    n.Size   = UDim2.new(0, 280, 0, 36)
    n.Position = UDim2.new(0.5, -140, 0.06, 0)
    n.BackgroundColor3 = THEME.notifBG
    n.TextColor3 = color or THEME.text
    n.Font = Enum.Font.SourceSansBold
    n.TextSize = 19
    n.BorderSizePixel = 0
    n.BackgroundTransparency = 0.15
    n.Text = msg
    n.ZIndex = 1000
    TweenService:Create(n, TweenInfo.new(0.12), {BackgroundTransparency = 0.05}):Play()
    task.wait(1.25)
    TweenService:Create(n, TweenInfo.new(0.25), {TextTransparency=1, BackgroundTransparency=1}):Play()
    task.wait(0.25)
    n:Destroy()
end

--========================= سجل جلسة بسيط ===================
local SessionLog = {}    -- { {userId=.., name=.., display=.., event="join"/"leave", t=os.clock()} , ... }

local function logEvent(userId, name, display, kind)
    table.insert(SessionLog, {
        userId  = userId,
        name    = name,
        display = display,
        event   = kind,
        t       = os.clock(),
    })
end

--========================= GUI رئيسي =======================
local gui = Instance.new("ScreenGui")
gui.Name = "GS4_Tracker_Arabic_Pro"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = CoreGui

-- زر صغير متحرك (فتح/قفل)
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 32, 0, 32)
toggleBtn.Position = UDim2.new(0, 16, 0.22, 0)
toggleBtn.BackgroundColor3 = THEME.toggleBG
toggleBtn.Text = "≡"
toggleBtn.TextScaled = true
toggleBtn.TextColor3 = THEME.blue
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = true
toggleBtn.Draggable = true
toggleBtn.ZIndex = 99

-- اللوحة
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, UI_SIZE.X, 0, UI_SIZE.Y)
main.Position = UDim2.new(0.5, -UI_SIZE.X/2, 0.26, 0)
main.BackgroundColor3 = THEME.bg
main.BorderSizePixel = 0
main.Visible = true
main.Active = true
main.Draggable = true

-- عنوان وحقوق
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundTransparency = 1
header.Font = Enum.Font.SourceSansBold
header.TextSize = FONT_H1
header.TextColor3 = THEME.blue
header.Text = "GS4 | العم حكومه"

local sep = Instance.new("Frame", main)
sep.Size = UDim2.new(1, -20, 0, 1)
sep.Position = UDim2.new(0, 10, 0, 44)
sep.BackgroundColor3 = THEME.line
sep.BorderSizePixel = 0

--========================= مكوّن بطاقة تتبع =================
local Trackers, MAX = {}, 4

export type CardState = {
    card: Frame,
    search: TextBox,
    pfp: ImageLabel,
    nameL: TextLabel,
    displayL: TextLabel,
    joinL: TextLabel,
    leaveL: TextLabel,
    statusDot: Frame,
    sinceL: TextLabel,
    elapsedL: TextLabel,
    targetId: number?,
    online: boolean,
    joins: number,
    leaves: number,
    startedAt: number?,
    lastSearchTick: number
}

local function makeCard(i): CardState
    local card = Instance.new("Frame", main)
    card.Size = UDim2.new(0.485, 0, 0, CARD_H)
    card.BackgroundColor3 = THEME.panel
    card.BorderSizePixel = 0

    -- تموضع 2×2
    local col = (i-1) % 2
    local row = math.floor((i-1)/2)
    local topMargin = 0.16
    local rowStep   = 0.41
    card.Position = UDim2.new(0.02 + col*0.50, 0, topMargin + row*rowStep, 0)

    -- حقل البحث (بدون Placeholder)
    local search = Instance.new("TextBox", card)
    search.Size = UDim2.new(1, -12, 0, 28)
    search.Position = UDim2.new(0, 6, 0, 6)
    search.BackgroundColor3 = THEME.field
    search.BorderSizePixel   = 0
    search.ClearTextOnFocus  = false
    search.Text = ""
    search.TextColor3 = THEME.text
    search.TextSize = FONT_H2
    search.Font = Enum.Font.SourceSans

    -- صورة
    local pfp = Instance.new("ImageLabel", card)
    pfp.BackgroundTransparency = 1
    pfp.Size = UDim2.new(0, 56, 0, 56)
    pfp.Position = UDim2.new(0, 6, 0, 44)
    pfp.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"

    -- نقطة حالة
    local statusDot = Instance.new("Frame", card)
    statusDot.Size = UDim2.new(0, 10, 0, 10)
    statusDot.Position = UDim2.new(0, 6+56-10, 0, 44) -- فوق يمين الصورة
    statusDot.BackgroundColor3 = THEME.offlineDot
    statusDot.BorderSizePixel = 0
    statusDot.Visible = true
    local statusCorner = Instance.new("UICorner", statusDot)
    statusCorner.CornerRadius = UDim.new(0, 5)

    -- اسم المستخدم (لا يظهر حتى يتم الالتقاط)
    local nameL = Instance.new("TextLabel", card)
    nameL.BackgroundTransparency = 1
    nameL.Size = UDim2.new(1, -74, 0, 24)
    nameL.Position = UDim2.new(0, 70, 0, 44)
    nameL.Font = Enum.Font.SourceSansBold
    nameL.TextSize = FONT_H2
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.TextColor3 = THEME.blue2
    nameL.Text = ""
    nameL.Visible = false

    -- اللقب (لا يظهر حتى يتم الالتقاط)
    local displayL = Instance.new("TextLabel", card)
    displayL.BackgroundTransparency = 1
    displayL.Size = UDim2.new(1, -74, 0, 22)
    displayL.Position = UDim2.new(0, 70, 0, 70)
    displayL.Font = Enum.Font.SourceSans
    displayL.TextSize = FONT_H3
    displayL.TextXAlignment = Enum.TextXAlignment.Left
    displayL.TextColor3 = THEME.cyan
    displayL.Text = ""
    displayL.Visible = false

    -- عدادات (سطر واحد مرتب)
    local joinL = Instance.new("TextLabel", card)
    joinL.BackgroundTransparency = 1
    joinL.Size = UDim2.new(0.5, -10, 0, 20)
    joinL.Position = UDim2.new(0, 6, 0, 110)
    joinL.Font = Enum.Font.SourceSansBold
    joinL.TextSize = 16
    joinL.TextXAlignment = Enum.TextXAlignment.Left
    joinL.TextColor3 = THEME.green
    joinL.Text = "مرات الدخول: 0"

    local leaveL = Instance.new("TextLabel", card)
    leaveL.BackgroundTransparency = 1
    leaveL.Size = UDim2.new(0.5, -10, 0, 20)
    leaveL.Position = UDim2.new(0.5, 0, 0, 110)
    leaveL.Font = Enum.Font.SourceSansBold
    leaveL.TextSize = 16
    leaveL.TextXAlignment = Enum.TextXAlignment.Left
    leaveL.TextColor3 = THEME.red
    leaveL.Text = "مرات الخروج: 0"

    -- سطر معلومات إضافية: منذ البدء + المدة
    local sinceL = Instance.new("TextLabel", card)
    sinceL.BackgroundTransparency = 1
    sinceL.Size = UDim2.new(0.5, -10, 0, 18)
    sinceL.Position = UDim2.new(0, 6, 0, 130)
    sinceL.Font = Enum.Font.SourceSans
    sinceL.TextSize = 14
    sinceL.TextXAlignment = Enum.TextXAlignment.Left
    sinceL.TextColor3 = THEME.text
    sinceL.TextTransparency = 0.15
    sinceL.Text = "" -- يظهر بعد الالتقاط

    local elapsedL = Instance.new("TextLabel", card)
    elapsedL.BackgroundTransparency = 1
    elapsedL.Size = UDim2.new(0.5, -10, 0, 18)
    elapsedL.Position = UDim2.new(0.5, 0, 0, 130)
    elapsedL.Font = Enum.Font.SourceSans
    elapsedL.TextSize = 14
    elapsedL.TextXAlignment = Enum.TextXAlignment.Right
    elapsedL.TextColor3 = THEME.text
    elapsedL.TextTransparency = 0.15
    elapsedL.Text = ""

    return {
        card      = card,
        search    = search,
        pfp       = pfp,
        nameL     = nameL,
        displayL  = displayL,
        joinL     = joinL,
        leaveL    = leaveL,
        statusDot = statusDot,
        sinceL    = sinceL,
        elapsedL  = elapsedL,
        targetId  = nil,
        online    = false,
        joins     = 0,
        leaves    = 0,
        startedAt = nil,
        lastSearchTick = 0
    }
end

for i=1,MAX do
    Trackers[i] = makeCard(i)
end

--========================= دوال ضبط البطاقة =================
local function clearCard(T: CardState)
    T.targetId  = nil
    T.online    = false
    T.joins, T.leaves = 0,0
    T.pfp.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    T.nameL.Text, T.displayL.Text = "", ""
    T.nameL.Visible, T.displayL.Visible = false, false
    T.joinL.Text, T.leaveL.Text = "مرات الدخول: 0", "مرات الخروج: 0"
    T.statusDot.BackgroundColor3 = THEME.offlineDot
    T.sinceL.Text, T.elapsedL.Text = "", ""
    T.startedAt = nil
end

local function setCard(T: CardState, plr: Player)
    T.targetId  = plr.UserId
    T.online    = true
    T.joins, T.leaves = 0,0
    T.pfp.Image = headshot(plr.UserId)
    T.nameL.Text    = "اسم المستخدم: " .. plr.Name
    T.displayL.Text = "اللقب: " .. plr.DisplayName
    T.nameL.Visible = true
    T.displayL.Visible = true
    T.statusDot.BackgroundColor3 = THEME.onlineDot
    T.startedAt = os.clock()
    T.sinceL.Text = "بدأ التتبع الآن"
    T.elapsedL.Text = "المدة: 00:00"
end

-- تحديث مدة التتبع حيًا
local function updateElapsed()
    for _,T in ipairs(Trackers) do
        if T.targetId and T.startedAt then
            local dt = os.clock() - T.startedAt
            T.elapsedL.Text = "المدة: " .. fmtDuration(dt)
            if dt > 1 and T.sinceL.Text == "بدأ التتبع الآن" then
                T.sinceL.Text = "منذ " .. fmtDuration(dt)
            end
        end
    end
end

--========================= بحث سريع ========================
local function handleSearch(T: CardState, text: string)
    local q = trim(text or "")
    if q == "" then
        clearCard(T)
        return
    end
    if #q < 2 then
        -- أقل من حرفين: لا نبحث (تجنّب الضوضاء، وللحفاظ على السرعة)
        return
    end
    local plr = bestMatch(q)
    if plr then
        setCard(T, plr)
    end
end

for _,T in ipairs(Trackers) do
    T.search:GetPropertyChangedSignal("Text"):Connect(function()
        T.lastSearchTick = tick()
        local thisTick = T.lastSearchTick
        task.delay(SEARCH_DEBOUNCE, function()
            if thisTick ~= T.lastSearchTick then return end
            handleSearch(T, T.search.Text)
        end)
    end)
    T.search.FocusLost:Connect(function()
        if trim(T.search.Text) == "" then clearCard(T) end
    end)
end

--========================= تتبع حي (دخول/خروج) =============
local function onJoin(plr: Player)
    for _,T in ipairs(Trackers) do
        if T.targetId and plr.UserId == T.targetId then
            T.online = true
            T.joins += 1
            T.joinL.Text = "مرات الدخول: " .. T.joins
            T.pfp.Image = headshot(plr.UserId)
            T.nameL.Text    = "اسم المستخدم: " .. plr.Name
            T.displayL.Text = "اللقب: " .. plr.DisplayName
            T.statusDot.BackgroundColor3 = THEME.onlineDot
            SndJoin:Play()
            notify(gui, plr.DisplayName .. " دخل", THEME.green)
            logEvent(plr.UserId, plr.Name, plr.DisplayName, "join")
        end
    end
end

local function onLeave(plr: Player)
    for _,T in ipairs(Trackers) do
        if T.targetId and plr.UserId == T.targetId then
            T.online = false
            T.leaves += 1
            T.leaveL.Text = "مرات الخروج: " .. T.leaves
            T.statusDot.BackgroundColor3 = THEME.offlineDot
            SndLeave:Play()
            notify(gui, plr.DisplayName .. " خرج", THEME.red)
            logEvent(plr.UserId, plr.Name, plr.DisplayName, "leave")
        end
    end
end

Players.PlayerAdded:Connect(onJoin)
Players.PlayerRemoving:Connect(onLeave)

--========================= زر فتح/قفل ======================
toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

--========================= تحسين الاستجابة البصرية ==========
-- ظل بسيط للكروت عند المرور
for _,T in ipairs(Trackers) do
    T.card.MouseEnter:Connect(function()
        TweenService:Create(T.card, TweenInfo.new(0.12), {BackgroundTransparency = 0.00}):Play()
    end)
    T.card.MouseLeave:Connect(function()
        TweenService:Create(T.card, TweenInfo.new(0.20), {BackgroundTransparency = 0.03}):Play()
    end)
end

--========================= ضبط تلقائي للأحجام ===============
local function autoscale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    if vp.X < 900 then
        main.Size = UDim2.new(0, UI_SIZE.X - 40, 0, UI_SIZE.Y - 30)
        header.TextSize = FONT_H1 - 2
        for _,T in ipairs(Trackers) do
            T.card.Size = UDim2.new(0.485, 0, 0, CARD_H - 8)
            T.nameL.TextSize   = FONT_H2 - 1
            T.displayL.TextSize= FONT_H3 - 1
        end
    end
end
autoscale()

-- تحديث المدة كل إطار (خفيف)
RunService.RenderStepped:Connect(function()
    updateElapsed()
end)

--========================= أدوات اختيارية (نسخ السجل) =======
-- ملاحظة: Roblox لا يسمح بملفات مباشرة من LocalScript، لذا نخزن السجل في الذاكرة.
-- تقدر تستخدم SessionLog من خلال _G:
_G.GS4_Tracker_SessionLog = SessionLog

--========================= تنظيف إن لزم =====================
-- مفيش AutoClean هنا لأننا عايزين الواجهة تفضل لحد ما اللاعب يطلع من السيرفر.
-- لو حابب زر "إعادة ضبط" نضيفه بسهولة:
local function resetAll()
    for _,T in ipairs(Trackers) do
        T.search.Text = ""
        clearCard(T)
    end
    table.clear(SessionLog)
    notify(gui, "تم مسح كل التتبعات والسجل", THEME.blue)
end

-- (اختياري) اختصار من الكيبورد: Ctrl+R لإعادة الضبط
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.R and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        resetAll()
    end
end)

--========================= نهاية ============================
-- جاهز. اكتب في أي صندوق بحث حرفين أو أكثر من اسم/لقب اللاعب وسيتم الالتقاط فورًا.
-- لا يوجد اختيار تلقائي من غير كتابة منك.
-- العدادات من لحظة التتبع، مع إشعارات وصوت، ووقت/مدة تتبع حيّة.
