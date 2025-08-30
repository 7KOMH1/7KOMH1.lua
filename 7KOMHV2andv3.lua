-- حقوق العم حكومه 😁🍷
-- نسخة فخمة/تقيلة: سرعة موزونة + نيترو تدريجي + درفت متوازن + واجهة وصورة + وسم RGB سفلي

--== Services ==--
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

--== Settings ==--
local CFG = {
    SpeedInput = 100,       -- السرعة الافتراضية اللي هتطبق (موزونة)
    MaxLimit = 2000,        -- الحد الأقصى المدخل
    NitroMult = 1.6,        -- قوة النيترو (تضاعف سلس)
    NitroRise = 0.12,       -- سرعة الارتفاع التدريجي للنيترو
    NitroFall = 0.10,       -- سرعة الهبوط بعد إطفاء النيترو
    DriftFriction = 0.35,   -- احتكاك وقت الدرفت (قليل = تزحلق أكتر)
    UpdateRate = 0.05,      -- تردد التحديث (كل 0.05 ثانية ≈ 20Hz)
    ImageURL = "https://cdn.discordapp.com/attachments/1409312288996986950/1411236683856478289/406130d543e87236c27d8ace0d0533c8.jpg",
}

-- ماب السرعة: نخلي 100 = سرعة حلوة؛ ونعمل منحنى هادي (جذر تربيعي) عشان ما تتفلتش
local function mapSpeed(userVal)
    userVal = math.clamp(tonumber(userVal) or 100, 1, CFG.MaxLimit)
    -- نحولها لنطاق عملي MaxSpeed (studs/s) ~ من 40 لحد ~ 450
    -- 100 → ~140 ، 200 → ~200 ، 500 → ~315 ، 1000 → ~450
    local base = 40
    local scaled = base + 10 * math.sqrt(userVal)
    return scaled
end

--== State ==--
local STATE = {
    Seat = nil,
    Root = nil,
    Car = nil,
    Nitro = 0.0,       -- 0..(NitroMult-1) داخلي
    NitroOn = false,
    DriftOn = false,
    CurrentMS = mapSpeed(CFG.SpeedInput),
}

--== Helpers ==--
local function getSeat()
    local ch = LP.Character
    if not ch then return nil end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local seat = hum.SeatPart
    if seat and seat:IsA("BasePart") then return seat end
    return nil
end

local function getCarRoot(seat)
    if not seat then return nil end
    if seat.AssemblyRootPart then return seat.AssemblyRootPart end
    local model = seat:FindFirstAncestorOfClass("Model")
    if model and model.PrimaryPart then return model.PrimaryPart end
    return seat
end

local savedProps = {}
local function setDrift(on)
    if not STATE.Car then return end
    for _,p in ipairs(STATE.Car:GetDescendants()) do
        if p:IsA("BasePart") then
            local n = (p.Name or ""):lower()
            local looksWheel = n:find("wheel") or n:find("tire") or p.Shape == Enum.PartType.Cylinder
            if looksWheel then
                if on then
                    if not savedProps[p] then savedProps[p] = p.CustomPhysicalProperties end
                    p.CustomPhysicalProperties = PhysicalProperties.new(0.8, CFG.DriftFriction, 0.3, 1, 1)
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

--== GUI (خفيف وفخم) ==--
if CoreGui:FindFirstChild("HKOMH_GUI") then CoreGui.HKOMH_GUI:Destroy() end
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "HKOMH_GUI"
gui.ResetOnSpawn = false

-- إطار رئيسي
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 360, 0, 420)
frame.Position = UDim2.new(0.32, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- صورة علوية
local img = Instance.new("ImageLabel", frame)
img.Size = UDim2.new(1, 0, 0, 150)
img.BackgroundTransparency = 1
img.Image = CFG.ImageURL

-- عنوان RGB
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -10, 0, 38)
title.Position = UDim2.new(0, 5, 0, 156)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "منور سكربت العم حكومه 😁🍷"
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255,255,255)

task.spawn(function()
    local h = 0
    while gui.Parent do
        h = (h + 0.01) % 1
        title.TextColor3 = Color3.fromHSV(h, 1, 1)
        task.wait(0.03)
    end
end)

-- صندوق سرعة + زر تطبيق
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0, 200, 0, 40)
speedBox.Position = UDim2.new(0.1, 0, 0, 205)
speedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.Font = Enum.Font.GothamSemibold
speedBox.TextSize = 16
speedBox.PlaceholderText = "اكتب السرعة (1..2000)"
speedBox.ClearTextOnFocus = false
speedBox.Text = tostring(CFG.SpeedInput)
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

local applyBtn = Instance.new("TextButton", frame)
applyBtn.Size = UDim2.new(0, 120, 0, 40)
applyBtn.Position = UDim2.new(0.63, 0, 0, 205)
applyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
applyBtn.TextColor3 = Color3.fromRGB(255,255,255)
applyBtn.Text = "🚀 تطبيق"
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 16
Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 8)

-- أزرار درفت/نيترو
local driftBtn = Instance.new("TextButton", frame)
driftBtn.Size = UDim2.new(0, 160, 0, 36)
driftBtn.Position = UDim2.new(0.07, 0, 0, 260)
driftBtn.BackgroundColor3 = Color3.fromRGB(60,60,90)
driftBtn.TextColor3 = Color3.fromRGB(255,255,255)
driftBtn.Text = "🌀 درفت: OFF"
driftBtn.Font = Enum.Font.GothamBold
driftBtn.TextSize = 14
Instance.new("UICorner", driftBtn).CornerRadius = UDim.new(0, 8)

