-- حقوق العم حكومه 😁🥂
-- 👑 ملك العربيات: شامل لكل المابات + GUI متوسط + نيترو + تفحيط + هاند بريك + قلب العربية + مضاد فليّنغ
-- مفاتيح سريعة: [+/-] سرعة | [LeftShift/N] نيترو | [G] تفحيط | [H] هاندبريك | [B] قلب العربية | [M] إظهار/إخفاء القائمة

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- إعدادات افتراضية (بتتحفظ للجلسة)
getgenv().CarKingConfig = getgenv().CarKingConfig or {
    Speed = 300,        -- السرعة الأساسية
    MaxLimit = 2000,    -- أقصى سرعة
    NitroBoost = 400,   -- قوة النيترو
    Accel = 60,         -- تسارع/سحب
    Steering = 350,     -- لفة الدركسيون
    Drift = false,      -- التفحيط
    SpeedEnabled = true -- تفعيل السرعة
}
local CFG = getgenv().CarKingConfig

-- حالة النيترو
local NitroActive = false
local NitroCap = 100      -- السعة
local Nitro = NitroCap    -- كمية حالية
local NitroDrain = 45     -- استهلاك/ث
local NitroRegen = 25     -- شحن/ث
local Handbrake = false   -- هاند بريك
local GuiVisible = true

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "CarKing_HKomh"
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 210)
frame.Position = UDim2.new(0.06, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = GuiVisible
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.BorderSizePixel = 0
title.Text = "🚗 ملك العربيات - حقوق العم حكومه 😁🥂"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -30, 0, 0)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255,70,70)
close.BackgroundColor3 = Color3.fromRGB(45,45,45)
close.BorderSizePixel = 0
close.Parent = frame
close.MouseButton1Click:Connect(function()
    GuiVisible = false
    frame.Visible = false
    openBtn.Visible = true
end)

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 70, 0, 30)
openBtn.Position = UDim2.new(0.06, 0, 0.25, -35)
openBtn.Text = "فتح 📂"
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
openBtn.BorderSizePixel = 0
openBtn.Visible = false
openBtn.Parent = gui
openBtn.MouseButton1Click:Connect(function()
    GuiVisible = true
    frame.Visible = true
    openBtn.Visible = false
end)

-- سطر حالة
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 24)
status.Position = UDim2.new(0, 10, 0, 38)
status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = Color3.fromRGB(230,230,230)
status.Font = Enum.Font.SourceSansSemibold
status.TextSize = 16
status.Text = "⚡ السرعة: "..CFG.Speed.." | 🛞 Steering: "..CFG.Steering.." | 🧲 Accel: "..CFG.Accel
status.Parent = frame

-- أزرار +/-
local minus = Instance.new("TextButton")
minus.Size = UDim2.new(0, 36, 0, 28)
minus.Position = UDim2.new(0, 10, 0, 70)
minus.Text = "-100"
minus.TextColor3 = Color3.new(1,1,1)
minus.BackgroundColor3 = Color3.fromRGB(60,60,60)
minus.BorderSizePixel = 0
minus.Parent = frame

local plus = minus:Clone()
plus.Text = "+100"
plus.Position = UDim2.new(0, 56, 0, 70)
plus.Parent = frame

local spdToggle = Instance.new("TextButton")
spdToggle.Size = UDim2.new(0, 120, 0, 28)
spdToggle.Position = UDim2.new(0, 112, 0, 70)
spdToggle.Text = CFG.SpeedEnabled and "🔵 السرعة: ON" or "🔴 السرعة: OFF"
spdToggle.TextColor3 = Color3.new(1,1,1)
spdToggle.BackgroundColor3 = Color3.fromRGB(70,90,70)
spdToggle.BorderSizePixel = 0
spdToggle.Parent = frame

local driftToggle = spdToggle:Clone()
driftToggle.Size = UDim2.new(0, 100, 0, 28)
driftToggle.Position = UDim2.new(0, 238, 0, 70)
driftToggle.Text = CFG.Drift and "🔥 Drift: ON" or "🔥 Drift: OFF"
driftToggle.Parent = frame

local accelLabel = Instance.new("TextLabel")
accelLabel.Size = UDim2.new(0, 175, 0, 22)
accelLabel.Position = UDim2.new(0, 10, 0, 106)
accelLabel.Text = "🧲 Accel: "..CFG.Accel
accelLabel.TextColor3 = Color3.new(1,1,1); accelLabel.BackgroundTransparency=1
accelLabel.Parent = frame

local accelMinus = minus:Clone()
accelMinus.Text = "-10"; accelMinus.Position = UDim2.new(0, 10, 0, 130); accelMinus.Parent = frame
local accelPlus = minus:Clone()
accelPlus.Text = "+10"; accelPlus.Position = UDim2.new(0, 56, 0, 130); accelPlus.Parent = frame

