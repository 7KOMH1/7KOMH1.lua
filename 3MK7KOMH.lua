-- حقوق العم حكومه 😁🍷
-- سرعة + درفت + تربو + يعمل حتى في مابات فيها حد سرعة (زي البيوت)

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- إعدادات
local CFG = {
    Speed = 200,      -- السرعة الافتراضية
    MaxLimit = 2000,  -- الحد الأقصى
    TurboMult = 2.0,  -- قوة التربو (×2)
    DriftFriction = 0.2, -- احتكاك للعجلات وقت الدرفت
    ImageURL = "https://cdn.discordapp.com/attachments/1409312288996986950/1411236683856478289/406130d543e87236c27d8ace0d0533c8.jpg"
}

local State = {
    Enabled = true,
    Turbo = false,
    Drift = false,
    CarModel = nil,
    Root = nil,
    Seat = nil
}

-- دوال مساعدة
local function getSeat()
    local char = LP.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    if hum.SeatPart and hum.SeatPart:IsA("BasePart") then
        return hum.SeatPart
    end
    -- بحث احتياطي
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Occupant == hum then
            return v
        end
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
    if not seat then return nil end
    return seat:FindFirstAncestorOfClass("Model")
end

-- تعديل احتكاك العجلات وقت الدرفت (مرة عند التفعيل/الإلغاء مش كل فريم)
local savedProps = {}
local function setDrift(on)
    if not State.CarModel then return end
    for _,p in ipairs(State.CarModel:GetDescendants()) do
        if p:IsA("BasePart") then
            local n = (p.Name or ""):lower()
            local looksLikeWheel = n:find("wheel") or n:find("tire") or p.Shape == Enum.PartType.Cylinder
            if looksLikeWheel then
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

-- واجهة GUI
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- إطار رئيسي
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 240)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
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

-- RGB بسيط وخفيف (بدون لاج تقيل)
task.spawn(function()
    local h = 0
    while gui.Parent do
        h = (h + 0.008) % 1
        title.TextColor3 = Color3.fromHSV(h, 1, 1)
        task.wait(0.03)
    end
end)

-- صورة
local img = Instance.new("ImageLabel", frame)
img.Size = UDim2.new(0, 90, 0, 90)
img.Position = UDim2.new(1, -100, 0, 40)
img.BackgroundTransparency = 1
img.Image = CFG.ImageURL  -- لو ما ظهرتش، ده من الماب/السندبوكس. مش هيوقف السكربت.

-- لاصق الحقوق
local wm = Instance.new("TextLabel", gui)
wm.Size = UDim2.new(0, 220, 0, 22)
wm.Position = UDim2.new(1, -230, 1, -28)
wm.BackgroundTransparency = 1
wm.Text = "حقوق العم حكومه 😁🍷"
wm.Font = Enum.Font.Gotham; wm.TextSize = 16
wm.TextColor3 = Color3.fromRGB(255,255,255)

-- عناصر التحكم
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0, 180, 0, 34)
speedBox.Position = UDim2.new(0, 10, 0, 60)
speedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedBox.PlaceholderText = "اكتب السرعة (حدها 2000)"
speedBox.Text = tostring(CFG.Speed)
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.Font = Enum.Font.GothamSemibold
speedBox.TextSize = 16
speedBox.ClearTextOnFocus = false

local applyBtn = Instance.new("TextButton", frame)
applyBtn.Size = UDim2.new(0, 110, 0, 34)
applyBtn.Position = UDim2.new(0, 200, 0, 60)
applyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
applyBtn.TextColor3 = Color3.fromRGB(255,255,255)
applyBtn.Text = "🚀 طبِّق السرعة"
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 14

local driftBtn = Instance.new("TextButton", frame)
driftBtn.Size = UDim2.new(0, 145, 0, 32)
driftBtn.Position = UDim2.new(0, 10, 0, 110)
driftBtn.BackgroundColor3 = Color3.fromRGB(60,60,90)
driftBtn.TextColor3 = Color3.fromRGB(255,255,255)
driftBtn.Text = "🌀 درفت: OFF"
driftBtn.Font = Enum.Font.GothamBold
driftBtn.TextSize = 14

local turboBtn = Instance.new("TextButton", frame)
turboBtn.Size = UDim2.new(0, 145, 0, 32)
turboBtn.Position = UDim2.new(0, 165, 0, 110)
turboBtn.BackgroundColor3 = Color3.fromRGB(100,40,40)
turboBtn.TextColor3 = Color3.fromRGB(255,255,255)
turboBtn.Text = "🔥 تربو: OFF"
turboBtn.Font = Enum.Font.GothamBold
turboBtn.TextSize = 14

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 22)
status.Position = UDim2.new(0, 10, 0, 150)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamSemibold
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = "جاهز - منور سكربت العم حكومه 😁🍷"
status.TextColor3 = Color3.fromRGB(220,220,220)

local hint = Instance.new("TextLabel", frame)
hint.Size = UDim2.new(1, -20, 0, 20)
hint.Position = UDim2.new(0, 10, 0, 175)
hint.BackgroundTransparency = 1
hint.TextColor3 = Color3.fromRGB(200,200,200)
hint.Font = Enum.Font.Gotham
hint.TextSize = 12
hint.Text = "P: فتح/قفل | Shift: تربو لحظي"

-- زر إظهار/إخفاء سريع
UIS.InputBegan:Connect(function(input,gpe)
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

-- أحداث GUI
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

-- لُب التحكم: شغال على أي عربية
RS.Heartbeat:Connect(function()
    if not State.Enabled then return end

    local seat = getSeat()
    if seat ~= State.Seat then
        State.Seat = seat
        State.CarModel = getCarModel(seat)
        State.Root = getCarRoot(seat)
        -- لو الدرفت كان شغال، أعد تطبيقه على العربية الجديدة
        if State.Drift then setDrift(true) end
    end

    local root = State.Root
    if not root then return end

    -- 1) لو VehicleSeat حقيقي، عدّل MaxSpeed
    if seat and seat.ClassName == "VehicleSeat" then
        local target = CFG.Speed * (State.Turbo and CFG.TurboMult or 1)
        if seat.MaxSpeed ~= target then
            seat.MaxSpeed = target
        end
    end

    -- 2) إجبار السرعة الفعلية حتى لو اللعبة محدّدة السرعة
    -- نطبق فقط وقت ما يكون في Throttle للأمام/للخلف
    local throttleForward = 0
    if seat and seat:IsA("VehicleSeat") then
        throttleForward = seat.Throttle -- -1 .. 1
    end

    -- fallback لو العربية مش VehicleSeat: لو بتتحرك قدّام (لو فيه سرعة) نزقها لقدام برضو
    local wantPush = throttleForward ~= 0

    -- سرعة مستهدفة
    local desired = CFG.Speed * (State.Turbo and CFG.TurboMult or 1)
    desired = math.min(desired, CFG.MaxLimit)

    if wantPush then
        local forward = root.CFrame.LookVector * (throttleForward >= 0 and 1 or -1)
        local cur = root.AssemblyLinearVelocity
        local newv = forward * desired
        -- خليك محافظ على المحور الرأسي عشان المطبات
        root.AssemblyLinearVelocity = Vector3.new(newv.X, cur.Y, newv.Z)
    end
end)

print("✅ شغّال - حقوق العم حكومه 😁🍷")
