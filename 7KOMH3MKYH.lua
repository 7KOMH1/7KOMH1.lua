--[[ 
🛡️ سكربت حماية العم حكومه 😁🍷 (Ultimate Protection)
- واجهة متوسطة + زر صغير لفتح/قفل
- مضاد: فلينق / تجميد / طيران إجباري / جذب / أدوات فيزيائية قسرية
- إصلاح تلقائي للمشي/القفز/الوضع
- حقوق RGB متحركة بأسفل الشاشة
- كود واحد متكامل وخفيف لاج

ملاحظة: مفيش حماية مضمونة 100% في كل الألعاب/التحديثات، بس ده معموله أقصى صلابة وأقل لاج.
]]

--// Services
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local StarterGui         = game:GetService("StarterGui")

local LP                 = Players.LocalPlayer

--// Config
local CFG = {
    UI = {
        SmallButtonPos   = UDim2.new(0, 20, 1, -60),
        PanelSize        = UDim2.new(0, 360, 0, 260),
        PanelPosHidden   = UDim2.new(0.5, -180, 1, 20),
        PanelPosShown    = UDim2.new(0.5, -180, 0.5, -130),
        CornerRadius     = 16,
    },
    Defaults = {
        WalkSpeed        = 16,
        JumpPower        = 50,
        HipHeight        = 2,
        Gravity          = workspace.Gravity, -- بنرجعها لو حد لعب فيها محلياً
    },
    Limits = {
        MaxSelfLinearVel = 150,      -- حد السرعة الطولية المسموح بيها (عشان مضاد الفلينق)
        MaxSelfAngular   = 30,       -- حد الدوران الزائد
    },
    Loop = {
        Hz               = 20,       -- عدد المرات في الثانية (أقل لاج)
    },
    BadForces = { -- كل اللي يتحذف لو لُزق على شخصيتك غصب
        "BodyForce","BodyGyro","BodyPosition","BodyVelocity",
        "RocketPropulsion","AlignPosition","AlignOrientation",
        "VectorForce","Torque","LinearVelocity","AngularVelocity",
        "HingeConstraint","SpringConstraint","RodConstraint"
    },
    BadWords = { -- فلتر محلي (للتنبيه فقط)
        "sex","porn","fuck","xnxx","s3x","rape","dick","pussy","boobs",
        "نيك","مص","اغتصاب","كس","زبر","شرج","طيز"
    },
    KickAwayVelocity = Vector3.new(0, 180, 0), -- رفسة للي يقرب وهو مؤذي
    NearDistance     = 5.5
}

--// Utils
local function safeDescend(inst, fn)
    for _,v in ipairs(inst:GetDescendants()) do
        pcall(fn, v)
    end
end

local function makeCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or CFG.UI.CornerRadius)
    c.Parent = parent
    return c
end

local function hsvLoop(setter)
    task.spawn(function()
        local h=0
        while setter and task.wait(0.03) do
            h = (h + 0.01) % 1
            pcall(setter, Color3.fromHSV(h,1,1))
        end
    end)
end

local function character()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function humanoid()
    local ch = character()
    return ch:FindFirstChildOfClass("Humanoid")
end

local function root()
    local ch = character()
    return ch:FindFirstChild("HumanoidRootPart")
end

-- إصلاح فوري لقيم أساسية
local function quickFix()
    local hum = humanoid()
    local hrp = root()
    if hum then
        hum.PlatformStand = false
        hum.Sit = false
        hum.JumpPower = CFG.Defaults.JumpPower
        hum.WalkSpeed = CFG.Defaults.WalkSpeed
        hum.HipHeight = CFG.Defaults.HipHeight
        hum.AutoRotate = true
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
    if hrp then
        hrp.Anchored = false
        hrp.AssemblyLinearVelocity = Vector3.new(0, math.clamp(hrp.AssemblyLinearVelocity.Y, -50, 50), 0)
        hrp.AssemblyAngularVelocity = Vector3.new()
        hrp.CustomPhysicalProperties = PhysicalProperties.new(1,0.3,0.5)
        if hrp:FindFirstChildWhichIsA("BodyMover") then
            for _,bm in ipairs(hrp:GetChildren()) do
                if bm:IsA("BodyMover") or bm:IsA("Constraint") then pcall(function() bm:Destroy() end) end
            end
        end
    end
    workspace.Gravity = CFG.Defaults.Gravity
end

