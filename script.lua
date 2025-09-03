--========================================================
--[[
    GS4 | العم حكومه 🍷  — لوحة تتبع 4 لاعبين (سريعة جداً)
    - حجم اللوحة: متوسط يميل للصغير
    - 4 كروت مرتبة (شبكة 2×2)
    - يلتقط اللاعب من أول حرفين (Username أو DisplayName)
    - لا يظهر (اسم المستخدم/اللقب/الصورة) إلا بعد تحديد لاعب ناجح
    - عدّاد دخول/خروج + صوت عند الدخول والخروج
    - زر فتح/قفل صغير قابل للسحب (Draggable)
    - تفريغ خانة البحث = إلغاء التتبّع فورًا
    - كتابة نص جديد تعني إعادة الالتقاط فورًا (استجابة عالية)
--]]
--========================================================

-- خدمات Roblox
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local UserInput    = game:GetService("UserInputService")

local LocalPlayer  = Players.LocalPlayer

--========================================================
-- إعدادات عامة
--========================================================
local THEME = {
    bg       = Color3.fromRGB(15,15,17),
    panel    = Color3.fromRGB(24,24,27),
    card     = Color3.fromRGB(28,28,32),
    bar      = Color3.fromRGB(35,35,40),
    blue     = Color3.fromRGB(60,170,255),
    green    = Color3.fromRGB(0, 210, 90),
    red      = Color3.fromRGB(230, 40, 45),
    text     = Color3.fromRGB(230,230,235),
    dim      = Color3.fromRGB(160,160,170),
    border   = Color3.fromRGB(55,55,65),
    shadow   = Color3.fromRGB(0,0,0),
}

-- أصوات (غيّر الـ IDs لو حابب)
local SOUND_IDS = {
    join  = "rbxassetid://138090596", -- Ding
    leave = "rbxassetid://138097048", -- Buzz
    click = "rbxassetid://12222005",
}

-- حجم اللوحة (متوسط → صغير)
local PANEL_W, PANEL_H = 720, 420   -- تقدر تصغر/تكبر هنا بس
local CARD_GAP          = 10

--========================================================
-- أدوات مساعدة
--========================================================
local function uiRoundify(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
    return c
end

local function uiPadding(obj, l,t,r,b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = obj
    return p
end

local function uiStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function makeText(parent, txt, size, color, bold, center)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.FontFace = Font.new("rbxasset://fonts/families/NotoSansArabic.json", Enum.FontWeight[bold and "Bold" or "Regular"])
    l.TextSize = size or 18
    l.TextColor3 = color or THEME.text
    l.Text = txt or ""
    l.TextXAlignment = center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function makeButton(parent, txt, size)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = true
    b.Text = txt or ""
    b.BackgroundColor3 = THEME.bar
    b.TextColor3 = THEME.text
    b.FontFace = Font.new("rbxasset://fonts/families/NotoSansArabic.json", Enum.FontWeight.Bold)
    b.TextSize = size or 16
    uiRoundify(b, 10)
    uiStroke(b, THEME.border, 1, 0.15)
    b.Parent = parent
    return b
end

local function play(id)
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = 0.5
    s.Parent = game:GetService("CoreGui")
    s:Play()
    s.Ended:Connect(function() s:Destroy() end)
end

local function formatTime(sec)
    sec = math.max(0, math.floor(sec))
    local m = math.floor(sec/60)
    local s = sec % 60
    return string.format("%02d:%02d", m, s)
end

--========================================================
-- ScreenGui + زر فتح/قفل (قابل للسحب)
--========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GS4_Tracker_UI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- زر صغير
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "GS4_Toggle"
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.fromOffset(46,46)
ToggleBtn.Position = UDim2.new(0, 20, 0.35, 0)
ToggleBtn.Image = "rbxassetid://3926305904" -- أيقونة قائمة
ToggleBtn.ImageRectOffset = Vector2.new(324, 364)
ToggleBtn.ImageRectSize   = Vector2.new(36, 36)
ToggleBtn.BackgroundColor3 = THEME.panel
uiRoundify(ToggleBtn, 12)
uiStroke(ToggleBtn, THEME.border, 1, 0.2)

-- سحب الزر
do
    local dragging, offset
    ToggleBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            offset = Vector2.new(i.Position.X, i.Position.Y) - Vector2.new(ToggleBtn.AbsolutePosition.X, ToggleBtn.AbsolutePosition.Y)
        end
    end)
    ToggleBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInput.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local pos = Vector2.new(i.Position.X, i.Position.Y) - offset
            ToggleBtn.Position = UDim2.fromOffset(pos.X, pos.Y)
        end
    end)
end

-- اللوحة الرئيسية
local Panel = Instance.new("Frame")
Panel.Name = "GS4_Panel"
Panel.Parent = ScreenGui
Panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
Panel.Position = UDim2.new(0.5, -PANEL_W/2, 0.5, -PANEL_H/2)
Panel.BackgroundColor3 = THEME.bg
Panel.Visible = false
uiRoundify(Panel, 18)
uiStroke(Panel, THEME.border, 1, 0.2)

