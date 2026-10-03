-- STREAMING_CHUNK:Initializing Services and Core Variables...
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui") or CoreGui
if playerGui:FindFirstChild("ApexCommercialUI") then
playerGui.ApexCommercialUI:Destroy()
end
-- STREAMING_CHUNK:Creating Commercial ScreenGui & Theme Tokens...
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ApexCommercialUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui
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
keyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
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
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
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
local homeTab = createTabContent("🏠 Dashboard")
local tdsTab = createTabContent("🤖 TDS Auto")
local settingsTab = createTabContent("⚙️ Settings")
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
-- Wave Tracker & Status Card
local waveStatusRow = Instance.new("Frame")
waveStatusRow.Size = UDim2.new(1, 0, 0, 50)
waveStatusRow.BackgroundColor3 = Theme.CardBg
waveStatusRow.Parent = tdsTab
local wsrCorner = Instance.new("UICorner")
wsrCorner.CornerRadius = UDim.new(0, 10)
wsrCorner.Parent = waveStatusRow
local wsrStroke = Instance.new("UIStroke")
wsrStroke.Color = Theme.Border
wsrStroke.Parent = waveStatusRow
local waveStatusLabel = Instance.new("TextLabel")
waveStatusLabel.Size = UDim2.new(1, -20, 1, 0)
waveStatusLabel.Position = UDim2.new(0, 15, 0, 0)
waveStatusLabel.BackgroundTransparency = 1
waveStatusLabel.Font = Enum.Font.GothamMedium
waveStatusLabel.Text = "Current Wave: Scanning..."
waveStatusLabel.TextColor3 = Theme.AccentGlow
waveStatusLabel.TextSize = 13
waveStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
waveStatusLabel.Parent = waveStatusRow
-- Live Wave Detector (scans Workspace / ReplicatedStorage or UI text)
task.spawn(function()
while true do
pcall(function()
-- Scan for wave indicators in PlayerGui or Game State
local waveFound = false
for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
if gui:IsA("TextLabel") and (gui.Text:find("คลื่น:") or gui.Text:lower():find("wave")) then
waveStatusLabel.Text = "Status: " .. gui.Text
waveFound = true
break
end
end
if not waveFound then
waveStatusLabel.Text = "Status: Waiting for game state..."
end
end)
task.wait(1)
end
end)
local autoSkipRow = Instance.new("Frame")
autoSkipRow.Size = UDim2.new(1, 0, 0, 55)
autoSkipRow.BackgroundColor3 = Theme.CardBg
autoSkipRow.Parent = tdsTab
local asrCorner = Instance.new("UICorner")
asrCorner.CornerRadius = UDim.new(0, 10)
asrCorner.Parent = autoSkipRow
local asrStroke = Instance.new("UIStroke")
asrStroke.Color = Theme.Border
asrStroke.Parent = autoSkipRow
local asrLabel = Instance.new("TextLabel")
asrLabel.Size = UDim2.new(0.7, 0, 1, 0)
asrLabel.Position = UDim2.new(0, 15, 0, 0)
asrLabel.BackgroundTransparency = 1
asrLabel.Font = Enum.Font.GothamMedium
asrLabel.Text = "Auto Skip Waves (Cobalt Engine)"
asrLabel.TextColor3 = Theme.TextWhite
asrLabel.TextSize = 13
asrLabel.TextXAlignment = Enum.TextXAlignment.Left
asrLabel.Parent = autoSkipRow
local autoSkipSwitch = Instance.new("TextButton")
autoSkipSwitch.Size = UDim2.new(0, 48, 0, 26)
autoSkipSwitch.Position = UDim2.new(1, -60, 0.5, -13)
autoSkipSwitch.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
autoSkipSwitch.Text = ""
autoSkipSwitch.AutoButtonColor = false
autoSkipSwitch.Active = true
autoSkipSwitch.Parent = autoSkipRow
local atsCorner = Instance.new("UICorner")
atsCorner.CornerRadius = UDim.new(1, 0)
atsCorner.Parent = autoSkipSwitch
local autoSkipDot = Instance.new("Frame")
autoSkipDot.Size = UDim2.new(0, 20, 0, 20)
autoSkipDot.Position = UDim2.new(0, 3, 0.5, -10)
autoSkipDot.BackgroundColor3 = Theme.TextWhite
autoSkipDot.Parent = autoSkipSwitch
local atdCorner = Instance.new("UICorner")
atdCorner.CornerRadius = UDim.new(1, 0)
atdCorner.Parent = autoSkipDot
local isAutoSkipActive = false
task.spawn(function()
while true do
if isAutoSkipActive then
pcall(function()
local remoteFunction = ReplicatedStorage:FindFirstChild("RemoteFunction")
if remoteFunction then
remoteFunction:InvokeServer("Voting", "Skip")
end
end)
end
task.wait(1.5)
end
end)
autoSkipSwitch.MouseButton1Click:Connect(function()
isAutoSkipActive = not isAutoSkipActive
if isAutoSkipActive then
TweenService:Create(autoSkipSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Success}):Play()
autoSkipDot:TweenPosition(UDim2.new(1, -23, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
sendNotification("Auto Wave Skip Enabled")
else
TweenService:Create(autoSkipSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}):Play()
autoSkipDot:TweenPosition(UDim2.new(0, 3, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
sendNotification("Auto Wave Skip Disabled")
end
end)
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
-- STREAMING_CHUNK:Creating Fixed Bottom-Left Toggle Button...
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
local function verifyKeyAction()
local inputKey = keyInputBox.Text
if inputKey == "VIP-APEX-2026" then
keyStatus.TextColor3 = Theme.Success
keyStatus.Text = "Status: Key Verified! Launching..."
task.wait(0.3)
keyFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true, function()
keyFrame.Visible = false
floatingBtn.Visible = true
isUIVisible = true
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Visible = true
mainFrame:TweenSize(UDim2.new(0, 620, 0, 400), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.4, true)
end)
else
keyStatus.TextColor3 = Color3.fromRGB(230, 60, 60)
keyStatus.Text = "Status: Invalid Key! Use VIP-APEX-2026"
end
end
verifyBtn.MouseButton1Click:Connect(verifyKeyAction)
keyInputBox.FocusLost:Connect(function(enterPressed)
if enterPressed then
verifyKeyAction()
end
end)
copyKeyBtn.MouseButton1ContextAction = nil
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
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UsageContext == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.Touch then
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
