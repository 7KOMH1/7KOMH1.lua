--[[
    سكربت حماية شامل (محلي) – واجهة + تحميل + اسم فوق الراس + RGB + حماية قوية
    ملاحظة مهمة: السكربت محلي (Client) وهدفه يصد محاولات الأذى زي الفلنج/التجميد/التحكم.
    لا يوجد شيء يضمن منع الحظر (الباند) – ده مسؤولية سياسات اللعبة نفسها.
    حقوق العم حكومه 😁🍷
]]

-- // Services
local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LP   = Players.LocalPlayer
local GUIR = game:GetService("CoreGui")

-- // Config
local CFG = {
    RGBSpeed = 0.35,
    TickRate = 0.10,         -- تحديث الحماية كل 0.10 ثانية (خفيف)
    VelCap   = 150,          -- حد السرعة القصوى لجسمك (لمقاومة الفلنج)
    AngCap   = 20,           -- حد الدوران الزائد
    WalkMin  = 8,            -- الحد الأدنى للمشي (لو حد صفره)
    WalkMax  = 32,           -- الحد الأقصى الطبيعي (لو حد عمل أرقام جنونية)
    JumpMin  = 35,
    JumpMax  = 75,
    ShowloadSeconds = 15,    -- شاشة التحميل 15 ثانية
}

-- // Utilities
local function colorRGB(t)
    return Color3.fromHSV((t * CFG.RGBSpeed) % 1, 1, 1)
end

local function safeFindHumanoid()
    local ch = LP.Character
    if not ch then return nil,nil end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return nil,nil end
    return hum, hrp
end

local function clampVecMagnitude(v, m)
    local mag = v.Magnitude
    if mag > m then
        return v.Unit * m
    end
    return v
end

local function destroyForeignConstraints(char)
    for _,d in ipairs(char:GetDescendants()) do
        if d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("RopeConstraint") or d:IsA("BallSocketConstraint") or d:IsA("Motor6D") then
            -- اسيب مكونات جسمي الأصلية، واقصّي أي حاجة غريبة متضافة على HRP/الجسم وقت التفعيل
            if d.Parent and not d.Parent:IsDescendantOf(char) then
                pcall(function() d:Destroy() end)
            end
        elseif d:IsA("BodyMover") or d:IsA("VectorForce") or d:IsA("Torque") or d:IsA("LinearVelocity") or d:IsA("AngularVelocity") then
            -- أي قوة اتزرعت جوا أجزاء جسمي تتشال
            if d.Parent and d.Parent:IsDescendantOf(char) then
                pcall(function() d:Destroy() end)
            end
        end
    end
end

local function instantFix()
    local hum, hrp = safeFindHumanoid()
    if not hum or not hrp then return end

    -- فك تجميد/قيود
    hum.PlatformStand = false
    hum.Sit = false
    hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    hum:ChangeState(Enum.HumanoidStateType.Running)

    -- إعادة القيم الطبيعية (لو حد لعب فيها)
    if hum.WalkSpeed < CFG.WalkMin or hum.WalkSpeed > CFG.WalkMax then
        hum.WalkSpeed = 16
    end
    if hum.JumpPower < CFG.JumpMin or hum.JumpPower > CFG.JumpMax then
        hum.JumpPower = 50
    end
    hum.AutoRotate = true

    -- قص السرعات الشاذة
    hrp.AssemblyLinearVelocity  = clampVecMagnitude(hrp.AssemblyLinearVelocity, CFG.VelCap)
    hrp.AssemblyAngularVelocity = clampVecMagnitude(hrp.AssemblyAngularVelocity, CFG.AngCap)

    -- إزالة أي قيود/قوى غريبة
    destroyForeignConstraints(LP.Character)
end

-- // UI: Root
local screen = Instance.new("ScreenGui")
screen.Name = "HKM_PROTECT_V3"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = GUIR

-- // Loading Overlay
local loadFrame = Instance.new("Frame")
loadFrame.Size = UDim2.fromScale(1,1)
loadFrame.BackgroundColor3 = Color3.fromRGB(10,10,12)
loadFrame.Parent = screen

