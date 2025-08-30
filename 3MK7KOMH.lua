-- حقوق العم حكومه 😁🍷
-- ملك العربيات: سرعة + درفت + تربو + واجهة تحميل + GUI/Watermark + ضبط ذكي لكل المابات

--====== إعدادات عامة ======--
local LP = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")

getgenv().HK_CFG = getgenv().HK_CFG or {
    Speed       = 600,      -- السرعة الأساسية
    MaxLimit    = 2000,     -- أقصى سرعة
    Accel       = 70,       -- سحب (يضاف على الدفع للأمام)
    Steering    = 350,      -- لفة الدركسيون
    NitroBoost  = 450,      -- قوة النيترو
    NitroCap    = 100,      -- سعة النيترو %
    Drift       = false,    -- التفحيط
    Enabled     = true,     -- تشغيل السكربت
    SplashSecs  = 3.5,      -- مدة واجهة التحميل
    SplashImage = nil       -- حط هنا rbxassetid://ID لو رفعت الصورة كـ Decal
}
local CFG = getgenv().HK_CFG

--====== GUI & Splash ======--
local CoreGui = game:GetService("CoreGui")
local gui = Instance.new("ScreenGui", CoreGui); gui.Name = "HKOMH_UI"

-- Splash
local splash = Instance.new("Frame", gui)
splash.Size = UDim2.new(1,0,1,0)
splash.BackgroundColor3 = Color3.fromRGB(10,10,10)

local bg = Instance.new("ImageLabel", splash)
bg.Size = UDim2.new(0.6,0,0.6,0)
bg.Position = UDim2.new(0.2,0,0.12,0)
bg.BackgroundTransparency = 1
bg.ScaleType = Enum.ScaleType.Fit
bg.Image = CFG.SplashImage or "" -- ضع rbxassetid://ID إن وجد

local splashTitle = Instance.new("TextLabel", splash)
splashTitle.Size = UDim2.new(1,0,0,60)
splashTitle.Position = UDim2.new(0,0,0.72,0)
splashTitle.BackgroundTransparency = 1
splashTitle.Text = "حكومه بيمسي 😁🍷"
splashTitle.TextColor3 = Color3.fromRGB(255,255,255)
splashTitle.Font = Enum.Font.GothamBold
splashTitle.TextSize = 38

local splashSub = splashTitle:Clone()
splashSub.Parent = splash
splashSub.Position = UDim2.new(0,0,0.82,0)
splashSub.TextSize = 24
splashSub.Text = "منور سكربت العم حكومه 😁🍷"

local skip = Instance.new("TextButton", splash)
skip.Size = UDim2.new(0,120,0,34)
skip.Position = UDim2.new(0.02,0,0.93,0)
skip.Text = "تخطي ▶"
skip.TextColor3 = Color3.fromRGB(255,255,255)
skip.BackgroundColor3 = Color3.fromRGB(40,40,40)
skip.BorderSizePixel = 0

local function hideSplash() splash.Visible=false end
skip.MouseButton1Click:Connect(hideSplash)
task.delay(CFG.SplashSecs, hideSplash)

-- Main GUI
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,300,0,210)
main.Position = UDim2.new(0.06,0,0.18,0)
main.BackgroundColor3 = Color3.fromRGB(28,28,28)
main.BorderSizePixel = 0
main.Active = true; main.Draggable = true
main.Visible = false

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,-30,0,30)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "🚗 سكربت العم حكومه 😁🍷"
title.Font = Enum.Font.GothamBold; title.TextSize = 18

local btnX = Instance.new("TextButton", main)
btnX.Size = UDim2.new(0,30,0,30)
btnX.Position = UDim2.new(1,-30,0,0)
btnX.Text = "X"
btnX.BackgroundColor3 = Color3.fromRGB(60,60,60)
btnX.TextColor3 = Color3.fromRGB(255,80,80)
btnX.BorderSizePixel = 0
btnX.MouseButton1Click:Connect(function() main.Visible=false end)

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,-20,0,22)
status.Position = UDim2.new(0,10,0,38)
status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = Color3.fromRGB(230,230,230)
status.Font = Enum.Font.GothamSemibold
status.TextSize = 15

local function mkBtn(text, x, y, w)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0,w or 130,0,28)
    b.Position = UDim2.new(0,x,0,y)
    b.BackgroundColor3 = Color3.fromRGB(70,70,70)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BorderSizePixel = 0
    b.Text = text; b.Font = Enum.Font.Gotham; b.TextSize = 14
    return b
