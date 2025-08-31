--[[ 
 HKM Protect V3.1 – Final FX (Client Only)
 By حكومه 😁🍷 | شعار GS4👑
 كل المؤثرات والانتقالات مضافة – محلي وآمن.
]]

--// Services
local Players   = game:GetService("Players")
local RS        = game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local TS        = game:GetService("TweenService")
local Lighting  = game:GetService("Lighting")

local LP        = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

--// CONFIG
local CFG = {
    ImageId          = "rbxassetid://114080090887781", -- GS4👑
    ClickSoundId     = "rbxassetid://12222005",
    HoverSoundId     = "rbxassetid://9118823105",
    ZapSoundId       = "rbxassetid://911343021",       -- صوت برق خفيف
    ShowloadSeconds  = 15,
    RGBSpeed         = 0.35,
    TickRate         = 0.10,
    VelCap           = 150,  AngCap = 20,
    WalkMin = 8,  WalkMax = 32,
    JumpMin = 35, JumpMax = 75,
    PlaceOffsets = {
        ["13853493395"] = 2.8, -- v6
        ["4924922222"]  = 2.6, -- RP
        default = 2.6
    },
}

local function colorRGB(t) return Color3.fromHSV((t*CFG.RGBSpeed)%1,1,1) end
local function now() return RS.Stepped:Wait() end -- لثبات التايمر

local function safeHum()
    local ch = LP.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    return hum, hrp
end

local function clampVec(v, m)
    local mag = v.Magnitude
    if mag > m then return v.Unit * m end
    return v
end

-- برق/سباركل مؤقت
local function flashFX(hrp)
    local s = Instance.new("Sparkles")
    s.SparkleColor = Color3.fromRGB(255, 230, 50)
    s.Enabled = true
    s.Parent = hrp
    local snd = Instance.new("Sound")
    snd.SoundId = CFG.ZapSoundId
    snd.Volume = 0.7
    snd.Parent = hrp
    snd:Play()
    task.delay(0.35, function()
        s.Enabled = false
        task.wait(0.2)
        s:Destroy()
        snd:Destroy()
    end)
end

local function instantFix()
    local hum, hrp = safeHum()
    if not hum or not hrp then return end
    hum.PlatformStand = false; hum.Sit = false; hum.AutoRotate = true
    if hum.WalkSpeed < CFG.WalkMin or hum.WalkSpeed > CFG.WalkMax then hum.WalkSpeed = 16 end
    if hum.JumpPower < CFG.JumpMin or hum.JumpPower > CFG.JumpMax then hum.JumpPower = 50 end
    hrp.AssemblyLinearVelocity  = clampVec(hrp.AssemblyLinearVelocity,  CFG.VelCap)
    hrp.AssemblyAngularVelocity = clampVec(hrp.AssemblyAngularVelocity, CFG.AngCap)
    -- نظف أي قوى مزروعة في جسمي
    for _,d in ipairs(LP.Character:GetDescendants()) do
        if d:IsA("BodyMover") or d:IsA("VectorForce") or d:IsA("Torque")
        or d:IsA("LinearVelocity") or d:IsA("AngularVelocity") then
            pcall(function() if d.Parent and d.Parent:IsDescendantOf(LP.Character) then d:Destroy() end end)
        end
    end
    flashFX(hrp)
end

--// BLUR مؤقت للانتقالات
local function getBlur()
    local b = Lighting:FindFirstChild("HKM_UI_BLUR")
    if not b then
        b = Instance.new("BlurEffect")
        b.Name = "HKM_UI_BLUR"; b.Size = 0; b.Parent = Lighting
    end
    return b
end

--// ROOT GUI
local screen = Instance.new("ScreenGui")
screen.Name = "HKM_PROTECT_V3"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.Parent = PlayerGui

--// LOADING: حرف حرف + Progress + وميض
local loadFrame = Instance.new("Frame")
loadFrame.Size = UDim2.fromScale(1,1)
loadFrame.BackgroundColor3 = Color3.fromRGB(10,10,12)
loadFrame.Parent = screen

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.AnchorPoint = Vector2.new(0.5,0.5)
title.Position = UDim2.new(0.5,0,0.36,0)
title.Size = UDim2.new(0,680,0,70)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = loadFrame

local v3 = Instance.new("TextLabel")
v3.BackgroundTransparency = 1
v3.AnchorPoint = Vector2.new(0.5,0.5)
v3.Position = UDim2.new(0.5,0,0.46,0)
v3.Size = UDim2.new(0,150,0,40)
v3.Font = Enum.Font.GothamBlack
v3.TextScaled = true
v3.Text = "V3"
v3.TextColor3 = Color3.fromRGB(255,255,255)
v3.Parent = loadFrame

