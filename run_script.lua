-- // Services & Cleanup
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("ApexCommercialUI") then
PlayerGui.ApexCommercialUI:Destroy()
end
-- // Color Theme (Cyberpunk / Neon Violet Palette)
local Theme = {
Background = Color3.fromRGB(12, 12, 18),
CardBg = Color3.fromRGB(18, 18, 26),
Accent = Color3.fromRGB(130, 80, 255),
Success = Color3.fromRGB(60, 210, 130),
TextWhite = Color3.fromRGB(255, 255, 255),
TextMuted = Color3.fromRGB(140, 140, 175),
Border = Color3.fromRGB(50, 40, 80)
}
-- // Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ApexCommercialUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui
-- // Main Dashboard Window Frame (เปิดขึ้นมาทันที ตรงกลางจอเป๊ะๆ)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainDashboard"
mainFrame.Size = UDim2.new(0, 620, 0, 400)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = true
mainFrame.Active = true
mainFrame.Parent = screenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Theme.Accent
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame
-- Topbar Header (Draggable Handle)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Theme.CardBg
topBar.BorderSizePixel = 0
topBar.Active = true
topBar.Parent = mainFrame
local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 16)
tbCorner.Parent = topBar
local tbFix = Instance.new("Frame")
tbFix.Size = UDim2.new(1, 0, 0, 10)
tbFix.Position = UDim2.new(0, 0, 1, -10)
tbFix.BackgroundColor3 = Theme.CardBg
tbFix.BorderSizePixel = 0
tbFix.Parent = topBar
local brandLabel = Instance.new("TextLabel")
brandLabel.Size = UDim2.new(0, 250, 1, 0)
brandLabel.Position = UDim2.new(0, 18, 0, 0)
brandLabel.BackgroundTransparency = 1
brandLabel.Font = Enum.Font.GothamBold
brandLabel.Text = "💎 APEX PREMIUM SUITE"
brandLabel.TextColor3 = Theme.TextWhite
brandLabel.TextSize = 15
brandLabel.TextXAlignment = Enum.TextXAlignment.Left
brandLabel.Parent = topBar
-- Sidebar Tabs Navigation
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 160, 1, -50)
sidebar.Position = UDim2.new(0, 0, 0, 50)
sidebar.BackgroundColor3 = Theme.CardBg
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
local sideLayout = Instance.new("UIListLayout")
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding = UDim.new(0, 6)
sideLayout.Parent = sidebar
local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 12)
sidePad.PaddingLeft = UDim.new(0, 12)
sidePad.PaddingRight = UDim.new(0, 12)
sidePad.Parent = sidebar
-- Content Container
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -160, 1, -50)
container.Position = UDim2.new(0, 160, 0, 50)
container.BackgroundTransparency = 1
container.Parent = mainFrame
local registeredTabs = {}
local function createTabContent(tabName)
local tabBtn = Instance.new("TextButton")
tabBtn.Size = UDim2.new(1, 0, 0, 42)
tabBtn.BackgroundColor3 = Theme.Background
tabBtn.BorderSizePixel = 0
tabBtn.Font = Enum.Font.GothamMedium
tabBtn.Text = tabName
tabBtn.TextColor3 = Theme.TextMuted
tabBtn.TextSize = 13
tabBtn.AutoButtonColor = true
tabBtn.Active = true
tabBtn.Parent = sidebar
local tbBtnCorner = Instance.new("UICorner")
tbBtnCorner.CornerRadius = UDim.new(0, 10)
tbBtnCorner.Parent = tabBtn
local scrollContent = Instance.new("ScrollingFrame")
scrollContent.Size = UDim2.new(1, 0, 1, 0)
scrollContent.BackgroundTransparency = 1
scrollContent.BorderSizePixel = 0
scrollContent.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollContent.ScrollBarThickness = 4
scrollContent.Visible = false
scrollContent.Parent = container
local scLayout = Instance.new("UIListLayout")
scLayout.SortOrder = Enum.SortOrder.LayoutOrder
scLayout.Padding = UDim.new(0, 12)
scLayout.Parent = scrollContent
local scPad = Instance.new("UIPadding")
scPad.PaddingTop = UDim.new(0, 16)
scPad.PaddingLeft = UDim.new(0, 16)
scPad.PaddingRight = UDim.new(0, 16)
scPad.PaddingBottom = UDim.new(0, 16)
scPad.Parent = scrollContent
scLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
scrollContent.CanvasSize = UDim2.new(0, 0, 0, scLayout.AbsoluteContentSize.Y + 32)
end)
tabBtn.MouseButton1Click:Connect(function()
for _, t in pairs(registeredTabs) do
TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background, TextColor3 = Theme.TextMuted}):Play()
t.Content.Visible = false
end
TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.TextWhite}):Play()
scrollContent.Visible = true
end)
table.insert(registeredTabs, {Btn = tabBtn, Content = scrollContent})
if #registeredTabs == 1 then
tabBtn.BackgroundColor3 = Theme.Accent
tabBtn.TextColor3 = Theme.TextWhite
scrollContent.Visible = true
end
return scrollContent
end
-- Tabs Initialization
local homeTab = createTabContent("🏠 Dashboard")
local tdsTab = createTabContent("🤖 TDS Auto")
local settingsTab = createTabContent("⚙️ Settings")
-- Notification System Function
local function sendNotification(text)
local notif = Instance.new("Frame")
notif.Size = UDim2.new(0, 280, 0, 55)
notif.Position = UDim2.new(1, 20, 1, -80)
notif.BackgroundColor3 = Theme.CardBg
notif.Parent = screenGui
local nCorner = Instance.new("UICorner")
nCorner.CornerRadius = UDim.new(0, 10)
nCorner.Parent = notif
local nStroke = Instance.new("UIStroke")
nStroke.Color = Theme.Accent
nStroke.Parent = notif
local nText = Instance.new("TextLabel")
nText.Size = UDim2.new(1, 0, 1, 0)
nText.BackgroundTransparency = 1
nText.Font = Enum.Font.GothamMedium
nText.Text = text
nText.TextColor3 = Theme.TextWhite
nText.TextSize = 13
nText.Parent = notif
notif:TweenPosition(UDim2.new(1, -300, 1, -80), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.3, true)
task.delay(2.8, function()
notif:TweenPosition(UDim2.new(1, 20, 1, -80), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true, function()
notif:Destroy()
end)
end)
end
-- Home Tab Content
local welcomeCard = Instance.new("TextLabel")
welcomeCard.Size = UDim2.new(1, 0, 0, 45)
welcomeCard.BackgroundTransparency = 1
welcomeCard.Font = Enum.Font.GothamBold
welcomeCard.Text = "Welcome, " .. Player.Name .. "!"
welcomeCard.TextColor3 = Theme.TextWhite
welcomeCard.TextSize = 15
welcomeCard.TextXAlignment = Enum.TextXAlignment.Left
welcomeCard.Parent = homeTab
local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(1, 0, 0, 48)
actionBtn.BackgroundColor3 = Theme.CardBg
actionBtn.Font = Enum.Font.GothamBold
actionBtn.Text = "🚀 Test System Notification"
actionBtn.TextColor3 = Theme.TextWhite
actionBtn.TextSize = 14
actionBtn.AutoButtonColor = true
actionBtn.Active = true
actionBtn.Parent = homeTab
local abCorner = Instance.new("UICorner")
abCorner.CornerRadius = UDim.new(0, 10)
abCorner.Parent = actionBtn
local abStroke = Instance.new("UIStroke")
abStroke.Color = Theme.Border
abStroke.Parent = actionBtn
actionBtn.MouseButton1Click:Connect(function()
sendNotification("Apex UI is fully operational & ready!")
end)
-- TDS Auto Tab Content
local tdsHeader = Instance.new("TextLabel")
tdsHeader.Size = UDim2.new(1, 0, 0, 35)
tdsHeader.BackgroundTransparency = 1
tdsHeader.Font = Enum.Font.GothamBold
tdsHeader.Text = "Tower Defense Simulator Automation"
tdsHeader.TextColor3 = Theme.TextWhite
tdsHeader.TextSize = 14
tdsHeader.TextXAlignment = Enum.TextXAlignment.Left
tdsHeader.Parent = tdsTab
-- Hardcore Macro Execution Button
local hardcoreBtn = Instance.new("TextButton")
hardcoreBtn.Size = UDim2.new(1, 0, 0, 48)
hardcoreBtn.BackgroundColor3 = Theme.CardBg
hardcoreBtn.Font = Enum.Font.GothamBold
hardcoreBtn.Text = "▶️ Execute Hardcore Macro Script"
hardcoreBtn.TextColor3 = Theme.Success
hardcoreBtn.TextSize = 13
hardcoreBtn.AutoButtonColor = true
hardcoreBtn.Active = true
hardcoreBtn.Parent = tdsTab
local hbCorner = Instance.new("UICorner")
hbCorner.CornerRadius = UDim.new(0, 10)
hbCorner.Parent = hardcoreBtn
local hbStroke = Instance.new("UIStroke")
hbStroke.Color = Theme.Border
hbStroke.Parent = hardcoreBtn
hardcoreBtn.MouseButton1Click:Connect(function()
sendNotification("Hardcore Macro Sequence Initialized!")
task.spawn(function()
pcall(function()
local Event = ReplicatedStorage:FindFirstChild("RemoteFunction")
if not Event then return end
Event:InvokeServer("Troops", "Place", { Rotation = CFrame.new(0,0,0,1,-0,0,0,1,-0,0,0,1), Position = Vector3.new(17.569147109985352, 0.99994909763336182, 19.149379730224609) }, "Electroshocker")
task.wait(1.5)
local towers = workspace:FindFirstChild("Towers")
if towers and towers:GetChildren()[1] then
Event:InvokeServer("Troops", "Upgrade", "Set", { Troop = towers:GetChildren()[1] })
end
task.wait(1.5)
Event:InvokeServer("Troops", "Place", { Rotation = CFrame.new(0,0,0,1,-0,0,0,1,-0,0,0,1), Position = Vector3.new(18.405981063842773, 0.99995207786560059, 14.898340225219727) }, "Electroshocker")
task.wait(1.5)
towers = workspace:FindFirstChild("Towers")
if towers and towers:GetChildren()[2] then
Event:InvokeServer("Troops", "Upgrade", "Set", { Troop = towers:GetChildren()[2] })
end
task.wait(1.5)
towers = workspace:FindFirstChild("Towers")
if towers and towers:GetChildren()[3] then
Event:InvokeServer("Troops", "Upgrade", "Set", { Troop = towers:GetChildren()[3] })
end
task.wait(1.5)
Event:InvokeServer("Troops", "Place", { Rotation = CFrame.new(0,0,0,1,-0,0,0,1,-0,0,0,1), Position = Vector3.new(6.2736315727233887, 3.5999782085418701, 18.636436462402344) }, "Engineer")
task.wait(1.5)
Event:InvokeServer("Troops", "Place", { Rotation = CFrame.new(0,0,0,1,-0,0,0,1,-0,0,0,1), Position = Vector3.new(3.0753617286682129, 3.5999782085418701, 18.906898498535156) }, "Engineer")
task.wait(1.5)
towers = workspace:FindFirstChild("Towers")
if towers and towers:GetChildren()[5] then
Event:InvokeServer("Troops", "Upgrade", "Set", { Troop = towers:GetChildren()[5] })
end
task.wait(1.5)
Event:InvokeServer("Troops", "Place", { Rotation = CFrame.new(0,0,0,1,-0,0,0,1,-0,0,0,1), Position = Vector3.new(9.3620901107788086, 3.5999886989593506, 16.302700042724609) }, "Engineer")
sendNotification("Hardcore Macro Sequence Completed!")
end)
end)
end)
-- Settings Tab Content
local settingsHeader = Instance.new("TextLabel")
settingsHeader.Size = UDim2.new(1, 0, 0, 35)
settingsHeader.BackgroundTransparency = 1
settingsHeader.Font = Enum.Font.GothamBold
settingsHeader.Text = "User Preferences"
settingsHeader.TextColor3 = Theme.TextWhite
settingsHeader.TextSize = 14
settingsHeader.TextXAlignment = Enum.TextXAlignment.Left
settingsHeader.Parent = settingsTab
local toggleRow = Instance.new("Frame")
toggleRow.Size = UDim2.new(1, 0, 0, 50)
toggleRow.BackgroundColor3 = Theme.CardBg
toggleRow.Parent = settingsTab
local trCorner = Instance.new("UICorner")
trCorner.CornerRadius = UDim.new(0, 10)
trCorner.Parent = toggleRow
local trStroke = Instance.new("UIStroke")
trStroke.Color = Theme.Border
trStroke.Parent = toggleRow
local trLabel = Instance.new("TextLabel")
trLabel.Size = UDim2.new(0.7, 0, 1, 0)
trLabel.Position = UDim2.new(0, 15, 0, 0)
trLabel.BackgroundTransparency = 1
trLabel.Font = Enum.Font.GothamMedium
trLabel.Text = "Enable Sound Effects"
trLabel.TextColor3 = Theme.TextWhite
trLabel.TextSize = 13
trLabel.TextXAlignment = Enum.TextXAlignment.Left
trLabel.Parent = toggleRow
local toggleSwitch = Instance.new("TextButton")
toggleSwitch.Size = UDim2.new(0, 48, 0, 26)
toggleSwitch.Position = UDim2.new(1, -60, 0.5, -13)
toggleSwitch.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
toggleSwitch.Text = ""
toggleSwitch.AutoButtonColor = false
toggleSwitch.Active = true
toggleSwitch.Parent = toggleRow
local tsCorner = Instance.new("UICorner")
tsCorner.CornerRadius = UDim.new(1, 0)
tsCorner.Parent = toggleSwitch
local toggleDot = Instance.new("Frame")
toggleDot.Size = UDim2.new(0, 20, 0, 20)
toggleDot.Position = UDim2.new(0, 3, 0.5, -10)
toggleDot.BackgroundColor3 = Theme.TextWhite
toggleDot.Parent = toggleSwitch
local tdCorner = Instance.new("UICorner")
tdCorner.CornerRadius = UDim.new(1, 0)
tdCorner.Parent = toggleDot
local isSoundEnabled = false
toggleSwitch.MouseButton1Click:Connect(function()
isSoundEnabled = not isSoundEnabled
if isSoundEnabled then
TweenService:Create(toggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Success}):Play()
toggleDot:TweenPosition(UDim2.new(1, -23, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
sendNotification("Sound effects enabled successfully")
else
TweenService:Create(toggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}):Play()
toggleDot:TweenPosition(UDim2.new(0, 3, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
sendNotification("Sound effects disabled")
end
end)
-- Fixed Bottom-Left Floating Toggle Button
local floatingBtn = Instance.new("TextButton")
floatingBtn.Name = "ApexFloatingToggle"
floatingBtn.Size = UDim2.new(0, 52, 0, 52)
floatingBtn.Position = UDim2.new(0, 25, 1, -75)
floatingBtn.AnchorPoint = Vector2.new(0, 0)
floatingBtn.BackgroundColor3 = Theme.CardBg
floatingBtn.Font = Enum.Font.GothamBold
floatingBtn.Text = "✅"
floatingBtn.TextColor3 = Theme.TextWhite
floatingBtn.TextSize = 22
floatingBtn.Visible = true
floatingBtn.AutoButtonColor = true
floatingBtn.Active = true
floatingBtn.Parent = screenGui
local fbCorner = Instance.new("UICorner")
fbCorner.CornerRadius = UDim.new(1, 0)
fbCorner.Parent = floatingBtn
local fbStroke = Instance.new("UIStroke")
fbStroke.Color = Theme.Accent
fbStroke.Thickness = 2
fbStroke.Parent = floatingBtn
local isUIVisible = true
floatingBtn.MouseButton1Click:Connect(function()
isUIVisible = not isUIVisible
if isUIVisible then
mainFrame.Visible = true
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame:TweenSize(UDim2.new(0, 620, 0, 400), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.3, true)
else
mainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true, function()
mainFrame.Visible = false
end)
end
end)
-- Implementing Window Draggable Functionality
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = mainFrame.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)
UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
RunService.RenderStepped:Connect(function()
if dragging and dragInput then
local delta = dragInput.Position - dragStart
mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
