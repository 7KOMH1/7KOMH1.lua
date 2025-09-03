-- 🎭 EG PRO TRACKER V12
-- نسخة طويلة ومرتبة وبتسجل دخول/خروج بإيموجي
-- Made by ＥＧ 🍷

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- GUI رئيسي
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "EG_Tracker"

-- فريم أساسي
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 280)
MainFrame.Position = UDim2.new(0.6, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- عنوان
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 0.2
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "ＥＧ | تتبع اللاعبين 🍷"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

-- قائمة اللاعبين
local ListFrame = Instance.new("ScrollingFrame", MainFrame)
ListFrame.Size = UDim2.new(1, -10, 1, -45)
ListFrame.Position = UDim2.new(0, 5, 0, 40)
ListFrame.CanvasSize = UDim2.new(0, 0, 5, 0)
ListFrame.ScrollBarThickness = 5
ListFrame.BackgroundTransparency = 1

-- قالب لكل لاعب
local function CreateSlot(parent, index, p)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -10, 0, 50)
    Frame.Position = UDim2.new(0, 0, 0, (index-1)*55)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.BorderSizePixel = 0

    local NameLabel = Instance.new("TextLabel", Frame)
    NameLabel.Size = UDim2.new(0.5, 0, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = p.Name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 15
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local InfoLabel = Instance.new("TextLabel", Frame)
    InfoLabel.Size = UDim2.new(0.5, -5, 1, 0)
    InfoLabel.Position = UDim2.new(0.5, 0, 0, 0)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "✅ دخول: 0 | ❌ خروج: 0 | وقت: 00:00"
    InfoLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextSize = 13
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

    return {Frame=Frame, NameLabel=NameLabel, InfoLabel=InfoLabel, join=0, leave=0, time=0}
end

-- تخزين بيانات اللاعبين
local Slots = {}

-- تحديث / إضافة لاعب
local function Refresh()
    for _, p in pairs(Players:GetPlayers()) do
        if not Slots[p.UserId] then
            Slots[p.UserId] = CreateSlot(ListFrame, #Slots+1, p)
        end
    end
end

-- دخول لاعب
Players.PlayerAdded:Connect(function(p)
    Refresh()
    if Slots[p.UserId] then
        Slots[p.UserId].join += 1
        Slots[p.UserId].InfoLabel.Text = "✅ دخول: "..Slots[p.UserId].join.." | ❌ خروج: "..Slots[p.UserId].leave.." | وقت: 00:00"
    end
end)

-- خروج لاعب
Players.PlayerRemoving:Connect(function(p)
    if Slots[p.UserId] then
        Slots[p.UserId].leave += 1
    end
end)

-- تحديث الوقت كل ثانية
RunService.Heartbeat:Connect(function(dt)
    for _, data in pairs(Slots) do
        data.time += dt
        local minutes = math.floor(data.time/60)
        local seconds = math.floor(data.time%60)
        data.InfoLabel.Text = "✅ دخول: "..data.join.." | ❌ خروج: "..data.leave.." | وقت: "..string.format("%02d:%02d", minutes, seconds)
    end
end)

Refresh()
