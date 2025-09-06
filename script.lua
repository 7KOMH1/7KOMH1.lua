--[[
    تتبع 4 لاعبين | نسخة كاملة شاملة نهائية
    الحقوق: العم حكومه 🍷 | كلان EG
    ملاحظات سريعة:
      • اكتب في الخانة من أول حرفين (يوزر أو لقب) – يلقط فورًا.
      • امسح الخانة لإلغاء التتبع.
      • واجهة متوسطة–صغيرة، مظلمة، مرتبة، وأداء عالي بدون لاج.
]]--

-- تنظيف أي نسخة سابقة
pcall(function()
    local root = (gethui and gethui()) or game:GetService("CoreGui")
    local old = root:FindFirstChild("EG_7KOMH_FULL_TRACKER")
    if old then old:Destroy() end
end)

-- خدمات Roblox
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local StarterGui    = game:GetService("StarterGui")
local UserInput     = game:GetService("UserInputService")

local LocalPlayer   = Players.LocalPlayer

-- إشعار صغير
local function toast(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "تنبيه",
            Text  = tostring(msg or ""),
            Duration = 2
        })
    end)
end

-- كاش صور الأفاتار لتسريع العرض
local ThumbCache = {} -- [userId] = contentId
local function getHeadshot(userId)
    if not userId or userId <= 0 then return nil end
    if ThumbCache[userId] then return ThumbCache[userId] end
    local ok, content = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and content then
        ThumbCache[userId] = content
        return content
    end
    return nil
end

-- بحث ذكي: يوزر أو لقب، من أول حرفين
local function smartFind(q)
    if not q then return nil end
    q = q:gsub("^%s+",""):gsub("%s+$","")
    if #q < 2 then return nil end
    local lq = string.lower(q)
    local best
    for _,plr in ipairs(Players:GetPlayers()) do
        local un = string.lower(plr.Name or "")
        local dn = string.lower(plr.DisplayName or "")
        if un:sub(1,#lq) == lq or dn:sub(1,#lq) == lq then
            best = plr
            break
        end
    end
    return best
end

-- إنشاء واجهة
local Gui = Instance.new("ScreenGui")
Gui.Name = "EG_7KOMH_FULL_TRACKER"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- زر فتح/قفل صغير (٣ شرطات) + قابل للسحب
local Toggle = Instance.new("Frame")
Toggle.Name = "Toggle"
Toggle.Parent = Gui
Toggle.BackgroundColor3 = Color3.fromRGB(28,28,32)
Toggle.BorderSizePixel = 0
Toggle.Size = UDim2.fromOffset(34, 34)
Toggle.Position = UDim2.new(0.06, 0, 0.35, 0)
local tCorner = Instance.new("UICorner", Toggle); tCorner.CornerRadius = UDim.new(0, 8)
local tStroke = Instance.new("UIStroke", Toggle); tStroke.Color = Color3.fromRGB(60,60,68); tStroke.Thickness = 1; tStroke.Transparency = 0.25

local function makeBar(p,y)
    local b = Instance.new("Frame")
    b.Parent = p
    b.BackgroundColor3 = Color3.fromRGB(235,235,240)
    b.BorderSizePixel = 0
    b.AnchorPoint = Vector2.new(0.5,0.5)
    b.Position = UDim2.new(0.5,0,y,0)
    b.Size = UDim2.new(0.68,0,0,2)
    local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0,2)
end
makeBar(Toggle, 0.30)
makeBar(Toggle, 0.50)
makeBar(Toggle, 0.70)

-- سحب زر التبديل
do
    local dragging, startPos, startInput
    Toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = Vector2.new(Toggle.AbsolutePosition.X, Toggle.AbsolutePosition.Y)
            startInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Toggle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput.Position
            Toggle.Position = UDim2.fromOffset(startPos.X + delta.X, startPos.Y + delta.Y)
        end
    end)
end

-- اللوحة الرئيسية (متوسط → صغير)
local Main = Instance.new("Frame")
Main.Parent = Gui
Main.BackgroundColor3 = Color3.fromRGB(16,16,18)
Main.BorderSizePixel = 0
Main.Size = UDim2.new(0, 600, 0, 360)
Main.Position = UDim2.new(0.5, -300, 0.5, -180)
local mCorner = Instance.new("UICorner", Main); mCorner.CornerRadius = UDim.new(0, 14)
local mStroke = Instance.new("UIStroke", Main); mStroke.Color = Color3.fromRGB(48,48,56); mStroke.Thickness = 1; mStroke.Transparency = 0.22
local padMain = Instance.new("UIPadding", Main)
padMain.PaddingTop = UDim.new(0, 64)
padMain.PaddingLeft = UDim.new(0, 12)
padMain.PaddingRight = UDim.new(0, 12)
padMain.PaddingBottom = UDim.new(0, 12)

-- سحب اللوحة
do
    local dragging, startPos, startInput
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = Vector2.new(Main.AbsolutePosition.X, Main.AbsolutePosition.Y)
            startInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Main.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput.Position
            Main.Position = UDim2.fromOffset(startPos.X + delta.X, startPos.Y + delta.Y)
        end
    end)
