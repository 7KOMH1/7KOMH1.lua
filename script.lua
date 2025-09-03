--[[
    📌 V14.1 Ultra Final
    حقوق: EG | العم حكومه 🍷
    تتبع 4 لاعبين - كامل بالأفاتار والدخول/الخروج
]]--

local Players = game:GetService("Players")

-- واجهة رئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrackerGui"
ScreenGui.Parent = game:GetService("CoreGui")

-- زرار الفتح/القفل (≡)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleButton.TextColor3 = Color3.fromRGB(0,170,255)
ToggleButton.Text = "≡"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22
ToggleButton.Parent = ScreenGui

-- الإطار الرئيسي
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 600, 0, 350)
Frame.Position = UDim2.new(0, 60, 0, 80)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0,170,255)
Title.Text = "EG | العم حكومه 🍷"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.Parent = Frame

-- وظيفة الزرار
ToggleButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

-- دالة إنشاء تتبع لاعب
local function createTracker(xPos, yPos, parent)
    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(0, 280, 0, 140)
    boxFrame.Position = UDim2.new(0, xPos, 0, yPos)
    boxFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    boxFrame.Parent = parent

    -- خانة إدخال
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -90, 0, 30)
    input.Position = UDim2.new(0, 10, 0, 10)
    input.PlaceholderText = "اكتب أول 2-3 حروف"
    input.Text = ""
    input.TextColor3 = Color3.new(1,1,1)
    input.BackgroundColor3 = Color3.fromRGB(50,50,50)
    input.Parent = boxFrame

    -- صورة الأفاتار
    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 60, 0, 60)
    avatar.Position = UDim2.new(1, -70, 0, 10)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatar.Parent = boxFrame

    -- الاسم
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -20, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 50)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(0,170,255)
    nameLabel.Text = "لا يوجد لاعب"
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 18
    nameLabel.Parent = boxFrame

    -- عداد الدخول
    local joinLabel = Instance.new("TextLabel")
    joinLabel.Size = UDim2.new(1, -20, 0, 25)
    joinLabel.Position = UDim2.new(0, 10, 0, 80)
    joinLabel.BackgroundTransparency = 1
    joinLabel.TextColor3 = Color3.fromRGB(0,255,0)
    joinLabel.Text = "✅ مرات الدخول: 0"
    joinLabel.Font = Enum.Font.SourceSans
    joinLabel.TextSize = 16
    joinLabel.Parent = boxFrame

    -- عداد الخروج
    local leaveLabel = Instance.new("TextLabel")
    leaveLabel.Size = UDim2.new(1, -20, 0, 25)
    leaveLabel.Position = UDim2.new(0, 10, 0, 105)
    leaveLabel.BackgroundTransparency = 1
    leaveLabel.TextColor3 = Color3.fromRGB(255,0,0)
    leaveLabel.Text = "❌ مرات الخروج: 0"
    leaveLabel.Font = Enum.Font.SourceSans
    leaveLabel.TextSize = 16
    leaveLabel.Parent = boxFrame

    -- متغيرات التتبع
    local targetPlayer, joins, leaves = nil, 0, 0

    -- تحديث العدادات
    local function updateLabels()
        if targetPlayer then
            joinLabel.Text = "✅ مرات الدخول: " .. joins
            leaveLabel.Text = "❌ مرات الخروج: " .. leaves
        end
    end

    -- البحث عن اللاعب
    input.FocusLost:Connect(function()
        local txt = input.Text:lower()
        if txt == "" then
            targetPlayer = nil
            avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            nameLabel.Text = "لا يوجد لاعب"
            joins, leaves = 0, 0
            joinLabel.Text = "✅ مرات الدخول: 0"
            leaveLabel.Text = "❌ مرات الخروج: 0"
            return
        end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower():sub(1, #txt) == txt then
                targetPlayer = plr
                nameLabel.Text = plr.Name
                avatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=60&height=60&format=png", plr.UserId)
                joins, leaves = 0, 0
                updateLabels()
                break
            end
        end
    end)

    -- أحداث الدخول والخروج
    Players.PlayerAdded:Connect(function(plr)
        if targetPlayer and plr.Name == targetPlayer.Name then
            joins += 1
            updateLabels()
        end
    end)
    Players.PlayerRemoving:Connect(function(plr)
        if targetPlayer and plr.Name == targetPlayer.Name then
            leaves += 1
            updateLabels()
        end
    end)
end

-- إنشاء ٤ خانات (٢ فوق + ٢ تحت)
createTracker(10, 50, Frame)
createTracker(310, 50, Frame)
createTracker(10, 200, Frame)
createTracker(310, 200, Frame)
