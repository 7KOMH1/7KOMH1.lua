--[[
  LocalScript: EG Tracker - نسخة نهائية مدمجة
  صنع حكومة | كلان EG - تتبع 4 لاعبين
  - 4 كروت تتبع
  - بحث من أول حرفين أو أكثر (يوزر أو DisplayName)
  - صورة أفاتار مربعة تظهر أسرع ما يمكن
  - عداد دخول/خروج حقيقي (+1 لكل دخول/خروج)
  - عداد وقت تتبع (ساعات:دقائق:ثواني) يبدأ عند الربط ويتوقف عند الخروج
  - زر إخفاء/إظهار للمحتوى فقط
  - هيدر قابل للسحب ويحفظ الموضع
  - كل النصوص بالعربي
  - لا يعتمد على تحميل خارجي أو loadstring
--]]

-- ======= خدمات ومتحولات أساسية =======
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ======= دوال مساعدة =======
local function New(class, props)
    local inst = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            pcall(function() inst[k] = v end)
        end
    end
    return inst
end

local function UICorner(parent, radius)
    local c = Instance.new("UICorner")
    c.Parent = parent
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function UIStroke(parent, thickness, color, transparency)
    local s = Instance.new("UIStroke")
    s.Parent = parent
    s.Thickness = thickness or 1
    s.Color = color or Color3.fromRGB(40,40,48)
    s.Transparency = transparency or 0.2
    return s
end

local function trim(s)
    return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function formatHMStoString(seconds)
    local s = math.max(0, math.floor(seconds or 0))
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = s % 60
    return string.format("%02d:%02d:%02d", h, m, sec)
end

local function clockStringFromUnix(ts)
    local t = type(ts) == "number" and os.date("*t", ts) or ts
    if not t then return "-" end
    local hour = t.hour
    local min = t.min
    local suffix = (hour >= 12) and "م" or "ص"
    local displayHour = hour % 12
    if displayHour == 0 then displayHour = 12 end
    return string.format("%02d:%02d %s", displayHour, min, suffix)
end

-- ======= Avatar thumbnail cache (preload) =======
local AvatarCache = {}
local function FetchAvatarThumb(userId)
    if not userId or userId <= 0 then return "rbxassetid://0" end
    if AvatarCache[userId] then return AvatarCache[userId] end
    local ok, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok and typeof(thumb) == "string" and thumb ~= "" then
        AvatarCache[userId] = thumb
        pcall(function() ContentProvider:PreloadAsync({thumb}) end)
        return thumb
    end
    return "rbxassetid://0"
end

-- ======= Colors config =======
local COLORS = {
    BG = Color3.fromRGB(10,10,10),
    PANEL = Color3.fromRGB(24,24,24),
    HEADER = Color3.fromRGB(18,18,18),
    ACCENT = Color3.fromRGB(0,150,255),
    TEXT = Color3.fromRGB(235,235,235),
    MUTED = Color3.fromRGB(155,155,160),
    GOOD = Color3.fromRGB(60,200,90),
    BAD = Color3.fromRGB(220,70,70),
    STROKE = Color3.fromRGB(45,45,52)
}

-- ======= حذف واجهات سابقة لو موجودة =======
pcall(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("EG_Tracker_GUI")
    if old then old:Destroy() end
end)

-- ======= بناء الواجهة =======
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = New("ScreenGui", {Name = "EG_Tracker_GUI", ResetOnSpawn = false, Parent = playerGui})

local Root = New("Frame", {
    Parent = ScreenGui,
    Name = "Root",
    Size = UDim2.new(0, 520, 0, 420),
    Position = UDim2.new(0.02, 0, 0.25, 0),
    BackgroundColor3 = COLORS.BG,
    BorderSizePixel = 0
})
UICorner(Root, 12); UIStroke(Root, 1, COLORS.STROKE, 0.18)

-- Header
local Header = New("Frame", {
    Parent = Root,
    Name = "Header",
    Size = UDim2.new(1, -28, 0, 84),
    Position = UDim2.new(0, 14, 0, 12),
    BackgroundColor3 = COLORS.HEADER,
    BorderSizePixel = 0
})
UICorner(Header, 10); UIStroke(Header, 1, COLORS.STROKE, 0.16)

local Title = New("TextLabel", {
    Parent = Header,
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = COLORS.ACCENT,
    Text = "صنع حكومة | كلان EG - تتبع 4 لاعبين",
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(0.8, 0, 0.6, 0),
    Position = UDim2.new(0, 12, 0, 8)
})

local Sub = New("TextLabel", {
    Parent = Header,
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = COLORS.MUTED,
    Text = "حقوق: حكومه",
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(0.8, 0, 0.4, 0),
    Position = UDim2.new(0, 12, 0, 38)
})