local steerLabel = accelLabel:Clone()
steerLabel.Position = UDim2.new(0, 200, 0, 106)
steerLabel.Text = "🛞 Steering: "..CFG.Steering
steerLabel.Parent = frame
local steerMinus = minus:Clone()
steerMinus.Text = "-25"; steerMinus.Position = UDim2.new(0, 200, 0, 130); steerMinus.Parent = frame
local steerPlus = minus:Clone()
steerPlus.Text = "+25"; steerPlus.Position = UDim2.new(0, 246, 0, 130); steerPlus.Parent = frame

-- شريط نيترو
local nitroBack = Instance.new("Frame")
nitroBack.Size = UDim2.new(1, -20, 0, 16)
nitroBack.Position = UDim2.new(0, 10, 0, 165)
nitroBack.BackgroundColor3 = Color3.fromRGB(50,50,50)
nitroBack.BorderSizePixel = 0
nitroBack.Parent = frame

local nitroFill = Instance.new("Frame")
nitroFill.Size = UDim2.new(Nitro/NitroCap, 0, 1, 0)
nitroFill.BackgroundColor3 = Color3.fromRGB(255,190,0)
nitroFill.BorderSizePixel = 0
nitroFill.Parent = nitroBack

local tips = Instance.new("TextLabel")
tips.Size = UDim2.new(1, -20, 0, 18)
tips.Position = UDim2.new(0, 10, 0, 185)
tips.BackgroundTransparency = 1
tips.TextColor3 = Color3.fromRGB(220,220,220)
tips.Text = "Shift/N: Nitro | G: Drift | H: Handbrake | B: Flip | +/-: Speed | M: إظهار/إخفاء"
tips.TextScaled = false; tips.TextSize = 14
tips.Parent = frame

-- فتح/إخفاء بـ M
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.M then
        GuiVisible = not GuiVisible
        frame.Visible = GuiVisible
        openBtn.Visible = not GuiVisible
    end
end)

-- أزرار GUI
local function updateStatus()
    status.Text = ("⚡ السرعة: %d | 🛞 Steering: %d | 🧲 Accel: %d"):format(CFG.Speed, CFG.Steering, CFG.Accel)
    spdToggle.Text = CFG.SpeedEnabled and "🔵 السرعة: ON" or "🔴 السرعة: OFF"
    driftToggle.Text = CFG.Drift and "🔥 Drift: ON" or "🔥 Drift: OFF"
end
minus.MouseButton1Click:Connect(function()
    CFG.Speed = math.max(0, CFG.Speed - 100); updateStatus()
end)
plus.MouseButton1Click:Connect(function()
    CFG.Speed = math.min(CFG.MaxLimit or 2000, CFG.Speed + 100); updateStatus()
end)
spdToggle.MouseButton1Click:Connect(function()
    CFG.SpeedEnabled = not CFG.SpeedEnabled; updateStatus()
end)
driftToggle.MouseButton1Click:Connect(function()
    CFG.Drift = not CFG.Drift; updateStatus()
end)
accelMinus.MouseButton1Click:Connect(function()
    CFG.Accel = math.max(10, CFG.Accel - 10); updateStatus(); accelLabel.Text = "🧲 Accel: "..CFG.Accel
end)
accelPlus.MouseButton1Click:Connect(function()
    CFG.Accel = math.min(200, CFG.Accel + 10); updateStatus(); accelLabel.Text = "🧲 Accel: "..CFG.Accel
end)
steerMinus.MouseButton1Click:Connect(function()
    CFG.Steering = math.max(100, CFG.Steering - 25); updateStatus(); steerLabel.Text = "🛞 Steering: "..CFG.Steering
end)
steerPlus.MouseButton1Click:Connect(function()
    CFG.Steering = math.min(800, CFG.Steering + 25); updateStatus(); steerLabel.Text = "🛞 Steering: "..CFG.Steering
end)

-- مفاتيح سريعة
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.LeftShift or i.KeyCode == Enum.KeyCode.N then
        NitroActive = true
    elseif i.KeyCode == Enum.KeyCode.G then
        CFG.Drift = not CFG.Drift; updateStatus()
    elseif i.KeyCode == Enum.KeyCode.H then
        Handbrake = true
    elseif i.KeyCode == Enum.KeyCode.B then
        -- قلب العربية
        local seat = nil
        pcall(function()
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("VehicleSeat") and LP.Character and v.Occupant == LP.Character:FindFirstChildOfClass("Humanoid") then
                    seat = v; break
                end
            end
        end)
        if seat and seat:IsA("BasePart") then
            local cf = seat.CFrame
            seat.CFrame = CFrame.new(cf.Position + Vector3.new(0,5,0)) * CFrame.Angles(0, cf:ToEulerAnglesYXZ())
            local bg = seat:FindFirstChildOfClass("BodyGyro") or Instance.new("BodyGyro", seat)
            bg.P = 9e4; bg.MaxTorque = Vector3.new(9e4,9e4,9e4)
            task.delay(0.5, function() if bg then bg:Destroy() end end)
        end
    elseif i.KeyCode == Enum.KeyCode.Equals then
        CFG.Speed = math.min(CFG.Speed + 100, CFG.MaxLimit or 2000); updateStatus()
    elseif i.KeyCode == Enum.KeyCode.Minus then
        CFG.Speed = math.max(CFG.Speed - 100, 0); updateStatus()
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.LeftShift or i.KeyCode == Enum.KeyCode.N then
        NitroActive = false
    elseif i.KeyCode == Enum.KeyCode.H then
        Handbrake = false
    end