local barBG = Instance.new("Frame")
barBG.AnchorPoint = Vector2.new(0.5,0.5)
barBG.Position = UDim2.new(0.5,0,0.62,0)
barBG.Size = UDim2.new(0.6,0,0,14)
barBG.BackgroundColor3 = Color3.fromRGB(30,30,36)
barBG.Parent = loadFrame

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0,0,1,0)
barFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
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

-- وميض بسيط (فلاش) على الخلفية وقت التحميل
task.spawn(function()
    while loadFrame.Parent do
        local flash = Instance.new("Frame")
        flash.BackgroundColor3 = Color3.fromRGB(255,255,255)
        flash.BackgroundTransparency = 0.85
        flash.Size = UDim2.fromScale(1,1)
        flash.Parent = loadFrame
        TS:Create(flash, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}):Play()
        task.wait(math.random(6,10)/10) -- وميض عشوائي
        flash:Destroy()
    end
end)

-- RGB للعنوان
task.spawn(function()
    local t=0
    while loadFrame.Parent do
        t += RS.RenderStepped:Wait()
        local c = colorRGB(t)
        title.TextColor3 = c; v3.TextColor3 = c; barFill.BackgroundColor3 = c
    end
end)

-- كتابة حرف حرف
task.spawn(function()
    local s = "سكربت حكومه 🥶💧"
    title.Text = ""
    for i=1,#s do title.Text = s:sub(1,i); task.wait(0.05) end
end)

-- تقدم 100%
task.spawn(function()
    local dur, start = CFG.ShowloadSeconds, tick()
    while true do
        local p = math.clamp((tick()-start)/dur,0,1)
        barFill.Size = UDim2.new(p,0,1,0)
        barText.Text = ("%d%%"):format(math.floor(p*100))
        if p>=1 then break end
        task.wait(0.05)
    end
    -- خروج بفيد + بلور خفيف
    local blur = getBlur()
    TS:Create(blur, TweenInfo.new(0.35), {Size = 12}):Play()
    TS:Create(loadFrame, TweenInfo.new(0.35), {BackgroundTransparency=1}):Play()
    for _,v in ipairs(loadFrame:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("Frame") then
            local prop = v:IsA("TextLabel") and "TextTransparency" or "BackgroundTransparency"
            TS:Create(v, TweenInfo.new(0.35), {[prop]=1}):Play()
        end
    end
    task.wait(0.4)
    loadFrame:Destroy()
    TS:Create(blur, TweenInfo.new(0.35), {Size = 0}):Play()
end)

--// Watermark
do
    local wm = Instance.new("TextLabel")
    wm.BackgroundTransparency = 1
    wm.Position = UDim2.new(1,-250,1,-24)
    wm.Size = UDim2.new(0,240,0,22)
    wm.Text = "حقوق العم حكومه 😁🍷"
    wm.Font = Enum.Font.GothamSemibold
    wm.TextSize = 16
    wm.TextColor3 = Color3.fromRGB(255,255,255)
    wm.Parent = screen
    task.spawn(function() local t=0; while wm.Parent do t+=RS.RenderStepped:Wait(); wm.TextColor3=colorRGB(t) end end)
end

--// زر فتح/قفل – أسود + GS4 + جِلُو ذهبي + انزلاق + نبض + قابل للسحب
local toggleHolder = Instance.new("Frame")
toggleHolder.Size = UDim2.new(0, 92, 0, 92)
toggleHolder.Position = UDim2.new(0, -110, 0.5, -46) -- يبدأ خارج الشاشة (انزلاق)
toggleHolder.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggleHolder.BorderSizePixel = 0
toggleHolder.Visible = false
toggleHolder.Parent = screen
Instance.new("UICorner", toggleHolder).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke", toggleHolder)
stroke.Color = Color3.fromRGB(255,215,0); stroke.Thickness = 3

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(1,-10,1,-10)
ToggleButton.Position = UDim2.new(0,5,0,5)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Image = CFG.ImageId
ToggleButton.Parent = toggleHolder

local clickS = Instance.new("Sound", ToggleButton); clickS.SoundId = CFG.ClickSoundId; clickS.Volume=1
local hoverS = Instance.new("Sound", ToggleButton); hoverS.SoundId = CFG.HoverSoundId; hoverS.Volume=0.4

-- ripple بصري عند الضغط
local function ripple(btn)
    local r = Instance.new("Frame"); r.BackgroundColor3 = Color3.fromRGB(255,215,0)
    r.BackgroundTransparency = 0.3; r.BorderSizePixel=0
    r.AnchorPoint=Vector2.new(0.5,0.5); r.Position=UDim2.fromScale(0.5,0.5)
    r.Size = UDim2.new(0,6,0,6); r.Parent = btn
    Instance.new("UICorner", r).CornerRadius = UDim.new(1,0)
    TS:Create(r, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1}):Play()
    task.delay(0.45,function() r:Destroy() end)