-- Toggle button (hide/show content only)
local ToggleBtn = New("TextButton", {
    Parent = Header,
    Size = UDim2.new(0, 96, 0, 36),
    Position = UDim2.new(1, -112, 0, 24),
    BackgroundColor3 = COLORS.PANEL,
    Font = Enum.Font.Gotham,
    TextSize = 16,
    TextColor3 = COLORS.TEXT,
    Text = "إخفاء",
    AutoButtonColor = true
})
UICorner(ToggleBtn, 8); UIStroke(ToggleBtn, 1, COLORS.STROKE, 0.16)
ToggleBtn.Active = true; ToggleBtn.Selectable = true; ToggleBtn.Draggable = true

-- separator under header
local Separator = New("Frame", {
    Parent = Root,
    Size = UDim2.new(1, -28, 0, 2),
    Position = UDim2.new(0, 14, 0, 108),
    BackgroundColor3 = COLORS.ACCENT,
    BorderSizePixel = 0
})

-- Content frame (this is what toggle hides)
local ContentFrame = New("Frame", {
    Parent = Root,
    Name = "Content",
    Size = UDim2.new(1, -28, 1, -136),
    Position = UDim2.new(0, 14, 0, 122),
    BackgroundTransparency = 1
})

-- Grid layout 2x2 for 4 cards
local Grid = New("Frame", {
    Parent = ContentFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0)
})

local UIGrid = Instance.new("UIGridLayout")
UIGrid.Parent = Grid
UIGrid.CellPadding = UDim2.new(0, 14, 0, 14)
UIGrid.CellSize = UDim2.new(0.5, -21, 0.5, -21)
UIGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIGrid.VerticalAlignment = Enum.VerticalAlignment.Top

-- ======= Card prototype (factory) =======
local CardProto = {}
CardProto.__index = CardProto

function CardProto.new(index)
    local self = setmetatable({}, CardProto)

    local frame = New("Frame", {Parent = Grid, BackgroundColor3 = COLORS.PANEL, BorderSizePixel = 0})
    UICorner(frame, 10); UIStroke(frame, 1, COLORS.STROKE, 0.15)
    self.Frame = frame

    -- Search textbox (empty placeholder)
    local search = New("TextBox", {
        Parent = frame,
        BackgroundColor3 = COLORS.BG,
        ClearTextOnFocus = false,
        PlaceholderText = "", -- LEFT EMPTY AS REQUESTED
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextColor3 = COLORS.TEXT,
        Size = UDim2.new(1, -12, 0, 36),
        Position = UDim2.new(0, 6, 0, 6)
    })
    UICorner(search, 8); UIStroke(search, 1, COLORS.STROKE, 0.12)
    self.SearchBox = search

    -- content area
    local content = New("Frame", {Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 1, -78), Position = UDim2.new(0, 6, 0, 48)})

    -- avatar square
    local avatar = New("ImageLabel", {
        Parent = content,
        BackgroundColor3 = COLORS.HEADER,
        Size = UDim2.new(0, 88, 0, 88),
        Position = UDim2.new(0, 0, 0, 0),
        ScaleType = Enum.ScaleType.Crop,
        Image = "rbxassetid://0"
    })
    UICorner(avatar, 8); UIStroke(avatar, 1, COLORS.STROKE, 0.14)
    self.Avatar = avatar

    -- meta frame (name / displayname / start / duration)
    local meta = New("Frame", {Parent = content, BackgroundTransparency = 1, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 100, 0, 0)})

    local nameLbl = New("TextLabel", {
        Parent = meta,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = COLORS.TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "-"
    })
    self.NameLabel = nameLbl

    local displayLbl = New("TextLabel", {
        Parent = meta,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = COLORS.MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 30),
        Text = "-"
    })
    self.DisplayLabel = displayLbl

    local startLbl = New("TextLabel", {
        Parent = meta,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = COLORS.MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 52),
        Text = "بداية التتبع: -"
    })
    self.StartLabel = startLbl

    local durationLbl = New("TextLabel", {
        Parent = meta,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = COLORS.MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 72),
        Text = "المدة: 00:00:00"
    })
    self.DurationLabel = durationLbl

    -- bottom row (state, enter count, exit count)
    local bottom = New("Frame", {Parent = frame, BackgroundColor3 = COLORS.BG, Size = UDim2.new(1, -12, 0, 48), Position = UDim2.new(0, 6, 1, -54)})
    UICorner(bottom, 6); UIStroke(bottom, 1, COLORS.STROKE, 0.12)

    local stateLbl = New("TextLabel", {
        Parent = bottom,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = COLORS.MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Text = "-"
    })
    self.StateLabel = stateLbl

    local enterLbl = New("TextLabel", {
        Parent = bottom,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = COLORS.GOOD,
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.new(0.2, -8, 1, 0),
        Position = UDim2.new(0.6, 0, 0, 0),
        Text = "دخول: 0"
    })
    self.EnterLabel = enterLbl

    local exitLbl = New("TextLabel", {
        Parent = bottom,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = COLORS.BAD,
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.new(0.2, -8, 1, 0),
        Position = UDim2.new(0.8, 0, 0, 0),
        Text = "خروج: 0"
    })
    self.ExitLabel = exitLbl

    -- internal fields
    self.Player = nil
    self._conns = {}
    self._timerToken = nil
    self._startTime = nil
    self._enterCount = 0
    self._exitCount = 0

    return self
