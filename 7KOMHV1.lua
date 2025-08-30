-- حقوق العم حكومه 😁🍷
-- حماية شاملة + طرد للمخترق

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- 🛡️ GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 240, 0, 110)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- اسود فاتح
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🛡️ حماية العم حكومه 😁🍷"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(0.9, 0, 0, 40)
Toggle.Position = UDim2.new(0.05, 0, 0.55, 0)
Toggle.Text = "تشغيل ✅"
Toggle.TextColor3 = Color3.fromRGB(0, 255, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Toggle.Font = Enum.Font.SourceSansBold
Toggle.TextSize = 20

local ProtectionEnabled = true

Toggle.MouseButton1Click:Connect(function()
    ProtectionEnabled = not ProtectionEnabled
    if ProtectionEnabled then
        Toggle.Text = "تشغيل ✅"
        Toggle.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        Toggle.Text = "ايقاف ❌"
        Toggle.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- 🛡️ منع الكيك/البان
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    if ProtectionEnabled then
        local method = getnamecallmethod()
        if tostring(method):lower() == "kick" then
            return warn("🛡️ محاولة كيك/بان تم منعها - حكومه 😁🍷")
        end
    end
    return old(self, ...)
end)

LocalPlayer.Kick = function()
    if ProtectionEnabled then
        warn("🛡️ محاولة كيك/بان تم منعها - حكومه 😁🍷")
        return
    end
end

-- 🛡️ منع الفلينج + معاقبة اللي يحاول
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    local root = char:WaitForChild("HumanoidRootPart")
    RunService.Heartbeat:Connect(function()
        if ProtectionEnabled then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = v.Character.HumanoidRootPart
                    if hrp.Velocity.magnitude > 250 then
                        -- إلغاء الفلينج
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.RotVelocity = Vector3.new(0, 0, 0)
                        -- معاقبة: طيران برا الماب 🚀
                        hrp.CFrame = CFrame.new(0, 9999, 0)
                        warn("🚀 لاعب حاول يعمل Fling/Freeze وتم طيره - حكومه 😁🍷")
                    end
                end
            end
        end
    end)
end)

-- 🛡️ منع التجميد (لو حد جمدك)
RunService.Heartbeat:Connect(function()
    if ProtectionEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if hrp.Anchored then
            hrp.Anchored = false
            warn("🛡️ محاولة تجميد تم منعها - حكومه 😁🍷")
        end
    end
end)

warn("✅ سكربت حماية حكومه شغال 😁🍷")
