local plr = game:GetService("Players").LocalPlayer
local players = game:GetService("Players")

local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.Name = "GS4GovUI"
gui.ResetOnSpawn = false

-- زر فتح القائمة (قابل للسحب)
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenButton"
openBtn.Parent = gui
openBtn.Size = UDim2.new(0, 180, 0, 50)
openBtn.Position = UDim2.new(0, 20, 0.45, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
openBtn.TextColor3 = Color3.fromRGB(0, 255, 127)
openBtn.Text = "📋 اضغط لفتح"
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBlack
openBtn.AutoButtonColor = true
openBtn.Active = true
openBtn.Draggable = true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 10)

-- الإطار الرئيسي
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 400, 0, 280)
main.Position = UDim2.new(0.5, -200, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- العنوان (الحقوق)
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "صنع حكومه GS4"
title.Font = Enum.Font.GothamBlack
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.TextScaled = true
title.ClipsDescendants = true
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)

-- صندوقين للبحث
local box1 = Instance.new("TextBox", main)
box1.PlaceholderText = "اسم اللاعب رقم 1"
box1.Size = UDim2.new(0.94, 0, 0, 34)
box1.Position = UDim2.new(0.03, 0, 0.2, 0)
box1.ClearTextOnFocus = false
box1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
box1.TextColor3 = Color3.new(1, 1, 1)
box1.Font = Enum.Font.GothamSemibold
box1.TextScaled = true
Instance.new("UICorner", box1).CornerRadius = UDim.new(0, 8)

local box2 = box1:Clone()
box2.Parent = main
box2.PlaceholderText = "اسم اللاعب رقم 2"
box2.Position = UDim2.new(0.03, 0, 0.35, 0)

-- صور اللاعبين
local thumb1 = Instance.new("ImageLabel", main)
thumb1.Size = UDim2.new(0, 60, 0, 60)
thumb1.Position = UDim2.new(0.05, 0, 0.53, 0)
thumb1.BackgroundTransparency = 1

local thumb2 = thumb1:Clone()
thumb2.Parent = main
thumb2.Position = UDim2.new(0.55, 0, 0.53, 0)

-- أسماء كاملة
local name1 = Instance.new("TextLabel", main)
name1.Position = UDim2.new(0.22, 0, 0.53, 0)
name1.Size = UDim2.new(0.3, 0, 0, 25)
name1.BackgroundTransparency = 1
name1.Font = Enum.Font.GothamBold
name1.TextColor3 = Color3.fromRGB(255, 255, 255)
name1.TextScaled = true

local name2 = name1:Clone()
name2.Parent = main
name2.Position = UDim2.new(0.72, 0, 0.53, 0)

-- دخول وخروج
local join1 = Instance.new("TextLabel", main)
join1.Size = UDim2.new(0.4, 0, 0, 20)
join1.Position = UDim2.new(0.22, 0, 0.63, 0)
join1.BackgroundTransparency = 1
join1.Font = Enum.Font.GothamBold
join1.TextColor3 = Color3.fromRGB(0, 255, 127)
join1.TextScaled = true
join1.Text = "الدخول: 0"

local leave1 = join1:Clone()
leave1.Position = UDim2.new(0.22, 0, 0.71, 0)
leave1.TextColor3 = Color3.fromRGB(255, 99, 99)
leave1.Text = "الخروج: 0"

local join2 = join1:Clone()
join2.Parent = main
join2.Position = UDim2.new(0.72, 0, 0.63, 0)
join2.Text = "الدخول: 0"

local leave2 = leave1:Clone()
leave2.Parent = main
leave2.Position = UDim2.new(0.72, 0, 0.71, 0)
leave2.Text = "الخروج: 0"

join1.Parent = main
leave1.Parent = main

-- تتبع الأسماء والصور
local tracked1, tracked2 = nil, nil
local joinCount1, leaveCount1 = 0, 0
local joinCount2, leaveCount2 = 0, 0

local function updatePlayer(box, thumb, nameLbl, index)
	for _, p in pairs(players:GetPlayers()) do
		if p.Name:lower():find(box.Text:lower()) then
			if index == 1 then
				tracked1 = p
				thumb1.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=420&height=420&format=png"
				name1.Text = p.Name
			else
				tracked2 = p
				thumb2.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=420&height=420&format=png"
				name2.Text = p.Name
			end
			break
		end
	end
end

box1:GetPropertyChangedSignal("Text"):Connect(function()
	updatePlayer(box1, thumb1, name1, 1)
end)

box2:GetPropertyChangedSignal("Text"):Connect(function()
	updatePlayer(box2, thumb2, name2, 2)
end)

-- الدخول والخروج
players.PlayerAdded:Connect(function(p)
	if tracked1 and p.Name == tracked1.Name then
		joinCount1 += 1
		join1.Text = "الدخول: "..joinCount1
	end
	if tracked2 and p.Name == tracked2.Name then
		joinCount2 += 1
		join2.Text = "الدخول: "..joinCount2
	end
end)

players.PlayerRemoving:Connect(function(p)
	if tracked1 and p.Name == tracked1.Name then
		leaveCount1 += 1
		leave1.Text = "الخروج: "..leaveCount1
	end
	if tracked2 and p.Name == tracked2.Name then
		leaveCount2 += 1
		leave2.Text = "الخروج: "..leaveCount2
	end
end)

-- فتح/قفل القائمة
openBtn.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)