end

-- الهيدر + الحقوق
local Header = Instance.new("Frame", Main)
Header.BackgroundColor3 = Color3.fromRGB(22,22,26)
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1, 0, 0, 56)
Header.Position = UDim2.new(0,0,0,0)
local hCorner = Instance.new("UICorner", Header); hCorner.CornerRadius = UDim.new(0, 14)
local hStroke = Instance.new("UIStroke", Header); hStroke.Color = Color3.fromRGB(52,52,60); hStroke.Thickness = 1; hStroke.Transparency = 0.18

local Title = Instance.new("TextLabel", Header)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.TextColor3 = Color3.fromRGB(0,142,255) -- أزرق واضح
Title.Text = "العم حكومه 🍷 | كلان EG"

-- زر إغلاق
local Close = Instance.new("TextButton", Header)
Close.Text = "×"
Close.Font = Enum.Font.GothamBold
Close.TextScaled = true
Close.BackgroundTransparency = 1
Close.TextColor3 = Color3.fromRGB(180,180,180)
Close.Size = UDim2.fromOffset(40, 40)
Close.Position = UDim2.new(1, -46, 0.5, -20)
Close.AutoButtonColor = true

local isOpen = true
local function setOpen(v)
    isOpen = v
    Main.Visible = v
end
Toggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        setOpen(not isOpen)
    end
end)
Close.MouseButton1Click:Connect(function() setOpen(false) end)

-- شبكة 2×2
local Grid = Instance.new("UIGridLayout", Main)
Grid.CellPadding = UDim2.fromOffset(12,12)
Grid.CellSize    = UDim2.new(0.5, -18, 0.5, -22)
Grid.SortOrder   = Enum.SortOrder.LayoutOrder
Grid.FillDirectionMaxCells = 2

----------------------------------------------------------------------
-- أدوات صغيرة
local function smallLabel(parent, text, size, color, bold, xalign)
    local L = Instance.new("TextLabel")
    L.Parent = parent
    L.BackgroundTransparency = 1
    L.Text = text or ""
    L.TextColor3 = color or Color3.fromRGB(220,220,225)
    L.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    L.TextScaled = false
    L.TextSize = size or 16
    L.TextXAlignment = xalign or Enum.TextXAlignment.Left
    return L
end

local function roundedFrame(parent, bg, radius)
    local f = Instance.new("Frame")
    f.Parent = parent
    f.BackgroundColor3 = bg or Color3.fromRGB(26,26,30)
    f.BorderSizePixel = 0
    local c = Instance.new("UICorner", f); c.CornerRadius = UDim.new(0, radius or 10)
    local s = Instance.new("UIStroke", f); s.Color = Color3.fromRGB(52,52,58); s.Thickness = 1; s.Transparency = 0.20
    return f
end