end

function CardProto:bindPlayer(plr)
    -- unbind first if needed
    self:unbind()

    if not plr then
        -- reset visuals
        self.Player = nil
        self.NameLabel.Text = "-"
        self.DisplayLabel.Text = "-"
        self.StartLabel.Text = "بداية التتبع: -"
        self.DurationLabel.Text = "المدة: 00:00:00"
        self.Avatar.Image = "rbxassetid://0"
        self.StateLabel.Text = "-"
        self.EnterLabel.Text = "دخول: 0"
        self.ExitLabel.Text = "خروج: 0"
        self._enterCount = 0
        self._exitCount = 0
        return
    end

    self.Player = plr
    self.NameLabel.Text = plr.Name or "-"
    self.DisplayLabel.Text = plr.DisplayName or "-"
    -- load avatar thumb
    spawn(function()
        local thumb = FetchAvatarThumb(plr.UserId)
        if thumb and typeof(thumb) == "string" then
            pcall(function() self.Avatar.Image = thumb end)
        end
    end)

    -- set start time & counts (create persistent table session wise)
    self._startTime = os.time()
    self.StartLabel.Text = "بداية التتبع: " .. clockStringFromUnix(self._startTime)
    self.DurationLabel.Text = "المدة: 00:00:00"
    self._enterCount = 0
    self._exitCount = 0
    self.EnterLabel.Text = "دخول: 0"
    self.ExitLabel.Text = "خروج: 0"
    self.StateLabel.Text = "الحالة: غير معروف"
    self.StateLabel.TextColor3 = COLORS.MUTED

    -- handlers
    local function onCharacterAdded(char)
        self._enterCount = self._enterCount + 1
        self.EnterLabel.Text = "دخول: " .. tostring(self._enterCount)
        self.StateLabel.Text = "الحالة: داخل"
        self.StateLabel.TextColor3 = COLORS.GOOD
    end

    local function onCharacterRemoving()
        self._exitCount = self._exitCount + 1
        self.ExitLabel.Text = "خروج: " .. tostring(self._exitCount)
        self.StateLabel.Text = "الحالة: خارج"
        self.StateLabel.TextColor3 = COLORS.BAD
    end

    -- connect safely
    if plr.Character then
        -- immediate trigger: if character present, count as enter
        onCharacterAdded(plr.Character)
    end
    table.insert(self._conns, plr.CharacterAdded:Connect(onCharacterAdded))
    if plr.CharacterRemoving then
        table.insert(self._conns, plr.CharacterRemoving:Connect(onCharacterRemoving))
    end

    -- start timer token
    local token = HttpService:GenerateGUID(false)
    self._timerToken = token

    spawn(function()
        while self._timerToken == token do
            if self._startTime then
                local elapsed = os.time() - self._startTime
                self.DurationLabel.Text = "المدة: " .. formatHMStoString(elapsed)
            end
            wait(1)
        end
    end)
end

function CardProto:unbind()
    -- stop timer
    self._timerToken = nil
    -- disconnect events
    for _, c in ipairs(self._conns) do
        if c and c.Disconnect then
            pcall(function() c:Disconnect() end)
        end
    end
    self._conns = {}
    -- preserve last duration and show "خارج" state only if exit happened? 
    -- keep player reference for display until user clears
    self.Player = nil
end

function CardProto:destroy()
    self:unbind()
    pcall(function() if self.Frame then self.Frame:Destroy() end end)
end

-- ======= Create 4 cards =======
local Cards = {}
for i = 1, 4 do
    Cards[i] = CardProto.new(i)
end

-- ======= Smart search helper (first 2 letters or more) =======
local function findPlayerByPrefix(q)
    if not q then return nil end
    q = trim(tostring(q):lower())
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

