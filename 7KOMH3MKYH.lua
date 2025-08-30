--========================================================--
--  Government Advanced Script - Transform & Skin Copier
--  سكربت الحكومة المتطور - تحوّلات + نسخ سكنات + واجهة كاملة
--  حقوق العم حكومه 😁🍷
--========================================================--

--============[ Services ]============--
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local StarterGui      = game:GetService("StarterGui")
local UserInputService= game:GetService("UserInputService")

local LP = Players.LocalPlayer

--============[ Utils ]============--
local function safeWait(t) local s=tick(); repeat task.wait() until tick()-s>=(t or 0) end
local function rgbCycle(step)
    local h=0
    return function()
        h=(h+(step or 0.01))%1
        return Color3.fromHSV(h,1,1)
    end
end
local function notify(txt, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title="حكومة 😁🍷", Text=txt, Duration=dur or 3})
    end)
end
local function getHumanoid(plr)
    local ch = plr.Character
    if not ch then return nil end
    return ch:FindFirstChildOfClass("Humanoid")
end
local function applyDescription(desc)
    local hum = getHumanoid(LP)
    if hum and desc then
        local ok,err = pcall(function() hum:ApplyDescriptionReset(desc) end)
        return ok,err
    end
    return false,"nohum"
end
local function getAppliedDescriptionOf(plr)
    local hum = getHumanoid(plr)
    if not hum then return nil end
    local ok,desc = pcall(function() return hum:GetAppliedDescription() end)
    if ok then return desc end
    return nil
end

--============[ Language Picker ]============--
local Lang = _G.GOV_LANG or "AR" -- default AR
do
    local gui = Instance.new("ScreenGui")
    gui.Name = "GOV_Lang"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromOffset(420,260)
    frame.Position = UDim2.new(.5,-210,.5,-130)
    frame.BackgroundColor3 = Color3.fromRGB(24,24,24)
    frame.Active = true; frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)
    local stroke = Instance.new("UIStroke", frame); stroke.Thickness=1.5

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,56)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.TextColor3 = Color3.new(1,1,1)
    title.Text = "اختر اللغة / Choose Language"

    local sub = Instance.new("TextLabel", frame)
    sub.Size = UDim2.new(1,0,0,24)
    sub.Position = UDim2.new(0,0,0,42)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 14
    sub.TextColor3 = Color3.fromRGB(220,220,220)
    sub.Text = "Government Script 😁🍷"

    local ar = Instance.new("TextButton", frame)
    ar.Size = UDim2.new(.45,0,0,44)
    ar.Position = UDim2.new(.05,0,.65,0)
    ar.BackgroundColor3 = Color3.fromRGB(42,120,62)
    ar.TextColor3 = Color3.new(1,1,1)
    ar.Text = "🇪🇬 العربية"
    ar.Font = Enum.Font.GothamBold
    ar.TextSize = 20
    Instance.new("UICorner", ar).CornerRadius = UDim.new(0,12)

    local en = Instance.new("TextButton", frame)
    en.Size = UDim2.new(.45,0,0,44)
    en.Position = UDim2.new(.5,0,.65,0)
    en.BackgroundColor3 = Color3.fromRGB(62,62,140)
    en.TextColor3 = Color3.new(1,1,1)
    en.Text = "🇬🇧 English"
    en.Font = Enum.Font.GothamBold
    en.TextSize = 20
    Instance.new("UICorner", en).CornerRadius = UDim.new(0,12)

    local cyc = rgbCycle(0.006)
    task.spawn(function()
        while gui.Parent do
            stroke.Color = cyc()
            task.wait(0.05)
        end
    end)

    local chosen=false
    ar.MouseButton1Click:Connect(function() Lang="AR"; chosen=true end)
    en.MouseButton1Click:Connect(function() Lang="EN"; chosen=true end)
    repeat task.wait() until chosen

    _G.GOV_LANG = Lang
    TweenService:Create(frame, TweenInfo.new(.25), {Size=UDim2.fromOffset(420,0), Position=UDim2.new(.5,-210,.5,0)}):Play()
    safeWait(.28); gui:Destroy()
end

