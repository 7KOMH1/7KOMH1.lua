--// سكربت التحولات المرعبة - حقوق العم حكومه 😁🍷

-- خدمات Roblox
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- دالة التحول
local function MorphTo(userId)
    local humanoidDescription = Players:GetHumanoidDescriptionFromUserId(userId)
    if humanoidDescription then
        character.Humanoid:ApplyDescription(humanoidDescription)
    end
end

-- واجهة
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 3
mainFrame.Active = true
mainFrame.Draggable = true

-- عنوان واجهة
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "⚡ سكربت التحولات المرعبة ⚡"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.Font = Enum.Font.Fantasy
title.TextSize = 22

-- قائمة الشخصيات المرعبة
local characters = {
    {Name = "👻 سلندر مان", UserId = 22612059},
    {Name = "🔪 جيسون", UserId = 77378689},
    {Name = "🩸 فريدي كروجر", UserId = 26422347},
    {Name = "🕷️ زومبي أسود", UserId = 45375092},
    {Name = "💀 هيكل عظمي", UserId = 14592711},
    {Name = "👹 وحش ضخم", UserId = 93837422},
    {Name = "🧟 زومبي عادي", UserId = 45370921},
    {Name = "👿 شيطان أحمر", UserId = 83274933},
    {Name = "🎃 هالوين", UserId = 17493288},
    {Name = "🪓 قاتل مجنون", UserId = 55392014},
    {Name = "🧛 مصاص دماء", UserId = 23458992},
    {Name = "🧟‍♀️ زومبي بنت", UserId = 67738291},
    {Name = "👺 قناع مرعب", UserId = 17293044},
    {Name = "🧞 جني مظلم", UserId = 18839202},
    {Name = "👾 وحش غريب", UserId = 90392022},
    {Name = "💀 شبح أسود", UserId = 32450922},
    {Name = "👹 أوجر ضخم", UserId = 54920291},
    {Name = "👽 فضائي مرعب", UserId = 76492013},
    {Name = "🪦 شبح مقبرة", UserId = 32948291},
    {Name = "🧟‍♂️ زومبي متحلل", UserId = 12837491},
    {Name = "🔥 جمجمة نار", UserId = 56293812},
    {Name = "👹 وحش الظل", UserId = 45619283},
    {Name = "🕷️ عنكبوت بشري", UserId = 19823719},
    {Name = "👻 شبح أبيض", UserId = 23817293},
    {Name = "💀 هيكل محترق", UserId = 45023981},
}

-- صنع أزرار التحول
local layout = Instance.new("UIListLayout", mainFrame)
layout.Padding = UDim.new(0, 5)
layout.FillDirection = Enum.FillDirection.Vertical

for _, charData in ipairs(characters) do
    local button = Instance.new("TextButton", mainFrame)
    button.Size = UDim2.new(1, -10, 0, 25)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.Text = charData.Name
    button.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Fantasy
    button.TextSize = 18

    button.MouseButton1Click:Connect(function()
        MorphTo(charData.UserId)
    end)
end

-- زر العودة للشكل الأصلي
local resetBtn = Instance.new("TextButton", mainFrame)
resetBtn.Size = UDim2.new(1, -10, 0, 25)
resetBtn.Text = "🔄 رجوع للشكل الأصلي"
resetBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.SourceSansBold
resetBtn.TextSize = 18

resetBtn.MouseButton1Click:Connect(function()
    player:LoadCharacter()
end)

-- حقوق العم حكومه 😁🍷 RGB
local credit = Instance.new("TextLabel", mainFrame)
credit.Size = UDim2.new(1, 0, 0, 30)
credit.Position = UDim2.new(0, 0, 1, -30)
credit.BackgroundTransparency = 1
credit.Font = Enum.Font.Fantasy
credit.TextSize = 20
credit.Text = "حقوق العم حكومه 😁🍷"

task.spawn(function()
    while task.wait(0.2) do
        credit.TextColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
    end
end)
