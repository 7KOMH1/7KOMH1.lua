-- حقوق العم 7KOMH

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local JoinLabel = Instance.new("TextLabel")
local LeaveLabel = Instance.new("TextLabel")
local InputBox = Instance.new("TextBox")

ScreenGui.Parent = game:GetService("CoreGui")

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 280, 0, 160)
Frame.Position = UDim2.new(0, 20, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40) -- أوضح وأغمق
Frame.BackgroundTransparency = 0 -- مش شفاف
Frame.Active = true
Frame.Draggable = true -- يخلي اللوحة تتحرك

Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "حقوق العم 7KOMH"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

InputBox.Parent = Frame
InputBox.Position = UDim2.new(0, 10, 0, 35)
InputBox.Size = UDim2.new(1, -20, 0, 25)
InputBox.PlaceholderText = "اكتب أول 3-5 حروف من اسم اللاعب"
InputBox.Text = ""
InputBox.TextColor3 = Color3.new(1,1,1)
InputBox.BackgroundColor3 = Color3.fromRGB(60,60,60)

JoinLabel.Parent = Frame
JoinLabel.Position = UDim2.new(0, 10, 0, 70)
JoinLabel.Size = UDim2.new(1, -20, 0, 30)
JoinLabel.TextColor3 = Color3.fromRGB(0,255,0)
JoinLabel.Text = "✅ مرات الدخول: 0"
JoinLabel.BackgroundTransparency = 1

LeaveLabel.Parent = Frame
LeaveLabel.Position = UDim2.new(0, 10, 0, 105)
LeaveLabel.Size = UDim2.new(1, -20, 0, 30)
LeaveLabel.TextColor3 = Color3.fromRGB(255,0,0)
LeaveLabel.Text = "❌ مرات الخروج: 0"
LeaveLabel.BackgroundTransparency = 1

-- متغيرات
local targetPlayer = nil
local joins, leaves = 0, 0

-- دالة لتحديث العرض
local function updateLabels()
    if targetPlayer then
        JoinLabel.Text = "✅ مرات الدخول: " .. joins
        LeaveLabel.Text = "❌ مرات الخروج: " .. leaves
    end
end

-- اختيار اللاعب حسب الحروف
InputBox.FocusLost:Connect(function()
    local txt = InputBox.Text:lower()
    if txt ~= "" then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower():sub(1, #txt) == txt then
                targetPlayer = plr.Name
                joins, leaves = 0, 0
                JoinLabel.Text = "✅ مرات الدخول: 0"
                LeaveLabel.Text = "❌ مرات الخروج: 0"
                Title.Text = "🎯 جاري تتبع: " .. targetPlayer .. " | حقوق العم 7KOMH"
                break
            end
        end
    end
end)

-- عداد الدخول والخروج
Players.PlayerAdded:Connect(function(plr)
    if targetPlayer and plr.Name == targetPlayer then
        joins = joins + 1
        updateLabels()
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if targetPlayer and plr.Name == targetPlayer then
        leaves = leaves + 1
        updateLabels()
    end
end)
