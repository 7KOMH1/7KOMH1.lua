-- LocalScript يوضع داخل StarterGui

-- صنع حكومه | كلان EG - تتبع 4 لاعبين --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI الرئيسي
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrackingGUI"
screenGui.Parent = playerGui

-- زر فتح/إخفاء القائمة
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 140, 0, 40)
toggleButton.Position = UDim2.new(0, 20, 0.5, -20)
toggleButton.Text = "فتح قائمة التتبع"
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.TextColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.Parent = screenGui
toggleButton.ZIndex = 10

-- الإطار الرئيسي
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, -310, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- حقوق
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 30)
credits.BackgroundTransparency = 1
credits.Text = "صنع حكومه | كلان EG - تتبع 4 لاعبين"
credits.TextColor3 = Color3.fromRGB(0, 170, 255)
credits.Font = Enum.Font.GothamBold
credits.TextSize = 14
credits.Parent = mainFrame

-- مربع البحث
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 40)
searchBox.PlaceholderText = "اكتب أول حرفين من الاسم..."
searchBox.Text = ""
searchBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.Parent = mainFrame

-- إطار اللاعبين
local playersFrame = Instance.new("Frame")
playersFrame.Size = UDim2.new(1, -20, 0, 300)
playersFrame.Position = UDim2.new(0, 10, 0, 80)
playersFrame.BackgroundTransparency = 1
playersFrame.Parent = mainFrame

-- قوالب لعرض 4 لاعبين
local playerSlots = {}
for i = 1, 4 do
    local slot = Instance.new("Frame")
    slot.Size = UDim2.new(1, 0, 0, 60)
    slot.Position = UDim2.new(0, 0, 0, (i - 1) * 70)
    slot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    slot.BorderSizePixel = 0
    slot.Parent = playersFrame

    local thumb = Instance.new("ImageLabel")
    thumb.Size = UDim2.new(0, 50, 0, 50)
    thumb.Position = UDim2.new(0, 5, 0, 5)
    thumb.BackgroundTransparency = 1
    thumb.Image = ""
    thumb.Parent = slot

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -70, 0, 25)
    nameLabel.Position = UDim2.new(0, 65, 0, 5)
    nameLabel.Text = "الاسم: ..."
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = slot

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -70, 0, 20)
    statusLabel.Position = UDim2.new(0, 65, 0, 30)
    statusLabel.Text = "الحالة: غير معروف"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.BackgroundTransparency = 1
    statusLabel.Parent = slot

    playerSlots[i] = {frame = slot, thumb = thumb, name = nameLabel, status = statusLabel}
end

-- تحديث بيانات اللاعبين
local function updatePlayers(filter)
    local foundPlayers = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            if filter == nil or string.len(filter) < 2 
            or string.find(string.lower(plr.Name), string.lower(filter)) 
            or string.find(string.lower(plr.DisplayName), string.lower(filter)) then
                table.insert(foundPlayers, plr)
            end
        end
    end

    for i = 1, 4 do
        local slot = playerSlots[i]
        if foundPlayers[i] then
            local plr = foundPlayers[i]
            slot.name.Text = "الاسم: " .. plr.DisplayName .. "(@" .. plr.Name .. ")"
            slot.status.Text = "الحالة: متصل"
            Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            local thumb, _ = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            slot.thumb.Image = thumb
        else
            slot.name.Text = "فارغ"
            slot.status.Text = "..."
            slot.thumb.Image = ""
        end
    end
end

-- حدث البحث
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updatePlayers(searchBox.Text)
end)

-- تحديث عند دخول/خروج لاعب
Players.PlayerAdded:Connect(function()
    updatePlayers(searchBox.Text)
end)
Players.PlayerRemoving:Connect(function()
    updatePlayers(searchBox.Text)
end)

-- زر فتح/إغلاق
local opened = false
toggleButton.MouseButton1Click:Connect(function()
    opened = not opened
    local goal = {}
    if opened then
        goal.Position = UDim2.new(0, 20, 0.5, -200)
    else
        goal.Position = UDim2.new(0, -310, 0.5, -200)
    end
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end)

-- أول تحديث
updatePlayers(nil)