end

local bMinus = mkBtn("-100",10,68,60)
local bPlus  = mkBtn("+100",76,68,60)
local bSpeed = mkBtn(CFG.Enabled and "🔵 السرعة: ON" or "🔴 السرعة: OFF",142,68,148)

local bDrift = mkBtn(CFG.Drift and "🔥 Drift: ON" or "🔥 Drift: OFF",10,102,130)
local bTurbo = mkBtn("🚀 Nitro: Shift/N",158,102,132)

local accelL = Instance.new("TextLabel", main)
accelL.Size = UDim2.new(0,140,0,22)
accelL.Position = UDim2.new(0,10,0,135)
accelL.BackgroundTransparency = 1
accelL.Text = "🧲 Accel: "..CFG.Accel
accelL.TextColor3 = Color3.new(1,1,1); accelL.Font=Enum.Font.Gotham; accelL.TextSize=14

local bAM = mkBtn("-10",10,160,60)
local bAP = mkBtn("+10",76,160,60)

local steerL = accelL:Clone(); steerL.Parent=main
steerL.Position = UDim2.new(0,158,0,135); steerL.Text = "🛞 Steering: "..CFG.Steering
local bSM = mkBtn("-25",158,160,60)
local bSP = mkBtn("+25",224,160,60)

local tips = Instance.new("TextLabel", main)
tips.Size = UDim2.new(1,-20,0,18)
tips.Position = UDim2.new(0,10,0,188)
tips.BackgroundTransparency = 1
tips.Text = "P: إظهار/إخفاء | +/-: سرعة | G: درفت | H: هاندبريك | B: قلب"
tips.TextColor3 = Color3.fromRGB(210,210,210)
tips.Font = Enum.Font.Gotham; tips.TextSize = 12

-- Watermark
local wm = Instance.new("TextLabel", gui)
wm.Size = UDim2.new(0,220,0,24)
wm.Position = UDim2.new(1,-230,1,-28)
wm.BackgroundTransparency = 1
wm.Text = "حقوق العم حكومه 😁🍷"
wm.TextColor3 = Color3.fromRGB(255,255,255)
wm.Font = Enum.Font.Gotham; wm.TextSize = 16

-- إظهار الواجهة بعد السلاش
task.delay(CFG.SplashSecs, function() if splash.Visible==false then main.Visible=true else task.wait(0.1); if not splash.Visible then main.Visible=true end end end)

--====== منطق السيارة (ذكاء/تكيّف) ======--
local NitroActive, Nitro = false, CFG.NitroCap
local Handbrake = false
local function mySeat()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Occupant == hum then return v end
    end
    for _,v in ipairs(LP.Character:GetDescendants()) do
        if v:IsA("VehicleSeat") then return v end
    end
end

local function burstFx(part)
    if not part then return end
    local p = Instance.new("ParticleEmitter", part)
    p.Texture = "rbxasset://textures/particles/smoke_main.dds"
    p.Lifetime = NumberRange.new(0.2,0.5)
    p.Rate = 160; p.Speed = NumberRange.new(10,16); p.SpreadAngle = Vector2.new(25,25)
    task.delay(0.15,function() p.Enabled=false end)
    task.delay(0.8,function() p:Destroy() end)
end

local function antiFling(seat)
    if seat.AssemblyLinearVelocity.Magnitude>1200 then
        seat.AssemblyLinearVelocity = seat.AssemblyLinearVelocity.Unit*1200
    end
    if seat.AssemblyAngularVelocity.Magnitude>200 then
        seat.AssemblyAngularVelocity = seat.AssemblyAngularVelocity.Unit*200
    end
end

