--[[
  حقوق العم حكومه 😁🍷
  نسخة كاملة – GUI فخمة + صورة + RGB + سرعة موزونة + تربو تدريجي + درفت متوازن + وسم سفلي
  مفاتيح سريعة:
    • F4   = فتح/قفل الواجهة
    • RightShift = تبديل تشغيل/إيقاف السكربت كله (يبقي الوسم شغال)
  ملاحظات:
    • 100 = سرعة متوازنة (مش مبالغ فيها)
    • السكربت خفيف: التحديث كل 0.05s تقريبًا ومفيش عمليات تقيلة كل فريم
--]]

--== Services ==--
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local LP      = Players.LocalPlayer

--== Config ==--
local CFG = {
    DefaultSpeed   = 100,     -- السرعة الافتراضية (قيمة إدخال المستخدم)
    MaxSpeedInput  = 2000,    -- أقصى رقم مسموح للمستخدم
    NitroMult      = 1.6,     -- مضاعف التربو (قوة البوست)
    NitroRise      = 0.10,    -- سرعة زيادة التربو التدريجية
    NitroFall      = 0.08,    -- سرعة هبوط التربو التدريجية
    DriftFriction  = 0.35,    -- احتكاك العجل أثناء الدرفت (أقل = تزحلق أكتر)
    UpdateRate     = 0.05,    -- معدل التحديث (ثانية)
    ImageURL       = "https://cdn.discordapp.com/attachments/1409312288996986950/1411236683856478289/406130d543e87236c27d8ace0d0533c8.jpg",
}

-- تحويل إدخال السرعة لقيمة MaxSpeed/TargetVelocity متوازنة:
-- 100 → ≈ 140   | 200 → ≈ 200 | 500 → ≈ 315 | 1000 → ≈ 450
local function mapSpeed(userVal)
    userVal = math.clamp(tonumber(userVal) or CFG.DefaultSpeed, 1, CFG.MaxSpeedInput)
    return 40 + 10 * math.sqrt(userVal)
end

--== State ==--
local STATE = {
    Enabled      = true,       -- تشغيل/إيقاف السكربت (التحكم)
    UIVisible    = true,       -- ظهور الواجهة
    CarModel     = nil,
    Seat         = nil,
    Root         = nil,
    BaseMaxSpeed = nil,        -- حفظ السرعة الأصلية لو موجودة
    CurrentMS    = mapSpeed(CFG.DefaultSpeed),
    InputValue   = CFG.DefaultSpeed,
    NitroOn      = false,
    NitroLevel   = 0.0,        -- 0..(NitroMult-1)
    DriftOn      = false,
}

--== Utils: التقاط العربية والروت ==--
local function getSeat()
    local ch = LP.Character
    if not ch then return nil end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local seat = hum.SeatPart
    if seat and seat:IsA("BasePart") then return seat end
    return nil
end

local function getRootFromSeat(seat)
    if not seat then return nil end
    if seat.AssemblyRootPart then return seat.AssemblyRootPart end
    local mdl = seat:FindFirstAncestorOfClass("Model")
    if mdl then
        if mdl.PrimaryPart then return mdl.PrimaryPart end
        -- fallback: اقرب جزء متصل
        return seat
    end
    return seat
end

--== Drift: تعديل خصائص أجزاء العجلات فقط ==--
local savedProps = {}
local function setDrift(on)
    if not STATE.CarModel then return end
    for _, p in ipairs(STATE.CarModel:GetDescendants()) do
        if p:IsA("BasePart") then
            local n = (p.Name or ""):lower()
            local looksWheel = n:find("wheel") or n:find("tire") or p.Shape == Enum.PartType.Cylinder
            if looksWheel then
                if on then
                    if savedProps[p] == nil then savedProps[p] = p.CustomPhysicalProperties end
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

--== GUI ==--
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("HKOMH_GUI") then CoreGui.HKOMH_GUI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "HKOMH_GUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- إطار رئيسي
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 430)
frame.Position = UDim2.new(0.32, 0, 0.22, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

-- صورة
local img = Instance.new("ImageLabel")
img.Size = UDim2.new(1, 0, 0, 150)
img.BackgroundTransparency = 1
img.Image = CFG.ImageURL
img.Parent = frame

-- عنوان RGB
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -10, 0, 40)
title.Position = UDim2.new(0, 5, 0, 156)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Text = "منوّر سكربت العم حكومه 😁🍷"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

task.spawn(function()
    local h=0
    while gui.Parent do
        h = (h + 0.015) % 1
        title.TextColor3 = Color3.fromHSV(h, 1, 1)
        task.wait(0.03)
    end
end)