-- شريط علوي
local TopBar = Instance.new("Frame")
TopBar.Parent = Panel
TopBar.Size = UDim2.new(1,0,0,54)
TopBar.BackgroundColor3 = THEME.panel
uiRoundify(TopBar, 18)
uiPadding(TopBar, 16, 6, 16, 6)

local Title = makeText(TopBar, "GS4 | العم حكومه  🍷", 28, THEME.blue, true, true)
Title.Size = UDim2.new(1,0,1,0)

-- تبديل ظهور اللوحة
ToggleBtn.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
    play(SOUND_IDS.click)
end)

--========================================================
-- شبكة الكروت 2×2
--========================================================
local Grid = Instance.new("Frame")
Grid.Parent = Panel
Grid.BackgroundTransparency = 1
Grid.Size = UDim2.new(1, -20, 1, -74)
Grid.Position = UDim2.new(0, 10, 0, 64)

local UIGrid = Instance.new("UIGridLayout")
UIGrid.Parent = Grid
UIGrid.CellPadding = UDim2.fromOffset(CARD_GAP, CARD_GAP)
UIGrid.CellSize = UDim2.new(0.5, -CARD_GAP/2, 0.5, -CARD_GAP/2)

--========================================================
-- منطق الكارت الواحد
--========================================================
local function createCard(index)
    local card = Instance.new("Frame")
    card.Name = "Card_"..index
    card.BackgroundColor3 = THEME.card
    uiRoundify(card, 14)
    uiStroke(card, THEME.border, 1, 0.2)
    card.Parent = Grid

    uiPadding(card, 10, 10, 10, 10)

    -- Head bar + صندوق البحث
    local head = Instance.new("Frame")
    head.Parent = card
    head.BackgroundColor3 = THEME.bar
    head.Size = UDim2.new(1,0,0,40)
    uiRoundify(head, 10)
    uiStroke(head, THEME.border, 1, 0.2)

    local search = Instance.new("TextBox")
    search.Parent = head
    search.BackgroundTransparency = 1
    search.ClearTextOnFocus = false
    search.Text = "" -- بلا نص "اكتب اسم"
    search.TextSize = 18
    search.TextColor3 = THEME.text
    search.FontFace = Font.new("rbxasset://fonts/families/NotoSansArabic.json", Enum.FontWeight.Medium)
    search.Size = UDim2.new(1, -16, 1, 0)
    search.Position = UDim2.fromOffset(8,0)
    search.TextXAlignment = Enum.TextXAlignment.Left

    -- جسم المعلومات
    local body = Instance.new("Frame")
    body.Parent = card
    body.BackgroundTransparency = 1
    body.Size = UDim2.new(1,0,1,-50)
    body.Position = UDim2.new(0,0,0,48)

    -- صورة الأفاتار (مخفية لحين التحديد)
    local avatar = Instance.new("ImageLabel")
    avatar.Parent = body
    avatar.BackgroundColor3 = THEME.panel
    avatar.Size = UDim2.fromOffset(80,80)
    avatar.Position = UDim2.fromOffset(8,8)
    avatar.Visible = false
    avatar.ScaleType = Enum.ScaleType.Fit
    uiRoundify(avatar, 10)
    uiStroke(avatar, THEME.border, 1, 0.2)

    -- اسم المستخدم + اللقب (لا تظهران إلا عند التحديد)
    local userLabel = makeText(body, "", 20, THEME.blue, true, false)
    userLabel.Position = UDim2.fromOffset(100, 10)
    userLabel.Size = UDim2.new(1, -110, 0, 24)
    userLabel.Visible = false

    local dispLabel = makeText(body, "", 18, Color3.fromRGB(120,220,220), false, false)
    dispLabel.Position = UDim2.fromOffset(100, 40)
    dispLabel.Size = UDim2.new(1, -110, 0, 22)
    dispLabel.Visible = false

    -- صف العدادات
    local stats = Instance.new("Frame")
    stats.Parent = body
    stats.BackgroundTransparency = 1
    stats.Size = UDim2.new(1, -10, 0, 28)
    stats.Position = UDim2.new(0, 8, 0, 96)

    local joinsTxt = makeText(stats, "0 :دخول", 18, THEME.green, true, false)
    joinsTxt.Position = UDim2.fromOffset(0,0)
    joinsTxt.Size = UDim2.new(0.5, -6, 1, 0)

    local leavesTxt = makeText(stats, "0 :خروج", 18, THEME.red, true, false)
    leavesTxt.Position = UDim2.new(0.5, 6, 0, 0)
    leavesTxt.Size = UDim2.new(0.5, -6, 1, 0)

    -- سطر “منذ بدء التتبع / المدة”
    local timeRow = Instance.new("Frame")
    timeRow.Parent = body
    timeRow.BackgroundTransparency = 1
    timeRow.Size = UDim2.new(1,-10,0,26)
    timeRow.Position = UDim2.new(0,8,0,130)

    local sinceTxt = makeText(timeRow, "", 16, THEME.dim, false, false)
    sinceTxt.Size = UDim2.new(0.5, -6, 1, 0)

    local durTxt = makeText(timeRow, "", 16, THEME.dim, false, true)
    durTxt.Position = UDim2.new(0.5,6,0,0)
    durTxt.Size = UDim2.new(0.5, -6, 1, 0)

    -- حالة الكارت
    local state = {
        target      = nil,     -- Player
        targetName  = "",
        joins       = 0,
        leaves      = 0,
        startTick   = 0,
        consAdded   = nil,
        consRemoved = nil,
        hbConn      = nil
    }

    local function clearTracking()
        -- فك أي اتصالات
        if state.consAdded then state.consAdded:Disconnect() state.consAdded=nil end
        if state.consRemoved then state.consRemoved:Disconnect() state.consRemoved=nil end
        if state.hbConn then state.hbConn:Disconnect() state.hbConn=nil end

        state.target     = nil
        state.targetName = ""
        state.joins, state.leaves = 0,0
        state.startTick  = 0

        avatar.Visible   = false
        userLabel.Visible = false
        dispLabel.Visible = false
        joinsTxt.Text    = "0 :دخول"
        leavesTxt.Text   = "0 :خروج"
        sinceTxt.Text    = ""
        durTxt.Text      = ""
    end

    local function updateAvatar(plr)
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and img then
            avatar.Image = img
            avatar.Visible = true
        else
            avatar.Visible = false
        end
    end

    local function setLabels(plr)
        userLabel.Text = "اسم المستخدم:  " .. (plr and plr.Name or "-")
        dispLabel.Text = "اللقب:  " .. (plr and plr.DisplayName or "-")
        userLabel.Visible = plr ~= nil
        dispLabel.Visible = plr ~= nil
    end

    local function updateCounters()
        joinsTxt.Text  = tostring(state.joins) .. " :دخول"
        leavesTxt.Text = tostring(state.leaves) .. " :خروج"
    end

    local function startTimer()
        if state.hbConn then state.hbConn:Disconnect() end
        state.hbConn = RunService.Heartbeat:Connect(function()
            if state.startTick > 0 then
                local since = os.time() - state.startTick
                sinceTxt.Text = "منذ بدء التتبع: "..formatTime(since)
                durTxt.Text   = "المدة: "..formatTime(since)
            end
        end)
    end

    local function beginTracking(plr)
        clearTracking()

        if not plr then return end
        state.target     = plr
        state.targetName = plr.Name
        state.startTick  = os.time()
        updateAvatar(plr)
        setLabels(plr)
        updateCounters()
        startTimer()

        -- ربط العدّادات
        state.consAdded = Players.PlayerAdded:Connect(function(p)
            if state.target and p.Name == state.targetName then
                state.joins += 1
                updateCounters()
                play(SOUND_IDS.join)
            end
        end)
        state.consRemoved = Players.PlayerRemoving:Connect(function(p)
            if state.target and p.Name == state.targetName then
                state.leaves += 1
                updateCounters()
                play(SOUND_IDS.leave)
            end
        end)
    end

    -- البحث الفوري (من أول حرفين)
    local function tryCapture(query)
        query = (query or ""):lower()
        if #query < 2 then
            clearTracking()
            return
        end

        local hit = nil
        for _,p in ipairs(Players:GetPlayers()) do
            local name  = p.Name:lower()
            local dname = p.DisplayName:lower()
            if name:sub(1, #query) == query or dname:sub(1, #query) == query then
                hit = p
                break
            end
        end
        beginTracking(hit)
    end

    -- أحداث الإدخال
    search:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = search.Text
        if txt == "" then
            clearTracking()
        else
            tryCapture(txt)
        end
    end)

    search.FocusLost:Connect(function()
        local txt = search.Text
        if txt == "" then
            clearTracking()
        else
            tryCapture(txt)
        end
    end)

    return {
        clear = clearTracking,
        set   = beginTracking,
        box   = search,
        getTarget = function() return state.target end,
    }
end

-- إنشاء 4 كروت
local Cards = {}
for i=1,4 do
    Cards[i] = createCard(i)
end

--========================================================
-- تحسينات بسيطة للّمسات البصرية
--========================================================
do
    local shadow = Instance.new("ImageLabel")
    shadow.Parent = Panel
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857084"
    shadow.ImageColor3 = THEME.shadow
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24,24,276,276)
    shadow.Size = UDim2.new(1,20,1,20)
    shadow.Position = UDim2.fromOffset(-10,-10)
    shadow.ZIndex = 0
end

--========================================================
-- إظهار اللوحة افتراضيًا أول مرة
--========================================================
Panel.Visible = true

-- ملاحظة:
-- - اكتب أول حرفين أو أكثر من اسم اللاعب أو لقبه في أي مربع بحث.
-- - لو فضّيت الخانة، الكارت هيلغي التتبّع فورًا.
-- - بعد الالتقاط الناجح: يظهر (اسم المستخدم/اللقب/الأفاتار) + عدادات الدخول/الخروج.
-- - فيه صوت لكل دخول/خروج للاعب المتتبّع.
-- - الزر الصغير بيتسحب لأي مكان ويقفل/يفتح اللوحة.
-- تمت.