--============[ Strings ]============--
local T = {
    TITLE_AR="👑 سكربت الحكومة المتطور - التحوّلات ونسخ السكنات 👑",
    TITLE_EN="👑 Government Advanced Script - Transforms & Skin Copier 👑",
    WELCOME_AR=("منوّر يا %s ✨ في سكربت الحكومة لنسخ السكنات والتحوّلات 😁🍷"),
    WELCOME_EN=("Welcome %s ✨ to Government Script for Skins & Transforms 😁🍷"),
    SHOWHIDE_AR="إظهار / إخفاء (P)",
    SHOWHIDE_EN="Show / Hide (P)",
    TAB_TRANSFORM_AR="التحوّلات",
    TAB_TRANSFORM_EN="Transforms",
    TAB_COPY_AR="نسخ السكنات",
    TAB_COPY_EN="Skin Copier",
    TAB_UTIL_AR="أدوات",
    TAB_UTIL_EN="Utilities",
    COPYLABEL_AR="نسخ سكن لاعب (أول 2-5 حروف)",
    COPYLABEL_EN="Copy Player Skin (first 2-5 letters)",
    COPYBTN_AR="نسخ الآن",
    COPYBTN_EN="Copy Now",
    STATUS_READY_AR="جاهز ✅",
    STATUS_READY_EN="Ready ✅",
    STATUS_COPIED_AR="تم النسخ ✅",
    STATUS_COPIED_EN="Copied ✅",
    STATUS_NOTFOUND_AR="لاعب غير موجود ❌",
    STATUS_NOTFOUND_EN="Player not found ❌",
    TRANSFORM_OK_AR="تم التحوّل إلى: ",
    TRANSFORM_OK_EN="Transformed to: ",
    TRANSFORM_FAIL_AR="تعذر التحوّل ❌",
    TRANSFORM_FAIL_EN="Transform failed ❌",
    REJOIN_AR="إعادة دخول السيرفر",
    REJOIN_EN="Rejoin Same Server",
    FOOT_AR="حكومة بيمسي 😁🍷",
    FOOT_EN="Gov Bimsy 😁🍷",
}
local function L(ar,en) return (Lang=="AR") and ar or en end

notify(L(T.WELCOME_AR:format(LP.DisplayName), T.WELCOME_EN:format(LP.DisplayName)), 4)

--============[ Main GUI ]============--
local GUI = Instance.new("ScreenGui")
GUI.Name = "GOV_Main"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.Parent = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui")

-- Toggle button (bottom-left)
local ToggleBtn = Instance.new("TextButton", GUI)
ToggleBtn.Size = UDim2.fromOffset(160,34)
ToggleBtn.Position = UDim2.new(0,12,1,-46)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Text = L(T.SHOWHIDE_AR,T.SHOWHIDE_EN)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,10)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn) ToggleStroke.Thickness=1

-- Watermark (small, RGB)
do
    local wm = Instance.new("TextLabel", GUI)
    wm.Size = UDim2.fromOffset(220,22)
    wm.Position = UDim2.new(0,10,1,-22)
    wm.BackgroundTransparency = 1
    wm.Font = Enum.Font.Gotham
    wm.TextSize = 16
    wm.Text = L(T.FOOT_AR,T.FOOT_EN)
    local cyc = rgbCycle(0.01)
    task.spawn(function()
        while wm.Parent do wm.TextColor3=cyc(); task.wait(0.05) end
    end)
end

-- Main window
local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.fromOffset(650,480)
Main.Position = UDim2.new(.5,-325,.5,-240)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,18)
local MainStroke = Instance.new("UIStroke", Main) MainStroke.Thickness=1.5

-- Mild RGB frame stroke (low-cost)
local cyc1 = rgbCycle(0.004)
task.spawn(function()
    while Main.Parent do
        local c=cyc1()
        MainStroke.Color=c; ToggleStroke.Color=c
        task.wait(0.06)
    end
end)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,-20,0,52)
Title.Position = UDim2.new(0,10,0,8)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(240,240,240)
Title.Text = L(T.TITLE_AR, T.TITLE_EN)

-- Tabs
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(1,-20,0,36)
Tabs.Position = UDim2.new(0,10,0,60)
Tabs.BackgroundTransparency = 1
local function mkTab(txt, x)
    local b = Instance.new("TextButton", Tabs)
    b.Size = UDim2.fromOffset(180,34)
    b.Position = UDim2.new(0,x,0,0)
    b.BackgroundColor3 = Color3.fromRGB(38,38,38)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.Text = txt
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke", b) s.Thickness=1
    task.spawn(function()
        local c=rgbCycle(0.007+ (x%3)*0.001)
        while b.Parent do s.Color=c(); task.wait(0.07) end
    end)
    return b
end
local Tab1 = mkTab(L(T.TAB_TRANSFORM_AR,T.TAB_TRANSFORM_EN), 0)
local Tab2 = mkTab(L(T.TAB_COPY_AR,T.TAB_COPY_EN), 200)
local Tab3 = mkTab(L(T.TAB_UTIL_AR,T.TAB_UTIL_EN), 400)