local loadTitle = Instance.new("TextLabel")
loadTitle.BackgroundTransparency = 1
loadTitle.AnchorPoint = Vector2.new(0.5,0.5)
loadTitle.Position = UDim2.new(0.5,0,0.38,0)
loadTitle.Size = UDim2.new(0, 600, 0, 60)
loadTitle.Font = Enum.Font.GothamBlack
loadTitle.TextScaled = true
loadTitle.Text = "سكربت حكومه للحماية 🥶💧"
loadTitle.TextColor3 = Color3.fromRGB(255,255,255)
loadTitle.Parent = loadFrame

local loadSub = Instance.new("TextLabel")
loadSub.BackgroundTransparency = 1
loadSub.AnchorPoint = Vector2.new(0.5,0.5)
loadSub.Position = UDim2.new(0.5,0,0.48,0)
loadSub.Size = UDim2.new(0, 200, 0, 40)
loadSub.Font = Enum.Font.GothamBlack
loadSub.TextScaled = true
loadSub.Text = "V3"
loadSub.TextColor3 = Color3.fromRGB(255,255,255)
loadSub.Parent = loadFrame

local barBG = Instance.new("Frame")
barBG.AnchorPoint = Vector2.new(0.5,0.5)
barBG.Position = UDim2.new(0.5,0,0.62,0)
barBG.Size = UDim2.new(0.6,0,0,14)
barBG.BackgroundColor3 = Color3.fromRGB(30,30,36)
barBG.BorderSizePixel = 0
barBG.Parent = loadFrame

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0,0,1,0)
barFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
barFill.BorderSizePixel = 0
barFill.Parent = barBG

local barText = Instance.new("TextLabel")
barText.BackgroundTransparency = 1
barText.AnchorPoint = Vector2.new(0.5,0.5)
barText.Position = UDim2.new(0.5,0,0.70,0)
barText.Size = UDim2.new(0,200,0,30)
barText.Font = Enum.Font.GothamBold
barText.TextScaled = true
barText.Text = "0%"
barText.TextColor3 = Color3.fromRGB(200,200,200)
barText.Parent = loadFrame

-- RGB animate loading texts
task.spawn(function()
    local t = 0
    while loadFrame.Parent do
        t += RS.RenderStepped:Wait()
        local c = colorRGB(t)
        loadTitle.TextColor3 = c
        loadSub.TextColor3 = c
        barFill.BackgroundColor3 = c
    end
end)

