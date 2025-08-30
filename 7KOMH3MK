-- حقوق العم حكومه 😁🍷
local Players = game:GetService("Players")
local ThumbType = Enum.ThumbnailType.HeadShot
local ThumbSize = Enum.ThumbnailSize.Size100x100

-- GUI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 360, 0, 350)
Frame.Position = UDim2.new(0, 100, 0, 150)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- أسود فاتح
Frame.BackgroundTransparency = 0.05
Frame.Active = true
Frame.Draggable = true
Frame.Visible = true -- يبدأ ظاهر

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, -30, 0, 30)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.Text = "🎯 تتبع ٤ لاعيبة | حقوق العم حكومه 😁🍷"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- زرار الإغلاق ❌
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = Frame
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 2)
CloseButton.Text = "❌"
CloseButton.TextColor3 = Color3.new(1, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
CloseButton.BackgroundTransparency = 0.1
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.AutoButtonColor = true

-- زرار إعادة الفتح
local OpenButton = Instance.new("TextButton")
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 60, 0, 30)
OpenButton.Position = UDim2.new(0, 30, 0, 100)
OpenButton.Text = "📂 فتح"
OpenButton.TextColor3 = Color3.new(1, 1, 1)
OpenButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
OpenButton.BackgroundTransparency = 0.1
OpenButton.Visible = false

CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    Frame.Visible = true
    OpenButton.Visible = false
end)

-- Data
local trackedPlayers = {}
for i = 1, 4 do
    trackedPlayers[i] = {name = nil, joins = 0, leaves = 0}
end

-- Function: Create input + labels for each slot
local function createSlot(index)
    local offsetY = 40 + (index - 1) * 75

    -- صورة الأفاتار
    local Avatar = Instance.new("ImageLabel")
    Avatar.Parent = Frame
    Avatar.Position = UDim2.new(0, 10, 0, offsetY)
    Avatar.Size = UDim2.new(0, 50, 0, 50)
    Avatar.BackgroundTransparency = 1
    Avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"

    -- صندوق الكتابة
    local InputBox = Instance.new("TextBox")
    InputBox.Parent = Frame
    InputBox.Position = UDim2.new(0, 70, 0, offsetY)
    InputBox.Size = UDim2.new(1, -80, 0, 25)
    InputBox.PlaceholderText = "اكتب أول 2-5 حروف من اسم اللاعب " .. index
    InputBox.Text = ""
    InputBox.TextColor3 = Color3.new(1, 1, 1)
    InputBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    InputBox.BackgroundTransparency = 0.1

    -- لابل الدخول
    local JoinLabel = Instance.new("TextLabel")
    JoinLabel.Parent = Frame
    JoinLabel.Position = UDim2.new(0, 70, 0, offsetY + 28)
    JoinLabel.Size = UDim2.new(0.45, -5, 0, 20)
    JoinLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    JoinLabel.Text = "✅ دخول: 0"
    JoinLabel.BackgroundTransparency = 1
    JoinLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- لابل الخروج
    local LeaveLabel = Instance.new("TextLabel")
    LeaveLabel.Parent = Frame
    LeaveLabel.Position = UDim2.new(0.5, 40, 0, offsetY + 28)
    LeaveLabel.Size = UDim2.new(0.45, -5, 0, 20)
    LeaveLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    LeaveLabel.Text = "❌ خروج: 0"
    LeaveLabel.BackgroundTransparency = 1
    LeaveLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Search & track player
    InputBox.FocusLost:Connect(function()
        local txt = InputBox.Text:lower()
        if #txt >= 2 and #txt <= 5 then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Name:lower():sub(1, #txt) == txt then
                    trackedPlayers[index].name = plr.Name
                    trackedPlayers[index].joins = 0
                    trackedPlayers[index].leaves = 0
                    JoinLabel.Text = "✅ دخول: 0"
                    LeaveLabel.Text = "❌ خروج: 0"
                    InputBox.Text = "🎯 " .. plr.Name

                    -- تحميل صورة الأفاتار
                    local thumbUrl = Players:GetUserThumbnailAsync(plr.UserId, ThumbType, ThumbSize)
                    Avatar.Image = thumbUrl
                    break
                end
            end
        end
    end)

    -- Update labels when join/leave
    local function updateLabels()
        JoinLabel.Text = "✅ دخول: " .. trackedPlayers[index].joins
        LeaveLabel.Text = "❌ خروج: " .. trackedPlayers[index].leaves
    end

    Players.PlayerAdded:Connect(function(plr)
        if trackedPlayers[index].name == plr.Name then
            trackedPlayers[index].joins += 1
            updateLabels()
        end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if trackedPlayers[index].name == plr.Name then
            trackedPlayers[index].leaves += 1
            updateLabels()
        end
    end)
end

-- Create 4 slots
for i = 1, 4 do
    createSlot(i)
end