-- Pages container
local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1,-20,1,-112)
Pages.Position = UDim2.new(0,10,0,102)
Pages.BackgroundColor3 = Color3.fromRGB(18,18,18)
Instance.new("UICorner", Pages).CornerRadius = UDim.new(0,12)

local function mkPage()
    local p = Instance.new("ScrollingFrame", Pages)
    p.Size = UDim2.fromScale(1,1)
    p.BackgroundTransparency = 1
    p.CanvasSize = UDim2.new(0,0,0,0)
    p.ScrollBarThickness = 6
    p.Visible=false
    return p
end
local P1 = mkPage() -- transforms
local P2 = mkPage() -- skin copier
local P3 = mkPage() -- utilities

local function showPage(p)
    for _,c in ipairs(Pages:GetChildren()) do if c:IsA("ScrollingFrame") then c.Visible=false end end
    p.Visible=true
end
showPage(P1)

Tab1.MouseButton1Click:Connect(function() showPage(P1) end)
Tab2.MouseButton1Click:Connect(function() showPage(P2) end)
Tab3.MouseButton1Click:Connect(function() showPage(P3) end)

-- Status
local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1,-20,0,24)
Status.Position = UDim2.new(0,10,1,-30)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.GothamSemibold
Status.TextSize = 14
Status.TextColor3 = Color3.fromRGB(220,220,220)
Status.Text = L(T.STATUS_READY_AR, T.STATUS_READY_EN)

-- Toggle show/hide
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
UserInputService.InputBegan:Connect(function(i,g) if not g and i.KeyCode==Enum.KeyCode.P then Main.Visible=not Main.Visible end end)

--============[ Transform System ]============--
local function buildTransform(params)
    local hum = getHumanoid(LP); if not hum then return false end
    local ok, base = pcall(function() return hum:GetAppliedDescription() end)
    if not ok or not base then return false end

    -- Scales
    if params.Height then base.HeightScale = params.Height end
    if params.Width  then base.WidthScale  = params.Width  end
    if params.Depth  then base.DepthScale  = params.Depth  end
    if params.Head   then base.HeadScale   = params.Head   end
    if params.Body   then base.BodyTypeScale = params.Body end
    if params.Prop   then base.ProportionScale = params.Prop end

    -- Colors
    local function setColor(field, c3)
        base[field.."Color"] = Color3.new(c3.R, c3.G, c3.B)
    end
    if params.Color then
        local C=params.Color
        setColor("Head",C); setColor("Torso",C)
        setColor("LeftArm",C); setColor("RightArm",C)
        setColor("LeftLeg",C); setColor("RightLeg",C)
    end

    return applyDescription(base)
end

