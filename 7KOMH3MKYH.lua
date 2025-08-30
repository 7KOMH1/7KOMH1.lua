-- سكربت التحولات مع حقوق العم حكومه 😁🍷

-- خدمات Roblox
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- إنشاء واجهة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- زرار فتح/قفل
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0,100,0,40)
ToggleButton.Position = UDim2.new(0,10,0,10)
ToggleButton.Text = "القائمة"
ToggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)

-- فريم القائمة
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0,300,0,400)
MainFrame.Position = UDim2.new(0.5,-150,0.5,-200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.Visible = false

-- حقوق العم حكومه 😁🍷
local Rights = Instance.new("TextLabel")
Rights.Parent = ScreenGui
Rights.Size = UDim2.new(1,0,0,30)
Rights.Position = UDim2.new(0,0,1,-30)
Rights.Text = "حقوق العم حكومه 😁🍷"
Rights.TextScaled = true
Rights.BackgroundTransparency = 1
Rights.TextColor3 = Color3.fromRGB(255,0,0)

-- الوان متغيرة (RGB)
task.spawn(function()
    local hue = 0
    while true do
        hue = (hue + 0.01) % 1
        Rights.TextColor3 = Color3.fromHSV(hue,1,1)
        task.wait(0.05)
    end
end)

-- حفظ الشخصية الأصلية
local OriginalDescription = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)

-- دالة للتحول
local function MorphTo(userId)
    local success, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    if success and desc then
        Character.Humanoid:ApplyDescription(desc)
    else
        warn("ماقدرش يجيب التحول")
    end
end

-- أزرار الشخصيات
local Characters = {
    {"Slenderman",  23309932}, 
    {"Monster",     74669399}, 
    {"Zombie",      83013256}, 
    {"Giant",       74669463}, 
    {"Demon",       74669410}, 
    {"Dragon",      83013400}, 
    {"Alien",       74669555}, 
    {"Robot",       83013521}, 
    {"Skeleton",    74669600}, 
    {"Shadow",      74669650}, 
    {"Vampire",     83013612}, 
    {"Werewolf",    74669730}, 
    {"DarkKnight",  74669800}, 
    {"Reaper",      83013733}, 
    {"Beast",       74669900}, 
    {"Titan",       83013844}, 
    {"Phantom",     74670000}, 
    {"Ghoul",       74670100}, 
    {"Wraith",      83013955}, 
    {"Ogre",        74670200}, 
    {"Devil",       74670300}, 
    {"AngelOfDeath",74670400}, 
    {"Mutant",      83014066}, 
    {"Cyclops",     74670500}, 
    {"Slayer",      74670600}
}

for i,data in ipairs(Characters) do
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0,130,0,30)
    btn.Position = UDim2.new(0,(i%2==0) and 150 or 10,0,((math.floor((i-1)/2))*35)+10)
    btn.Text = "تحول: "..data[1]
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.MouseButton1Click:Connect(function()
        MorphTo(data[2])
    end)
end

-- زرار الرجوع
local back = Instance.new("TextButton")
back.Parent = MainFrame
back.Size = UDim2.new(0,280,0,30)
back.Position = UDim2.new(0,10,1,-40)
back.Text = "رجوع للشخصية الأصلية"
back.BackgroundColor3 = Color3.fromRGB(80,0,0)
back.TextColor3 = Color3.fromRGB(255,255,255)
back.MouseButton1Click:Connect(function()
    Character.Humanoid:ApplyDescription(OriginalDescription)
end)

-- تشغيل وفتح/قفل
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
