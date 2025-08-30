-- ############################################################
-- 👑 أقوى سكربت حماية شامل (جاهز للرفع) 👑
-- حقوق العم حكومه 😁🍷  | UI RGB + Toggle + أقوى مضادات
-- ملاحظات:
-- 1) بعض المزايا الاختيارية تحتاج بيئة إكسبلويت (getrawmetatable/newcclosure/checkcaller/setreadonly)
-- 2) الكود موحّد في لوب واحد لتقليل اللاج + ريت-ليميت ذكي
-- ############################################################

-- =============== Services ===============
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")
local GuiService        = game:GetService("GuiService")

local LP                = Players.LocalPlayer

-- =============== State ===============
local ProtectionEnabled = true  -- شغالة افتراضياً
local RGBt              = 0
local LastCF            = nil
local LastVelClamp      = 0
local lastFix           = 0
local lastScan          = 0
local VELOCITY_LIMIT    = 180    -- حد اقصى للسرعة لمنع الفلنق
local ANG_VEL_LIMIT     = 60     -- حد اقصى للدوران لمنع الفلنق
local TELEPORT_DELTA    = 120    -- لو اتسحب فجأه اكتر من كده نرجع مكاننا
local TICK_COOLDOWN     = 0.15   -- كولداون اصلاح
local SCAN_COOLDOWN     = 0.35   -- كولداون فحوصات ثقيلة
local MIN_WALKSPEED     = 14     -- أقل مشي طبيعي
local MAX_WALKSPEED     = 24     -- لو حد حاول يبوظ يرجّع رينج طبيعي
local MIN_JUMP          = 40
local MAX_JUMP          = 70

-- =============== Helpers ===============
local function now() return os.clock() end

local function getHumanoid()
    local ch = LP.Character
    if not ch then return nil end
    return ch:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local ch = LP.Character
    if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart")
end

local function clampVec3(v, m)
    local mag = v.Magnitude
    if mag > m then
        return v.Unit * m
    end
    return v
end

-- =============== UI ===============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Gov_Protection_UI"
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game.CoreGui
else
    ScreenGui.Parent = (LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui"))
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 180)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(24,24,24)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local corner = Instance.new("UICorner", Frame)
corner.CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -12, 0, 36)
Title.Position = UDim2.new(0, 6, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "👑 حماية العم حكومه 😁🍷"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 42)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 58)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Text = "🟢 الحماية: شغالة (F10)"
ToggleBtn.Parent = Frame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

local AntiRemoteSwitch = Instance.new("TextButton")
AntiRemoteSwitch.Size = UDim2.new(0.43, 0, 0, 34)
AntiRemoteSwitch.Position = UDim2.new(0.05, 0, 0, 110)
AntiRemoteSwitch.BackgroundColor3 = Color3.fromRGB(50,50,50)
AntiRemoteSwitch.BorderSizePixel = 0
AntiRemoteSwitch.TextColor3 = Color3.fromRGB(255,255,255)
AntiRemoteSwitch.Font = Enum.Font.GothamBold
AntiRemoteSwitch.TextSize = 14
AntiRemoteSwitch.Text = "🔒 مضاد Remote: ON"
AntiRemoteSwitch.Parent = Frame
Instance.new("UICorner", AntiRemoteSwitch).CornerRadius = UDim.new(0, 8)

local AntiTP_Switch = Instance.new("TextButton")
AntiTP_Switch.Size = UDim2.new(0.43, 0, 0, 34)
AntiTP_Switch.Position = UDim2.new(0.52, 0, 0, 110)
AntiTP_Switch.BackgroundColor3 = Color3.fromRGB(50,50,50)
AntiTP_Switch.BorderSizePixel = 0
AntiTP_Switch.TextColor3 = Color3.fromRGB(255,255,255)
AntiTP_Switch.Font = Enum.Font.GothamBold
AntiTP_Switch.TextSize = 14
AntiTP_Switch.Text = "📍 مضاد Teleport: ON"
AntiTP_Switch.Parent = Frame
Instance.new("UICorner", AntiTP_Switch).CornerRadius = UDim.new(0, 8)

local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0.9, 0, 0, 32)
HideBtn.Position = UDim2.new(0.05, 0, 0, 148)
HideBtn.BackgroundColor3 = Color3.fromRGB(36,36,36)
HideBtn.BorderSizePixel = 0
HideBtn.TextColor3 = Color3.fromRGB(255,255,255)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 14
HideBtn.Text = "🟦 اخفاء / اظهار"
HideBtn.Parent = Frame
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 8)

-- حقوق ثابتة صغيرة أسفل الشاشة
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 260, 0, 22)
Watermark.Position = UDim2.new(1, -270, 1, -28)
Watermark.BackgroundTransparency = 1
Watermark.Text = "حقوق العم حكومه 😁🍷"
Watermark.Font = Enum.Font.Gotham
Watermark.TextSize = 16
Watermark.TextColor3 = Color3.new(1,1,1)
Watermark.Parent = ScreenGui

-- RGB بسيط للعنوان و الووترمارك
RunService.RenderStepped:Connect(function()
    RGBt = (RGBt + 0.015) % 1
    local color = Color3.fromHSV(RGBt, 1, 1)
    Title.TextColor3 = color
    Watermark.TextColor3 = color
end)

-- أزرار
local AntiRemoteON = true
local AntiTP_ON     = true