-- إزالة أي قوى/قيود غريبة لاصقة في الشخصية
local function purgeBadForces()
    local ch = character()
    safeDescend(ch, function(v)
        for _,cn in ipairs(CFG.BadForces) do
            if v.ClassName == cn then pcall(function() v:Destroy() end) end
        end
    end)
end

-- فحص فلينق/تجميد وحماية ذاتية
local function protectSelf()
    local hum = humanoid()
    local hrp = root()
    if not hum or not hrp then return end

    -- مضاد التجميد/الإجبار
    if hrp.Anchored then hrp.Anchored = false end
    if hum.PlatformStand then hum.PlatformStand = false end
    if hum.SeatPart then hum.Sit = false end
    if hum.WalkSpeed < 8 or hum.WalkSpeed > 120 then hum.WalkSpeed = CFG.Defaults.WalkSpeed end
    if hum.JumpPower < 30 or hum.JumpPower > 200 then hum.JumpPower = CFG.Defaults.JumpPower end
    if not hum.AutoRotate then hum.AutoRotate = true end

    -- حد السرعات (مضاد فلينق)
    local lv = hrp.AssemblyLinearVelocity
    local av = hrp.AssemblyAngularVelocity
    local maxL = CFG.Limits.MaxSelfLinearVel
    local maxA = CFG.Limits.MaxSelfAngular
    if lv.Magnitude > maxL then
        local y = math.clamp(lv.Y, -maxL, maxL)
        local flat = lv.Unit * maxL
        hrp.AssemblyLinearVelocity = Vector3.new(flat.X, y, flat.Z)
    end
    if math.max(math.abs(av.X),math.abs(av.Y),math.abs(av.Z)) > maxA then
        hrp.AssemblyAngularVelocity = Vector3.new()
    end

    -- إزالة أي قوى/قيود ضارة مضافة حديثاً
    purgeBadForces()
end

-- رفس المؤذيين القريبين (محلياً)
local function repelAggressors()
    local myCh = character()
    local myHRP = root()
    if not myHRP then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist < CFG.NearDistance then
                    -- لو داخل جداً عليك → رفسة لفوق
                    pcall(function()
                        hrp.AssemblyLinearVelocity = CFG.KickAwayVelocity
                    end)
                end
            end
        end
    end
end

-- فلتر محلي للكلمات (تنبيه فقط)
local function hookChatFilter()
    if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
        local TextChatService = game:GetService("TextChatService")
        TextChatService.OnIncomingMessage = function(msg)
            local txt = string.lower(msg.Text or "")
            for _,bw in ipairs(CFG.BadWords) do
                if txt:find(bw) then
                    -- نخفي الرسالة محلياً ونطلع تنبيه بسيط
                    StarterGui:SetCore("ChatMakeSystemMessage", {Text="🚫 رسالة غير لائقة تم إخفاؤها محلياً.", Color = Color3.fromRGB(255,80,80)})
                    return nil
                end
            end
            return msg
        end
    else
        -- Legacy Chat: ما نقدرش نمسح بسهولة، نكتفي بالتنبيه.
        LP.Chatted:Connect(function(m)
            local s = string.lower(m or "")
            for _,bw in ipairs(CFG.BadWords) do
                if s:find(bw) then
                    StarterGui:SetCore("ChatMakeSystemMessage", {Text="🚫 رسالة غير لائقة (محلية).", Color = Color3.fromRGB(255,80,80)})
                    break
                end
            end
        end)
    end
end

--// GUI
local CoreGui = game:GetService("CoreGui")
local sg = Instance.new("ScreenGui")
sg.Name = "HKM_Protection_UI"
sg.ResetOnSpawn = false
sg.Parent = CoreGui

-- زر صغير ثابت
local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 110, 0, 32)
mini.Position = CFG.UI.SmallButtonPos
mini.BackgroundColor3 = Color3.fromRGB(40,40,40)
mini.TextColor3 = Color3.new(1,1,1)
mini.Text = "🛡️ الحماية"
mini.Font = Enum.Font.GothamBold
mini.TextSize = 14
mini.AutoButtonColor = true
mini.Parent = sg
makeCorner(mini, 10)
mini.Active = true
mini.Draggable = true

-- لوحة رئيسية
local panel = Instance.new("Frame")
panel.Size = CFG.UI.PanelSize
panel.Position = CFG.UI.PanelPosHidden
panel.BackgroundColor3 = Color3.fromRGB(22,22,22)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = sg
makeCorner(panel, CFG.UI.CornerRadius)