local Characters = {
    {AR="سليندر مان",     EN="Slenderman",     P={Height=1.4, Width=0.75, Depth=0.9,  Head=0.9,  Body=0.0, Prop=1.1, Color=Color3.fromRGB(10,10,10)}},
    {AR="رأس الصراخ",     EN="Siren Head",     P={Height=1.5, Width=0.80, Depth=1.0,  Head=0.7,  Body=0.1, Prop=0.9, Color=Color3.fromRGB(30,30,30)}},
    {AR="الوحش الظل",     EN="Shadow Monster", P={Height=1.3, Width=0.85, Depth=1.05, Head=0.85, Body=0.0, Prop=1.0, Color=Color3.fromRGB(5,5,5)}},
    {AR="زومبي",          EN="Zombie",         P={Height=1.0, Width=1.00, Depth=1.00, Head=1.0,  Body=0.3, Prop=1.0, Color=Color3.fromRGB(60,120,60)}},
    {AR="شيطان أحمر",     EN="Red Demon",      P={Height=1.2, Width=1.05, Depth=1.05, Head=0.95, Body=0.2, Prop=1.0, Color=Color3.fromRGB(140,20,20)}},
    {AR="هيكل عظمي عملاق",EN="Giant Skeleton", P={Height=1.45,Width=0.85, Depth=0.90, Head=0.85, Body=0.0, Prop=1.0, Color=Color3.fromRGB(220,220,220)}},
    {AR="المهرج القاتل",  EN="Killer Clown",   P={Height=1.1, Width=1.00, Depth=1.00, Head=1.1,  Body=0.4, Prop=1.0, Color=Color3.fromRGB(230,230,230)}},
    {AR="وحش البحر",      EN="Sea Monster",    P={Height=1.25,Width=1.10, Depth=1.10, Head=1.0,  Body=0.3, Prop=1.0, Color=Color3.fromRGB(20,80,120)}},
    {AR="المسخ الأسود",   EN="Dark Mutant",    P={Height=1.2, Width=1.10, Depth=1.15, Head=0.9,  Body=0.2, Prop=1.0, Color=Color3.fromRGB(15,15,15)}},
    {AR="وحش الجبال",     EN="Mountain Beast", P={Height=1.3, Width=1.20, Depth=1.20, Head=1.0,  Body=0.4, Prop=1.0, Color=Color3.fromRGB(100,80,60)}},
    {AR="الروح الشريرة",  EN="Evil Spirit",    P={Height=1.35,Width=0.80, Depth=0.90, Head=0.8,  Body=0.0, Prop=1.1, Color=Color3.fromRGB(240,240,255)}},
    {AR="الغول العملاق",  EN="Ogre Giant",     P={Height=1.4, Width=1.25, Depth=1.25, Head=1.1,  Body=0.7, Prop=0.9, Color=Color3.fromRGB(80,140,80)}},
    {AR="الزاحف الليلي",  EN="Night Crawler",  P={Height=1.2, Width=0.90, Depth=1.05, Head=0.9,  Body=0.1, Prop=1.0, Color=Color3.fromRGB(20,20,40)}},
    {AR="المستذئب",       EN="Werewolf",       P={Height=1.25,Width=1.15, Depth=1.10, Head=1.0,  Body=0.5, Prop=1.0, Color=Color3.fromRGB(90,70,50)}},
    {AR="مومياء",         EN="Mummy",          P={Height=1.1, Width=1.00, Depth=1.00, Head=1.0,  Body=0.2, Prop=1.0, Color=Color3.fromRGB(230,220,200)}},
    {AR="القاتل المقنع",  EN="Masked Killer",  P={Height=1.15,Width=1.00, Depth=1.00, Head=1.0,  Body=0.3, Prop=1.0, Color=Color3.fromRGB(35,35,35)}},
    {AR="وحش النيران",    EN="Fire Monster",   P={Height=1.2, Width=1.05, Depth=1.05, Head=1.0,  Body=0.4, Prop=1.0, Color=Color3.fromRGB(200,70,30)}},
    {AR="شبح أبيض",       EN="White Ghost",    P={Height=1.25,Width=0.85, Depth=0.90, Head=0.9,  Body=0.0, Prop=1.1, Color=Color3.fromRGB(245,245,245)}},
    {AR="التنين الأسود",  EN="Black Dragon",   P={Height=1.35,Width=1.10, Depth=1.10, Head=0.95, Body=0.6, Prop=1.0, Color=Color3.fromRGB(10,10,10)}},
    {AR="الدمية المرعبة", EN="Creepy Doll",    P={Height=0.9, Width=0.90, Depth=0.90, Head=1.2,  Body=0.4, Prop=1.0, Color=Color3.fromRGB(240,220,220)}},
}

do
    local pad = Instance.new("UIPadding", P1) pad.PaddingLeft=UDim.new(0,10) pad.PaddingTop=UDim.new(0,10)
    local grid = Instance.new("UIGridLayout", P1)
    grid.CellPadding = UDim2.fromOffset(10,10)
    grid.CellSize = UDim2.new(0,300,0,40)

    for i,char in ipairs(Characters) do
        local btn = Instance.new("TextButton", P1)
        btn.BackgroundColor3 = Color3.fromRGB(36,36,36)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 16
        btn.Text = (Lang=="AR" and char.AR or char.EN)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        local s = Instance.new("UIStroke", btn) s.Thickness=1

        btn.MouseButton1Click:Connect(function()
            local ok = buildTransform(char.P)
            if ok then
                Status.Text = (Lang=="AR") and (T.TRANSFORM_OK_AR..char.AR) or (T.TRANSFORM_OK_EN..char.EN)
                TweenService:Create(btn, TweenInfo.new(.12), {BackgroundColor3=Color3.fromRGB(60,60,90)}):Play()
                safeWait(.15)
                TweenService:Create(btn, TweenInfo.new(.2), {BackgroundColor3=Color3.fromRGB(36,36,36)}):Play()
            else
                Status.Text = L(T.TRANSFORM_FAIL_AR,T.TRANSFORM_FAIL_EN)
            end
        end)

        task.spawn(function()
            local c=rgbCycle(0.008+(i%5)*0.001)
            while s.Parent do s.Color=c(); task.wait(0.06) end
        end)
    end
end

