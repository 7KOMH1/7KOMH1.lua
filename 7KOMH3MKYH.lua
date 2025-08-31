--[[
    سكربت حماية شامل (Client) – واجهة + تحميل + اسم فوق الراس + RGB + حماية وتحسينات
    تنبيه: ده سكربت محلي هدفه يحميك من أذى اللاعبين (تجميد/فلنج/تحكم). مش ضمان ضد الباند.
    حقوق: العم حكومه 😁🍷  |  GS4👑
]]

-- // Services
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInput      = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local TextService    = game:GetService("TextService")
local StarterGui     = game:GetService("StarterGui")

local LP             = Players.LocalPlayer
local CoreGui        = game:FindService("CoreGui")
local PlayerGui      = (LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui"))
local GUI_PARENT     = CoreGui or PlayerGui

-- // Config
local CFG = {
    RGBSpeed           = 0.35,
    TickRate           = 0.10,     -- تحديث الحماية كل 0.10 ثانية
    VelCap             = 150,      -- حد السرعة القصوى لمقاومة الفلنج
    AngCap             = 20,       -- حد الدوران
    WalkMin            = 8,
    WalkMax            = 32,
    JumpMin            = 35,
    JumpMax            = 75,
    ShowloadSeconds    = 15,       -- مدة شاشة التحميل
    DefaultName        = "سكربت حكومه للحماية 🥶💧\nV3",
    ToggleKey          = Enum.KeyCode.P,  -- فتح/قفل اللوحة
    Gold               = Color3.fromRGB(255,215,0),
}

-- // Helpers
local function colorRGB(t)
    return Color3.fromHSV((t * CFG.RGBSpeed) % 1, 1, 1)
end

local function safeHum()
    local ch = LP.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if hum and hrp then return hum, hrp end
end

local function clampVec(v, cap)
    local m = v.Magnitude
    if m > cap then return v.Unit * cap end
    return v
end

local function destroyWeirdStuff(char)
    if not char then return end
    for _,d in ipairs(char:GetDescendants()) do
        if d:IsA("BodyMover") or d:IsA("VectorForce") or d:IsA("Torque") or d:IsA("LinearVelocity") or d:IsA("AngularVelocity") then
            pcall(function() d:Destroy() end)
        elseif d:IsA("WeldConstraint") or d:IsA("RopeConstraint") or d:IsA("BallSocketConstraint") then
            -- امسح الحاجات اللي متزرعة على أجزاء جسمي
            pcall(function() d:Destroy() end)
        end
    end
end

local function instantFix()
    local hum, hrp = safeHum()
    if not hum or not hrp then return end

    hum.PlatformStand = false
    hum.Sit = false
    hum.AutoRotate = true
    hum:ChangeState(Enum.HumanoidStateType.Running)
    hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)

    if hum.WalkSpeed < CFG.WalkMin or hum.WalkSpeed > CFG.WalkMax then hum.WalkSpeed = 16 end
    if hum.JumpPower < CFG.JumpMin or hum.JumpPower > CFG.JumpMax then hum.JumpPower = 50 end

    hrp.AssemblyLinearVelocity  = clampVec(hrp.AssemblyLinearVelocity,  CFG.VelCap)
    hrp.AssemblyAngularVelocity = clampVec(hrp.AssemblyAngularVelocity, CFG.AngCap)

    destroyWeirdStuff(LP.Character)
end

-- // Root GUI
local screen = Instance.new("ScreenGui")
screen.Name = "HKM_PROTECT_V3"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.Parent = GUI_PARENT

-- /////// LOADING ///////
local loadRoot = Instance.new("Frame")
loadRoot.BackgroundColor3 = Color3.fromRGB(10,10,12)
loadRoot.Size = UDim2.fromScale(1,1)
loadRoot.Parent = screen

-- خلفية متحركة بتحسسك بالجلو
local bgGrad = Instance.new("UIGradient", loadRoot)
bgGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12,12,16)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18,18,24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12,12,16))
}
bgGrad.Rotation = 0

task.spawn(function()
    local t = 0
    while loadRoot.Parent do
        t += RunService.RenderStepped:Wait()
        bgGrad.Offset = Vector2.new(math.sin(t*0.25)*0.1, math.cos(t*0.25)*0.1)
    end
end)

