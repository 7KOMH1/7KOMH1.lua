-- سكربت العم حكومه 😁🍷
-- منور سكربت العم حكومه

-- إعدادات
local turboKey = Enum.KeyCode.T
local driftKey = Enum.KeyCode.LeftShift
local toggleGuiKey = Enum.KeyCode.X

local maxSpeed = 2000
local turboForce = 5000
local driftFriction = 0.2

-- عمل GUI
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

-- شاشة تحميل
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(0.5,0,0.5,0)
LoadingFrame.Position = UDim2.new(0.25,0,0.25,0)
LoadingFrame.BackgroundTransparency = 0
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)

local BgImage = Instance.new("ImageLabel", LoadingFrame)
BgImage.Size = UDim2.new(1,0,1,0)
BgImage.Image = "https://cdn.discordapp.com/attachments/1409312288996986950/1411236683856478289/406130d543e87236c27d8ace0d0533c8.jpg"
BgImage.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", LoadingFrame)
Title.Size = UDim2.new(1,0,0.3,0)
Title.Position = UDim2.new(0,0,0,0)
Title.Text = "حكومه بيمسي 😁🍷"
Title.TextColor3 = Color3.fromRGB(255,255,0)
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local SubTitle = Instance.new("TextLabel", LoadingFrame)
SubTitle.Size = UDim2.new(1,0,0.2,0)
SubTitle.Position = UDim2.new(0,0,0.7,0)
SubTitle.Text = "منور سكربت العم حكومه 😁🍷"
SubTitle.TextColor3 = Color3.fromRGB(255,255,255)
SubTitle.TextScaled = true
SubTitle.BackgroundTransparency = 1
SubTitle.Font = Enum.Font.GothamBold

-- القائمة الرئيسية
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0.35,0,0.4,0)
MainFrame.Position = UDim2.new(0.325,0,0.3,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.Visible = false

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0,12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255,255,0)

local TitleMain = Instance.new("TextLabel", MainFrame)
TitleMain.Size = UDim2.new(1,0,0.2,0)
TitleMain.Text = "🚗 سكربت سرعه ودرفت - العم حكومه 😁🍷"
TitleMain.TextScaled = true
TitleMain.TextColor3 = Color3.fromRGB(255,255,255)
TitleMain.BackgroundTransparency = 1
TitleMain.Font = Enum.Font.GothamBold

-- أزرار
local function createButton(text,posY,callback)
    local Btn = Instance.new("TextButton", MainFrame)
    Btn.Size = UDim2.new(0.8,0,0.15,0)
    Btn.Position = UDim2.new(0.1,0,posY,0)
    Btn.Text = text
    Btn.TextScaled = true
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Btn.Font = Enum.Font.GothamBold
    local corner = Instance.new("UICorner", Btn)
    corner.CornerRadius = UDim.new(0,8)
    Btn.MouseButton1Click:Connect(callback)
end

-- منور الرساله
task.delay(4,function()
    LoadingFrame.Visible = false
    MainFrame.Visible = true
end)

-- التحكم في العربية
local turboEnabled = false
local driftEnabled = false

createButton("تشغيل/ايقاف التربو",0.25,function()
    turboEnabled = not turboEnabled
end)

createButton("تشغيل/ايقاف الدرفت",0.45,function()
    driftEnabled = not driftEnabled
end)

-- كود التربو والدرفت
game:GetService("RunService").Heartbeat:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local seat = char:FindFirstChildWhichIsA("VehicleSeat",true)
        if seat then
            if turboEnabled then
                seat.MaxSpeed = maxSpeed
                seat.Velocity = seat.CFrame.LookVector * turboForce
            else
                seat.MaxSpeed = 50
            end
            if driftEnabled then
                seat.Torque = Vector3.new(0,10000,0)
                seat.Steer = seat.Steer*1.5
            end
        end
    end
end)

-- زر فتح/قفل
game:GetService("UserInputService").InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode == toggleGuiKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
