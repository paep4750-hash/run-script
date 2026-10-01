-- STREAMING_CHUNK:Initializing Services and Core Variables...
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui") or CoreGui
-- Cleanup existing UI if present
if playerGui:FindFirstChild("ApexCommercialUI") then
playerGui.ApexCommercialUI:Destroy()
end
-- STREAMING_CHUNK:Creating Commercial ScreenGui & Theme Tokens...
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ApexCommercialUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui
-- Color Theme (Cyberpunk / Neon Violet Palette)
local Theme = {
Background = Color3.fromRGB(12, 12, 18),
CardBg = Color3.fromRGB(18, 18, 26),
Accent = Color3.fromRGB(130, 80, 255),
AccentGlow = Color3.fromRGB(160, 110, 255),
Success = Color3.fromRGB(60, 210, 130),
TextWhite = Color3.fromRGB(255, 255, 255),
TextMuted = Color3.fromRGB(140, 140, 175),
Border = Color3.fromRGB(50, 40, 80)
}
-- STREAMING_CHUNK:Building Key System Window...
local keyFrame = Instance.new("Frame")
keyFrame.Name = "KeySystem"
keyFrame.Size = UDim2.new(0, 460, 0, 310)
keyFrame.Position = UDim2.new(0.5, -230, 0.5, -155)
keyFrame.BackgroundColor3 = Theme.Background
keyFrame.BorderSizePixel = 0
keyFrame.Active = true
keyFrame.Parent = screenGui
local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 16)
keyCorner.Parent = keyFrame
local keyStroke = Instance.new("UIStroke")
keyStroke.Color = Theme.Accent
keyStroke.Thickness = 2
keyStroke.Parent = keyFrame
-- Key Title & Badge
local keyHeader = Instance.new("TextLabel")
keyHeader.Size = UDim2.new(1, 0, 0, 60)
keyHeader.BackgroundTransparency = 1
keyHeader.Font = Enum.Font.GothamBold
keyHeader.Text = "⚡ APEX COMMERCIAL HUB"
keyHeader.TextColor3 = Theme.TextWhite
keyHeader.TextSize = 18
keyHeader.Parent = keyFrame
local keySub = Instance.new("TextLabel")
keySub.Size = UDim2.new(1, 0, 0, 25)
keySub.Position = UDim2.new(0, 0, 0, 45)
keySub.BackgroundTransparency = 1
keySub.Font = Enum.Font.GothamMedium
keySub.Text = "Test Key: VIP-APEX-2026 (Click Copy or Type)"
keySub.TextColor3 = Theme.Success
keySub.TextSize = 12
keySub.Parent = keyFrame
local keyInputBox = Instance.new("TextBox")
keyInputBox.Size = UDim2.new(0.85, 0, 0, 50)
keyInputBox.Position = UDim2.new(0.075, 0, 0, 90)
keyInputBox.BackgroundColor3 = Theme.CardBg
keyInputBox.BorderSizePixel = 0
keyInputBox.Font = Enum.Font.GothamMedium
keyInputBox.PlaceholderText = "Enter license key..."
keyInputBox.PlaceholderColor3 = Theme.TextMuted
keyInputBox.Text = "VIP-APEX-2026"
keyInputBox.TextColor3 = Theme.TextWhite
keyInputBox.TextSize = 14
keyInputBox.ClearTextOnFocus = false
keyInputBox.Parent = keyFrame
local kiCorner = Instance.new("UICorner")
kiCorner.CornerRadius = UDim.new(0, 10)
kiCorner.Parent = keyInputBox
local kiStroke = Instance.new("UIStroke")
kiStroke.Color = Theme.Border
kiStroke.Parent = keyInputBox
local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(0.41, 0, 0, 45)
verifyBtn.Position = UDim2.new(0.075, 0, 0, 160)
verifyBtn.BackgroundColor3 = Theme.Accent
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.Text = "Verify License"
verifyBtn.TextColor3 = Theme.TextWhite
verifyBtn.TextSize = 14
verifyBtn.AutoButtonColor = true
verifyBtn.Active = true
verifyBtn.Parent = keyFrame
local vbCorner = Instance.new("UICorner")
vbCorner.CornerRadius = UDim.new(0, 10)
vbCorner.Parent = verifyBtn
local copyKeyBtn = Instance.new("TextButton")
copyKeyBtn.Size = UDim2.new(0.41, 0, 0, 45)
copyKeyBtn.Position = UDim2.new(0.515, 0, 0, 160)
copyKeyBtn.BackgroundColor3 = Theme.CardBg
copyKeyBtn.Font = Enum.Font.GothamBold
copyKeyBtn.Text = "Copy Key"
copyKeyBtn.TextColor3 = Theme.TextMuted
copyKeyBtn.TextSize = 14
copyKeyBtn.AutoButtonColor = true
copyKeyBtn.Active = true
copyKeyBtn.Parent = keyFrame
local ckCorner = Instance.new("UICorner")
ckCorner.CornerRadius = UDim.new(0, 10)
ckCorner.Parent = copyKeyBtn
local ckStroke = Instance.new("UIStroke")
ckStroke.Color = Theme.Border
ckStroke.Parent = copyKeyBtn
local keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, 0, 0, 30)
keyStatus.Position = UDim2.new(0, 0, 0, 230)
keyStatus.BackgroundTransparency = 1
keyStatus.Font = Enum.Font.Gotham
keyStatus.Text = "Status: Ready for activation"
keyStatus.TextColor3 = Theme.TextMuted
keyStatus.TextSize = 12
keyStatus.Parent = keyFrame
-- STREAMING_CHUNK:Building Main Dashboard Window Frame...
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainDashboard"
mainFrame.Size = UDim2.new(0, 620, 0, 400)
mainFrame.Position = UDim2.new(0.5, -310, 0.5, -200)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Parent = screenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Theme.Accent
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame
-- Topbar Header
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
-- Close / Hide Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "×"
closeBtn.TextColor3 = Theme.TextWhite
closeBtn.TextSize = 14
closeBtn.AutoButtonColor = true
closeBtn.Active = true
closeBtn.Parent = topBar
local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(1, 0)
cbCorner.Parent = closeBtn
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
-- STREAMING_CHUNK:Creating Tab Generation Utility...
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
-- STREAMING_CHUNK:Building Home & Settings Tabs...
local homeTab = createTabContent("🏠 Dashboard")
local settingsTab = createTabContent("⚙️ Settings")
-- Notification system function
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
-- Home Tab Content Elements
local welcomeCard = Instance.new("TextLabel")
welcomeCard.Size = UDim2.new(1, 0, 0, 45)
welcomeCard.BackgroundTransparency = 1
welcomeCard.Font = Enum.Font.GothamBold
welcomeCard.Text = "Welcome, " .. player.Name .. "!"
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
sendNotification("Apex UI is fully operational & commercial-ready!")
end)
-- STREAMING_CHUNK:Configuring Settings Tab Controls & Game Stats...
local settingsHeader = Instance.new("TextLabel")
settingsHeader.Size = UDim2.new(1, 0, 0, 35)
settingsHeader.BackgroundTransparency = 1
settingsHeader.Font = Enum.Font.GothamBold
settingsHeader.Text = "User Preferences"
settingsHeader.TextColor3 = Theme.TextWhite
settingsHeader.TextSize = 14
settingsHeader.TextXAlignment = Enum.TextXAlignment.Left
settingsHeader.Parent = settingsTab
-- Toggle Setting Component
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
-- Game Stats Monitor Header
local statsHeader = Instance.new("TextLabel")
statsHeader.Size = UDim2.new(1, 0, 0, 35)
statsHeader.BackgroundTransparency = 1
statsHeader.Font = Enum.Font.GothamBold
statsHeader.Text = "📊 Game Stats Monitor (Configurable)"
statsHeader.TextColor3 = Theme.TextWhite
statsHeader.TextSize = 14
statsHeader.TextXAlignment = Enum.TextXAlignment.Left
statsHeader.Parent = settingsTab
-- Game Stats Card Container
local statsCard = Instance.new("Frame")
statsCard.Size = UDim2.new(1, 0, 0, 110)
statsCard.BackgroundColor3 = Theme.CardBg
statsCard.Parent = settingsTab
local scCardCorner = Instance.new("UICorner")
scCardCorner.CornerRadius = UDim.new(0, 10)
scCardCorner.Parent = statsCard
local scCardStroke = Instance.new("UIStroke")
scCardStroke.Color = Theme.Border
scCardStroke.Parent = statsCard
-- Coin Status Label
local coinStatLabel = Instance.new("TextLabel")
coinStatLabel.Size = UDim2.new(1, -30, 0, 30)
coinStatLabel.Position = UDim2.new(0, 15, 0, 15)
coinStatLabel.BackgroundTransparency = 1
coinStatLabel.Font = Enum.Font.GothamMedium
coinStatLabel.Text = "🪙 Coins: [Connect your game variable]"
coinStatLabel.TextColor3 = Theme.TextMuted
coinStatLabel.TextSize = 12
coinStatLabel.TextXAlignment = Enum.TextXAlignment.Left
coinStatLabel.Parent = statsCard
-- Gem Status Label
local gemStatLabel = Instance.new("TextLabel")
gemStatLabel.Size = UDim2.new(1, -30, 0, 30)
gemStatLabel.Position = UDim2.new(0, 15, 0, 45)
gemStatLabel.BackgroundTransparency = 1
gemStatLabel.Font = Enum.Font.GothamMedium
gemStatLabel.Text = "💎 Gems: [Connect your game variable]"
gemStatLabel.TextColor3 = Theme.TextMuted
gemStatLabel.TextSize = 12
gemStatLabel.TextXAlignment = Enum.TextXAlignment.Left
gemStatLabel.Parent = statsCard
-- Custom Status Label (Level / Power)
local customStatLabel = Instance.new("TextLabel")
customStatLabel.Size = UDim2.new(1, -30, 0, 30)
customStatLabel.Position = UDim2.new(0, 15, 0, 75)
customStatLabel.BackgroundTransparency = 1
customStatLabel.Font = Enum.Font.GothamMedium
customStatLabel.Text = "⭐ Status: [Connect your game variable]"
customStatLabel.TextColor3 = Theme.TextMuted
customStatLabel.TextSize = 12
customStatLabel.TextXAlignment = Enum.TextXAlignment.Left
customStatLabel.Parent = statsCard
-- STREAMING_CHUNK:Adding Live Stats Update Loop (For Buyers to Customize)...
task.spawn(function()
while task.wait(1) do
pcall(function()
-- =========================================================================
-- 🛠️ คำแนะนำสำหรับผู้ซื้อนำไปปรับใช้ (Instructions for Buyers):
-- ให้เปลี่ยน path ด้านล่างนี้ให้ตรงกับ Leaderstats หรือค่าข้อมูลในเกมที่คุณต้องการดึงมาแสดง
-- ตัวอย่างเช่น: player:WaitForChild("leaderstats"):WaitForChild("Coins").Value
-- =========================================================================
local leaderstats = player:FindFirstChild("leaderstats")
if leaderstats then
local coins = leaderstats:FindFirstChild("Coins") or leaderstats:FindFirstChild("Gold")
local gems = leaderstats:FindFirstChild("Gems") or leaderstats:FindFirstChild("Diamonds")
if coins then
coinStatLabel.Text = "🪙 Coins: " .. tostring(coins.Value)
coinStatLabel.TextColor3 = Theme.TextWhite
end
if gems then
gemStatLabel.Text = "💎 Gems: " .. tostring(gems.Value)
gemStatLabel.TextColor3 = Theme.TextWhite
end
end
end)
end
end)
-- STREAMING_CHUNK:Creating Fixed Bottom-Left Toggle & Window Controls...
local floatingBtn = Instance.new("TextButton")
floatingBtn.Name = "ApexFloatingToggle"
floatingBtn.Size = UDim2.new(0, 48, 0, 48)
-- ล็อกตำแหน่งไว้ที่มุมซ้ายล่างของจอแบบตายตัว ไม่ขยับ ไม่บังปุ่มอัปเกรด
floatingBtn.Position = UDim2.new(0, 20, 1, -68)
floatingBtn.BackgroundColor3 = Theme.CardBg
floatingBtn.Font = Enum.Font.GothamBold
floatingBtn.Text = "✅"
floatingBtn.TextColor3 = Theme.TextWhite
floatingBtn.TextSize = 20
floatingBtn.Visible = false
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
-- Floating Button Interaction State
local isUIVisible = false
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
closeBtn.MouseButton1Click:Connect(function()
isUIVisible = false
mainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true, function()
mainFrame.Visible = false
end)
end)
-- Key Verification Execution Logic
local function verifyKeyAction()
local inputKey = keyInputBox.Text
if inputKey == "VIP-APEX-2026" then
keyStatus.TextColor3 = Theme.Success
keyStatus.Text = "Status: Key Verified! Launching..."
task.wait(0.4)
keyFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true, function()
keyFrame.Visible = false
floatingBtn.Visible = true
isUIVisible = true
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Visible = true
mainFrame:TweenSize(UDim2.new(0, 620, 0, 400), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.4, true)
end)
else
keyStatus.TextColor3 = Color3.fromRG
keyStatus.Text = "Status: Invalid Key! Use VIP-APEX-2026"
end
end
verifyBtn.MouseButton1Click:Connect(verifyKeyAction)
keyInputBox.FocusLost:Connect(function(enterPressed)
if enterPressed then
verifyKeyAction()
end
end)
copyKeyBtn.MouseButton1Click:Connect(function()
if setclipboard then
setclipboard("VIP-APEX-2026")
keyStatus.TextColor3 = Theme.Accent
keyStatus.Text = "Status: License key copied to clipboard!"
else
keyStatus.Text = "Status: Clipboard unsupported. Key: VIP-APEX-2026"
end
end)
-- STREAMING_CHUNK:Implementing Window Draggable Functionality...
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