local lastFx = 0
RS.Heartbeat:Connect(function(dt)
    -- نيترو شحن/تفريغ
    if NitroActive and Nitro>0 then Nitro = math.max(0, Nitro - 45*dt) else Nitro = math.min(CFG.NitroCap, Nitro + 25*dt) end

    local seat = mySeat()
    if not seat then return end

    -- تكيّف ذكي: لو العربية تقيلة أو بطيئة زوّد السحب مؤقتًا
    local massBoost = math.clamp(seat.AssemblyMass/1000, 0, 2)
    local dynAccel  = CFG.Accel + (massBoost*20)

    if CFG.Enabled then
        local target = math.min(CFG.Speed + (NitroActive and CFG.NitroBoost or 0), CFG.MaxLimit)
        seat.MaxSpeed = target
        seat.TurnSpeed = CFG.Steering
        seat.Torque = Vector3.new(0, CFG.Steering*100, 0)

        if seat.Throttle ~= 0 then
            local bv = seat:FindFirstChildOfClass("BodyVelocity") or Instance.new("BodyVelocity", seat)
            bv.MaxForce = Vector3.new(1.6e5,0,1.6e5)
            if CFG.Drift or Handbrake then
                bv.MaxForce = Vector3.new(9e4,0,9e4)
                bv.Velocity = seat.CFrame.LookVector * (target*0.85)
                if tick()-lastFx>0.12 then burstFx(seat); lastFx=tick() end
            else
                bv.Velocity = seat.CFrame.LookVector * (target + dynAccel)
            end
        end
    end

    if Handbrake then
        local bv = seat:FindFirstChildOfClass("BodyVelocity")
        if bv then bv.Velocity = bv.Velocity*0.6 end
    end

    antiFling(seat)

    status.Text = string.format("⚡ %d | 🛞 %d | 🧲 %d | 🎇 %d%%",
        CFG.Speed, CFG.Steering, CFG.Accel, math.floor((Nitro/CFG.NitroCap)*100))
end)

--====== أزرار GUI ======--
local function refresh()
    status.Text = ("⚡ %d | 🛞 %d | 🧲 %d | 🎇").format and " " or status.Text
    bSpeed.Text = CFG.Enabled and "🔵 السرعة: ON" or "🔴 السرعة: OFF"
    bDrift.Text = CFG.Drift and "🔥 Drift: ON" or "🔥 Drift: OFF"
    accelL.Text = "🧲 Accel: "..CFG.Accel
    steerL.Text = "🛞 Steering: "..CFG.Steering
end

bMinus.MouseButton1Click:Connect(function() CFG.Speed = math.max(0, CFG.Speed-100); refresh() end)
bPlus.MouseButton1Click:Connect(function()  CFG.Speed = math.min(CFG.MaxLimit, CFG.Speed+100); refresh() end)
bSpeed.MouseButton1Click:Connect(function() CFG.Enabled = not CFG.Enabled; refresh() end)
bDrift.MouseButton1Click:Connect(function() CFG.Drift = not CFG.Drift; refresh() end)
bAM.MouseButton1Click:Connect(function()   CFG.Accel = math.max(10, CFG.Accel-10); refresh() end)
bAP.MouseButton1Click:Connect(function()   CFG.Accel = math.min(200, CFG.Accel+10); refresh() end)
bSM.MouseButton1Click:Connect(function()   CFG.Steering = math.max(100, CFG.Steering-25); refresh() end)
bSP.MouseButton1Click:Connect(function()   CFG.Steering = math.min(800, CFG.Steering+25); refresh() end)

--====== مفاتيح سريعة ======--
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.P then main.Visible = not main.Visible end
    if i.KeyCode==Enum.KeyCode.LeftShift or i.KeyCode==Enum.KeyCode.N then NitroActive=true end
    if i.KeyCode==Enum.KeyCode.G then CFG.Drift = not CFG.Drift; refresh() end
    if i.KeyCode==Enum.KeyCode.H then Handbrake=true end
    if i.KeyCode==Enum.KeyCode.B then
        local s = mySeat()
        if s then
            s.CFrame = CFrame.new(s.Position + Vector3.new(0,5,0))
            local bg = Instance.new("BodyGyro", s); bg.P=9e4; bg.MaxTorque=Vector3.new(9e4,9e4,9e4)
            task.delay(0.5,function() bg:Destroy() end)
        end
    end
    if i.KeyCode==Enum.KeyCode.Equals then CFG.Speed = math.min(CFG.Speed+100, CFG.MaxLimit); refresh() end
    if i.KeyCode==Enum.KeyCode.Minus  then CFG.Speed = math.max(CFG.Speed-100, 0); refresh() end
end)
UIS.InputEnded:Connect(function(i)
    if i.KeyCode==Enum.KeyCode.LeftShift or i.KeyCode==Enum.KeyCode.N then NitroActive=false end
    if i.KeyCode==Enum.KeyCode.H then Handbrake=false end
end)

print("✅ سكربت جاهز - حقوق العم حكومه 😁🍷")