-- زر تشغيل/إيقاف السكربت (يبقي الواجهة)
local masterBtn = Instance.new("TextButton")
masterBtn.Size = UDim2.new(0, 110, 0, 30)
masterBtn.Position = UDim2.new(0.04, 0, 0, 200)
masterBtn.Text = "تشغيل ✅"
masterBtn.Font = Enum.Font.GothamBold
masterBtn.TextSize = 14
masterBtn.TextColor3 = Color3.fromRGB(255,255,255)
masterBtn.BackgroundColor3 = Color3.fromRGB(40,100,40)
Instance.new("UICorner", masterBtn).CornerRadius = UDim.new(0,8)
masterBtn.Parent = frame

-- زر إخفاء الواجهة
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 80, 0, 30)
hideBtn.Position = UDim2.new(0.7, 0, 0, 200)
hideBtn.Text = "إخفاء"
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 14
hideBtn.TextColor3 = Color3.fromRGB(255,255,255)
hideBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0,8)
hideBtn.Parent = frame

-- خانة السرعة
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 210, 0, 40)
speedBox.Position = UDim2.new(0.05, 0, 0, 245)
speedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.Text = tostring(CFG.DefaultSpeed)
speedBox.PlaceholderText = "اكتب السرعة (1..2000)"
speedBox.ClearTextOnFocus = false
speedBox.Font = Enum.Font.GothamSemibold
speedBox.TextSize = 16
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)
speedBox.Parent = frame

-- زر تطبيق السرعة
local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(0, 110, 0, 40)
applyBtn.Position = UDim2.new(0.68, 0, 0, 245)
applyBtn.Text = "🚀 تطبيق"
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 16
applyBtn.TextColor3 = Color3.fromRGB(255,255,255)
applyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 8)
applyBtn.Parent = frame

-- أزرار درفت/تربو/إيقاف السرعة
local driftBtn = Instance.new("TextButton")
driftBtn.Size = UDim2.new(0, 160, 0, 36)
driftBtn.Position = UDim2.new(0.05, 0, 0, 300)
driftBtn.Text = "🌀 درفت: OFF"
driftBtn.Font = Enum.Font.GothamBold
driftBtn.TextSize = 14
driftBtn.TextColor3 = Color3.fromRGB(255,255,255)
driftBtn.BackgroundColor3 = Color3.fromRGB(60,60,90)
Instance.new("UICorner", driftBtn).CornerRadius = UDim.new(0,8)
driftBtn.Parent = frame

local nitroBtn = Instance.new("TextButton")
nitroBtn.Size = UDim2.new(0, 160, 0, 36)
nitroBtn.Position = UDim2.new(0.52, 0, 0, 300)
nitroBtn.Text = "🔥 نيترو: OFF"
nitroBtn.Font = Enum.Font.GothamBold
nitroBtn.TextSize = 14
nitroBtn.TextColor3 = Color3.fromRGB(255,255,255)
nitroBtn.BackgroundColor3 = Color3.fromRGB(100,40,40)
Instance.new("UICorner", nitroBtn).CornerRadius = UDim.new(0,8)
nitroBtn.Parent = frame

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0, 320, 0, 36)
stopBtn.Position = UDim2.new(0.055, 0, 0, 350)
stopBtn.Text = "⛔ إيقاف السرعة (رجوع للطبيعي)"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
stopBtn.BackgroundColor3 = Color3.fromRGB(90,60,60)
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0,8)
stopBtn.Parent = frame

-- حالة/ملاحظات
local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, -20, 0, 22)
status.Position = UDim2.new(0, 10, 0, 395)
status.Font = Enum.Font.GothamSemibold
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextColor3 = Color3.fromRGB(220,220,220)
status.Text = "جاهز: اكتب سرعة واضغط تطبيق. F4 لفتح/قفل الواجهة."
status.Parent = frame

-- وسم RGB سفلي
local watermark = Instance.new("TextLabel")
watermark.Size = UDim2.new(0, 270, 0, 24)
watermark.Position = UDim2.new(0, 10, 1, -30)
watermark.BackgroundTransparency = 1
watermark.Font = Enum.Font.GothamBold
watermark.TextSize = 16
watermark.Text = "حكومه بيمسي 😁🍷"
watermark.TextXAlignment = Enum.TextXAlignment.Left
watermark.Parent = gui

task.spawn(function()
    local h=0
    while gui.Parent do
        h = (h + 0.012) % 1
        watermark.TextColor3 = Color3.fromHSV(h,1,1)
        task.wait(0.03)
    end
end)

-- تبديل يمين/شمال للوسم بالضغط عليه
watermark.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        if watermark.Position.X.Scale < 0.5 then
            watermark.Position = UDim2.new(1, -280, 1, -30)
            watermark.TextXAlignment = Enum.TextXAlignment.Right
        else
            watermark.Position = UDim2.new(0, 10, 1, -30)
            watermark.TextXAlignment = Enum.TextXAlignment.Left
        end
    end
end)

