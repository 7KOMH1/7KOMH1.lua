-- 🍷 GS4 | العم حكومه 🛰️
-- نسخة نهائية

local Players = game:GetService("Players")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")

-- زر فتح/قفل متحرك
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 200)
ToggleButton.Text = "≡"
ToggleButton.TextScaled = true
ToggleButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.BorderSizePixel = 0
ToggleButton.Active = true
ToggleButton.Draggable = true

-- الإطار الأساسي
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0, 70, 0, 150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

-- التحكم في إظهار/إخفاء الفريم
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- العنوان
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🍷 GS4 | العم حكومه 🛰️"
Title.TextColor3 = Color3.fromRGB(0,170,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22

-- دالة لإنشاء كارت لاعب
local function createPlayerBox(parent, position)
    local Box = Instance.new("Frame")
    Box.Parent = parent
    Box.Size = UDim2.new(0.5, -15, 0.5, -15)
    Box.Position = position
    Box.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Box.BorderSizePixel = 0

    local Input = Instance.new("TextBox")
    Input.Parent = Box
    Input.Size = UDim2.new(1, -10, 0, 25)
    Input.Position = UDim2.new(0, 5, 0, 5)
    Input.PlaceholderText = "اكتب اسم اللاعب"
    Input.TextColor3 = Color3.new(1,1,1)
    Input.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Input.BorderSizePixel = 0

    local Avatar = Instance.new("ImageLabel")
    Avatar.Parent = Box
    Avatar.Size = UDim2.new(0, 60, 0, 60)
    Avatar.Position = UDim2.new(0, 5, 0, 35)
    Avatar.BackgroundTransparency = 1

    local JoinLabel = Instance.new("TextLabel")
    JoinLabel.Parent = Box
    JoinLabel.Size = UDim2.new(1, -75, 0, 25)
    JoinLabel.Position = UDim2.new(0, 70, 0, 40)
    JoinLabel.Text = "✅ دخول: 0"
    JoinLabel.TextColor3 = Color3.fromRGB(0,255,0)
    JoinLabel.BackgroundTransparency = 1
    JoinLabel.TextXAlignment = Enum.TextXAlignment.Left

    local LeaveLabel = Instance.new("TextLabel")
    LeaveLabel.Parent = Box
    LeaveLabel.Size = UDim2.new(1, -75, 0, 25)
    LeaveLabel.Position = UDim2.new(0, 70, 0, 65)
    LeaveLabel.Text = "❌ خروج: 0"
    LeaveLabel.TextColor3 = Color3.fromRGB(255,0,0)
    LeaveLabel.BackgroundTransparency = 1
    LeaveLabel.TextXAlignment = Enum.TextXAlignment.Left

    local state = {player=nil, joins=0, leaves=0}

    -- اختيار اللاعب
    Input.FocusLost:Connect(function()
        local txt = Input.Text:lower()
        if txt == "" then
            state.player = nil
            Avatar.Image = ""
            JoinLabel.Text = "✅ دخول: 0"
            LeaveLabel.Text = "❌ خروج: 0"
            return
        end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower():sub(1,#txt) == txt or plr.DisplayName:lower():sub(1,#txt) == txt then
                state.player = plr.Name
                state.joins, state.leaves = 0, 0
                Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=100&height=100&format=png"
                JoinLabel.Text = "✅ دخول: 0"
                LeaveLabel.Text = "❌ خروج: 0"
                break
            end
        end
    end)

    -- متابعة الدخول والخروج
    Players.PlayerAdded:Connect(function(plr)
        if state.player and plr.Name == state.player then
            state.joins += 1
            JoinLabel.Text = "✅ دخول: "..state.joins
        end
    end)
    Players.PlayerRemoving:Connect(function(plr)
        if state.player and plr.Name == state.player then
            state.leaves += 1
            LeaveLabel.Text = "❌ خروج: "..state.leaves
        end
    end)

    return Box
end

-- ٤ أماكن للاعبين (2 فوق / 2 تحت)
createPlayerBox(MainFrame, UDim2.new(0, 10, 0, 50))
createPlayerBox(MainFrame, UDim2.new(0.5, 5, 0, 50))
createPlayerBox(MainFrame, UDim2.new(0, 10, 0.5, 5))
createPlayerBox(MainFrame, UDim2.new(0.5, 5, 0.5, 5))