-- عنوان
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1,-20,0,40)
title.Position = UDim2.new(0,10,0,10)
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.Text = "🛡️ حماية العم حكومه 😁🍷"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = panel

-- RGB للعنوان
hsvLoop(function(c) if title and title.Parent then title.TextColor3 = c end end)

-- أزرار
local function mkBtn(txt, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,38)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = color or Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.fromRGB(250,250,250)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.AutoButtonColor = true
    b.Parent = panel
    makeCorner(b, 10)
    return b
end

local info = Instance.new("TextLabel")
info.BackgroundTransparency = 1
info.Size = UDim2.new(1,-20,0,22)
info.Position = UDim2.new(0,10,1,-26)
info.Font = Enum.Font.Gotham
info.TextSize = 14
info.TextXAlignment = Enum.TextXAlignment.Center
info.Text = "وضع الحماية: قيد التشغيل ✅"
info.TextColor3 = Color3.fromRGB(190,190,190)
info.Parent = panel

local btnToggleProtect = mkBtn("تشغيل/إيقاف الحماية", 58, Color3.fromRGB(30,120,60))
local btnQuickFix      = mkBtn("إصلاح فوري (سرعة/قفز/فك تجميد)", 106, Color3.fromRGB(60,60,100))
local btnPurge         = mkBtn("إزالة أي قوى/قيود غريبة", 154, Color3.fromRGB(120,60,60))
local btnClosePanel    = mkBtn("إخفاء اللوحة", 202, Color3.fromRGB(60,60,60))

-- وسم الحقوق بأسفل الشاشة
local rights = Instance.new("TextLabel")
rights.BackgroundTransparency = 1
rights.Size = UDim2.new(0, 240, 0, 24)
rights.Position = UDim2.new(1, -250, 1, -30)
rights.Text = "حقوق العم حكومه 😁🍷"
rights.Font = Enum.Font.GothamBold
rights.TextSize = 16
rights.TextColor3 = Color3.fromRGB(255,255,255)
rights.Parent = sg
hsvLoop(function(c) if rights and rights.Parent then rights.TextColor3 = c end end)

-- أنيميشن فتح/قفل
local function showPanel(show)
    panel.Visible = true
    local goal = {}
    goal.Position = show and CFG.UI.PanelPosShown or CFG.UI.PanelPosHidden
    local tw = TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tw:Play()
    tw.Completed:Wait()
    if not show then panel.Visible = false end
end

mini.MouseButton1Click:Connect(function()
    if not panel.Visible then
        showPanel(true)
    else
        showPanel(false)
    end
end)

btnClosePanel.MouseButton1Click:Connect(function()
    showPanel(false)
end)

-- منطق الحماية العام
local ProtectionOn = true

btnToggleProtect.MouseButton1Click:Connect(function()
    ProtectionOn = not ProtectionOn
    info.Text = ProtectionOn and "وضع الحماية: قيد التشغيل ✅" or "وضع الحماية: متوقف ❌"
    btnToggleProtect.BackgroundColor3 = ProtectionOn and Color3.fromRGB(30,120,60) or Color3.fromRGB(120,60,60)
end)

btnQuickFix.MouseButton1Click:Connect(function()
    quickFix()
    StarterGui:SetCore("SendNotification",{Title="إصلاح", Text="تم إصلاح الشخصية.", Duration=2})
end)

btnPurge.MouseButton1Click:Connect(function()
    purgeBadForces()
    StarterGui:SetCore("SendNotification",{Title="تنظيف", Text="تم إزالة أي قوى/قيود غريبة.", Duration=2})
end)

-- ربط فلتر الشات المحلي (إخفاء الإباحي محلياً)
hookChatFilter()

-- لوجيك مستمر (خفيف)
local lastTick = 0
RunService.Heartbeat:Connect(function(dt)
    -- خنق التكرار لتقليل اللاج
    local now = tick()
    if now - lastTick < (1/CFG.Loop.Hz) then return end
    lastTick = now

    if not ProtectionOn then return end

    -- حماية مستمرة
    pcall(protectSelf)
    pcall(repelAggressors)
end)

-- إعادة ضبط لما الشخصية تعيد السبون
LP.CharacterAdded:Connect(function()
    task.wait(0.25)
    quickFix()
    purgeBadForces()
end)

print("✅ حماية العم حكومه 😁🍷 شغّالة.")