end

-- نبض مستمر
task.spawn(function()
    while ToggleButton.Parent do
        TS:Create(toggleHolder, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Position = toggleHolder.Position + UDim2.fromOffset(0,4)}):Play()
        task.wait(1.2)
        TS:Create(toggleHolder, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Position = toggleHolder.Position - UDim2.fromOffset(0,4)}):Play()
        task.wait(1.2)
    end
end)

-- إظهار بعد التحميل بانزلاق
task.delay(CFG.ShowloadSeconds, function()
    toggleHolder.Visible = true
    TS:Create(toggleHolder, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0,16,0.5,-46)}):Play()
end)

-- سحب
local dragging=false; local delta
ToggleButton.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragging=true; delta = i.Position - toggleHolder.AbsolutePosition; clickS:Play(); ripple(ToggleButton)
    elseif i.UserInputType==Enum.UserInputType.MouseMovement then hoverS:Play() end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        toggleHolder.Position = UDim2.fromOffset(i.Position.X - delta.X, i.Position.Y - delta.Y)
    end
end)

--// اللوحة الرئيسية (تفتح/تقفل بتكبير+بلور)
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 440, 0, 310)
panel.Position = UDim2.new(0, 120, 0.5, -155)
panel.BackgroundColor3 = Color3.fromRGB(20,20,24)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = screen
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)

local header = Instance.new("TextLabel")
header.BackgroundTransparency = 1
header.Position = UDim2.new(0,12,0,8)
header.Size = UDim2.new(1,-24,0,44)
header.Font = Enum.Font.GothamBlack
header.TextSize = 22
header.Text = "لوحة حماية حكومه – V3.1"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.Parent = panel
task.spawn(function() local t=0; while header.Parent do t+=RS.RenderStepped:Wait(); header.TextColor3=colorRGB(t) end end)

local sep = Instance.new("Frame"); sep.Size=UDim2.new(1,-24,0,1); sep.Position=UDim2.new(0,12,0,52)
sep.BackgroundColor3=Color3.fromRGB(60,60,70); sep.BorderSizePixel=0; sep.Parent=panel

local function mkBtn(txt,x,y,w,h)
    local b = Instance.new("TextButton")
    b.Text = txt; b.Font = Enum.Font.GothamBold; b.TextSize=16
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(40,40,50)
    b.Size = UDim2.new(0,w,0,h); b.Position = UDim2.new(0,x,0,y)
    b.Parent = panel; Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    local sHover = Instance.new("Sound", b); sHover.SoundId = CFG.HoverSoundId; sHover.Volume=0.4
    b.MouseEnter:Connect(function() sHover:Play(); TS:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play() end)
    b.MouseLeave:Connect(function() TS:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play() end)
    b.MouseButton1Click:Connect(function() ripple(b); clickS:Play() end)
    task.spawn(function() local t=0; while b.Parent do t+=RS.RenderStepped:Wait(); b.BackgroundColor3=colorRGB(t) end end)
    return b
end

local nameBox = Instance.new("TextBox")
nameBox.PlaceholderText = "اكتب اسم يظهر فوق راسك"
nameBox.ClearTextOnFocus = false
nameBox.Text = ""
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 16
nameBox.TextColor3 = Color3.fromRGB(255,255,255)
nameBox.BackgroundColor3 = Color3.fromRGB(35,35,45)
nameBox.Size = UDim2.new(0, 270, 0, 34)
nameBox.Position = UDim2.new(0, 12, 0, 70)
nameBox.Parent = panel; Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,8)

local setNameBtn = mkBtn("عرض الاسم", 290, 70, 138, 34)
local rgbOnBtn  = mkBtn("RGB للاسم", 12, 112, 132, 34)
local rgbOffBtn = mkBtn("إيقاف RGB", 154, 112, 132, 34)
local clearName = mkBtn("مسح الاسم", 298, 112, 130, 34)

