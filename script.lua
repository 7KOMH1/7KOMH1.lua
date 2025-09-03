-- ✦ حقوق: EG | العم حكومه 🍷 ✦

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- شاشة
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local MainFrame = Instance.new("Frame")
local Toggle = Instance.new("TextButton")

ScreenGui.Name = "EG_Hokoma_Tracker"
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true

-- زرار ≡
Toggle.Parent = ScreenGui
Toggle.Size = UDim2.new(0, 30, 0, 30)
Toggle.Position = UDim2.new(0, 10, 0, 10)
Toggle.Text = "≡"
Toggle.TextColor3 = Color3.fromRGB(0, 170, 255)
Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

Toggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- عنوان
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "✦ EG | العم حكومه 🍷 ✦"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextScaled = true

-- إعدادات عامة
local trackers = {}
local positions = {
    {x = 0, y = 40}, {x = 250, y = 40},
    {x = 0, y = 170}, {x = 250, y = 170}
}

-- إنشاء تتبع
local function createTracker(pos)
    local frame = Instance.new("Frame", MainFrame)
    frame.Size = UDim2.new(0, 240, 0, 120)
    frame.Position = UDim2.new(0, pos.x, 0, pos.y)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0

    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(1, -90, 0, 25)
    input.Position = UDim2.new(0, 5, 0, 5)
    input.PlaceholderText = "اكتب اسم اللاعب..."
    input.TextColor3 = Color3.new(1, 1, 1)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

    local avatar = Instance.new("ImageLabel", frame)
    avatar.Size = UDim2.new(0, 60, 0, 60)
    avatar.Position = UDim2.new(1, -70, 0, 5)
    avatar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

    local nameLabel = Instance.new("TextLabel", frame)
    nameLabel.Size = UDim2.new(1, -10, 0, 25)
    nameLabel.Position = UDim2.new(0, 5, 0, 40)
    nameLabel.Text = "👤 لا يوجد لاعب"
    nameLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextScaled = true

    local joinLabel = Instance.new("TextLabel", frame)
    joinLabel.Size = UDim2.new(1, -10, 0, 25)
    joinLabel.Position = UDim2.new(0, 5, 0, 70)
    joinLabel.Text = "✅ مرات الدخول: 0"
    joinLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    joinLabel.BackgroundTransparency = 1
    joinLabel.TextScaled = true

    local leaveLabel = Instance.new("TextLabel", frame)
    leaveLabel.Size = UDim2.new(1, -10, 0, 25)
    leaveLabel.Position = UDim2.new(0, 5, 0, 95)
    leaveLabel.Text = "❌ مرات الخروج: 0"
    leaveLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    leaveLabel.BackgroundTransparency = 1
    leaveLabel.TextScaled = true

    local data = {
        target = nil,
        joins = 0,
        leaves = 0
    }

    local function updateLabels()
        if data.target then
            joinLabel.Text = "✅ مرات الدخول: " .. data.joins
            leaveLabel.Text = "❌ مرات الخروج: " .. data.leaves
        else
            nameLabel.Text = "👤 لا يوجد لاعب"
            avatar.Image = ""
            joinLabel.Text = "✅ مرات الدخول: 0"
            leaveLabel.Text = "❌ مرات الخروج: 0"
        end
    end

    input.FocusLost:Connect(function()
        local txt = input.Text:lower()
        if txt == "" then
            data.target = nil
            data.joins, data.leaves = 0, 0
            updateLabels()
            return
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower():sub(1, #txt) == txt then
                data.target = plr.Name
                data.joins, data.leaves = 0, 0
                nameLabel.Text = "🎯 " .. data.target
                avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=150&height=150&format=png"
                break
            end
        end
    end)

    Players.PlayerAdded:Connect(function(plr)
        if data.target and plr.Name == data.target then
            data.joins += 1
            updateLabels()
        end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if data.target and plr.Name == data.target then
            data.leaves += 1
            updateLabels()
        end
    end)

    updateLabels()
end

-- إنشاء 4 خانات
for _, pos in ipairs(positions) do
    createTracker(pos)
end
