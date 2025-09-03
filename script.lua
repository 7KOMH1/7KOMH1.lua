-- الحقوق: العم حكومه 🍷 | GS4
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- أصوات
local joinSound = Instance.new("Sound", LocalPlayer:WaitForChild("PlayerGui"))
joinSound.SoundId = "rbxassetid://138248981" -- صوت دخول
local leaveSound = Instance.new("Sound", LocalPlayer:WaitForChild("PlayerGui"))
leaveSound.SoundId = "rbxassetid://138186576" -- صوت خروج

-- GUI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 520, 0, 300)
Frame.Position = UDim2.new(0.5, -260, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "العم حكومه 🍷 | GS4"
Title.TextColor3 = Color3.fromRGB(0,170,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22

-- إشعارات صغيرة
local Notification = Instance.new("TextLabel", ScreenGui)
Notification.Size = UDim2.new(0,200,0,30)
Notification.Position = UDim2.new(0.5,-100,1,-50)
Notification.BackgroundColor3 = Color3.fromRGB(15,15,15)
Notification.TextColor3 = Color3.fromRGB(255,255,255)
Notification.Font = Enum.Font.SourceSansBold
Notification.TextSize = 18
Notification.Visible = false
Notification.BorderSizePixel = 0
Notification.BackgroundTransparency = 0.2

local function showNotification(msg,color)
    Notification.Text = msg
    Notification.TextColor3 = color
    Notification.Visible = true
    TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(0.5,-100,1,-80)}):Play()
    task.delay(2,function()
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {Position = UDim2.new(0.5,-100,1,-50)}):Play()
        task.wait(0.3)
        Notification.Visible = false
    end)
end

-- تتبع ٤ لاعبين
local trackers = {}
local playerStats = {}

local function makeTracker(i)
    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(0.45, -10, 0, 25)
    Box.Position = UDim2.new(((i-1)%2)*0.5+0.025, 0, math.floor((i-1)/2)*0.5+0.2, 0)
    Box.PlaceholderText = "🔍 لاعب "..i
    Box.TextColor3 = Color3.new(1,1,1)
    Box.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Box.Text = ""
    
    local NameLabel = Instance.new("TextLabel", Frame)
    NameLabel.Size = UDim2.new(0.45, -10, 0, 20)
    NameLabel.Position = Box.Position + UDim2.new(0,0,0,30)
    NameLabel.BackgroundTransparency = 1
    NameLabel.TextColor3 = Color3.fromRGB(0,120,255) -- الأزرق
    NameLabel.Text = "Username: -"
    NameLabel.TextScaled = true
    
    local DisplayLabel = Instance.new("TextLabel", Frame)
    DisplayLabel.Size = UDim2.new(0.45, -10, 0, 20)
    DisplayLabel.Position = Box.Position + UDim2.new(0,0,0,55)
    DisplayLabel.BackgroundTransparency = 1
    DisplayLabel.TextColor3 = Color3.fromRGB(0,255,255) -- السماوي
    DisplayLabel.Text = "Display: -"
    DisplayLabel.TextScaled = true
    
    local JoinLabel = Instance.new("TextLabel", Frame)
    JoinLabel.Size = UDim2.new(0.45, -10, 0, 20)
    JoinLabel.Position = Box.Position + UDim2.new(0,0,0,80)
    JoinLabel.BackgroundTransparency = 1
    JoinLabel.TextColor3 = Color3.fromRGB(0,255,0)
    JoinLabel.Text = "✅ دخول: 0"
    JoinLabel.TextScaled = true
    
    local LeaveLabel = Instance.new("TextLabel", Frame)
    LeaveLabel.Size = UDim2.new(0.45, -10, 0, 20)
    LeaveLabel.Position = Box.Position + UDim2.new(0,0,0,105)
    LeaveLabel.BackgroundTransparency = 1
    LeaveLabel.TextColor3 = Color3.fromRGB(255,0,0)
    LeaveLabel.Text = "❌ خروج: 0"
    LeaveLabel.TextScaled = true

    trackers[i] = {
        Box=Box,
        NameLabel=NameLabel,
        DisplayLabel=DisplayLabel,
        JoinLabel=JoinLabel,
        LeaveLabel=LeaveLabel,
        target=nil
    }
end

for i=1,4 do makeTracker(i) end

-- تحديث عرض لاعب
local function updateLabels(i)
    local t = trackers[i]
    if t and t.target then
        local stats = playerStats[t.target.UserId] or {joins=0,leaves=0}
        t.NameLabel.Text = "Username: "..t.target.Name
        t.DisplayLabel.Text = "Display: "..t.target.DisplayName
        t.JoinLabel.Text = "✅ دخول: "..stats.joins
        t.LeaveLabel.Text = "❌ خروج: "..stats.leaves
    end
end

-- البحث
for i,t in ipairs(trackers) do
    t.Box.FocusLost:Connect(function()
        local txt = t.Box.Text:lower()
        if txt~="" then
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr.Name:lower():sub(1,#txt)==txt or plr.DisplayName:lower():sub(1,#txt)==txt then
                    t.target = plr
                    playerStats[plr.UserId] = playerStats[plr.UserId] or {joins=0,leaves=0}
                    updateLabels(i)
                    break
                end
            end
        else
            t.target=nil
            t.NameLabel.Text="Username: -"
            t.DisplayLabel.Text="Display: -"
            t.JoinLabel.Text="✅ دخول: 0"
            t.LeaveLabel.Text="❌ خروج: 0"
        end
    end)
end

-- أحداث الدخول والخروج
Players.PlayerAdded:Connect(function(plr)
    joinSound:Play()
    playerStats[plr.UserId] = playerStats[plr.UserId] or {joins=0,leaves=0}
    playerStats[plr.UserId].joins += 1
    for i,t in ipairs(trackers) do
        if t.target and t.target.Name==plr.Name then
            t.target = plr
            updateLabels(i)
        end
    end
    showNotification("✅ "..plr.DisplayName.." دخل", Color3.fromRGB(0,255,0))
end)

Players.PlayerRemoving:Connect(function(plr)
    leaveSound:Play()
    if playerStats[plr.UserId] then
        playerStats[plr.UserId].leaves += 1
    end
    for i,t in ipairs(trackers) do
        if t.target and t.target.Name==plr.Name then
            updateLabels(i)
        end
    end
    showNotification("❌ "..plr.DisplayName.." خرج", Color3.fromRGB(255,0,0))
end)
