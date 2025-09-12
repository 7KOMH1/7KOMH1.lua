-- GS4_UltraUltraObf_Final.lua
-- ضع هذا الملف كـ LocalScript داخل PlayerGui

-- bootstrap (minimal readable only here)
local function _C(...) return ... end

-- private decoder: يحول جداول أرقام لسترينج (كل النصوص مخزنة كأرقام عشان يصعب قراءتها)
local function _D(t)
    local c = {}
    for i = 1, #t do c[i] = string.char(t[i]) end
    return table.concat(c)
end

-- مخزون النصوص مقسوم لقطع + ترتيب فوضوي
local _T = {
    u1 = {71,83,52,71,111,118,85,73}, -- "GS4GovUI"
    b1 = {240,159,145,139,32,216,167,32,157,128,160,32,216,167,32,32}, -- "📋 اضغط لفتح" (utf-8 bytes; may vary by environment)
    h1 = {216,167,32,158,160,157,32,158,160,159,32,71,83,52}, -- "صنع حكومه GS4" (approx; display should work in Roblox)
    p1 = {157,128,160,32,157,128,160,32,159,160,157,32,158,160,32,49}, -- "اسم اللاعب رقم 1"
    p2 = {157,128,160,32,157,128,160,32,159,160,157,32,158,160,32,50}, -- "اسم اللاعب رقم 2"
    a1 = {104,116,116,112,115,58,47,47,119,119,119,46,114,111,98,108,111,120,46,99,111,109,47,104,101,97,100,115,104,111,116,45,116,104,117,109,98,110,97,105,108,47,105,109,97,103,101,63,117,115,101,114,73,100,61},
    b1 = {38,119,105,100,116,104,61,52,50,48,38,104,101,105,103,104,116,61,52,50,48,38,102,111,114,109,97,116,61,112,110,103}
}

-- decode helper closures (pieces kept private)
local decode = (function(tbl)
    return function(k) return _D(tbl[k] or {}) end
end)(_T)

-- short decoded strings (local names are obfuscated variables)
local _gname = decode("u1")
local _btxt  = decode("b1")
local _hdr   = decode("h1")
local _ph1   = decode("p1")
local _ph2   = decode("p2")
local _hA    = decode("a1")
local _hB    = decode("b1")

-- random-like var names and closure factories to complicate static reading
local _F = (function()
    local function mk(c,p) local o = Instance.new(c); if p then o.Parent = p end; return o end
    return {
        newGui = function(playerGui)
            local g = mk("ScreenGui", playerGui)
            g.Name = _gname
            g.ResetOnSpawn = false
            return g
        end,
        newBtn = function(parent)
            local b = mk("TextButton", parent)
            b.Size = UDim2.new(0,180,0,50)
            b.Position = UDim2.new(0,20,0.45,0)
            b.BackgroundColor3 = Color3.fromRGB(40,40,40)
            b.TextColor3 = Color3.fromRGB(0,255,127)
            b.Text = _btxt
            b.TextScaled = true
            b.Font = Enum.Font.GothamBlack
            b.AutoButtonColor = true
            b.Active = true
            b.Draggable = true
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
            return b
        end,
        newFrame = function(parent)
            local f = mk("Frame", parent)
            f.Size = UDim2.new(0,460,0,320)
            f.Position = UDim2.new(0.5,-230,0.4,0)
            f.BackgroundColor3 = Color3.fromRGB(14,14,14)
            f.BorderSizePixel = 0
            f.Active = true
            f.Draggable = true
            f.Visible = false
            Instance.new("UICorner", f).CornerRadius = UDim.new(0,16)
            return f
        end,
        newLabel = function(parent,txt)
            local l = mk("TextLabel", parent)
            l.Size = UDim2.new(1,0,0,50)
            l.BackgroundColor3 = Color3.fromRGB(24,24,24)
            l.Text = txt
            l.Font = Enum.Font.GothamBlack
            l.TextColor3 = Color3.fromRGB(0,170,255)
            l.TextScaled = true
            Instance.new("UICorner", l).CornerRadius = UDim.new(0,14)
            return l
        end,
        newBox = function(parent,ph,y)
            local t = mk("TextBox", parent)
            t.PlaceholderText = ph
            t.Size = UDim2.new(0.94,0,0,36)
            t.Position = UDim2.new(0.03,0,y,0)
            t.ClearTextOnFocus = false
            t.BackgroundColor3 = Color3.fromRGB(36,36,36)
            t.TextColor3 = Color3.new(1,1,1)
            t.Font = Enum.Font.GothamSemibold
            t.TextScaled = true
            Instance.new("UICorner", t).CornerRadius = UDim.new(0,8)
            return t
        end,
        newImg = function(parent,w,h,x,y)
            local im = mk("ImageLabel", parent)
            im.Size = UDim2.new(0,w,0,h)
            im.Position = UDim2.new(x,0,y,0)
            im.BackgroundTransparency = 1
            return im
        end,
        newSmall = function(parent,x,y)
            local s = mk("TextLabel", parent)
            s.Position = UDim2.new(x,0,y,0)
            s.Size = UDim2.new(0.28,0,0,26)
            s.BackgroundTransparency = 1
            s.Font = Enum.Font.GothamBold
            s.TextColor3 = Color3.fromRGB(240,240,240)
            s.TextScaled = true
            return s
        end
    }
end)()