local frameBox = Instance.new("Frame")
frameBox.AnchorPoint = Vector2.new(0.5,0.5)
frameBox.Position = UDim2.new(0.5,0,0.5,0)
frameBox.Size = UDim2.new(0, 520, 0, 240)
frameBox.BackgroundColor3 = Color3.fromRGB(20,20,24)
frameBox.Parent = loadRoot

local boxCorner = Instance.new("UICorner", frameBox)
boxCorner.CornerRadius = UDim.new(0,16)

local boxStroke = Instance.new("UIStroke", frameBox)
boxStroke.Thickness = 2
boxStroke.Color = CFG.Gold
boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- جلو ذهبي متحرك
local glow = Instance.new("ImageLabel")
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://4996891970" -- soft glow sprite عام
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(20,20,244,244)
glow.Size = UDim2.new(1.1,0,1.1,0)
glow.Position = UDim2.new(-0.05,0,-0.05,0)
glow.ImageTransparency = 0.35
glow.ImageColor3 = CFG.Gold
glow.Parent = frameBox

task.spawn(function()
    local dir = 1
    while glow.Parent do
        TweenService:Create(glow, TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {ImageTransparency = dir==1 and 0.15 or 0.35}):Play()
        dir = -dir
        task.wait(1)
    end
end)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,0,0,18)
title.Size = UDim2.new(1,0,0,54)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.Text = "سكربت حكومه للحماية 🥶💧"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frameBox

local sub = Instance.new("TextLabel")
sub.BackgroundTransparency = 1
sub.Position = UDim2.new(0,0,0,74)
sub.Size = UDim2.new(1,0,0,30)
sub.Font = Enum.Font.GothamBlack
sub.TextScaled = true
sub.Text = "V3"
sub.TextColor3 = Color3.fromRGB(255,255,255)
sub.Parent = frameBox

-- كتابة حرف-بحرف "منوّر سكربت حكومه"
local typing = Instance.new("TextLabel")
typing.BackgroundTransparency = 1
typing.Position = UDim2.new(0,0,0,110)
typing.Size = UDim2.new(1,0,0,34)
typing.Font = Enum.Font.GothamSemibold
typing.TextScaled = true
typing.TextColor3 = Color3.fromRGB(230,230,230)
typing.Text = ""
typing.Parent = frameBox

local barBG = Instance.new("Frame")
barBG.AnchorPoint = Vector2.new(0.5,0)
barBG.Position = UDim2.new(0.5,0,0,160)
barBG.Size = UDim2.new(0.8,0,0,14)
barBG.BackgroundColor3 = Color3.fromRGB(30,30,36)
barBG.Parent = frameBox
Instance.new("UICorner", barBG).CornerRadius = UDim.new(0,8)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0,0,1,0)
barFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
barFill.Parent = barBG
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0,8)

local barText = Instance.new("TextLabel")
barText.BackgroundTransparency = 1
barText.AnchorPoint = Vector2.new(0.5,0)
barText.Position = UDim2.new(0.5,0,0,182)
barText.Size = UDim2.new(0,200,0,26)
barText.Font = Enum.Font.GothamBold
barText.TextScaled = true
barText.Text = "0%"
barText.TextColor3 = Color3.fromRGB(210,210,210)
barText.Parent = frameBox

-- RGB للحاجات المهمة
task.spawn(function()
    local t = 0
    while loadRoot.Parent do
        t += RunService.RenderStepped:Wait()
        local c = colorRGB(t)
        title.TextColor3 = c
        sub.TextColor3 = c
        barFill.BackgroundColor3 = c
    end
end)

-- تأثير الكتابة
task.spawn(function()
    local txt = "منوّر سكربت حكومه"
    typing.Text = ""
    for i = 1, #txt do
        typing.Text = string.sub(txt, 1, i)
        task.wait(0.06)
    end
end)

