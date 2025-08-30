-- سكربت السرعة + درفت + تربو
-- حقوق العم حكومه 😁🍷

local player = game.Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SpeedBox = Instance.new("TextBox")
local SpeedButton = Instance.new("TextButton")
local DriftButton = Instance.new("TextButton")
local TurboButton = Instance.new("TextButton")
local ToggleButton = Instance.new("TextButton")
local CarImage = Instance.new("ImageLabel")

-- الإطار الأساسي
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Size = UDim2.new(0, 380, 0, 280)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.BorderSizePixel = 0

-- العنوان RGB
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "🚗 سكربت العم حكومه 😁🍷"
Title.TextSize = 22

-- النص يلمع RGB
spawn(function()
    while true do
        for i = 0, 255, 5 do
            Title.TextColor3 = Color3.fromHSV(i/255, 1, 1)
            wait(0.05)
        end
    end
end)

-- صورة
CarImage.Parent = MainFrame
CarImage.Size = UDim2.new(0, 100, 0, 100)
CarImage.Position = UDim2.new(0.7, 0, 0.05, 0)
CarImage.BackgroundTransparency = 1
CarImage.Image = "rbxassetid://12284307677" -- 🔥 هنا حط لينك الصورة بتاعتك

-- خانة السرعة
SpeedBox.Parent = MainFrame
SpeedBox.Size = UDim2.new(0, 200, 0, 40)
SpeedBox.Position = UDim2.new(0.1, 0, 0.25, 0)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedBox.PlaceholderText = "اكتب السرعة (حد اقصى 2000)"
SpeedBox.TextColor3 = Color3.new(1,1,1)
SpeedBox.Font = Enum.Font.SourceSansBold
SpeedBox.TextSize = 18

-- زرار السرعة
SpeedButton.Parent = MainFrame
SpeedButton.Size = UDim2.new(0, 140, 0, 40)
SpeedButton.Position = UDim2.new(0.35, 0, 0.4, 0)
SpeedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedButton.Text = "🚀 السرعة"
SpeedButton.TextColor3 = Color3.new(1,1,1)

-- زرار الدرفت
DriftButton.Parent = MainFrame
DriftButton.Size = UDim2.new(0, 140, 0, 40)
DriftButton.Position = UDim2.new(0.1, 0, 0.6, 0)
DriftButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
DriftButton.Text = "🌀 درفت"
DriftButton.TextColor3 = Color3.new(1,1,1)

-- زرار التربو
TurboButton.Parent = MainFrame
TurboButton.Size = UDim2.new(0, 140, 0, 40)
TurboButton.Position = UDim2.new(0.55, 0, 0.6, 0)
TurboButton.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
TurboButton.Text = "🔥 تربو"
TurboButton.TextColor3 = Color3.new(1,1,1)

-- زرار فتح/قفل
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 100, 0, 30)
ToggleButton.Position = UDim2.new(0, 20, 0, 200)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "⚙️ فتح/قفل"
ToggleButton.TextColor3 = Color3.new(1,1,1)

-- 🔑 دوال السيارات
local function getCar()
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChildWhichIsA("VehicleSeat", true)
end

-- زر السرعة
SpeedButton.MouseButton1Click:Connect(function()
    local seat = getCar()
    if seat then
        local val = tonumber(SpeedBox.Text)
        if val and val > 0 then
            if val > 2000 then val = 2000 end
            seat.MaxSpeed = val
        end
    end
end)

-- زر الدرفت
DriftButton.MouseButton1Click:Connect(function()
    local seat = getCar()
    if seat then
        seat.Torque = seat.Torque * 0.5
    end
end)

-- زر التربو
TurboButton.MouseButton1Click:Connect(function()
    local seat = getCar()
    if seat then
        seat.Velocity = seat.Velocity + seat.CFrame.LookVector * 2000
    end
end)

-- فتح/قفل
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

print("✅ سكربت حكومه شغال بدون لاج قوي 😁🍷")