----------------------------------------------------------------------
-- مكون خانة تتبع واحدة
local function createTrackerCell(index)
    local card = roundedFrame(Main, Color3.fromRGB(26,26,30), 12)

    local pad = Instance.new("UIPadding", card)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)

    -- حقل الإدخال (فاضي – بدون Placeholder)
    local input = Instance.new("TextBox", card)
    input.Size = UDim2.new(1, -12, 0, 34)
    input.Position = UDim2.new(0, 6, 0, 6)
    input.BackgroundColor3 = Color3.fromRGB(34,34,38)
    input.BorderSizePixel = 0
    input.ClearTextOnFocus = false
    input.Text = ""
    input.PlaceholderText = ""
    input.Font = Enum.Font.GothamSemibold
    input.TextSize = 18
    input.TextColor3 = Color3.fromRGB(235,235,238)
    input.TextXAlignment = Enum.TextXAlignment.Left
    local inpC = Instance.new("UICorner", input); inpC.CornerRadius = UDim.new(0, 10)
    local inpS = Instance.new("UIStroke", input); inpS.Color = Color3.fromRGB(60,60,66); inpS.Thickness = 1; inpS.Transparency = 0.25

    -- جسم أفقي: الصورة + معلومات (المعلومات مخفية لحد ما يتحدد لاعب)
    local body = Instance.new("Frame", card)
    body.BackgroundTransparency = 1
    body.Size = UDim2.new(1, -12, 1, - (34 + 16))
    body.Position = UDim2.new(0, 6, 0, 34 + 10)

    local lay = Instance.new("UIListLayout", body)
    lay.FillDirection = Enum.FillDirection.Horizontal
    lay.Padding = UDim.new(0, 8)
    lay.HorizontalAlignment = Enum.HorizontalAlignment.Left
    lay.VerticalAlignment = Enum.VerticalAlignment.Top

    local avatar = Instance.new("ImageLabel", body)
    avatar.Size = UDim2.fromOffset(74,74)
    avatar.BackgroundColor3 = Color3.fromRGB(30,30,34)
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxassetid://11270877980" -- مؤقت
    local avC = Instance.new("UICorner", avatar); avC.CornerRadius = UDim.new(0, 10)
    local avS = Instance.new("UIStroke", avatar); avS.Color = Color3.fromRGB(55,55,60); avS.Thickness = 1; avS.Transparency = 0.22

    local info = Instance.new("Frame", body)
    info.BackgroundTransparency = 1
    info.Size = UDim2.new(1, -90, 1, 0)
    info.Visible = false -- يظهر بعد التقاط اللاعب

    local uname = smallLabel(info, "يوزر: -", 18, Color3.fromRGB(0,142,255), true)
    uname.Size = UDim2.new(1, 0, 0, 26)
    uname.Position = UDim2.new(0, 0, 0, 0)

    local dname = smallLabel(info, "لقب: -", 18, Color3.fromRGB(225,225,230), true)
    dname.Size = UDim2.new(1, 0, 0, 24)
    dname.Position = UDim2.new(0, 0, 0, 26)

    local stats = Instance.new("Frame", info)
    stats.BackgroundTransparency = 1
    stats.Size = UDim2.new(1, 0, 0, 22)
    stats.Position = UDim2.new(0, 0, 0, 26+24)

    local join = smallLabel(stats, "دخول: 0", 16, Color3.fromRGB(20,210,95), true)
    join.Size = UDim2.new(0.5, -4, 1, 0)
    join.Position = UDim2.new(0, 0, 0, 0)

    local leave = smallLabel(stats, "خروج: 0", 16, Color3.fromRGB(230,70,70), true)
    leave.Size = UDim2.new(0.5, -4, 1, 0)
    leave.Position = UDim2.new(0.5, 8, 0, 0)
    leave.TextXAlignment = Enum.TextXAlignment.Right

    local dur = smallLabel(info, "المدة: 00:00", 16, Color3.fromRGB(190,190,195), false)
    dur.Size = UDim2.new(1, 0, 0, 20)
    dur.Position = UDim2.new(0, 0, 0, 26+24+22)

    -- حالة التتبع
    local state = {
        userId = nil,
        name   = nil,
        dname  = nil,
        joins  = 0,
        leaves = 0,
        start  = 0
    }

    local function refresh()
        if state.userId then
            uname.Text = "يوزر: " .. (state.name or "-")
            dname.Text = "لقب: " .. (state.dname or "-")
            join.Text  = "دخول: " .. tostring(state.joins)
            leave.Text = "خروج: " .. tostring(state.leaves)
            info.Visible = true
        else
            info.Visible = false
            avatar.Image = "rbxassetid://11270877980"
            dur.Text = "المدة: 00:00"
        end
    end

    local function setTarget(plr)
        if not plr then
            state.userId = nil
            state.name   = nil
            state.dname  = nil
            state.joins  = 0
            state.leaves = 0
            state.start  = 0
            refresh()
            return
        end
        state.userId = plr.UserId
        state.name   = plr.Name
        state.dname  = plr.DisplayName or plr.Name
        state.joins  = 0
        state.leaves = 0
        state.start  = tick()
        local img = getHeadshot(plr.UserId)
        if img then avatar.Image = img end
        refresh()
        toast("تم تحديد: "..state.dname)
    end

    -- التقط بسرعة فائقة مع خنق بسيط لمنع السبام
    local last = 0
    input:GetPropertyChangedSignal("Text"):Connect(function()
        local now = tick()
        if now - last < 0.06 then return end -- أسرع من عُشر ثانية
        last = now
        local q = (input.Text or ""):gsub("^%s+",""):gsub("%s+$","")
        if q == "" then setTarget(nil) return end
        if #q >= 2 then
            local p = smartFind(q)
            if p then setTarget(p) end
        end
    end)

    input.FocusLost:Connect(function()
        local q = (input.Text or ""):gsub("^%s+",""):gsub("%s+$","")
        if q == "" then setTarget(nil) return end
        local p = smartFind(q)
        if p then setTarget(p) else toast("لاعب غير موجود") end
    end)

    -- تحديث مدة التتبع
    RunService.Heartbeat:Connect(function()
        if state.userId and state.start > 0 then
            local t = math.floor(tick() - state.start)
            local m = math.floor(t/60)
            local s = t % 60
            dur.Text = string.format("المدة: %02d:%02d", m, s)
        end
    end)

    -- عدادات الدخول/الخروج بدقة باستخدام UserId
    Players.PlayerAdded:Connect(function(p)
        if state.userId and p.UserId == state.userId then
            state.joins += 1
            local img = getHeadshot(p.UserId)
            if img then avatar.Image = img end
            refresh()
            toast("دخول: "..(p.DisplayName or p.Name))
        end
    end)
    Players.PlayerRemoving:Connect(function(p)
        if state.userId and p.UserId == state.userId then
            state.leaves += 1
            refresh()
            toast("خروج: "..(p.DisplayName or p.Name))
        end
    end)

    refresh()
    return card
end

-- إنشاء ٤ خلايا مرتبة 2×2
for i=1,4 do
    local cell = createTrackerCell(i)
    cell.Parent = Main
end

toast("العم حكومه 🍷 | كلان EG — جاهز ✅")