local function updateToggleText()
    if ProtectionEnabled then
        ToggleBtn.Text = "🟢 الحماية: شغالة (F10)"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,160,0)
    else
        ToggleBtn.Text = "🔴 الحماية: مقفولة (F10)"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(160,0,0)
    end
end
updateToggleText()

ToggleBtn.MouseButton1Click:Connect(function()
    ProtectionEnabled = not ProtectionEnabled
    updateToggleText()
end)

AntiRemoteSwitch.MouseButton1Click:Connect(function()
    AntiRemoteON = not AntiRemoteON
    AntiRemoteSwitch.Text = AntiRemoteON and "🔒 مضاد Remote: ON" or "🔓 مضاد Remote: OFF"
    AntiRemoteSwitch.BackgroundColor3 = AntiRemoteON and Color3.fromRGB(50,110,50) or Color3.fromRGB(90,50,50)
end)

AntiTP_Switch.MouseButton1Click:Connect(function()
    AntiTP_ON = not AntiTP_ON
    AntiTP_Switch.Text = AntiTP_ON and "📍 مضاد Teleport: ON" or "📍 مضاد Teleport: OFF"
    AntiTP_Switch.BackgroundColor3 = AntiTP_ON and Color3.fromRGB(50,110,50) or Color3.fromRGB(90,50,50)
end)

HideBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

-- مفتاح F10 تشغيل/إيقاف
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F10 then
        ProtectionEnabled = not ProtectionEnabled
        updateToggleText()
    elseif input.KeyCode == Enum.KeyCode.F8 then
        Frame.Visible = not Frame.Visible
    end
end)

-- =============== Anti-Remote Hook (اختياري بحسب البيئة) ===============
local hasExploit = (getrawmetatable and newcclosure and setreadonly and getnamecallmethod and (checkcaller ~= nil))
if hasExploit then
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if ProtectionEnabled and AntiRemoteON then
            if (method == "FireServer" or method == "InvokeServer") and not checkcaller() then
                -- منع أي محاولة تحكم عن بعد على اللاعب من سكربتات غريبة
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- =============== Auto-Rejoin (محاولة مبسطة) ===============
-- لو اترفست أو فشل التليبورٹ، نحاول نرجع
TeleportService.TeleportInitFailed:Connect(function(player, result)
    if player == LP then
        task.delay(2, function()
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LP)
            end)
        end)
    end
end)

-- =============== Core Protection Loop ===============
RunService.Heartbeat:Connect(function(dt)
    if not ProtectionEnabled then return end

    local ch  = LP.Character
    local hum = getHumanoid()
    local hrp = getHRP()
    if not (ch and hum and hrp) then return end

    -- (1) Anti-Fling / Anti-Freeze / Physics Cleanup (خفيف)
    -- إزالة أي BodyMover/Align مضافة غصب
    local t = now()
    if (t - lastScan) > SCAN_COOLDOWN then
        lastScan = t
        for _,obj in ipairs(ch:GetDescendants()) do
            if obj:IsA("BodyMover") or obj:IsA("AlignPosition") or obj:IsA("AlignOrientation") or obj:IsA("VectorForce") or obj:IsA("Torque") then
                -- تسيب حاجات اللعبة الطبيعية؟ مفيش حل سحري هنا، بس ده يمنع الفلنق الشائع
                pcall(function() obj:Destroy() end)
            end
        end

        -- أدوات/إكسسوارات محقونة
        for _,v in ipairs(ch:GetChildren()) do
            if v:IsA("Tool") or v:IsA("Accessory") then
                if v.Parent ~= LP.Backpack and v.Parent ~= ch then
                    pcall(function() v:Destroy() end)
                end
            end
        end
    end

    -- (2) Unfreeze + Collision طبيعي
    if hrp.Anchored then hrp.Anchored = false end
    if not hrp.CanCollide then hrp.CanCollide = true end

    -- (3) Clamp Velocity لمنع الفلنق العنيف (ريت-ليميت)
    if (t - LastVelClamp) > TICK_COOLDOWN then
        LastVelClamp = t
        hrp.AssemblyLinearVelocity     = clampVec3(hrp.AssemblyLinearVelocity, VELOCITY_LIMIT)
        hrp.AssemblyAngularVelocity    = clampVec3(hrp.AssemblyAngularVelocity, ANG_VEL_LIMIT)
    end

    -- (4) Anti-Teleport: رجوع لو اتسحبت فجأة
    if AntiTP_ON then
        if LastCF then
            local delta = (hrp.Position - LastCF.Position).Magnitude
            if delta > TELEPORT_DELTA then
                hrp.CFrame = LastCF
            end
        end
        LastCF = hrp.CFrame
    end

    -- (5) WalkSpeed/JumpPower normalization (يحافظ على الطبيعي)
    if hum.WalkSpeed < MIN_WALKSPEED or hum.WalkSpeed > MAX_WALKSPEED then
        hum.WalkSpeed = 16
    end
    if hum.JumpPower < MIN_JUMP or hum.JumpPower > MAX_JUMP then
        hum.JumpPower = 50
    end
end)

-- =============== Safe Respawn Handling ===============
LP.CharacterAdded:Connect(function(char)
    LastCF = nil
    task.defer(function()
        local hum = char:WaitForChild("Humanoid", 6)
        local hrp = char:WaitForChild("HumanoidRootPart", 6)
        if hum and hrp then
            hum.PlatformStand = false
            hrp.Anchored = false
        end
    end)
end)

-- تم — أقوى حماية شغالة فعلياً، مش مجرد زرار.
