--[[
  ✨ العم حكومه 🍷 | GS4 👑 — تتبع 4 (نسخة مستقرة بدون لاج)
  - لا يضيف لاعبين تلقائياً: يظهر فقط عند التقاط الاسم/اللقب من البحث.
  - تايمر حقيقي يبدأ من لحظة التتبع + “دخل الماب” لمن يدخل بعد تشغيل السكربت.
  - زر فتح/قفل صغير قابل للسحب.
  - تحديث تايمرات موحّد كل ثانية (أداء أفضل).
  - صورة أفاتار من GetUserThumbnailAsync (رسمي).
  ملاحظة تقنية: اللاعبين الموجودين قبل تشغيل السكربت لن نعرف وقت دخولهم الحقيقي من الكلاينت،
  فنعرض وقت التتبع فقط لهم. أي لاعب يدخل بعد كده بنسجّل دخوله الحقيقي لحظياً.
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GS4Tracker"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- زر فتح/قفل صغير قابل للسحب
local Toggle = Instance.new("TextButton")
Toggle.Name = "GS4_Toggle"
Toggle.Size = UDim2.new(0, 36, 0, 36)
Toggle.Position = UDim2.new(0.85, 0, 0.1, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
Toggle.Text = "≡"
Toggle.TextScaled = true
Toggle.TextColor3 = Color3.fromRGB(255,255,255)
Toggle.AutoButtonColor = true
Toggle.Parent = ScreenGui
do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = Toggle
end

-- سحب الزر
do
    local dragging = false
    local dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        Toggle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    Toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Toggle.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- الإطار الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Name = "GS4_Main"
MainFrame.Size = UDim2.new(0, 480, 0, 340)
MainFrame.Position = UDim2.new(0.25, 0, 0.22, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = MainFrame
end

Toggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -12, 0, 38)
Title.Position = UDim2.new(0, 6, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "✨ العم حكومه 🍷 | GS4 👑"
Title.TextColor3 = Color3.fromRGB(0,170,255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- حاوية الكروت
local CardsFrame = Instance.new("Frame")
CardsFrame.Size = UDim2.new(1, -12, 1, -96)
CardsFrame.Position = UDim2.new(0, 6, 0, 44)
CardsFrame.BackgroundTransparency = 1
CardsFrame.Parent = MainFrame

local Grid = Instance.new("UIGridLayout")
Grid.Parent = CardsFrame
Grid.CellSize = UDim2.new(0, 226, 0, 136) -- 2x2 بحجم صغير
Grid.CellPadding = UDim2.new(0, 8, 0, 8)
Grid.FillDirectionMaxCells = 2

-- مربع البحث
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.96, 0, 0, 32)
SearchBox.Position = UDim2.new(0.02, 0, 1, -40)
SearchBox.PlaceholderText = "🔍 اكتب أول حروف (يوزر أو لقب)..."
SearchBox.Text = ""
SearchBox.Font = Enum.Font.GothamBold
SearchBox.TextScaled = true
SearchBox.TextColor3 = Color3.fromRGB(255,255,255)
SearchBox.BackgroundColor3 = Color3.fromRGB(35,35,45)
SearchBox.Parent = MainFrame
do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = SearchBox
end

-- ===== المنطق =====
local MAX_CARDS = 4
local tracked = {}        -- [userId] = cardData
local order = {}          -- ترتيب الإضافة (علشان نستبدل الأقدم لو امتلينا)
local joinTimes = {}      -- وقت دخول الماب الحقيقي لمن يدخل بعد تشغيل السكربت
local leftTimes = {}      -- وقت الخروج (نثبّت التايمر)

-- بطاقة لاعب
local function makeCard(player: Player, trackStartUnix: number)
    -- لو عندنا 4، نشيل أقدم واحد
    if #order >= MAX_CARDS then
        local oldUserId = table.remove(order, 1)
        if tracked[oldUserId] and tracked[oldUserId].frame then
            tracked[oldUserId].frame:Destroy()
        end
        tracked[oldUserId] = nil
    end

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(35,35,45)
    frame.Parent = CardsFrame
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = frame
    end

    -- هالة خفيفة عند الإضافة
    do
        frame.BackgroundTransparency = 0.2
        TweenService:Create(frame, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
    end

    -- أفاتار
    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 54, 0, 54)
    avatar.Position = UDim2.new(0, 6, 0, 6)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxassetid://0"
    avatar.Parent = frame

    -- اسم المستخدم
    local userLabel = Instance.new("TextLabel")
    userLabel.Size = UDim2.new(1, -68, 0, 24)
    userLabel.Position = UDim2.new(0, 66, 0, 6)
    userLabel.BackgroundTransparency = 1
    userLabel.Text = "👤 " .. player.Name
    userLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    userLabel.TextScaled = true
    userLabel.Font = Enum.Font.GothamBold
    userLabel.Parent = frame

    -- اللقب
    local dispLabel = Instance.new("TextLabel")
    dispLabel.Size = UDim2.new(1, -68, 0, 22)
    dispLabel.Position = UDim2.new(0, 66, 0, 30)
    dispLabel.BackgroundTransparency = 1
    dispLabel.Text = "⭐ " .. player.DisplayName
    dispLabel.TextColor3 = Color3.fromRGB(255, 220, 180)
    dispLabel.TextScaled = true
    dispLabel.Font = Enum.Font.GothamBold
    dispLabel.Parent = frame

    -- دخل الماب (إن توفر)
    local joinLabel = Instance.new("TextLabel")
    joinLabel.Size = UDim2.new(1, -68, 0, 18)
    joinLabel.Position = UDim2.new(0, 66, 0, 54)
    joinLabel.BackgroundTransparency = 1
    joinLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    joinLabel.TextScaled = true
    joinLabel.Font = Enum.Font.GothamSemiBold
    joinLabel.Parent = frame

    local jt = joinTimes[player.UserId]
    if jt then
        joinLabel.Text = "🟢 دخل: " .. os.date("%X", jt)
    else
        joinLabel.Text = "🟢 دخل: —"
    end

    -- بدأ التتبع
    local trackLabel = Instance.new("TextLabel")
    trackLabel.Size = UDim2.new(1, -68, 0, 18)
    trackLabel.Position = UDim2.new(0, 66, 0, 74)
    trackLabel.BackgroundTransparency = 1
    trackLabel.Text = "🔎 تتبع من: " .. os.date("%X", trackStartUnix)
    trackLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    trackLabel.TextScaled = true
    trackLabel.Font = Enum.Font.GothamSemiBold
    trackLabel.Parent = frame

    -- تايمر
    local timer = Instance.new("TextLabel")
    timer.Size = UDim2.new(1, -12, 0, 26)
    timer.Position = UDim2.new(0, 6, 0, 102)
    timer.BackgroundTransparency = 1
    timer.TextColor3 = Color3.fromRGB(150, 150, 255)
    timer.TextScaled = true
    timer.Font = Enum.Font.GothamBold
    timer.Text = "⏳ 00:00:00"
    timer.Parent = frame

    -- صورة الأفاتار (رسمي)
    task.spawn(function()
        local ok, url = pcall(function()
            local image, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            return image
        end)
        if ok and url then avatar.Image = url end
    end)

    -- احفظ البيانات
    tracked[player.UserId] = {
        frame = frame,
        player = player,
        trackStart = trackStartUnix,
        timerLabel = timer,
        left = false,
    }
    table.insert(order, player.UserId)
end

-- حذف بطاقة
local function removeCard(userId:number, markLeft:boolean)
    local data = tracked[userId]
    if not data then return end
    if markLeft and data.timerLabel then
        data.left = true
        data.timerLabel.Text = "🚪 خرج"
        data.timerLabel.TextColor3 = Color3.fromRGB(255,0,0)
        -- خليه باين إنه خرج بدل ما نمسحه فوراً
        TweenService:Create(data.frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45,25,25)}):Play()
        -- امسحه بعد شوية
        task.delay(2.0, function()
            if data.frame then data.frame:Destroy() end
        end)
    else
        if data.frame then data.frame:Destroy() end
    end
    -- شيل من الترتيب
    for i, uid in ipairs(order) do
        if uid == userId then table.remove(order, i) break end
    end
    tracked[userId] = nil
end

-- تحديث تايمرات كل ثانية (موحّد)
do
    local acc = 0
    RunService.Heartbeat:Connect(function(dt)
        acc += dt
        if acc < 1 then return end
        acc = 0
        local now = os.time()
        for _, data in pairs(tracked) do
            if not data.left and data.timerLabel and data.trackStart then
                local elapsed = now - data.trackStart
                if elapsed < 0 then elapsed = 0 end
                local h = math.floor(elapsed / 3600)
                local m = math.floor((elapsed % 3600) / 60)
                local s = elapsed % 60
                data.timerLabel.Text = string.format("⏳ %02d:%02d:%02d", h, m, s)
            end
        end
    end)
end

-- التقاط بالبحث (يلقط من أول حروف اليوزر أو اللقب، أو حتى جزء من النص)
local function tryTrackByQuery(q:string)
    q = q:lower()
    if #q < 2 then return end -- لتجنب اللقط العشوائي من حرف واحد
    -- أفضلية: يبدأ بالاسم > يبدأ باللقب > يحتوي الاسم > يحتوي اللقب
    local best
    local function score(plr)
        local n, d = plr.Name:lower(), plr.DisplayName:lower()
        if n:sub(1, #q) == q then return 1 end
        if d:sub(1, #q) == q then return 2 end
        if string.find(n, q, 1, true) then return 3 end
        if string.find(d, q, 1, true) then return 4 end
        return math.huge
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local sc = score(plr)
            if sc < math.huge and not tracked[plr.UserId] then
                if not best or sc < best.sc then
                    best = {plr = plr, sc = sc}
                end
            end
        end
    end
    if best and best.plr then
        makeCard(best.plr, os.time())
        -- فلاش بسيط تأكيد الالتقاط
        TweenService:Create(MainFrame, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(26,26,38)}):Play()
        task.delay(0.14, function()
            TweenService:Create(MainFrame, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(20,20,30)}):Play()
        end)
    end
end

-- تغيّر البحث
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    tryTrackByQuery(SearchBox.Text)
end)

-- دخول/خروج حقيقيين
Players.PlayerAdded:Connect(function(plr)
    -- سجّل وقت دخول الماب الحقيقي للاعبين الجدد
    joinTimes[plr.UserId] = os.time()
end)

Players.PlayerRemoving:Connect(function(plr)
    leftTimes[plr.UserId] = os.time()
    if tracked[plr.UserId] then
        removeCard(plr.UserId, true) -- علّمه أنه خرج وبعدين امسحه
    end
end)

-- لا نضيف أي لاعب تلقائيًا هنا (عشان ما يلقطش لوحده)
-- اللاعبين الموجودين بالفعل قبل تشغيل السكربت: joinTimes مش متوفر لهم (بنظهر "—")، والتتبع يبدأ عند الالتقاط.

-- اختياري: اضغط Enter يعمل محاولة لالتقاط سريع
SearchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        tryTrackByQuery(SearchBox.Text)
    end
end)