-- ======= Wire search boxes: when user types >=2 chars, bind quickly =======
for _, card in ipairs(Cards) do
    -- store last text to avoid repeat
    local last = ""
    local debounce = false
    card.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = trim(card.SearchBox.Text or "")
        if txt == last then return end
        last = txt
        if debounce then return end
        debounce = true
        spawn(function()
            wait(0.06) -- small debounce for speed but stability
            if #txt >= 2 then
                local found = findPlayerByPrefix(txt)
                if found then
                    card:bindPlayer(found)
                else
                    -- if none found, unbind (clear)
                    card:unbind()
                    -- reset visuals
                    card.NameLabel.Text = "-"
                    card.DisplayLabel.Text = "-"
                    card.StartLabel.Text = "بداية التتبع: -"
                    card.DurationLabel.Text = "المدة: 00:00:00"
                    card.Avatar.Image = "rbxassetid://0"
                    card.StateLabel.Text = "-"
                    card.EnterLabel.Text = "دخول: 0"
                    card.ExitLabel.Text = "خروج: 0"
                end
            else
                -- less than 2 chars: clear
                card:unbind()
                card.NameLabel.Text = "-"
                card.DisplayLabel.Text = "-"
                card.StartLabel.Text = "بداية التتبع: -"
                card.DurationLabel.Text = "المدة: 00:00:00"
                card.Avatar.Image = "rbxassetid://0"
                card.StateLabel.Text = "-"
                card.EnterLabel.Text = "دخول: 0"
                card.ExitLabel.Text = "خروج: 0"
            end
            debounce = false
        end)
    end)
    -- also clear on focus lost if empty
    card.SearchBox.FocusLost:Connect(function(enter)
        local txt = trim(card.SearchBox.Text or "")
        if #txt < 2 then
            card:unbind()
            card.NameLabel.Text = "-"
            card.DisplayLabel.Text = "-"
            card.StartLabel.Text = "بداية التتبع: -"
            card.DurationLabel.Text = "المدة: 00:00:00"
            card.Avatar.Image = "rbxassetid://0"
            card.StateLabel.Text = "-"
            card.EnterLabel.Text = "دخول: 0"
            card.ExitLabel.Text = "خروج: 0"
        end
    end)
end

-- ======= Global PlayerAdded/Removing handlers: update relevant cards quickly =======
Players.PlayerAdded:Connect(function(plr)
    -- For each card bound to this player, increase enter and update
    for _, card in ipairs(Cards) do
        if card.Player and card.Player == plr then
            -- simulate character added (if Character present it's already handled)
            if plr.Character then
                -- increment handled by card's onCharacterAdded when bound
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    for _, card in ipairs(Cards) do
        if card.Player and card.Player == plr then
            -- increment exit counter and update state
            -- since card._exitCount updated in handler, here just reflect UI and unbind
            card.ExitLabel.Text = "خروج: " .. tostring((tonumber(card.ExitLabel.Text:match("%d+")) or 0) + 1)
            card.StateLabel.Text = "الحالة: خارج"
            card.StateLabel.TextColor3 = COLORS.BAD
            -- stop timer but leave last duration visible
            card._timerToken = nil
            card.Player = nil
            -- keep the visuals so user can see last info (per your request)
        end
    end
end)

-- ======= Toggle behaviour: hide/show content only =======
ToggleBtn.MouseButton1Click:Connect(function()
    ContentFrame.Visible = not ContentFrame.Visible
    ToggleBtn.Text = ContentFrame.Visible and "إخفاء" or "إظهار"
end)

-- ======= Header drag: move root by dragging header only =======
do
    local dragging = false
    local dragStart = Vector2.new(0,0)
    local startPos = Root.Position
    Header.InputBegan:Connect(function(input)
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
    Header.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ======= Save & Load position locally (Attributes) =======
local posKey = "EG_TRACKER_POS"
local function savePos()
    pcall(function()
        LocalPlayer:SetAttribute(posKey, HttpService:JSONEncode({x = Root.Position.X.Offset, y = Root.Position.Y.Offset}))
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

-- ======= Small helper: show temporary hint =======
local function showHint(text, seconds)
    seconds = seconds or 3
    local hint = New("TextLabel", {
        Parent = Root,
        Size = UDim2.new(0.6, 0, 0, 28),
        Position = UDim2.new(0.2, 0, 1, -40),
        BackgroundColor3 = COLORS.PANEL,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = COLORS.TEXT,
        Text = text
    })
    UICorner(hint, 8); UIStroke(hint, 1, COLORS.STROKE, 0.14)
    delay(seconds, function() pcall(function() hint:Destroy() end) end)
end

showHint("أكتب أول حرفين أو أكثر داخل أي خانة لربط لاعب وبدء التتبع", 4)

-- ======= End of script: ready =======
-- Script is modular — if you want any styling changes (font, colors, avatar size, add sound on enter/exit,
-- or save full history to a file), tell me and I will integrate it.