local nitroBtn = Instance.new("TextButton", frame)
nitroBtn.Size = UDim2.new(0, 160, 0, 36)
nitroBtn.Position = UDim2.new(0.55, 0, 0, 260)
nitroBtn.BackgroundColor3 = Color3.fromRGB(100,40,40)
nitroBtn.TextColor3 = Color3.fromRGB(255,255,255)
nitroBtn.Text = "🔥 نيترو: OFF"
nitroBtn.Font = Enum.Font.GothamBold
nitroBtn.TextSize = 14
Instance.new("UICorner", nitroBtn).CornerRadius = UDim.new(0, 8)

-- حالة وHints
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 22)
status.Position = UDim2.new(0, 10, 0, 305)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamSemibold
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = Color3.fromRGB(220,220,220)
status.Text = "جاهز: اكتب سرعة واضغط تطبيق. F4 لفتح/قفل الواجهة."

-- زر قفل (يبقي السكربت شغال)
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 80, 0, 30)
closeBtn.Position = UDim2.new(0.7, 0, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Text = "إخفاء"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- وسم سفلي RGB (يمين/شمال)
local watermark = Instance.new("TextLabel", gui)
watermark.Size = UDim2.new(0, 260, 0, 24)
watermark.BackgroundTransparency = 1
watermark.Font = Enum.Font.GothamBold
watermark.TextSize = 16
watermark.Text = "حكومه بيمسي 😁🍷"
watermark.TextXAlignment = Enum.TextXAlignment.Left
watermark.Position = UDim2.new(0, 10, 1, -30)  -- يسار تحت

task.spawn(function()
    local h = 0
    while gui.Parent do
        h = (h + 0.015) % 1
        watermark.TextColor3 = Color3.fromHSV(h, 1, 1)
        task.wait(0.03)
    end
end)

-- زر تبديل يمين/شمال للوسم بالضغط عليه
watermark.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        if watermark.Position.X.Scale < 0.5 then
            watermark.Position = UDim2.new(1, -270, 1, -30) -- يمين تحت
            watermark.TextXAlignment = Enum.TextXAlignment.Right
        else
            watermark.Position = UDim2.new(0, 10, 1, -30) -- يسار تحت
            watermark.TextXAlignment = Enum.TextXAlignment.Left
        end
    end
end)

-- أحداث GUI
applyBtn.MouseButton1Click:Connect(function()
    local n = tonumber(speedBox.Text)
    if n then
        CFG.SpeedInput = math.clamp(n, 1, CFG.MaxLimit)
        STATE.CurrentMS = mapSpeed(CFG.SpeedInput)
        status.Text = ("تم ضبط السرعة (موزونة) على: %d"):format(CFG.SpeedInput)
    else
        status.Text = "⚠️ اكتب رقم صحيح"
    end
end)

driftBtn.MouseButton1Click:Connect(function()
    STATE.DriftOn = not STATE.DriftOn
    driftBtn.Text = STATE.DriftOn and "🌀 درفت: ON" or "🌀 درفت: OFF"
    setDrift(STATE.DriftOn)
end)

nitroBtn.MouseButton1Click:Connect(function()
    STATE.NitroOn = not STATE.NitroOn
    nitroBtn.Text = STATE.NitroOn and "🔥 نيترو: ON" or "🔥 نيترو: OFF"
end)

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- مفتاح فتح/قفل GUI (F4)
UIS.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        frame.Visible = not frame.Visible
    end
end)

--== التحكم في العربية (خفيف لاج) ==--
local acc = 0 -- تراكم ناعم لتأثير النيترو
RS.Heartbeat:Connect(function(dt)
    -- تحديث مرن على فواصل زمنية لتقليل اللاج
    acc = acc + dt
    if acc < CFG.UpdateRate then return end
    acc = 0

    local seat = getSeat()
    if seat ~= STATE.Seat then
        STATE.Seat = seat
        STATE.Car = seat and seat:FindFirstAncestorOfClass("Model") or nil
        STATE.Root = seat and getCarRoot(seat) or nil
        if STATE.DriftOn then setDrift(true) end
    end
    if not STATE.Root then return end

    -- احسب السرعة المستهدفة
    local baseMS = STATE.CurrentMS
    -- نيترو تدريجي (يرتفع/يهبط بسلاسة)
    local nitroTarget = STATE.NitroOn and (CFG.NitroMult - 1) or 0
    STATE.Nitro = STATE.Nitro + (nitroTarget - STATE.Nitro) * (STATE.NitroOn and CFG.NitroRise or CFG.NitroFall)
    local targetMS = baseMS * (1 + STATE.Nitro)

    -- لو VehicleSeat: استخدم MaxSpeed الموزون
    if STATE.Seat and STATE.Seat.ClassName == "VehicleSeat" then
        if math.abs((STATE.Seat.MaxSpeed or 0) - targetMS) > 1 then
            STATE.Seat.MaxSpeed = targetMS
        end
        return
    end

    -- fallback: دفع ناعم لسرعة الجسم الأساسية (لو الماب قافل/سيستم مختلف)
    local v = STATE.Root.AssemblyLinearVelocity
    local forward = STATE.Root.CFrame.LookVector
    -- نسعى تدريجيًا للسرعة المطلوبة (Lerp)
    local desired = forward * targetMS
    local lerp = 0.25 -- سلاسة
    local newV = v:Lerp(Vector3.new(desired.X, v.Y, desired.Z), lerp)
    STATE.Root.AssemblyLinearVelocity = newV
end)

print("✅ شغّال – نسخة موزونة/فخمة – حقوق العم حكومه 😁🍷")