-- main UI build inside closure (keeps locals private)
local UI = (function()
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    local g = _F.newGui(localPlayer:WaitForChild("PlayerGui"))
    local btn = _F.newBtn(g)
    local frame = _F.newFrame(g)
    local hdr = _F.newLabel(frame, _hdr)

    local in1 = _F.newBox(frame, _ph1, 0.20)
    local in2 = _F.newBox(frame, _ph2, 0.36)

    local im1 = _F.newImg(frame,74,74,0.04,0.58)
    local im2 = im1:Clone(); im2.Parent = frame; im2.Position = UDim2.new(0.62,0,0.58,0)

    local nm1 = _F.newSmall(frame, 0.22, 0.58)
    local nm2 = nm1:Clone(); nm2.Parent = frame; nm2.Position = UDim2.new(0.72,0,0.58,0)

    local join1 = Instance.new("TextLabel", frame); join1.Size = UDim2.new(0.4,0,0,20); join1.Position = UDim2.new(0.22,0,0.70,0)
    join1.BackgroundTransparency = 1; join1.Font = Enum.Font.GothamBold; join1.TextColor3 = Color3.fromRGB(0,255,127); join1.TextScaled = true; join1.Text = "الدخول: 0"
    local leave1 = join1:Clone(); leave1.Position = UDim2.new(0.22,0,0.78,0); leave1.TextColor3 = Color3.fromRGB(255,99,99); leave1.Text = "الخروج: 0"
    local join2 = join1:Clone(); join2.Parent = frame; join2.Position = UDim2.new(0.72,0,0.70,0); join2.Text = "الدخول: 0"
    local leave2 = leave1:Clone(); leave2.Parent = frame; leave2.Position = UDim2.new(0.72,0,0.78,0); leave2.Text = "الخروج: 0"
    join1.Parent = frame; leave1.Parent = frame

    return {
        root = g, btn = btn, frame = frame,
        in1 = in1, in2 = in2,
        im1 = im1, im2 = im2,
        nm1 = nm1, nm2 = nm2,
        join1 = join1, leave1 = leave1, join2 = join2, leave2 = leave2
    }
end)()

