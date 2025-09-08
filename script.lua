-- صنع حكومه | كلان EG
-- Player Tracker GUI (4 Slots, Prefix Search, True Join/Leave, Toggle, Draggable, Compact 600x320)

-- ⬇️ محليّات وخدمات
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ⬇️ إعدادات
local UI_WIDTH, UI_HEIGHT = 600, 320
local SLOT_W, SLOT_H = 285, 120
local MIN_PREFIX = 2 -- اقل عدد حروف للالتقاط (غيّرها لـ 1 لو عايز يلقط من أول حرف)

-- ⬇️ أداة سحب لأي عنصر GUI (بديل قوي عن Draggable)
local function makeDraggable(guiObject)
    local dragging, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                guiObject.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
end

-- ⬇️ GUI: زرار التبديل (إظهار/إخفاء)
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "ToggleTracker"
ToggleGui.ResetOnSpawn = false
ToggleGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Text = "إظهار التتبع"
ToggleButton.Size = UDim2.new(0, 120, 0, 36)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -18)
ToggleButton.AutoButtonColor = true
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.BorderSizePixel = 0
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Parent = ToggleGui
makeDraggable(ToggleButton)

-- ⬇️ GUI: الواجهة الرئيسية الصغيرة
local TrackerGui = Instance.new("ScreenGui")
TrackerGui.Name = "ClanEG_Tracker"
TrackerGui.ResetOnSpawn = false
TrackerGui.Enabled = false
TrackerGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, UI_WIDTH, 0, UI_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -UI_WIDTH/2, 0.18, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = TrackerGui
makeDraggable(MainFrame)

-- ترويسة
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "صنع حكومه | كلان EG - تتبع 4 لاعبين"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextColor3 = Color3.fromRGB(200, 240, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

-- فاصل سفلي بسيط
local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(1, 0, 0, 2)
Bar.Position = UDim2.new(0, 0, 0, 40)
Bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Bar.BorderSizePixel = 0
Bar.Parent = MainFrame

-- ⬇️ نموذج خانة لاعب
export type SlotState = {
    Frame: Frame,
    Input: TextBox,
    Avatar: ImageLabel,
    NameLabel: TextLabel,
    TimeLabel: TextLabel,
    JLLabel: TextLabel,
    Target: Player?,
    Seconds: number,
    Conns: { RBXScriptConnection },
    JoinCount: number,
    LeaveCount: number
}

local ThumbnailType = Enum.ThumbnailType.HeadShot
local ThumbnailSize = Enum.ThumbnailSize.Size100x100

local function createSlot(xOffset: number, yOffset: number): SlotState
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, SLOT_W, 0, SLOT_H)
    frame.Position = UDim2.new(0, xOffset, 0, yOffset)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = MainFrame
    makeDraggable(frame)

    -- مربع كتابة الاسم (بدون Placeholder)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 160, 0, 28)
    input.Position = UDim2.new(0, 8, 0, 8)
    input.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.SourceSans
    input.TextSize = 16
    input.ClearTextOnFocus = false
    input.Text = ""
    input.Parent = frame

    -- صورة أفاتار
    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 60, 0, 60)
    avatar.Position = UDim2.new(0, SLOT_W - 68, 0, 8)
    avatar.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    avatar.BorderSizePixel = 0
    avatar.ScaleType = Enum.ScaleType.Fit
    avatar.Parent = frame

    -- الاسم/اللقب
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, SLOT_W - 80, 0, 24)
    nameLabel.Position = UDim2.new(0, 8, 0, 44)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 16
    nameLabel.Text = ""
    nameLabel.Parent = frame

    -- الوقت
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0, SLOT_W - 16, 0, 22)
    timeLabel.Position = UDim2.new(0, 8, 0, 74)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    timeLabel.Font = Enum.Font.SourceSans
    timeLabel.TextSize = 15
    timeLabel.Text = "الوقت: 00:00:00"
    timeLabel.Parent = frame

    -- الدخول/الخروج
    local jlLabel = Instance.new("TextLabel")
    jlLabel.Size = UDim2.new(0, SLOT_W - 16, 0, 22)
    jlLabel.Position = UDim2.new(0, 8, 0, 96)
    jlLabel.BackgroundTransparency = 1
    jlLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
    jlLabel.Font = Enum.Font.SourceSans
    jlLabel.TextSize = 15
    jlLabel.Text = "الدخول: 0 | الخروج: 0"
    jlLabel.Parent = frame

    return {
        Frame = frame,
        Input = input,
        Avatar = avatar,
        NameLabel = nameLabel,
        TimeLabel = timeLabel,
        JLLabel = jlLabel,
        Target = nil,
        Seconds = 0,
        Conns = {},
        JoinCount = 0,
        LeaveCount = 0
    }
end