--============[ Skin Copier ]============--
local function copySkinByPrefix(prefix)
    if not prefix or #prefix<2 or #prefix>20 then return false,"short" end
    prefix = prefix:lower()
    local target
    for _,p in ipairs(Players:GetPlayers()) do
        local dn = (p.DisplayName or p.Name):lower()
        if dn:sub(1,#prefix)==prefix or p.Name:lower():sub(1,#prefix)==prefix then target=p break end
    end
    if not target or target==LP then return false,"notfound" end
    local desc = getAppliedDescriptionOf(target)
    if not desc then return false,"nohum" end
    local ok,err = applyDescription(desc)
    return ok, err or "ok"
end

do
    local label = Instance.new("TextLabel", P2)
    label.Size = UDim2.new(1,-20,0,28)
    label.Position = UDim2.new(0,10,0,10)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Text = L(T.COPYLABEL_AR,T.COPYLABEL_EN)

    local box = Instance.new("TextBox", P2)
    box.Size = UDim2.new(1,-20,0,36)
    box.Position = UDim2.new(0,10,0,42)
    box.BackgroundColor3 = Color3.fromRGB(34,34,34)
    box.TextColor3 = Color3.new(1,1,1)
    box.PlaceholderText = (Lang=="AR") and "اكتب أول 2-5 حروف" or "Type first 2–5 letters"
    box.Font = Enum.Font.Gotham
    box.TextSize = 16
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)

    local btn = Instance.new("TextButton", P2)
    btn.Size = UDim2.new(0,160,0,36)
    btn.Position = UDim2.new(0,10,0,88)
    btn.BackgroundColor3 = Color3.fromRGB(52,52,90)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = L(T.COPYBTN_AR,T.COPYBTN_EN)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

    btn.MouseButton1Click:Connect(function()
        local txt = (box.Text or ""):gsub("%s+","")
        local ok,why = copySkinByPrefix(txt)
        if ok then
            Status.Text = L(T.STATUS_COPIED_AR,T.STATUS_COPIED_EN)
            notify(L("تم نسخ السكن ✅","Skin copied ✅"),2.5)
        else
            if why=="notfound" then
                Status.Text = L(T.STATUS_NOTFOUND_AR,T.STATUS_NOTFOUND_EN)
            else
                Status.Text = (Lang=="AR") and "فشل النسخ ❌" or "Copy failed ❌"
            end
        end
    end)
end

--============[ Utilities ]============--
do
    local rejoin = Instance.new("TextButton", P3)
    rejoin.Size = UDim2.new(0,220,0,40)
    rejoin.Position = UDim2.new(0,10,0,10)
    rejoin.BackgroundColor3 = Color3.fromRGB(58,58,58)
    rejoin.TextColor3 = Color3.new(1,1,1)
    rejoin.Font = Enum.Font.GothamBold
    rejoin.TextSize = 16
    rejoin.Text = L(T.REJOIN_AR,T.REJOIN_EN)
    Instance.new("UICorner", rejoin).CornerRadius = UDim.new(0,10)
    rejoin.MouseButton1Click:Connect(function()
        notify(L("جاري إعادة الدخول…","Rejoining…"),2)
        local TeleportService = game:GetService("TeleportService")
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
        end)
    end)
end

--============[ Splash (light) ]============--
do
    local splash = Instance.new("Frame", Main)
    splash.Size = UDim2.new(1,0,1,0)
    splash.BackgroundColor3 = Color3.fromRGB(10,10,10)
    splash.BackgroundTransparency = .15
    splash.ZIndex = 3
    Instance.new("UICorner", splash).CornerRadius = UDim.new(0,18)

    local txt = Instance.new("TextLabel", splash)
    txt.Size = UDim2.new(1,0,0,64)
    txt.Position = UDim2.new(0,0,.45,-32)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBlack
    txt.TextSize = 28
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.TextWrapped = true
    txt.Text = L(("منوّر يا %s ✨\nسكربت الحكومة المتطور لنسخ السكنات والتحوّلات 😁🍷"):format(LP.DisplayName),
                  ("Welcome %s ✨\nGovernment Advanced Transform & Skin Script 😁🍷"):format(LP.DisplayName))
    local cyc = rgbCycle(0.008)
    task.spawn(function()
        for i=1,40 do txt.TextColor3=cyc(); task.wait(0.05) end
    end)
    TweenService:Create(splash, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 1.4), {BackgroundTransparency=1}):Play()
    safeWait(1.6); splash:Destroy()
end

-- Done
print("✅ Government Script Loaded - حقوق العم حكومه 😁🍷")
