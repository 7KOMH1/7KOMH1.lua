--================================================--
-- الحقوق: العم حكومه 🍷 | كلان EG
--================================================--

-- مكتبات Roblox
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- إنشاء ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "لوحة_اللاعبين"
screenGui.ResetOnSpawn = false
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- إطار الحقوق والعنوان
local header = Instance.new("TextLabel")
header.Parent = screenGui
header.Size = UDim2.new(0.6, 0, 0.08, 0)
header.Position = UDim2.new(0.2, 0, 0.02, 0)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
header.Text = "🍷 العم حكومه | كلان EG 🍷"
header.TextColor3 = Color3.fromRGB(0, 170, 255)
header.Font = Enum.Font.GothamBold
header.TextScaled = true
header.BorderSizePixel = 0
header.BackgroundTransparency = 0.2
header.ZIndex = 2
header.TextStrokeTransparency = 0.3
header.TextStrokeColor3 = Color3.fromRGB(0,0,0)
header.ClipsDescendants = true
header.TextWrapped = true
header.TextYAlignment = Enum.TextYAlignment.Center
header.TextXAlignment = Enum.TextXAlignment.Center
header.AnchorPoint = Vector2.new(0.5,0)
header.Position = UDim2.new(0.5,0,0.02,0)
header.Size = UDim2.new(0.7,0,0.08,0)
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.ZIndex = 2
header.TextWrapped = true

-- الإطار الرئيسي للوحة
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0.7, 0, 0.6, 0)
mainFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.1
mainFrame.ZIndex = 1

-- دالة لإنشاء صندوق لاعب
local function createPlayerBox(parent, position)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0.48, 0, 0.45, 0)
    box.Position = position
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.BorderSizePixel = 0
    box.Parent = parent
    
    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.Parent = box
    username.Size = UDim2.new(1, -10, 0.25, 0)
    username.Position = UDim2.new(0, 5, 0, 5)
    username.BackgroundTransparency = 1
    username.TextColor3 = Color3.fromRGB(0, 200, 255)
    username.Font = Enum.Font.GothamBold
    username.TextScaled = true
    username.Text = "يوزر: -"
    username.TextXAlignment = Enum.TextXAlignment.Left
    
    local nickname = Instance.new("TextLabel")
    nickname.Name = "Nickname"
    nickname.Parent = box
    nickname.Size = UDim2.new(1, -10, 0.25, 0)
    nickname.Position = UDim2.new(0, 5, 0.3, 0)
    nickname.BackgroundTransparency = 1
    nickname.TextColor3 = Color3.fromRGB(0, 255, 127)
    nickname.Font = Enum.Font.Gotham
    nickname.TextScaled = true
    nickname.Text = "لقب: -"
    nickname.TextXAlignment = Enum.TextXAlignment.Left

    local joinLabel = Instance.new("TextLabel")
    joinLabel.Parent = box
    joinLabel.Size = UDim2.new(0.5, -5, 0.2, 0)
    joinLabel.Position = UDim2.new(0, 5, 0.65, 0)
    joinLabel.BackgroundTransparency = 1
    joinLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    joinLabel.Font = Enum.Font.GothamBold
    joinLabel.TextScaled = true
    joinLabel.Text = "✅ دخول: 0"
    joinLabel.TextXAlignment = Enum.TextXAlignment.Left

    local leaveLabel = Instance.new("TextLabel")
    leaveLabel.Parent = box
    leaveLabel.Size = UDim2.new(0.5, -5, 0.2, 0)
    leaveLabel.Position = UDim2.new(0.5, 0, 0.65, 0)
    leaveLabel.BackgroundTransparency = 1
    leaveLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    leaveLabel.Font = Enum.Font.GothamBold
    leaveLabel.TextScaled = true
    leaveLabel.Text = "❌ خروج: 0"
    leaveLabel.TextXAlignment = Enum.TextXAlignment.Left

    local timer = Instance.new("TextLabel")
    timer.Parent = box
    timer.Size = UDim2.new(1, -10, 0.2, 0)
    timer.Position = UDim2.new(0, 5, 0.85, 0)
    timer.BackgroundTransparency = 1
    timer.TextColor3 = Color3.fromRGB(255, 255, 0)
    timer.Font = Enum.Font.GothamBold
    timer.TextScaled = true
    timer.Text = "⏱️ الوقت: 00:00"
    timer.TextXAlignment = Enum.TextXAlignment.Left

    return box, username, nickname, joinLabel, leaveLabel, timer
end

-- إنشاء 4 صناديق للاعبين
local playerBoxes = {}
table.insert(playerBoxes, createPlayerBox(mainFrame, UDim2.new(0.01, 0, 0.02, 0)))
table.insert(playerBoxes, createPlayerBox(mainFrame, UDim2.new(0.51, 0, 0.02, 0)))
table.insert(playerBoxes, createPlayerBox(mainFrame, UDim2.new(0.01, 0, 0.52, 0)))
table.insert(playerBoxes, createPlayerBox(mainFrame, UDim2.new(0.51, 0, 0.52, 0)))

-- تحديث بيانات اللاعبين
local function updatePlayers()
    local allPlayers = Players:GetPlayers()
    for i, boxData in ipairs(playerBoxes) do
        local box, username, nickname, joinLabel, leaveLabel, timer = unpack(boxData)
        local plr = allPlayers[i]
        if plr then
            username.Text = "يوزر: " .. plr.Name
            nickname.Text = "لقب: " .. (plr.DisplayName or "-")
            joinLabel.Text = "✅ دخول: 1"
            leaveLabel.Text = "❌ خروج: 0"
            timer.Text = "⏱️ الوقت: " .. os.date("!%X")
        else
            username.Text = "يوزر: -"
            nickname.Text = "لقب: -"
            joinLabel.Text = "✅ دخول: 0"
            leaveLabel.Text = "❌ خروج: 0"
            timer.Text = "⏱️ الوقت: 00:00"
        end
    end
end

-- حدث التحديث عند دخول أو خروج لاعب
Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)

-- تحديث أولي
updatePlayers()