-- fake loading to 100% in CFG.ShowloadSeconds
task.spawn(function()
    local dur = CFG.ShowloadSeconds
    local start = tick()
    while true do
        local p = math.clamp((tick()-start)/dur,0,1)
        barFill.Size = UDim2.new(p,0,1,0)
        barText.Text = ("%d%%"):format(math.floor(p*100))
        if p >= 1 then break end
        task.wait(0.05)
    end
    -- fade out
    TS:Create(loadFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    for _,v in ipairs(loadFrame:GetDescendants()) do
        if v:IsA("TextLabel") then
            TS:Create(v, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
        elseif v:IsA("Frame") then
            TS:Create(v, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
        end
    end
    task.wait(0.4)
    loadFrame:Destroy()
end)

-- // Watermark (حقوق)
local wm = Instance.new("TextLabel")
wm.BackgroundTransparency = 1
wm.Position = UDim2.new(1,-230,1,-26)
wm.Size = UDim2.new(0,220,0,20)
wm.Text = "حقوق العم حكومه 😁🍷"
wm.Font = Enum.Font.GothamSemibold
wm.TextSize = 16
wm.TextColor3 = Color3.fromRGB(255,255,255)
wm.Parent = screen

task.spawn(function()
    local t = 0
    while wm.Parent do
        t += RS.RenderStepped:Wait()
        wm.TextColor3 = colorRGB(t)
    end
end)

-- // Small Toggle Button (فتح/قفل الواجهة)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 42, 0, 42)
toggleBtn.Position = UDim2.new(0, 12, 0.5, -21)
toggleBtn.BackgroundColor3 = Color3.fromRGB(28,28,32)
toggleBtn.Text = "☰"
toggleBtn.TextScaled = true
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = screen

-- RGB glow
task.spawn(function()
    local t = 0
    while toggleBtn.Parent do
        t += RS.RenderStepped:Wait()
        toggleBtn.BackgroundColor3 = colorRGB(t)
        toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    end
end)

-- // Main Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 420, 0, 300)
panel.Position = UDim2.new(0, 64, 0.5, -150)
panel.BackgroundColor3 = Color3.fromRGB(20,20,24)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Visible = false
panel.Parent = screen

local uiCorner = Instance.new("UICorner", panel)
uiCorner.CornerRadius = UDim.new(0,12)

local header = Instance.new("TextLabel")
header.BackgroundTransparency = 1
header.Size = UDim2.new(1, -12, 0, 42)
header.Position = UDim2.new(0, 12, 0, 8)
header.Font = Enum.Font.GothamBlack
header.TextSize = 22
header.Text = "لوحة حماية حكومه – V3"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.Parent = panel

task.spawn(function()
    local t=0
    while header.Parent do
        t += RS.RenderStepped:Wait()
        header.TextColor3 = colorRGB(t)
    end
end)

local line = Instance.new("Frame")
line.Size = UDim2.new(1,-24,0,1)
line.Position = UDim2.new(0,12,0,52)
line.BackgroundColor3 = Color3.fromRGB(60,60,70)
line.BorderSizePixel = 0
line.Parent = panel

-- // Controls
local function mkButton(txt, posX, posY, w, h)
    local b = Instance.new("TextButton")
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(40,40,50)
    b.AutoButtonColor = true
    b.Size = UDim2.new(0, w, 0, h)
    b.Position = UDim2.new(0, posX, 0, posY)
    b.Parent = panel
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0,8)
    task.spawn(function()
        local t=0
        while b.Parent do
            t += RS.RenderStepped:Wait()
            b.BackgroundColor3 = colorRGB(t)
        end
    end)
    return b
end

-- اسم فوق الراس
local nameBox = Instance.new("TextBox")
nameBox.PlaceholderText = "اكتب اسم يظهر فوق راسك"
nameBox.ClearTextOnFocus = false
nameBox.Text = ""
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 16
nameBox.TextColor3 = Color3.fromRGB(255,255,255)
nameBox.BackgroundColor3 = Color3.fromRGB(35,35,45)
nameBox.Size = UDim2.new(0, 260, 0, 34)
nameBox.Position = UDim2.new(0, 12, 0, 70)
nameBox.Parent = panel
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,8)

local setNameBtn = mkButton("عرض الاسم", 280, 70, 128, 34)
local rgbOnBtn  = mkButton("RGB للاسم", 12, 112, 128, 34)
local rgbOffBtn = mkButton("إيقاف RGB", 148, 112, 128, 34)
local clearName = mkButton("مسح الاسم", 284, 112, 124, 34)

local protectToggle = mkButton("تفعيل الحماية", 12, 162, 180, 38)
local quickFix      = mkButton("إصلاح فوري (تلقائي)", 204, 162, 204, 38)
local closeOpen     = mkButton("قفل/فتح اللوحة (P)", 12, 210, 180, 38)

-- // Billboard (الاسم فوق الراس)
local billboard
local rgbNameOn = true
local function ensureBillboard()
    if billboard and billboard.Parent then return billboard end
    billboard = Instance.new("BillboardGui")
    billboard.Name = "HKM_NameTag"
    billboard.Size = UDim2.new(0,200,0,60)
    billboard.ExtentsOffsetWorldSpace = Vector3.new(0,2.6,0)
    billboard.AlwaysOnTop = true

    local main = Instance.new("TextLabel")
    main.Name = "Main"
    main.BackgroundTransparency = 1
    main.Size = UDim2.new(1,0,1,0)
    main.Font = Enum.Font.GothamBlack
    main.TextScaled = true
    main.Text = ""
    main.TextColor3 = Color3.fromRGB(255,255,255)
    main.Parent = billboard
    return billboard
end

local function attachBillboard(text)
    local hum, hrp = safeFindHumanoid()
    if not hum or not hrp then return end
    local bb = ensureBillboard()
    bb.Adornee = hrp
    bb.Parent = LP:WaitForChild("PlayerGui", 2) or screen
    bb.Main.Text = text or ""
end

local function removeBillboard()
    if billboard then billboard:Destroy() billboard=nil end
end

-- RGB animation للاسم
task.spawn(function()
    local t=0
    while true do
        RS.RenderStepped:Wait()
        t += 0.016
        if rgbNameOn and billboard and billboard:FindFirstChild("Main") then
            billboard.Main.TextColor3 = colorRGB(t)
        end
    end
end)

-- // Protection Core
local ProtectionOn = false
local lastTick = 0

local function protectionStep()
    local hum, hrp = safeFindHumanoid()
    if not hum or not hrp then return end

    -- تصحيح حالات غصب/تجميد/تحكم
    if hum.PlatformStand then hum.PlatformStand = false end
    if hum.Sit then hum.Sit = false end
    if hum.AutoRotate == false then hum.AutoRotate = true end

    -- تصحيح السرعات
    if hum.WalkSpeed < CFG.WalkMin or hum.WalkSpeed > CFG.WalkMax then
        hum.WalkSpeed = math.clamp(hum.WalkSpeed, CFG.WalkMin, CFG.WalkMax)
        if hum.WalkSpeed < CFG.WalkMin or hum.WalkSpeed > CFG.WalkMax then
            hum.WalkSpeed = 16
        end
    end
    if hum.JumpPower < CFG.JumpMin or hum.JumpPower > CFG.JumpMax then
        hum.JumpPower = math.clamp(hum.JumpPower, CFG.JumpMin, CFG.JumpMax)
        if hum.JumpPower < CFG.JumpMin or hum.JumpPower > CFG.JumpMax then
            hum.JumpPower = 50
        end
    end

    -- قص السرعات الشاذة (ضد الفلنج)
    hrp.AssemblyLinearVelocity  = clampVecMagnitude(hrp.AssemblyLinearVelocity,  CFG.VelCap)
    hrp.AssemblyAngularVelocity = clampVecMagnitude(hrp.AssemblyAngularVelocity, CFG.AngCap)

    -- إزالة قيود/قوى غريبة
    destroyForeignConstraints(LP.Character)
end

-- معدل خفيف
RS.Heartbeat:Connect(function(dt)
    if not ProtectionOn then return end
    lastTick += dt
    if lastTick >= CFG.TickRate then
        lastTick = 0
        protectionStep()
    end
end)

-- // Buttons logic
setNameBtn.MouseButton1Click:Connect(function()
    attachBillboard(nameBox.Text ~= "" and nameBox.Text or "سكربت حكومه للحماية 🥶💧")
end)

rgbOnBtn.MouseButton1Click:Connect(function()
    rgbNameOn = true
end)

rgbOffBtn.MouseButton1Click:Connect(function()
    rgbNameOn = false
    if billboard and billboard:FindFirstChild("Main") then
        billboard.Main.TextColor3 = Color3.fromRGB(255,255,255)
    end
end)

clearName.MouseButton1Click:Connect(function()
    removeBillboard()
end)

protectToggle.MouseButton1Click:Connect(function()
    ProtectionOn = not ProtectionOn
    protectToggle.Text = ProtectionOn and "إيقاف الحماية" or "تفعيل الحماية"
    if ProtectionOn then
        instantFix()
    end
end)

quickFix.MouseButton1Click:Connect(function()
    instantFix()
end)

toggleBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

-- مفتاح P إظهار/إخفاء اللوحة
UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.P then
        panel.Visible = not panel.Visible
    end
end)

-- // Auto instant-fix لو حصل لاج/تجميد واضح
task.spawn(function()
    while screen.Parent do
        task.wait(1.0)
        if ProtectionOn then
            local hum, hrp = safeFindHumanoid()
            if hum and hrp then
                -- مؤشرات تجميد/تثبيت
                local frozen = hum.PlatformStand or (hum.WalkSpeed <= 1 and hum.MoveDirection.Magnitude == 1) or (hrp.AssemblyLinearVelocity.Magnitude < 0.05 and hum.MoveDirection.Magnitude == 1)
                if frozen then
                    instantFix()
                end
            end
        end
    end
end)

-- // اسم تلقائي فوق الراس بعد التحميل (RGB) + عنوان V3
task.delay(CFG.ShowloadSeconds + 0.2, function()
    attachBillboard("سكربت حكومه للحماية 🥶💧\nV3")
    rgbNameOn = true
end)

print("✅ HKM_PROTECT_V3 Loaded – حقوق العم حكومه 😁🍷")
