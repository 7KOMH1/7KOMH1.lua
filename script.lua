--[[ 
 📌 نسخة نهائية + صوت دخول وخروج
 🍷 حقوق: GS4 | العم حكومه
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- اصوات
local JoinSound = Instance.new("Sound")
JoinSound.SoundId = "rbxassetid://12222005" -- صوت دخول
JoinSound.Volume = 2
JoinSound.Parent = LocalPlayer:WaitForChild("PlayerGui")

local LeaveSound = Instance.new("Sound")
LeaveSound.SoundId = "rbxassetid://12222242" -- صوت خروج
LeaveSound.Volume = 2
LeaveSound.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- زرار الفتح/القفل
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0,40,0,40)
ToggleButton.Position = UDim2.new(0.05,0,0.2,0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20,20,20)
ToggleButton.Text = "≡"
ToggleButton.TextColor3 = Color3.fromRGB(0,200,255)
ToggleButton.Parent = ScreenGui
ToggleButton.Draggable = true

-- الفريم الاساسي
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,500,0,350)
MainFrame.Position = UDim2.new(0.5,-250,0.5,-175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "🍷 GS4 | العم حكومه"
Title.TextColor3 = Color3.fromRGB(0,200,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.Parent = MainFrame

-- اماكن اللاعبين
local Slots = {}
for i=1,4 do
    local Slot = Instance.new("Frame")
    Slot.Size = UDim2.new(0.5,-10,0.5,-30)
    Slot.Position = UDim2.new(((i-1)%2)*0.5,5,math.floor((i-1)/2)*0.5,30)
    Slot.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Slot.Parent = MainFrame

    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0,60,0,60)
    Avatar.Position = UDim2.new(0,5,0,5)
    Avatar.BackgroundTransparency = 1
    Avatar.Parent = Slot

    local NameBox = Instance.new("TextBox")
    NameBox.Size = UDim2.new(1,-75,0,30)
    NameBox.Position = UDim2.new(0,70,0,5)
    NameBox.PlaceholderText = "اكتب اسم اللاعب"
    NameBox.TextColor3 = Color3.fromRGB(255,255,255)
    NameBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
    NameBox.Parent = Slot

    local NickLabel = Instance.new("TextLabel")
    NickLabel.Size = UDim2.new(1,-75,0,25)
    NickLabel.Position = UDim2.new(0,70,0,40)
    NickLabel.BackgroundTransparency = 1
    NickLabel.TextColor3 = Color3.fromRGB(200,200,200)
    NickLabel.Text = "لاعب غير محدد"
    NickLabel.Parent = Slot

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1,-10,0,25)
    Status.Position = UDim2.new(0,5,0,70)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(0,255,0)
    Status.Text = "✅ دخول: 0   ❌ خروج: 0"
    Status.Parent = Slot

    Slots[i] = {Box=NameBox,Nick=NickLabel,Avatar=Avatar,Status=Status,CountIn=0,CountOut=0}
end

-- تحديث بيانات
local function UpdateSlot(slot,player)
    if player then
        local userId = player.UserId
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size100x100
        local content = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        slot.Avatar.Image = content
        slot.Nick.Text = "@"..player.Name
    else
        slot.Avatar.Image = ""
        slot.Nick.Text = "لاعب غير محدد"
    end
end

-- دخول اللاعب
Players.PlayerAdded:Connect(function(player)
    for _,slot in ipairs(Slots) do
        if slot.Box.Text ~= "" and player.Name:lower():sub(1,#slot.Box.Text) == slot.Box.Text:lower() then
            slot.CountIn += 1
            slot.Status.Text = "✅ دخول: "..slot.CountIn.."   ❌ خروج: "..slot.CountOut
            UpdateSlot(slot,player)
            JoinSound:Play() -- تشغيل صوت دخول
        end
    end
end)

-- خروج اللاعب
Players.PlayerRemoving:Connect(function(player)
    for _,slot in ipairs(Slots) do
        if slot.Box.Text ~= "" and player.Name:lower():sub(1,#slot.Box.Text) == slot.Box.Text:lower() then
            slot.CountOut += 1
            slot.Status.Text = "✅ دخول: "..slot.CountIn.."   ❌ خروج: "..slot.CountOut
            UpdateSlot(slot,nil)
            LeaveSound:Play() -- تشغيل صوت خروج
        end
    end
end)

-- فتح/قفل
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
