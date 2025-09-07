-- صنع حكومه | كلان EG - تتبع 4 لاعبين
-- Script by M1

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))

-- زرار فتح/قفل
local Toggle = Instance.new("TextButton", ScreenGui)
Toggle.Size = UDim2.new(0, 50, 0, 50)
Toggle.Position = UDim2.new(0, 10, 0.4, 0)
Toggle.Text = "☰"
Toggle.TextSize = 28
Toggle.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Toggle.TextColor3 = Color3.fromRGB(255,255,255)

-- Main Frame
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 600, 0, 400)
Main.Position = UDim2.new(0.5, -300, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Visible = false

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "صنع حكومه | كلان EG - تتبع 4 لاعبين"
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22

-- زرار يفتح ويقفل القايمة
Toggle.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Slots (4 لاعبين)
local slots = {}

for i = 1, 4 do
    local slot = Instance.new("Frame", Main)
    slot.Size = UDim2.new(0.48, 0, 0.35, 0)
    slot.Position = UDim2.new((i-1)%2 * 0.5 + 0.02, 0, math.floor((i-1)/2)*0.4 + 0.2, 0)
    slot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    slot.Visible = true
    
    local Avatar = Instance.new("ImageLabel", slot)
    Avatar.Size = UDim2.new(0,80,0,80)
    Avatar.Position = UDim2.new(0,10,0,10)
    Avatar.BackgroundTransparency = 1
    
    local NameLabel = Instance.new("TextLabel", slot)
    NameLabel.Size = UDim2.new(1,-100,0,25)
    NameLabel.Position = UDim2.new(0,100,0,10)
    NameLabel.BackgroundTransparency = 1
    NameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    NameLabel.TextSize = 18
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Text = "انتظار..."
    
    local ClanLabel = Instance.new("TextLabel", slot)
    ClanLabel.Size = UDim2.new(1,-100,0,20)
    ClanLabel.Position = UDim2.new(0,100,0,40)
    ClanLabel.BackgroundTransparency = 1
    ClanLabel.TextColor3 = Color3.fromRGB(0,200,255)
    ClanLabel.TextSize = 16
    ClanLabel.TextXAlignment = Enum.TextXAlignment.Left
    ClanLabel.Text = "الكلان: EG"
    
    local TimeLabel = Instance.new("TextLabel", slot)
    TimeLabel.Size = UDim2.new(1,-100,0,20)
    TimeLabel.Position = UDim2.new(0,100,0,70)
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.TextColor3 = Color3.fromRGB(0,255,0)
    TimeLabel.TextSize = 16
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
    TimeLabel.Text = "الوقت: 00:00:00"
    
    slots[i] = {
        frame = slot,
        avatar = Avatar,
        name = NameLabel,
        clan = ClanLabel,
        time = TimeLabel,
        player = nil,
        startTime = 0
    }
end

-- دالة تتبع لاعب
local function trackPlayer(slot, plr)
    local info = slots[slot]
    info.player = plr
    info.startTime = tick()
    info.name.Text = "الاسم: "..plr.Name
    info.clan.Text = "الكلان: EG"
    
    -- صورة افاتار
    local thumb = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    info.avatar.Image = thumb
end

-- توزيع أول 4 لاعبين
for i,plr in ipairs(Players:GetPlayers()) do
    if i <= 4 then
        trackPlayer(i, plr)
    end
end

-- تحديث الوقت
RunService.RenderStepped:Connect(function()
    for i,slot in ipairs(slots) do
        if slot.player then
            local elapsed = tick() - slot.startTime
            local h = math.floor(elapsed/3600)
            local m = math.floor((elapsed%3600)/60)
            local s = math.floor(elapsed%60)
            slot.time.Text = string.format("الوقت: %02d:%02d:%02d", h,m,s)
        end
    end
end)

-- لو لاعب جديد دخل
Players.PlayerAdded:Connect(function(plr)
    for i,slot in ipairs(slots) do
        if not slot.player then
            trackPlayer(i, plr)
            break
        end
    end
end)

-- لو لاعب خرج
Players.PlayerRemoving:Connect(function(plr)
    for i,slot in ipairs(slots) do
        if slot.player == plr then
            slot.player = nil
            slot.name.Text = "انتظار..."
            slot.avatar.Image = ""
            slot.time.Text = "الوقت: 00:00:00"
        end
    end
end)