local protectToggle = mkBtn("تفعيل الحماية", 12, 162, 190, 38)
local quickFix      = mkBtn("إصلاح فوري",   214, 162, 214, 38)
local killAll       = mkBtn("قفل السكربت",   12, 210, 416, 38)

-- فتح/قفل اللوحة بتحريك/بلور
local function togglePanel()
    local blur = getBlur()
    if not panel.Visible then
        panel.Visible = true; panel.Size = UDim2.new(0, 10, 0, 10)
        TS:Create(blur, TweenInfo.new(0.25), {Size=18}):Play()
        TS:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0,440,0,310)}):Play()
    else
        TS:Create(blur, TweenInfo.new(0.25), {Size=0}):Play()
        TS:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0,10,0,10)}):Play()
        task.delay(0.2, function() panel.Visible=false end)
    end
end
ToggleButton.MouseButton1Click:Connect(togglePanel)

-- الاسم فوق الراس
local billboard, rgbOn = nil, true
local function offsetY()
    local id = tostring(game.PlaceId)
    return CFG.PlaceOffsets[id] or CFG.PlaceOffsets.default
end
local function ensureBillboard()
    if billboard and billboard.Parent then return billboard end
    billboard = Instance.new("BillboardGui")
    billboard.Name = "HKM_NameTag"; billboard.Size = UDim2.new(0,220,0,64)
    billboard.AlwaysOnTop = true
    local main = Instance.new("TextLabel")
    main.Name="Main"; main.BackgroundTransparency=1; main.Size=UDim2.new(1,0,1,0)
    main.Font = Enum.Font.GothamBlack; main.TextScaled=true
    main.TextColor3 = Color3.fromRGB(255,255,255); main.Parent=billboard
    return billboard
end
local function attachBillboard(text)
    local hum, hrp = safeHum(); if not hum or not hrp then return end
    local bb = ensureBillboard(); bb.Adornee = hrp; bb.ExtentsOffsetWorldSpace = Vector3.new(0, offsetY(), 0)
    bb.Parent = PlayerGui; bb.Main.Text = text or ""
end
local function removeBillboard() if billboard then billboard:Destroy(); billboard=nil end end
task.spawn(function() local t=0; while true do RS.RenderStepped:Wait(); t+=0.016; if rgbOn and billboard and billboard:FindFirstChild("Main") then billboard.Main.TextColor3 = colorRGB(t) end end end)

-- أزرار الاسم
setNameBtn.MouseButton1Click:Connect(function()
    local t = (nameBox.Text ~= "" and nameBox.Text or "سكربت حكومه 🥶💧\nV3")
    attachBillboard(t)
end)
rgbOnBtn.MouseButton1Click:Connect(function() rgbOn = true end)
rgbOffBtn.MouseButton1Click:Connect(function() rgbOn = false; if billboard and billboard:FindFirstChild("Main") then billboard.Main.TextColor3 = Color3.fromRGB(255,255,255) end end)
clearName.MouseButton1Click:Connect(removeBillboard)

-- حماية
local ProtectionOn=false; local acc=0
protectToggle.MouseButton1Click:Connect(function()
    ProtectionOn = not ProtectionOn
    protectToggle.Text = ProtectionOn and "إيقاف الحماية" or "تفعيل الحماية"
    if ProtectionOn then instantFix() end
end)
quickFix.MouseButton1Click:Connect(instantFix)

RS.Heartbeat:Connect(function(dt)
    if not ProtectionOn then return end
    acc += dt; if acc >= CFG.TickRate then acc=0; instantFix() end
end)

-- أوتو إصلاح لو في تجميد واضح
task.spawn(function()
    while screen.Parent do
        task.wait(1.0)
        if ProtectionOn then
            local hum, hrp = safeHum()
            if hum and hrp then
                local frozen = hum.PlatformStand or hum.Sit or (hrp.AssemblyLinearVelocity.Magnitude < 0.05 and hum.MoveDirection.Magnitude == 1)
                if frozen then instantFix() end
            end
        end
    end
end)

-- قفل السكربت كله
killAll.MouseButton1Click:Connect(function() screen:Destroy() end)

-- اسم تلقائي بعد التحميل
task.delay(CFG.ShowloadSeconds + 0.2, function()
    attachBillboard("سكربت حكومه 🥶💧\nV3")
    rgbOn = true
end)

print("✅ HKM Protect V3.1 FX Loaded – حقوق العم حكومه 😁🍷 | GS4👑")