end)

-- جلب المقعد (يلتقط أي ماب)
local function getMySeat()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Occupant == hum then
            return v
        end
    end
    -- احتياطي لو بعض المابات بتحط الـSeat داخل الشخصية
    for _,v in ipairs(LP.Character:GetDescendants()) do
        if v:IsA("VehicleSeat") then return v end
    end
    return nil
end

-- مؤثرات بسيطة (شرر/دخان عند النيترو/الدرفت)
local function burstFx(part)
    if not part or not part.Parent then return end
    local p = Instance.new("ParticleEmitter")
    p.Texture = "rbxasset://textures/particles/smoke_main.dds"
    p.Lifetime = NumberRange.new(0.3,0.6)
    p.Rate = 200
    p.Speed = NumberRange.new(10,18)
    p.SpreadAngle = Vector2.new(30,30)
    p.Parent = part
    task.delay(0.2, function() if p then p.Enabled=false end end)
    task.delay(1, function() if p then p:Destroy() end end)
end

-- مضاد فلينج بسيط للعربية (يحد السرعات الشاذة)
local function antiFling(seat)
    if not seat or not seat:IsA("BasePart") then return end
    if seat.AssemblyLinearVelocity.Magnitude > 1200 then
        seat.AssemblyLinearVelocity = seat.AssemblyLinearVelocity.Unit * 1200
    end
    if seat.AssemblyAngularVelocity.Magnitude > 200 then
        seat.AssemblyAngularVelocity = seat.AssemblyAngularVelocity.Unit * 200
    end
end

-- اللوب الرئيسي
local lastDriftFx = 0
RS.Heartbeat:Connect(function(dt)
    -- نيترو شحن/تفريغ
    if NitroActive and Nitro > 0 then
        Nitro = math.max(0, Nitro - NitroDrain * dt)
        if math.floor(Nitro) % 5 == 0 then -- لمعة تأثير
            local s = getMySeat(); if s then burstFx(s) end
        end
    elseif not NitroActive then
        Nitro = math.min(NitroCap, Nitro + NitroRegen * dt)
    end
    nitroFill.Size = UDim2.new(Nitro/NitroCap, 0, 1, 0)

    local seat = getMySeat()
    if not seat then return end

    -- تطبيق الإعدادات
    if CFG.SpeedEnabled then
        local target = math.min(CFG.Speed + (NitroActive and CFG.NitroBoost or 0), CFG.MaxLimit or 2000)
        seat.MaxSpeed = target
    end
    -- Steering/Accel
    seat.TurnSpeed = CFG.Steering
    seat.Torque = Vector3.new(0, CFG.Steering * 100, 0)
    -- بوش تسارع بسيط عشان السحب
    if seat.Throttle ~= 0 and CFG.SpeedEnabled then
        local bv = seat:FindFirstChildOfClass("BodyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1e5,0,1e5); bv.Parent = seat
        end
        local forward = seat.CFrame.LookVector
        local base = (seat.MaxSpeed or CFG.Speed)
        if CFG.Drift or Handbrake then
            -- دريفت/هاندبريك: تقليل الجر وزود إنزلاق
            bv.MaxForce = Vector3.new(9e4, 0, 9e4)
            bv.Velocity = forward * (base * 0.85)
            if tick() - lastDriftFx > 0.12 then burstFx(seat); lastDriftFx = tick() end
        else
            bv.MaxForce = Vector3.new(1.6e5, 0, 1.6e5)
            bv.Velocity = forward * (base + CFG.Accel)
        end
    else
        local bv = seat:FindFirstChildOfClass("BodyVelocity")
        if bv and (not CFG.Drift) and (not Handbrake) then
            bv:Destroy()
        end
    end

    -- هاندبريك: قفل دفع للأمام مؤقتًا
    if Handbrake then
        local bv = seat:FindFirstChildOfClass("BodyVelocity")
        if bv then
            bv.Velocity = bv.Velocity * 0.6
        end
    end

    -- مضاد فلينج
    antiFling(seat)

    -- تحديث حالة النص
    status.Text = ("⚡ السرعة: %d | 🛞 Steering: %d | 🧲 Accel: %d | 🎇 Nitro: %d%%")
        :format(CFG.Speed, CFG.Steering, CFG.Accel, math.floor((Nitro/NitroCap)*100))
end)

warn("✅ ملك العربيات شغال | حقوق العم حكومه 😁🥂")
```0