-- مفاتيح سريعة
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    -- فتح/قفل الواجهة
    if i.KeyCode == Enum.KeyCode.F4 then
        STATE.UIVisible = not STATE.UIVisible
        frame.Visible = STATE.UIVisible
    end
    -- تشغيل/إيقاف السكربت كله
    if i.KeyCode == Enum.KeyCode.RightShift then
        STATE.Enabled = not STATE.Enabled
        masterBtn.Text = STATE.Enabled and "تشغيل ✅" or "إيقاف ❌"
        masterBtn.BackgroundColor3 = STATE.Enabled and Color3.fromRGB(40,100,40) or Color3.fromRGB(120,60,60)
        status.Text = STATE.Enabled and "التحكم مفعل." or "التحكم متوقف (الواجهة والوسم فقط)."
        -- عند الإيقاف نرجّع أي تغييرات (درفت/ماكس سبيد)
        if not STATE.Enabled then
            if STATE.DriftOn then setDrift(false) end
            STATE.DriftOn = false
            nitroBtn.Text = "🔥 نيترو: OFF"
            driftBtn.Text = "🌀 درفت: OFF"
            STATE.NitroOn = false
            -- رجوع MaxSpeed الأصلي لو موجود
            if STATE.Seat and STATE.BaseMaxSpeed then
                pcall(function() STATE.Seat.MaxSpeed = STATE.BaseMaxSpeed end)
            end
        end
    end
end)

hideBtn.MouseButton1Click:Connect(function()
    STATE.UIVisible = not STATE.UIVisible
    frame.Visible = STATE.UIVisible
end)

-- أزرار الواجهة
applyBtn.MouseButton1Click:Connect(function()
    local n = tonumber(speedBox.Text)
    if not n then status.Text = "⚠️ اكتب رقم صحيح"; return end
    STATE.InputValue = math.clamp(n, 1, CFG.MaxSpeedInput)
    STATE.CurrentMS = mapSpeed(STATE.InputValue)
    status.Text = ("تم ضبط السرعة (موزونة) على: %d"):format(STATE.InputValue)
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

stopBtn.MouseButton1Click:Connect(function()
    STATE.InputValue = CFG.DefaultSpeed
    STATE.CurrentMS = mapSpeed(CFG.DefaultSpeed)
    STATE.NitroOn = false
    nitroBtn.Text = "🔥 نيترو: OFF"
    if STATE.Seat and STATE.BaseMaxSpeed then
        pcall(function() STATE.Seat.MaxSpeed = STATE.BaseMaxSpeed end)
    end
    status.Text = "تم إيقاف السرعة – رجوع للإعدادات الأصلية."
end)

--== اللوب الخفيف للتحكم ==--
local accumulator = 0
RS.Heartbeat:Connect(function(dt)
    accumulator += dt
    if accumulator < CFG.UpdateRate then return end
    local steps = math.floor(accumulator / CFG.UpdateRate)
    accumulator -= steps * CFG.UpdateRate

    while steps > 0 do
        steps -= 1

        -- تحديث العربية اللي راكبها
        local seat = getSeat()
        if seat ~= STATE.Seat then
            STATE.Seat = seat
            STATE.CarModel = seat and seat:FindFirstAncestorOfClass("Model") or nil
            STATE.Root = seat and getRootFromSeat(seat) or nil
            STATE.BaseMaxSpeed = nil
            if STATE.Seat and STATE.Seat.ClassName == "VehicleSeat" then
                -- حفظ السرعة الأصلية أول مرة
                pcall(function() STATE.BaseMaxSpeed = STATE.Seat.MaxSpeed end)
            end
            if STATE.DriftOn then setDrift(true) end
        end

        if not STATE.Enabled then
            continue
        end

        if STATE.Root then
            -- حساب هدف السرعة مع النيترو التدريجي
            local baseMS = STATE.CurrentMS
            local targetNitro = STATE.NitroOn and (CFG.NitroMult - 1) or 0
            local rate = STATE.NitroOn and CFG.NitroRise or CFG.NitroFall
            STATE.NitroLevel = STATE.NitroLevel + (targetNitro - STATE.NitroLevel) * rate
            local targetMS = baseMS * (1 + STATE.NitroLevel)

            -- لو عربية VehicleSeat، استخدم MaxSpeed
            if STATE.Seat and STATE.Seat.ClassName == "VehicleSeat" then
                if math.abs((STATE.Seat.MaxSpeed or 0) - targetMS) > 1 then
                    pcall(function() STATE.Seat.MaxSpeed = targetMS end)
                end
            else
                -- fallback: دفع ناعم للسرعة الأمامية (لو النظام مختلف)
                local v = STATE.Root.AssemblyLinearVelocity
                local f = STATE.Root.CFrame.LookVector
                local desired = f * targetMS
                local newV = v:Lerp(Vector3.new(desired.X, v.Y, desired.Z), 0.25)
                STATE.Root.AssemblyLinearVelocity = newV
            end
        end
    end
end)

print("✅ شغّال – نسخة كاملة/فخمة وخفيفة لاج – حقوق العم حكومه 😁🍷")