-- ⬇️ أربع خانات في شبكة 2×2
local slots: {SlotState} = {}
slots[1] = createSlot(10,  56)
slots[2] = createSlot(305, 56)
slots[3] = createSlot(10,  186)
slots[4] = createSlot(305, 186)

-- ⬇️ مساعدات
local function setAvatarForUserId(img: ImageLabel, userId: number)
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(userId, ThumbnailType, ThumbnailSize)
    end)
    if ok and typeof(url) == "string" and #url > 0 then
        img.Image = url
    else
        img.Image = ""
    end
end

local function resetSlot(slot: SlotState)
    slot.Target = nil
    slot.Seconds = 0
    for _, c in ipairs(slot.Conns) do
        if c and c.Connected then c:Disconnect() end
    end
    slot.Conns = {}
    slot.Avatar.Image = ""
    slot.NameLabel.Text = ""
    slot.TimeLabel.Text = "الوقت: 00:00:00"
    slot.JoinCount, slot.LeaveCount = 0, 0
    slot.JLLabel.Text = "الدخول: 0 | الخروج: 0"
end

local function setJL(slot: SlotState)
    slot.JLLabel.Text = string.format("الدخول: %d | الخروج: %d", slot.JoinCount, slot.LeaveCount)
end

local function bindPlayer(slot: SlotState, plr: Player)
    -- لو نفس اللاعب، سيب كل حاجة زي ما هي
    if slot.Target and slot.Target == plr then return end

    -- فصل أي اتصالات قديمة
    for _, c in ipairs(slot.Conns) do
        if c and c.Connected then c:Disconnect() end
    end
    slot.Conns = {}

    -- تهيئة
    slot.Target = plr
    slot.Seconds = 0
    slot.JoinCount, slot.LeaveCount = 0, 0

    -- لو اللاعب موجود بالفعل في السيرفر عند الربط نحسب دخول واحد
    if plr.Parent == Players then
        slot.JoinCount = 1
    end
    setJL(slot)

    -- صورة + اسم/لقب
    setAvatarForUserId(slot.Avatar, plr.UserId)
    slot.NameLabel.Text = string.format("%s (@%s)", plr.DisplayName, plr.Name)

    -- تايمر: يعد بس واللاعب موجود
    task.spawn(function()
        while slot.Target == plr do
            if plr.Parent == Players then
                slot.Seconds += 1
                local h = math.floor(slot.Seconds/3600)
                local m = math.floor((slot.Seconds%3600)/60)
                local s = slot.Seconds%60
                slot.TimeLabel.Text = string.format("الوقت: %02d:%02d:%02d", h, m, s)
            end
            task.wait(1)
        end
    end)

    -- سماع الدخول/الخروج الحقيقيين لهذا اللاعب
    table.insert(slot.Conns, Players.PlayerRemoving:Connect(function(rem)
        if slot.Target == plr and rem == plr then
            slot.LeaveCount += 1
            setJL(slot)
        end
    end))

    table.insert(slot.Conns, Players.PlayerAdded:Connect(function(add)
        if slot.Target == plr and add.UserId == plr.UserId then
            -- تحديث المرجع (plr الجديد) بعد إعادة الدخول
            slot.Target = add
            setAvatarForUserId(slot.Avatar, add.UserId)
            slot.NameLabel.Text = string.format("%s (@%s)", add.DisplayName, add.Name)
            slot.JoinCount += 1
            setJL(slot)
        end
    end))

    -- لو اللاعب خرج حالاً بعد الربط
    if plr.Parent ~= Players then
        slot.LeaveCount += 1
        setJL(slot)
    end
end

-- ⬇️ التقاط باسم أو لقب ببداية الحروف (Prefix)
local function findByPrefix(prefix: string): Player?
    prefix = prefix:lower()
    if #prefix < MIN_PREFIX then return nil end
    -- أولوية: اسم المستخدم، ثم اللقب
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #prefix) == prefix then
            return p
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.DisplayName:lower():sub(1, #prefix) == prefix then
            return p
        end
    end
    return nil
end

-- ⬇️ بحث لحظي "سرعة البرق" لكل خانة
for _, slot in ipairs(slots) do
    slot.Input:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = slot.Input.Text or ""
        if txt == "" then
            resetSlot(slot)
            return
        end
        local plr = findByPrefix(txt)
        if plr then
            bindPlayer(slot, plr)
        end
    end)
end

-- ⬇️ تبديل ظهور الواجهة من نفس الزرار
ToggleButton.MouseButton1Click:Connect(function()
    TrackerGui.Enabled = not TrackerGui.Enabled
    ToggleButton.Text = TrackerGui.Enabled and "إخفاء التتبع" or "إظهار التتبع"
end)

-- ⬇️ أمان: لو حصل Reset للـ Character ما نفقدش الواجهات
LocalPlayer.CharacterAdded:Connect(function()
    ToggleGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    TrackerGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)