-- زيادة التحميل لـ 100% خلال ShowloadSeconds
task.spawn(function()
    local dur = CFG.ShowloadSeconds
    local start = tick()
    while loadRoot.Parent do
        local p = math.clamp((tick()-start)/dur, 0, 1)
        barFill.Size = UDim2.new(p,0,1,0)
        barText.Text = ("%d%%"):format(math.floor(p*100))
        if p >= 1 then break end
        task.wait(0.04)
    end
    -- إخفاء اللود
    TweenService:Create(loadRoot, TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    for _,v in ipairs(loadRoot:GetDescendants()) do
        if v:IsA("TextLabel") then
            TweenService:Create(v, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
        elseif v:IsA("Frame") or v:IsA("ImageLabel") then
            TweenService:Create(v, TweenInfo.new(0.35), {BackgroundTransparency = 1, ImageTransparency = (v:IsA("ImageLabel") and 1 or v.BackgroundTransparency)}):Play()
        end
    end
    task.wait(0.4)
    loadRoot:Destroy()
end)

-- /////// WATERMARK + حقوق ///////
local wm = Instance.new("TextLabel")
wm.BackgroundTransparency = 1
wm.Position = UDim2.new(1,-250,1,-24)
wm.Size = UDim2.new(0,240,0,20)
wm.Text = "حقوق العم حكومه 😁🍷  |  GS4👑"
wm.Font = Enum.Font.GothamSemibold
wm.TextSize = 16
wm.TextColor3 = Color3.fromRGB(255,255,255)
wm.Parent = screen

task.spawn(function()
    local t=0
    while wm.Parent do
        t += RunService.RenderStepped:Wait()
        wm.TextColor3 = colorRGB(t)
    end
end)

-- /////// TOGGLE BUTTON (فتح/قفل) ///////
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,44,0,44)
toggleBtn.Position = UDim2.new(0, 12, 0.5, -22)
toggleBtn.BackgroundColor3 = Color3.fromRGB(28,28,32)
toggleBtn.Text = "☰"
toggleBtn.TextScaled = true
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = screen
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,12)

task.spawn(function()
    local t=0
    while toggleBtn.Parent do
        t += RunService.RenderStepped:Wait()
        toggleBtn.BackgroundColor3 = colorRGB(t)
    end
end)

-- /////// MAIN PANEL ///////
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 460, 0, 320)
panel.Position = UDim2.new(0, 64, 0.5, -160)
panel.BackgroundColor3 = Color3.fromRGB(20,20,24)
panel.Active = true
panel.Draggable = true
panel.Visible = false
panel.Parent = screen
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,14)

-- جلو ذهبي للوحة
local pStroke = Instance.new("UIStroke", panel)
pStroke.Thickness = 2
pStroke.Color = CFG.Gold
pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local pGlow = Instance.new("ImageLabel")
pGlow.BackgroundTransparency = 1
pGlow.Image = "rbxassetid://4996891970"
pGlow.ScaleType = Enum.ScaleType.Slice
pGlow.SliceCenter = Rect.new(20,20,244,244)
pGlow.Size = UDim2.new(1.05,0,1.05,0)
pGlow.Position = UDim2.new(-0.025,0,-0.025,0)
pGlow.ImageTransparency = 0.45
pGlow.ImageColor3 = CFG.Gold
pGlow.Parent = panel

local header = Instance.new("TextLabel")
header.BackgroundTransparency = 1
header.Position = UDim2.new(0,14,0,8)
header.Size = UDim2.new(1,-28,0,40)
header.Font = Enum.Font.GothamBlack
header.TextSize = 22
header.Text = "لوحة حماية حكومه – V3"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.Parent = panel

task.spawn(function()
    local t=0
    while header.Parent do
        t += RunService.RenderStepped:Wait()
        header.TextColor3 = colorRGB(t)
    end
end)

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1,-28,0,1)
divider.Position = UDim2.new(0,14,0,52)
divider.BackgroundColor3 = Color3.fromRGB(60,60,70)
divider.BorderSizePixel = 0
divider.Parent = panel

-- // صنع زرار سريع
local function mkBtn(txt, pos, size)
    local b = Instance.new("TextButton")
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(42,42,52)
    b.AutoButtonColor = true
    b.Size = size
    b.Position = pos
    b.Parent = panel
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0,10)
    -- RGB باكجراوند خفيف
    task.spawn(function()
        local t=0
        while b.Parent do
            t += RunService.RenderStepped:Wait()
            b.BackgroundColor3 = colorRGB(t)
        end
    end)
    return b
