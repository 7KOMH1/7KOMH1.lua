-- حقوق العم حكومه | EG 🍷
-- نسخة نهائية متكاملة

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- واجهة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")

-- زر فتح/قفل صغير
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 200)
ToggleButton.Text = "≡"
ToggleButton.TextScaled = true
ToggleButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = true

-- الإطار الأساسي
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 400, 0, 260)
MainFrame.Position = UDim2.new(0, 60, 0, 160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

-- عنوان
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "📡 تتبع اللاعبين | EG 🍷 العم حكومه"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

-- مربعات إدخال للأسماء (4 تتبع)
local InputBoxes = {}
local PlayerData = {}

for i = 1,4 do
    local Box = Instance.new("TextBox")
    Box.Parent = MainFrame
    Box.Size = UDim2.new(0.45, -10, 0, 25)
    Box.Position = UDim2.new(((i-1)%2)*0.5 + 0.025, 0, math.floor((i-1)/2)*0.45 + 0.2, 0)
    Box.PlaceholderText = "اكتب اسم اللاعب "..i
    Box.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Box.TextColor3 = Color3.new(1,1,1)
    Box.Text = ""
    Box.ClearTextOnFocus = false
    InputBoxes[i] = Box

    -- إطار عرض
    local Frame = Instance.new("Frame")
    Frame.Parent = Box
    Frame.Size = UDim2.new(1, 0, 2, 60)
    Frame.Position = UDim2.new(0,0,1,5)
    Frame.BackgroundTransparency = 1

    local Avatar = Instance.new("ImageLabel")
    Avatar.Parent = Frame
    Avatar.Size = UDim2.new(0, 40, 0, 40)
    Avatar.Position = UDim2.new(0,0,0,0)
    Avatar.BackgroundTransparency = 1

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Parent = Frame
    NameLabel.Size = UDim2.new(1, -50, 0, 20)
    NameLabel.Position = UDim2.new(0, 50, 0, 0)
    NameLabel.Text = "لاعب غير محدد"
    NameLabel.TextColor3 = Color3.new(1,1,1)
    NameLabel.BackgroundTransparency = 1
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Font = Enum.Font.SourceSansBold
    NameLabel.TextSize = 16

    local JoinLabel = Instance.new("TextLabel")
    JoinLabel.Parent = Frame
    JoinLabel.Size = UDim2.new(1, -50, 0, 20)
    JoinLabel.Position = UDim2.new(0, 50, 0, 20)
    JoinLabel.Text = "✅ دخول: 0"
    JoinLabel.TextColor3 = Color3.fromRGB(0,255,0)
    JoinLabel.BackgroundTransparency = 1
    JoinLabel.TextXAlignment = Enum.TextXAlignment.Left

    local LeaveLabel = Instance.new("TextLabel")
    LeaveLabel.Parent = Frame
    LeaveLabel.Size = UDim2.new(1, -50, 0, 20)
    LeaveLabel.Position = UDim2.new(0, 50, 0, 40)
    LeaveLabel.Text = "❌ خروج: 0"
    LeaveLabel.TextColor3 = Color3.fromRGB(255,0,0)
    LeaveLabel.BackgroundTransparency = 1
    LeaveLabel.TextXAlignment = Enum.TextXAlignment.Left

    PlayerData[i] = {
        Target = nil,
        Joins = 0,
        Leaves = 0,
        Avatar = Avatar,
        NameLabel = NameLabel,
        JoinLabel = JoinLabel,
        LeaveLabel = LeaveLabel
    }

    -- تحديث عند الكتابة
    Box.FocusLost:Connect(function()
        local txt = Box.Text:lower()
        if txt == "" then
            PlayerData[i].Target = nil
            PlayerData[i].Joins = 0
            PlayerData[i].Leaves = 0
            PlayerData[i].Avatar.Image = ""
            PlayerData[i].NameLabel.Text = "❌ غير محدد"
            PlayerData[i].JoinLabel.Text = "✅ دخول: 0"
            PlayerData[i].LeaveLabel.Text = "❌ خروج: 0"
            return
        end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower():sub(1, #txt) == txt then
                PlayerData[i].Target = plr.Name
                PlayerData[i].Joins = 0
                PlayerData[i].Leaves = 0
                PlayerData[i].NameLabel.Text = "🎯 "..plr.Name
                -- صورة افاتار
                pcall(function()
                    PlayerData[i].Avatar.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                end)
                break
            end
        end
    end)
end

-- دخول وخروج
Players.PlayerAdded:Connect(function(plr)
    for i = 1,4 do
        if PlayerData[i].Target == plr.Name then
            PlayerData[i].Joins += 1
            PlayerData[i].JoinLabel.Text = "✅ دخول: "..PlayerData[i].Joins
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    for i = 1,4 do
        if PlayerData[i].Target == plr.Name then
            PlayerData[i].Leaves += 1
            PlayerData[i].LeaveLabel.Text = "❌ خروج: "..PlayerData[i].Leaves
        end
    end
end)

-- فتح وقفل
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
