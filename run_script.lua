-- // Services & Cleanup
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("ApexTDSUI") then
PlayerGui.ApexTDSUI:Destroy()
end
-- // Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexTDSUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui
-- // 1. KEY SYSTEM FRAME
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.new(0, 380, 0, 220)
KeyFrame.Position = UDim2.new(0.5, -190, 0.5, -110)
KeyFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
KeyFrame.BorderSizePixel = 0
KeyFrame.Parent = ScreenGui
local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 12)
KeyCorner.Parent = KeyFrame
local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(0, 255, 128)
KeyStroke.Transparency = 0.5
KeyStroke.Thickness = 1.5
KeyStroke.Parent = KeyFrame
local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 50)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "APEX TDS - LICENSE SYSTEM"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 16
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyFrame
local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.85, 0, 0, 45)
KeyBox.Position = UDim2.new(0.075, 0, 0.35, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "Enter license key..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
KeyBox.TextSize = 14
KeyBox.Font = Enum.Font.Gotham
KeyBox.Parent = KeyFrame
local KeyBoxCorner = Instance.new("UICorner")
KeyBoxCorner.CornerRadius = UDim.new(0, 8)
KeyBoxCorner.Parent = KeyBox
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.85, 0, 0, 45)
VerifyBtn.Position = UDim2.new(0.075, 0, 0.65, 0)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
VerifyBtn.BorderSizePixel = 0
VerifyBtn.Text = "VERIFY LICENSE"
VerifyBtn.TextColor3 = Color3.fromRGB(10, 15, 12)
VerifyBtn.TextSize = 14
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = KeyFrame
local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 8)
VerifyCorner.Parent = VerifyBtn
-- // 2. MAIN DASHBOARD FRAME (ตั้งค่ากลางจอเป๊ะๆ และซ่อนไว้ก่อน)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 255, 128)
MainStroke.Transparency = 0.6
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame
-- Top Bar (ไม่มีปุ่ม X)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "APEX TDS AUTO SUITE"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar
-- Sidebar Tabs
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
local TabContainer = Instance.new("UIListLayout")
TabContainer.SortOrder = Enum.SortOrder.LayoutIndex
TabContainer.Padding = UDim.new(0, 5)
TabContainer.Parent = Sidebar
-- Content Container
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -140, 1, -40)
Container.Position = UDim2.new(0, 140, 0, 40)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame
local function createPage(name)
local page = Instance.new("ScrollingFrame")
page.Name = name .. "Page"
page.Size = UDim2.new(1, 0, 1, 0)
page.BackgroundTransparency = 1
page.BorderSizePixel = 0
page.Visible = false
page.CanvasSize = UDim2.new(0, 0, 0, 0)
page.ScrollBarThickness = 4
page.Parent = Container
local uiLayout = Instance.new("UIListLayout")
uiLayout.SortOrder = Enum.SortOrder.LayoutIndex
uiLayout.Padding = UDim.new(0, 10)
uiLayout.Parent = page
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 15)
uiPadding.PaddingLeft = UDim.new(0, 15)
uiPadding.PaddingRight = UDim.new(0, 15)
uiPadding.Parent = page
return page
end
local DashboardPage = createPage("Dashboard")
local TDSAutoPage = createPage("TDSAuto")
local SettingsPage = createPage("Settings")
DashboardPage.Visible = true
local function createTabButton(text, pageObj)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, 0, 0, 40)
btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
btn.BorderSizePixel = 0
btn.Text = text
btn.TextColor3 = Color3.fromRGB(180, 180, 200)
btn.TextSize = 13
btn.Font = Enum.Font.GothamSemibold
btn.Parent = Sidebar
btn.MouseButton1Click:Connect(function()
DashboardPage.Visible = false
TDSAutoPage.Visible = false
SettingsPage.Visible = false
pageObj.Visible = true
end)
end
createTabButton("🏠 Dashboard", DashboardPage)
createTabButton("🤖 TDS Auto", TDSAutoPage)
createTabButton("⚙️ Settings", SettingsPage)
-- Dashboard Content
local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, 0, 0, 50)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = "Welcome back, Operator!\nSelect 'TDS Auto' to run your macro."
welcomeLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
welcomeLabel.TextSize = 13
welcomeLabel.Font = Enum.Font.Gotham
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
welcomeLabel.Parent = DashboardPage
-- TDS Auto Macro Content
local runMacroBtn = Instance.new("TextButton")
runMacroBtn.Size = UDim2.new(1, -20, 0, 45)
runMacroBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
runMacroBtn.BorderSizePixel = 0
runMacroBtn.Text = "▶ Execute Hardcore Macro Script"
runMacroBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
runMacroBtn.TextSize = 13
runMacroBtn.Font = Enum.Font.GothamBold
runMacroBtn.Parent = TDSAutoPage
local runMacroCorner = Instance.new("UICorner")
runMacroCorner.CornerRadius = UDim.new(0, 8)
runMacroCorner.Parent = runMacroBtn
runMacroBtn.MouseButton1Click:Connect(function()
task.spawn(function()
print("[Apex TDS] Starting Hardcore Macro...")
local RemoteFunction = ReplicatedStorage:FindFirstChild("RemoteFunction")
if not RemoteFunction then return end
local actions = {
function() RemoteFunction:InvokeServer("Troops", "Place", { Rotation = CFrame.new(0,0,0,1,0,0,0,1,0,0,0,1), Position = Vector3.new(17.569, 0.999, 19.149) }, "Electroshocker") end,
function()
local t = workspace:FindFirstChild("Towers") and workspace.Towers:FindFirstChild("Vigilante")
if t then RemoteFunction:InvokeServer("Troops", "Upgrade", "Set", { Troop = t }) end
end,
function() RemoteFunction:InvokeServer("Troops", "Place", { Rotation = CFrame.new(0,0,0,1,0,0,0,1,0,0,0,1), Position = Vector3.new(18.405, 0.999, 14.898) }, "Electroshocker") end,
function()
local tws = workspace:FindFirstChild("Towers") and workspace.Towers:GetChildren()
if tws and #tws >= 2 then RemoteFunction:InvokeServer("Troops", "Upgrade", "Set", { Troop = tws[2] }) end
end,
function()
local tws = workspace:FindFirstChild("Towers") and workspace.Towers:GetChildren()
if tws and #tws >= 3 then RemoteFunction:InvokeServer("Troops", "Upgrade", "Set", { Troop = tws[3] }) end
end,
function() RemoteFunction:InvokeServer("Troops", "Place", { Rotation = CFrame.new(0,0,0,1,0,0,0,1,0,0,0,1), Position = Vector3.new(6.273, 3.599, 18.636) }, "Engineer") end,
function() RemoteFunction:InvokeServer("Troops", "Place", { Rotation = CFrame.new(0,0,0,1,0,0,0,1,0,0,0,1), Position = Vector3.new(3.075, 3.599, 18.906) }, "Engineer") end,
function()
local tws = workspace:FindFirstChild("Towers") and workspace.Towers:GetChildren()
if tws and #tws >= 5 then RemoteFunction:InvokeServer("Troops", "Upgrade", "Set", { Troop = tws[5] }) end
end,
function() RemoteFunction:InvokeServer("Troops", "Place", { Rotation = CFrame.new(0,0,0,1,0,0,0,1,0,0,0,1), Position = Vector3.new(9.362, 3.599, 16.302) }, "Engineer") end
}
for _, action in ipairs(actions) do
pcall(action)
task.wait(1.2)
end
print("[Apex TDS] Macro sequence completed!")
end)
end)
-- Settings Page Content
local settingsInfo = Instance.new("TextLabel")
settingsInfo.Size = UDim2.new(1, -20, 0, 50)
settingsInfo.BackgroundTransparency = 1
settingsInfo.Text = "Configuration Options\nTheme: Cyberpunk Neon Green"
settingsInfo.TextColor3 = Color3.fromRGB(180, 180, 200)
settingsInfo.TextSize = 13
settingsInfo.Font = Enum.Font.Gotham
settingsInfo.TextXAlignment = Enum.TextXAlignment.Left
settingsInfo.Parent = SettingsPage
-- // 3. FLOATING TOGGLE BUTTON (วงกลมซ้ายล่าง ล็อกตำแหน่งนิ่งๆ)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleUIBtn"
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 20, 1, -65)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 110)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "✅"
ToggleBtn.TextSize = 18
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Transparency = 0.4
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn
-- ฟังก์ชันกดซ่อน/แสดงหน้าต่างหลัก
local uiVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
uiVisible = not uiVisible
MainFrame.Visible = uiVisible
end)
-- // KEY VERIFICATION LOGIC
VerifyBtn.MouseButton1Click:Connect(function()
KeyFrame.Visible = false
MainFrame.Visible = true
ToggleBtn.Visible = true
uiVisible = true
end)
KeyBox.FocusLost:Connect(function(enterPressed)
if enterPressed then
KeyFrame.Visible = false
MainFrame.Visible = true
ToggleBtn.Visible = true
uiVisible = true
end
end)