end

-- // إدخالات الاسم فوق الراس
local nameBox = Instance.new("TextBox")
nameBox.PlaceholderText = "اكتب اسم يظهر فوق راسك (على حسب الماب)"
nameBox.ClearTextOnFocus = false
nameBox.Text = ""
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 16
nameBox.TextColor3 = Color3.fromRGB(255,255,255)
nameBox.BackgroundColor3 = Color3.fromRGB(35,35,45)
nameBox.Size = UDim2.new(0, 280, 0, 36)
nameBox.Position = UDim2.new(0, 14, 0, 70)
nameBox.Parent = panel
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,10)

local setNameBtn  = mkBtn("عرض الاسم", UDim2.new(0, 306, 0, 70), UDim2.new(0, 140, 0, 36))
local rgbOnBtn    = mkBtn("RGB للاسم", UDim2.new(0, 14, 0, 116), UDim2.new(0, 140, 0, 36))
local rgbOffBtn   = mkBtn("إيقاف RGB", UDim2.new(0, 160, 0, 116), UDim2.new(0, 140, 0, 36))
local clearName   = mkBtn("مسح الاسم",  UDim2.new(0, 306, 0, 116), UDim2.new(0, 140, 0, 36))

local protectBtn  = mkBtn("تفعيل الحماية", UDim2.new(0, 14, 0, 168), UDim2.new(0, 200, 0, 40))
local fixBtn      = mkBtn("إصلاح فوري (تلقائي)", UDim2.new(0, 226, 0, 168), UDim2.new(0, 220, 0, 40))
local closeOpen   = mkBtn("قفل/فتح اللوحة (P)", UDim2.new(0, 14, 0, 214), UDim2.new(0, 200, 0, 40))
local killAllBtn  = mkBtn("إغلاق السكربت بالكامل", UDim2.new(0, 226, 0, 214), UDim2.new(0, 220, 0, 40))

-- إضافة توقيع صغير جوه اللوحة
local sig = Instance.new("TextLabel")
sig.BackgroundTransparency = 1
sig.AnchorPoint = Vector2.new(1,1)
sig.Position = UDim2.new(1,-12,1,-10)
sig.Size = UDim2.new(0,160,0,18)
sig.Font = Enum.Font.GothamSemibold
sig.TextSize = 14
sig.Text = "العم حكومه 😁🍷  •  GS4👑"
sig.TextColor3 = CFG.Gold
sig.Parent = panel

-- /////// BILLBOARD NAME (فوق الراس) ///////
local billboard, rgbNameOn = nil, true

local function computeBillboardSize(text)
    -- حجم ديناميك حسب طول النص + قياس الماب (باخد جسم اللاعب)
    local hum, hrp = safeHum()
    local heightScale = 1
    if hum then
        -- تقدير ارتفاع الجسم = HipHeight + BodyHeight تقريبي
        heightScale = math.clamp((hum.HipHeight or 2) / 2, 0.8, 1.4)
    end
    local result = TextService:GetTextSize(text, 36, Enum.Font.GothamBlack, Vector2.new(1000,50))
    local w = math.clamp(result.X + 40, 140, 420)
    local h = math.clamp(result.Y + 12, 36, 72)
    return UDim2.new(0, math.floor(w*heightScale), 0, math.floor(h*heightScale))
end

local function ensureBillboard()
    if billboard and billboard.Parent then return billboard end
    billboard = Instance.new("BillboardGui")
    billboard.Name = "HKM_NameTag"
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 200
    billboard.Size = UDim2.new(0, 200, 0, 60)

    local bg = Instance.new("Frame")
    bg.Name = "BG"
    bg.BackgroundColor3 = Color3.fromRGB(15,15,18)
    bg.BackgroundTransparency = 0.2
    bg.Size = UDim2.new(1,0,1,0)
    bg.Parent = billboard
    local c = Instance.new("UICorner", bg)
    c.CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke", bg)
    s.Thickness = 2
    s.Color = CFG.Gold

    local main = Instance.new("TextLabel")
    main.Name = "Main"
    main.BackgroundTransparency = 1
    main.Size = UDim2.new(1,0,1,0)
    main.Font = Enum.Font.GothamBlack
    main.TextScaled = true
    main.TextWrapped = true
    main.Text = ""
    main.TextColor3 = Color3.fromRGB(255,255,255)
    main.Parent = billboard

    return billboard
