-- GS4_Full_Obfuscated.lua
local P=game:GetService("Players").LocalPlayer
local PL=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
-- إنشاء RemoteEvents لو مش موجودة
local trackEvt=RS:FindFirstChild("GS4TrackEvent") or Instance.new("RemoteEvent",RS);trackEvt.Name="GS4TrackEvent"
local updateEvt=RS:FindFirstChild("GS4UpdateEvent") or Instance.new("RemoteEvent",RS);updateEvt.Name="GS4UpdateEvent"

-- GUI مضغوط
local G=Instance.new("ScreenGui",P:WaitForChild("PlayerGui"));G.Name="GS4GovUI";G.ResetOnSpawn=false
local B=Instance.new("TextButton",G);B.Size=UDim2.new(0,180,0,50);B.Position=UDim2.new(0,20,0.45,0)
B.BackgroundColor3=Color3.fromRGB(40,40,40);B.TextColor3=Color3.fromRGB(0,255,127);B.Text="📋 اضغط لفتح"
B.TextScaled=true;B.Font=Enum.Font.GothamBlack;B.AutoButtonColor=true;B.Active=true;B.Draggable=true
Instance.new("UICorner",B).CornerRadius=UDim.new(0,10)

local M=Instance.new("Frame",G);M.Size=UDim2.new(0,400,0,280);M.Position=UDim2.new(0.5,-200,0.4,0)
M.BackgroundColor3=Color3.fromRGB(20,20,20);M.BorderSizePixel=0;M.Active=true;M.Draggable=true;M.Visible=false
Instance.new("UICorner",M).CornerRadius=UDim.new(0,14)

local T=Instance.new("TextLabel",M);T.Size=UDim2.new(1,0,0,40);T.BackgroundColor3=Color3.fromRGB(30,30,30)
T.Text="صنع حكومه GS4";T.Font=Enum.Font.GothamBlack;T.TextColor3=Color3.fromRGB(0,170,255);T.TextScaled=true
Instance.new("UICorner",T).CornerRadius=UDim.new(0,14)

local E1=Instance.new("TextBox",M);E1.PlaceholderText="اسم اللاعب رقم 1";E1.Size=UDim2.new(0.94,0,0,34);E1.Position=UDim2.new(0.03,0,0.2,0)
E1.ClearTextOnFocus=false;E1.BackgroundColor3=Color3.fromRGB(40,40,40);E1.TextColor3=Color3.new(1,1,1)
E1.Font=Enum.Font.GothamSemibold;E1.TextScaled=true;Instance.new("UICorner",E1).CornerRadius=UDim.new(0,8)
local E2=E1:Clone();E2.Parent=M;E2.PlaceholderText="اسم اللاعب رقم 2";E2.Position=UDim2.new(0.03,0,0.35,0)

local Th1=Instance.new("ImageLabel",M);Th1.Size=UDim2.new(0,60,0,60);Th1.Position=UDim2.new(0.05,0,0.53,0);Th1.BackgroundTransparency=1
local Th2=Th1:Clone();Th2.Parent=M;Th2.Position=UDim2.new(0.55,0,0.53,0)

local N1=Instance.new("TextLabel",M);N1.Position=UDim2.new(0.22,0,0.53,0);N1.Size=UDim2.new(0.3,0,0,25);N1.BackgroundTransparency=1
N1.Font=Enum.Font.GothamBold;N1.TextColor3=Color3.fromRGB(255,255,255);N1.TextScaled=true
local N2=N1:Clone();N2.Parent=M;N2.Position=UDim2.new(0.72,0,0.53,0)

local J1=Instance.new("TextLabel",M);J1.Size=UDim2.new(0.4,0,0,20);J1.Position=UDim2.new(0.22,0,0.63,0);J1.BackgroundTransparency=1
J1.Font=Enum.Font.GothamBold;J1.TextColor3=Color3.fromRGB(0,255,127);J1.TextScaled=true;J1.Text="الدخول: 0"
local L1=J1:Clone();L1.Position=UDim2.new(0.22,0,0.71,0);L1.TextColor3=Color3.fromRGB(255,99,99);L1.Text="الخروج: 0"
local J2=J1:Clone();J2.Parent=M;J2.Position=UDim2.new(0.72,0,0.63,0);J2.Text="الدخول: 0"
local L2=L1:Clone();L2.Parent=M;L2.Position=UDim2.new(0.72,0,0.71,0);L2.Text="الخروج: 0"
J1.Parent=M;L1.Parent=M

-- إرسال طلب تتبع للسيرفر
E1:GetPropertyChangedSignal("Text"):Connect(function() trackEvt:FireServer(1,E1.Text) end)
E2:GetPropertyChangedSignal("Text"):Connect(function() trackEvt:FireServer(2,E2.Text) end)

-- استقبال التحديث من السيرفر
updateEvt.OnClientEvent:Connect(function(idx,info)
    if not info then return end
    local url = info.userId and ("https://www.roblox.com/headshot-thumbnail/image?userId="..info.userId.."&width=420&height=420&format=png") or ""
    if idx==1 then Th1.Image=url; N1.Text=info.name or "-"; J1.Text="الدخول: "..(info.joins or 0); L1.Text="الخروج: "..(info.leaves or 0)
    else Th2.Image=url; N2.Text=info.name or "-"; J2.Text="الدخول: "..(info.joins or 0); L2.Text="الخروج: "..(info.leaves or 0) end
end)

B.MouseButton1Click:Connect(function() M.Visible = not M.Visible end)
