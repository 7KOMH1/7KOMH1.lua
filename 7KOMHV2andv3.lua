--[[
    حقوق العم حكومه 😁🍷
    سكربت شامل: سرعة + تربو + درفت + واجهة + صورة + RGB
    • يشتغل على أي عربية مبنية على VehicleSeat (زي بروكهافن وغيرها)
    • يقلل اللاج قدر الإمكان بدون حذف مميزات
    • يفضل تشغيله عبر Executor خارجي
]]

--== خدمات Roblox ==--
local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local LP      = Players.LocalPlayer

--== إعدادات قابلة للتعديل ==--
local CFG = {
    Speed         = 150,          -- السرعة الافتراضية (متوازنة)
    MaxLimit      = 2000,         -- الحد الأقصى للسرعة
    TurboMult     = 2.0,          -- قوة التربو (×2)
    DriftFriction = 0.20,         -- احتكاك وقت الدرفت (أقل = تفحيط أكثر)
    ImageURL      = "https://cdn.discordapp.com/attachments/1409312288996986950/1411236683856478289/406130d543e87236c27d8ace0d0533c8.jpg"
}

--== حالة السكربت ==--
local State = {
    Enabled = true,   -- السكربت شغال حتى لو الواجهة مقفولة
    Turbo   = false,
    Drift   = false,
    Seat    = nil,
    Root    = nil,
    Car     = nil
}

--== دوال مساعدة ==--
local function getSeat()
    local char = LP.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    if hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        return hum.SeatPart
    end
    return nil
end

local function getCarRoot(seat)
    if not seat or not seat:IsA("BasePart") then return nil end
    if seat.AssemblyRootPart then return seat.AssemblyRootPart end
    local model = seat:FindFirstAncestorOfClass("Model")
    if model and model.PrimaryPart then return model.PrimaryPart end
    return seat
end

local function getCarModel(seat)
    return seat and seat:FindFirstAncestorOfClass("Model") or nil
end

-- حفظ/استرجاع خصائص العجلات للدرفت
local savedProps = {}
local function setDrift(on)
    if not State.Car then return end
    for _,p in ipairs(State.Car:GetDescendants()) do
        if p:IsA("BasePart") then
            local n = (p.Name or ""):lower()
            local isWheel = n:find("wheel") or n:find("tire") or p.Shape == Enum.PartType.Cylinder
            if isWheel then
                if on then
                    if not savedProps[p] then savedProps[p] = p.CustomPhysicalProperties end
                    p.CustomPhysicalProperties = PhysicalProperties.new(1, CFG.DriftFriction, 0.3, 1, 1)
                else
                    if savedProps[p] ~= nil then
                        p.CustomPhysicalProperties = savedProps[p]
                    end
                end
            end
        end
    end
    if not on then savedProps = {} end
end

--== الواجهة (GUI) ==--
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Name = "Hakomah_ProGUI"
gui.Parent = game:GetService("CoreGui")

-- زر صغير دائماً ظاهر (إظهار/إخفاء القائمة)
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 110, 0, 36)
toggleBtn.Position = UDim2.new(0.02, 0, 0.12, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = true
toggleBtn.Text = "📌 القائمة"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Active = true

-- الإطار الرئيسي (حجم متوسط)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 340, 0, 260)
frame.Position = UDim2.new(0.05, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(22,22,22)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true

-- عنوان RGB
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -10, 0, 36)
title.Position = UDim2.new(0, 5, 0, 6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "🚗 سكربت العم حكومه 😁🍷"
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255,255,255)
task.spawn(function()
    local h = 0
    while gui.Parent do
        h = (h + 0.01) % 1
        title.TextColor3 = Color3.fromHSV(h, 1, 1)
        task.wait(0.06) -- أبطأ شوية = لاج أقل
    end
end)

-- الصورة
local img = Instance.new("ImageLabel", frame)
img.Size = UDim2.new(0, 96, 0, 96)
img.Position = UDim2.new(1, -106, 0, 42)
img.BackgroundTransparency = 1
img.Image = CFG.ImageURL

-- خانة السرعة + زر تطبيق
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0, 190, 0, 34)
speedBox.Position = UDim2.new(0, 10, 0, 60)
speedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedBox.BorderSizePixel = 0
speedBox.PlaceholderText = "اكتب السرعة (حدها "..tostring(CFG.MaxLimit)..")"
speedBox.Text = tostring(CFG.Speed)
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.Font = Enum.Font.GothamSemibold
speedBox.TextSize = 16
speedBox.ClearTextOnFocus = false

local applyBtn = Instance.new("TextButton", frame)
applyBtn.Size = UDim2.new(0, 120, 0, 34)
applyBtn.Position = UDim2.new(0, 210, 0, 60)
applyBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
applyBtn.BorderSizePixel = 0
applyBtn.TextColor3 = Color3.fromRGB(255,255,255)
applyBtn.Text = "🚀 طبِّق السرعة"
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 14

-- أزرار درفت + تربو
local driftBtn = Instance.new("TextButton", frame)
driftBtn.Size = UDim2.new(0, 150, 0, 32)
driftBtn.Position = UDim2.new(0, 10, 0, 110)
driftBtn.BackgroundColor3 = Color3.fromRGB(60,60,90)
driftBtn.BorderSizePixel = 0
driftBtn.TextColor3 = Color3.fromRGB(255,255,255)
driftBtn.Text = "🌀 درفت: OFF"
driftBtn.Font = Enum.Font.GothamBold
driftBtn.TextSize = 14

