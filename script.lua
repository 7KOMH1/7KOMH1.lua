-- سكربت تتبع لاعبين | صنع حكومة - كلان EG | تتبع 4 لاعبين
-- نسخة مرتبة بخلفية سوداء وواجهة بسيطة

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- واجهة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ClanEG_Tracker"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 220)
MainFrame.Position = UDim2.new(0.7, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- زر إخفاء
local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(0, 60, 0, 25)
HideButton.Position = UDim2.new(1, -65, 0, 5)
HideButton.Text = "إخفاء"
HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HideButton.Parent = MainFrame

local Hidden = false
HideButton.MouseButton1Click:Connect(function()
    Hidden = not Hidden
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child ~= HideButton then
            child.Visible = not Hidden
        end
    end
    HideButton.Text = Hidden and "إظهار" or "إخفاء"
end)

-- العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 0, 30)
Title.Position = UDim2.new(0, 5, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "صنع حكومة | كلان EG - تتبع 4 لاعبين"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- قوالب اللاعب
local PlayerFrames = {}

local function CreatePlayerFrame(index)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.Position = UDim2.new(0, 5, 0, 35 + (index - 1) * 45)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Parent = MainFrame

    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(0.5, 0, 1, 0)
    Name.Position = UDim2.new(0, 5, 0, 0)
    Name.BackgroundTransparency = 1
    Name.Text = "-"
    Name.TextColor3 = Color3.fromRGB(255, 255, 255)
    Name.Font = Enum.Font.SourceSansBold
    Name.TextSize = 16
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.Parent = Frame

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(0.5, -10, 1, 0)
    Info.Position = UDim2.new(0.5, 0, 0, 0)
    Info.BackgroundTransparency = 1
    Info.Text = "دخول: 0 | خروج: 0 | المدة: 0س 0د"
    Info.TextColor3 = Color3.fromRGB(200, 200, 200)
    Info.Font = Enum.Font.SourceSans
    Info.TextSize = 14
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.Parent = Frame

    return {Frame = Frame, Name = Name, Info = Info, StartTime = nil, Joins = 0, Leaves = 0}
end

for i = 1, 4 do
    PlayerFrames[i] = CreatePlayerFrame(i)
end

-- تحديث البيانات
local function UpdateFrame(frameData, player, joined)
    if player then
        frameData.Name.Text = player.Name
        if joined then
            frameData.Joins = frameData.Joins + 1
            frameData.StartTime = os.time()
        else
            frameData.Leaves = frameData.Leaves + 1
        end

        local duration = 0
        if frameData.StartTime then
            duration = os.time() - frameData.StartTime
        end
        local mins = math.floor(duration / 60)
        local hours = math.floor(mins / 60)
        mins = mins % 60

        frameData.Info.Text = string.format("دخول: %d | خروج: %d | المدة: %dس %dد", frameData.Joins, frameData.Leaves, hours, mins)
    else
        frameData.Name.Text = "-"
        frameData.Info.Text = "دخول: 0 | خروج: 0 | المدة: 0س 0د"
        frameData.StartTime = nil
        frameData.Joins, frameData.Leaves = 0, 0
    end
end

-- ربط الأحداث
Players.PlayerAdded:Connect(function(player)
    for _, frame in ipairs(PlayerFrames) do
        if frame.Name.Text == "-" then
            UpdateFrame(frame, player, true)
            break
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    for _, frame in ipairs(PlayerFrames) do
        if frame.Name.Text == player.Name then
            UpdateFrame(frame, player, false)
            break
        end
    end
end)

-- تحميل الموجودين بالفعل
for _, player in ipairs(Players:GetPlayers()) do
    for _, frame in ipairs(PlayerFrames) do
        if frame.Name.Text == "-" then
            UpdateFrame(frame, player, true)
            break
        end
    end
end