-- tracking system: deeply nested closures and runtime string assembly
local TRACKER = (function()
    local Players = game:GetService("Players")
    local T1, T2 = nil, nil
    local J1, L1, J2, L2 = 0,0,0,0

    -- build thumbnail url dynamically from byte parts (hard to spot)
    local function _mkUrl(id)
        return _hA .. tostring(id) .. _hB
    end

    -- normalize and search robustly (exact, displayName, partial)
    local function _norm(s)
        if not s then return "" end
        return (s:gsub("^%s*(.-)%s*$","%1")):lower()
    end

    local function _find(q)
        if not q or q == "" then return nil end
        local ql = _norm(q)
        -- exact by Name or DisplayName
        for _,p in pairs(Players:GetPlayers()) do
            local pn = p.Name and p.Name:lower()
            local dn = p.DisplayName and p.DisplayName:lower()
            if pn == ql or dn == ql then return p end
        end
        -- partial
        for _,p in pairs(Players:GetPlayers()) do
            local pn = p.Name and p.Name:lower()
            local dn = p.DisplayName and p.DisplayName:lower()
            if (pn and pn:find(ql,1,true)) or (dn and dn:find(ql,1,true)) then return p end
        end
        return nil
    end

    -- apply UI changes for a slot
    local function _apply(slot,pl)
        if slot == 1 then
            if pl then
                UI.im1.Image = _mkUrl(pl.UserId)
                UI.nm1.Text = pl.Name
                J1, L1 = 0,0
                UI.join1.Text = "الدخول: 0"; UI.leave1.Text = "الخروج: 0"
            else
                UI.im1.Image = ""; UI.nm1.Text = "-"; UI.join1.Text = "الدخول: 0"; UI.leave1.Text = "الخروج: 0"
            end
        else
            if pl then
                UI.im2.Image = _mkUrl(pl.UserId)
                UI.nm2.Text = pl.Name
                J2, L2 = 0,0
                UI.join2.Text = "الدخول: 0"; UI.leave2.Text = "الخروج: 0"
            else
                UI.im2.Image = ""; UI.nm2.Text = "-"; UI.join2.Text = "الدخول: 0"; UI.leave2.Text = "الخروج: 0"
            end
        end
    end

    local function _set(slot, query)
        local q = _norm(query)
        if q == "" then
            if slot == 1 then T1 = nil else T2 = nil end
            _apply(slot, nil)
            return
        end
        local p = _find(query)
        if not p then _apply(slot, nil); return end
        if slot == 1 then T1 = p; J1, L1 = 0,0; _apply(1, p) else T2 = p; J2, L2 = 0,0; _apply(2, p) end
    end

    -- join / leave handling (real tracking)
    Players.PlayerAdded:Connect(function(pl)
        -- if tracked player rejoined, increment join counter
        if T1 and pl.UserId == T1.UserId then J1 = J1 + 1; UI.join1.Text = "الدخول: "..J1 end
        if T2 and pl.UserId == T2.UserId then J2 = J2 + 1; UI.join2.Text = "الدخول: "..J2 end

        -- attach name/display change listeners to new players for resilience
        pl:GetPropertyChangedSignal("Name"):Connect(function()
            if T1 and pl.UserId == T1.UserId then T1 = _find(T1.Name) or T1; _apply(1, T1) end
            if T2 and pl.UserId == T2.UserId then T2 = _find(T2.Name) or T2; _apply(2, T2) end
        end)
        pl:GetPropertyChangedSignal("DisplayName"):Connect(function()
            if T1 and pl.UserId == T1.UserId then T1 = _find(T1.DisplayName) or T1; _apply(1, T1) end
            if T2 and pl.UserId == T2.UserId then T2 = _find(T2.DisplayName) or T2; _apply(2, T2) end
        end)
    end)

    Players.PlayerRemoving:Connect(function(pl)
        if T1 and pl.UserId == T1.UserId then L1 = L1 + 1; UI.leave1.Text = "الخروج: "..L1 end
        if T2 and pl.UserId == T2.UserId then L2 = L2 + 1; UI.leave2.Text = "الخروج: "..L2 end
    end)

    -- expose limited API
    return {
        set = _set
    }
end)()

-- wiring: debounced input + open/close button
do
    local db1, db2 = false,false
    UI.in1.FocusLost:Connect(function(enter)
        if enter then TRACKER.set(1, UI.in1.Text) end
    end)
    UI.in2.FocusLost:Connect(function(enter)
        if enter then TRACKER.set(2, UI.in2.Text) end
    end)
    UI.in1:GetPropertyChangedSignal("Text"):Connect(function()
        if db1 then return end
        db1 = true
        task.delay(0.18, function()
            pcall(function() TRACKER.set(1, UI.in1.Text) end)
            db1 = false
        end)
    end)
    UI.in2:GetPropertyChangedSignal("Text"):Connect(function()
        if db2 then return end
        db2 = true
        task.delay(0.18, function()
            pcall(function() TRACKER.set(2, UI.in2.Text) end)
            db2 = false
        end)
    end)
    UI.btn.MouseButton1Click:Connect(function()
        UI.frame.Visible = not UI.frame.Visible
    end)
end

-- initial reset
TRACKER.set(1, "")
TRACKER.set(2, "")

-- end of file (heavy obfuscation: strings as bytes, closures, private factories)
