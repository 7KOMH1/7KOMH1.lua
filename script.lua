-- ✦ نسخة شاملة Ultimate ✦
-- حقوق ✦ 𝑬𝑮 ✦ | العم حكومه🍷

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- GUI رئيسي
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "EG_UltimateTracker"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 380)
MainFrame.Position = UDim2.new(0, 50, 0, 120)
MainFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "✦ 𝑬𝑮 ✦ | العم حكومه🍷"
Title.TextColor3 = Color3.fromRGB(0,170,255)
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold

local Grid = Instance.new("Frame", MainFrame)
Grid.Size = UDim2.new(1, -20, 1, -70)
Grid.Position = UDim2.new(0, 10, 0, 60)
Grid.BackgroundTransparency = 1

local UIGrid = Instance.new("UIGridLayout", Grid)
UIGrid.CellSize = UDim2.new(0, 270, 0, 120)
UIGrid.CellPadding = UDim2.new(0, 20, 0, 20)

-- Cache للاعبين (تحديث تلقائي)
local nameCache = {}
local function refreshCache()
    nameCache = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        nameCache[plr.Name:lower()] = plr
    end
end
refreshCache()

Players.PlayerAdded:Connect(function(plr)
    nameCache[plr.Name:lower()] = plr
end)
Players.PlayerRemoving:Connect(function(plr)
    nameCache[plr.Name:lower()] = nil
end)

-- دالة اختيار أفضل مطابقة
local function findBestMatch(txt)
    local best, score = nil, math.huge
    for name, plr in pairs(nameCache) do
        if name:sub(1, #txt) == txt then
            local diff = math.abs(#name - #txt)
            if diff < score then
                score = diff
                best = plr
            end
        end
    end
    return best
end

-- دالة إنشاء خانة لاعب
local function CreatePlayerBox()
    local Box = Instance.new("Frame", Grid)
    Box.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)

    local NameInput = Instance.new("TextBox", Box)
    NameInput.Size = UDim2.new(1, -10, 0, 28)
    NameInput.Position = UDim2.new(0, 5, 0, 5)
    NameInput.PlaceholderText = "✍️ اكتب أول حروف من اسم اللاعب"
    NameInput.TextColor3 = Color3.new(1,1,1)
    NameInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
    NameInput.ClearTextOnFocus = false
    NameInput.Font = Enum.Font.SourceSansSemibold

    local Avatar = Instance.new("ImageLabel", Box)
    Avatar.Size = UDim2.new(0, 60, 0, 60)
    Avatar.Position = UDim2.new(0, 5, 0, 40)
    Avatar.BackgroundTransparency = 1

    local Info = Instance.new("TextLabel", Box)
    Info.Size = UDim2.new(1, -70, 0, 60)
    Info.Position = UDim2.new(0, 70, 0, 40)
    Info.Text = "🎯 لم يتم تحديد لاعب"
    Info.TextColor3 = Color3.fromRGB(220,220,220)
    Info.TextWrapped = true
    Info.BackgroundTransparency = 1
    Info.Font = Enum.Font.SourceSansBold
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextYAlignment = Enum.TextYAlignment.Top

    local joins, leaves = 0, 0
    local trackedPlayer = nil

    local function updateLabels()
        if trackedPlayer then
            Info.Text = string.format("🎯 %s\n✅ دخول: %d | ❌ خروج: %d", trackedPlayer.Name, joins, leaves)
        else
            Info.Text = "🎯 لم يتم تحديد لاعب"
            Avatar.Image = ""
        end
    end

    -- تحديث مباشر أثناء الكتابة
    NameInput:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = NameInput.Text:lower()
        if txt ~= "" then
            local plr = findBestMatch(txt)
            if plr then
                trackedPlayer = plr
                joins, leaves = 0, 0
                Avatar.Image = string.format(
                    "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150",
                    plr.UserId
                )
                updateLabels()
            else
                trackedPlayer = nil
                Info.Text = "⚠️ لاعب غير موجود"
                Avatar.Image = ""
            end
        else
            trackedPlayer = nil
            joins, leaves = 0, 0
            updateLabels()
        end
    end)

    -- تتبع دخول/خروج
    Players.PlayerAdded:Connect(function(plr)
        if trackedPlayer and plr == trackedPlayer then
            joins += 1
            updateLabels()
        end
    end)
    Players.PlayerRemoving:Connect(function(plr)
        if trackedPlayer and plr == trackedPlayer then
            leaves += 1
            updateLabels()
        end
    end)

    updateLabels()
end

-- ✦ عدد الخانات (غير الرقم 4 لأي عدد)
local totalBoxes = 4
for i = 1, totalBoxes do
    CreatePlayerBox()
end