end

local function attachBillboard(text)
    local hum, hrp = safeHum()
    if not hum or not hrp then return end
    local bb = ensureBillboard()
    bb.Adornee = hrp
    bb.Parent = PlayerGui -- فوق الراس في المابات اللي بتسمح
    bb.Size = computeBillboardSize(text or "")
    bb.ExtentsOffsetWorldSpace = Vector3.new(0, (hum.HipHeight or 2) + 2.2, 0)
    bb.Main.Text = text or ""
end

local function removeBillboard()
    if billboard then billboard:Destroy() billboard = nil end
end

-- RGB للاسم
task.spawn(function()
    local t=0
    while true do
        RunService.RenderStepped:Wait()
        t += 0.016
        if rgbNameOn and billboard and billboard:FindFirstChild("Main") then
            billboard.Main.TextColor3 = colorRGB(t)
        end
    end
end)

-- /////// PROTECTION CORE ///////
local ProtectionOn, tickAcc = false, 0

local function protectionStep()
    local hum, hrp = safeHum()
    if not hum or not hrp then return end

    if hum.PlatformStand then hum.PlatformStand = false end
    if hum.Sit then hum.Sit = false end
    if hum.AutoRotate == false then hum.AutoRotate = true end

    if hum.WalkSpeed < CFG.WalkMin or hum.WalkSpeed > CFG.WalkMax then
        hum.WalkSpeed = 16
    end
    if hum.JumpPower < CFG.JumpMin or hum.JumpPower > CFG.JumpMax then
        hum.JumpPower = 50
    end

    hrp.AssemblyLinearVelocity  = clampVec(hrp.AssemblyLinearVelocity,  CFG.VelCap)
    hrp.AssemblyAngularVelocity = clampVec(hrp.AssemblyAngularVelocity, CFG.AngCap)

    destroyWeirdStuff(LP.Character)
end

RunService.Heartbeat:Connect(function(dt)
    if not ProtectionOn then return end
    tickAcc += dt
    if tickAcc >= CFG.TickRate then
        tickAcc = 0
        protectionStep()
    end
end)

-- Auto instant-fix عند الاشتباه في لاج/تجميد
task.spawn(function()
    while screen.Parent do
        task.wait(1)
        if ProtectionOn then
            local hum, hrp = safeHum()
            if hum and hrp then
                local frozen = hum.PlatformStand
                    or (hum.WalkSpeed <= 1 and hum.MoveDirection.Magnitude == 1)
                    or (hrp.AssemblyLinearVelocity.Magnitude < 0.05 and hum.MoveDirection.Magnitude == 1)
                if frozen then
                    instantFix()
                end
            end
        end
    end
end)

-- /////// BUTTONS LOGIC ///////
setNameBtn.MouseButton1Click:Connect(function()
    local txt = (nameBox.Text ~= "" and nameBox.Text or CFG.DefaultName)
    attachBillboard(txt)
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

protectBtn.MouseButton1Click:Connect(function()
    ProtectionOn = not ProtectionOn
    protectBtn.Text = ProtectionOn and "إيقاف الحماية" or "تفعيل الحماية"
    if ProtectionOn then instantFix() end
end)

fixBtn.MouseButton1Click:Connect(function()
    instantFix()
end)

closeOpen.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

killAllBtn.MouseButton1Click:Connect(function()
    -- قفل كل حاجة
    pcall(function() screen:Destroy() end)
end)

toggleBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

UserInput.InputBegan:Connect(function(io,gp)
    if gp then return end
    if io.KeyCode == CFG.ToggleKey then
        panel.Visible = not panel.Visible
    end
end)

-- /////// بعد التحميل: اعرض الاسم الافتراضي فوق الراس (RGB) ///////
task.delay(CFG.ShowloadSeconds + 0.2, function()
    attachBillboard(CFG.DefaultName)
    rgbNameOn = true
end)

print("✅ HKM_PROTECT_V3 Loaded – حقوق العم حكومه 😁🍷  |  GS4👑")