local turboBtn = Instance.new("TextButton", frame)
turboBtn.Size = UDim2.new(0, 150, 0, 32)
turboBtn.Position = UDim2.new(0, 180, 0, 110)
turboBtn.BackgroundColor3 = Color3.fromRGB(100,40,40)
turboBtn.BorderSizePixel = 0
turboBtn.TextColor3 = Color3.fromRGB(255,255,255)
turboBtn.Text = "🔥 تربو: OFF"
turboBtn.Font = Enum.Font.GothamBold
turboBtn.TextSize = 14

-- تبديل تشغيل السكربت (يبقى شغال حتى لو الواجهة مقفولة)
local masterBtn = Instance.new("TextButton", frame)
masterBtn.Size = UDim2.new(0, 320, 0, 30)
masterBtn.Position = UDim2.new(0, 10, 0, 150)
masterBtn.BackgroundColor3 = Color3.fromRGB(50,120,60)
masterBtn.BorderSizePixel = 0
masterBtn.TextColor3 = Color3.fromRGB(255,255,255)
masterBtn.Text = "✅ السكربت شغال (اضغط للإيقاف)"
masterBtn.Font = Enum.Font.GothamBold
masterBtn.TextSize = 14

-- حالة تحت العنوان
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 22)
status.Position = UDim2.new(0, 10, 0, 186)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamSemibold
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = Color3.fromRGB(220,220,220)
status.Text = "جاهز - اركب عربية وابدأ"

-- تعليمات
local hint = Instance.new("TextLabel", frame)
hint.Size = UDim2.new(1, -20, 0, 20)
hint.Position = UDim2.new(0, 10, 0, 208)
hint.BackgroundTransparency = 1
hint.Font = Enum.Font.Gotham
hint.TextSize = 12
hint.TextColor3 = Color3.fromRGB(200,200,200)
hint.Text = "P: إظهار/إخفاء | Shift: تربو لحظي"

-- وسم/حقوق أسفل الشاشة (RGB)
local wm = Instance.new("TextLabel", gui)
wm.Size = UDim2.new(0, 300, 0, 30)
wm.Position = UDim2.new(0.02, 0, 1, -42)
wm.BackgroundTransparency = 1
wm.Font = Enum.Font.GothamBold
wm.Text = "حكومه بيمسي 😁🍷"
wm.TextSize = 20
wm.TextColor3 = Color3.new(1,1,1)
task.spawn(function()
    local h = 0
    while gui.Parent do
        h = (h + 0.01) % 1
        wm.TextColor3 = Color3.fromHSV(h, 1, 1)
        task.wait(0.06)
    end
end)

--== تحكم الواجهة ==--
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    -- مهم: السكربت يفضل Enabled حسب State.Enabled (مش حسب الواجهة)
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.P then
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        State.Turbo = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        State.Turbo = false
    end
end)

applyBtn.MouseButton1Click:Connect(function()
    local n = tonumber(speedBox.Text)
    if n and n > 0 then
        CFG.Speed = math.clamp(n, 1, CFG.MaxLimit)
        status.Text = "تم ضبط السرعة على "..CFG.Speed
    else
        speedBox.Text = tostring(CFG.Speed)
    end
end)

driftBtn.MouseButton1Click:Connect(function()
    State.Drift = not State.Drift
    driftBtn.Text = State.Drift and "🌀 درفت: ON" or "🌀 درفت: OFF"
    setDrift(State.Drift)
end)

turboBtn.MouseButton1Click:Connect(function()
    State.Turbo = not State.Turbo
    turboBtn.Text = State.Turbo and "🔥 تربو: ON" or "🔥 تربو: OFF"
end)

masterBtn.MouseButton1Click:Connect(function()
    State.Enabled = not State.Enabled
    if State.Enabled then
        masterBtn.Text = "✅ السكربت شغال (اضغط للإيقاف)"
        masterBtn.BackgroundColor3 = Color3.fromRGB(50,120,60)
        status.Text = "تشغيل: ON"
    else
        masterBtn.Text = "⛔ السكربت متوقف (اضغط للتشغيل)"
        masterBtn.BackgroundColor3 = Color3.fromRGB(120,60,60)
        status.Text = "تشغيل: OFF"
    end
end)

--== اللوب الفعلي (خفيف) ==--
local lastAppliedMax = 0
RS.Heartbeat:Connect(function()
    if not State.Enabled then return end

    -- تتبع العربية الحالية (بدون بحث تقيل)
    local seat = getSeat()
    if seat ~= State.Seat then
        State.Seat = seat
        State.Car  = getCarModel(seat)
        State.Root = getCarRoot(seat)
        lastAppliedMax = 0
        if State.Drift then setDrift(true) end
    end

    local root = State.Root
    if not root or not seat or seat.ClassName ~= "VehicleSeat" then return end

    -- اضبط MaxSpeed لو اتغير فقط
    local target = math.clamp(CFG.Speed * (State.Turbo and CFG.TurboMult or 1), 1, CFG.MaxLimit)
    if lastAppliedMax ~= target then
        seat.MaxSpeed = target
        lastAppliedMax = target
    end

    -- دفع السرعة وقت الضغط قدّام/وراء
    local thr = seat.Throttle -- -1 .. 1
    if thr ~= 0 then
        local forward = root.CFrame.LookVector * (thr > 0 and 1 or -1)
        local cur = root.AssemblyLinearVelocity
        local desired = forward * target
        -- حافظ على الـ Y عشان المطبات
        root.AssemblyLinearVelocity = Vector3.new(desired.X, cur.Y, desired.Z)
    end
end)

print("✅ شغّال — حقوق العم حكومه 😁🍷")
