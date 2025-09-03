-- ✨ العم حكومه 🍷 | GS4 👑
-- سكربت تتبع كامل متكامل (4 لاعبين + بحث + مزخرف + دخول/خروج حقيقي)

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GS4Tracker"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 420)
MainFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "✨ العم حكومه 🍷 | GS4 👑"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Container
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -10, 1, -90)
Container.Position = UDim2.new(0, 5, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIGrid = Instance.new("UIGridLayout")
UIGrid.CellSize = UDim2.new(0, 260, 0, 150)
UIGrid.CellPadding = UDim2.new(0, 10, 0, 10)
UIGrid.FillDirectionMaxCells = 2
UIGrid.Parent = Container

-- Search Box
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.9, 0, 0, 35)
SearchBox.Position = UDim2.new(0.05, 0, 1, -40)
SearchBox.PlaceholderText = "🔍 اكتب أول حروف (يوزر أو لقب)..."
SearchBox.Text = ""
SearchBox.Font = Enum.Font.GothamBold
SearchBox.TextScaled = true
SearchBox.TextColor3 = Color3.fromRGB(255,255,255)
SearchBox.BackgroundColor3 = Color3.fromRGB(35,35,45)
SearchBox.Parent = MainFrame
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)

-- Toggle Button
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 50, 0, 50)
Toggle.Position = UDim2.new(0.9, 0, 0.05, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Toggle.Text = "≡"
Toggle.TextScaled = true
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Parent = ScreenGui
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 25)

Toggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Tracking Data
local Tracked = {}

-- دالة لإنشاء كارت لاعب
local function createCard(player)
    local joinTime = os.time()
    local trackTime = os.time()

    local Card = Instance.new("Frame")
    Card.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Card.Parent = Container
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    -- Avatar
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 60, 0, 60)
    Avatar.Position = UDim2.new(0, 5, 0, 5)
    Avatar.BackgroundTransparency = 1
    Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=100&height=100&format=png"
    Avatar.Parent = Card

    -- UserName
    local UserLabel = Instance.new("TextLabel")
    UserLabel.Size = UDim2.new(1, -70, 0, 25)
    UserLabel.Position = UDim2.new(0, 70, 0, 5)
    UserLabel.BackgroundTransparency = 1
    UserLabel.Text = "👤 " .. player.Name
    UserLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    UserLabel.TextScaled = true
    UserLabel.Font = Enum.Font.GothamBold
    UserLabel.Parent = Card

    -- DisplayName
    local DisplayLabel = Instance.new("TextLabel")
    DisplayLabel.Size = UDim2.new(1, -70, 0, 25)
    DisplayLabel.Position = UDim2.new(0, 70, 0, 30)
    DisplayLabel.BackgroundTransparency = 1
    DisplayLabel.Text = "⭐ " .. player.DisplayName
    DisplayLabel.TextColor3 = Color3.fromRGB(255, 220, 180)
    DisplayLabel.TextScaled = true
    DisplayLabel.Font = Enum.Font.GothamBold
    DisplayLabel.Parent = Card

    -- Join Time
    local JoinLabel = Instance.new("TextLabel")
    JoinLabel.Size = UDim2.new(1, -70, 0, 20)
    JoinLabel.Position = UDim2.new(0, 70, 0, 60)
    JoinLabel.BackgroundTransparency = 1
    JoinLabel.Text = "🟢 دخل: " .. os.date("%X", joinTime)
    JoinLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    JoinLabel.TextScaled = true
    JoinLabel.Font = Enum.Font.GothamBold
    JoinLabel.Parent = Card

    -- Track Time
    local TrackLabel = Instance.new("TextLabel")
    TrackLabel.Size = UDim2.new(1, -70, 0, 20)
    TrackLabel.Position = UDim2.new(0, 70, 0, 85)
    TrackLabel.BackgroundTransparency = 1
    TrackLabel.Text = "🔎 تتبع من: " .. os.date("%X", trackTime)
    TrackLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    TrackLabel.TextScaled = true
    TrackLabel.Font = Enum.Font.GothamBold
    TrackLabel.Parent = Card

    -- Timer
    local Timer = Instance.new("TextLabel")
    Timer.Size = UDim2.new(1, -10, 0, 25)
    Timer.Position = UDim2.new(0, 5, 0, 115)
    Timer.BackgroundTransparency = 1
    Timer.TextColor3 = Color3.fromRGB(150, 150, 255)
    Timer.TextScaled = true
    Timer.Font = Enum.Font.GothamBold
    Timer.Parent = Card

    -- Update Timer
    task.spawn(function()
        while player.Parent do
            local elapsed = os.time() - trackTime
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = elapsed % 60
            Timer.Text = string.format("⏳ %02d:%02d:%02d", h, m, s)
            task.wait(1)
        end
        Timer.Text = "🚪 خرج"
        Timer.TextColor3 = Color3.fromRGB(255, 0, 0)
    end)

    return Card
end

-- Player Events
Players.PlayerAdded:Connect(function(player)
    if #Container:GetChildren() <= 4 then
        Tracked[player.UserId] = createCard(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if Tracked[player.UserId] then
        Tracked[player.UserId]:Destroy()
        Tracked[player.UserId] = nil
    end
end)

-- Existing Players
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= localPlayer and #Container:GetChildren() <= 4 then
        Tracked[plr.UserId] = createCard(plr)
    end
end

-- Smart Search
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local txt = SearchBox.Text:lower()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            if plr.Name:lower():sub(1, #txt) == txt or plr.DisplayName:lower():sub(1, #txt) == txt then
                if not Tracked[plr.UserId] and #Container:GetChildren() <= 4 then
                    Tracked[plr.UserId] = createCard(plr)
                end
            end
        end
    end
end)
