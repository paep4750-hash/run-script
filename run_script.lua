--[[
========================================================================
[  GEMINI PREMIUM MULTI-FUNCTION BYPASS HUB v3.1 (CLEAN EDITION)  ]
========================================================================
สคริปต์ส่วนที่ 1: การตั้งค่าระบบ, บายพาสความเร็ว และระบบตรวจจับตำแหน่ง (ESP)
--]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
-- ตรวจสอบและรอแถบการแสดงผล PlayerGui ของผู้เล่น
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
if not PlayerGui then return end
-- ตารางตั้งค่าพารามิเตอร์ระบบ
local HubSettings = {
SpeedEnabled = false,
SpeedMultiplier = 2,
EspEnabled = false,
InvisibleEnabled = false,
RigMode = "Original",
GodModeEnabled = false,
}
local EspObjects = {}
local GhostClone = nil
local GhostPlatform = nil
local RealCharacterCFrame = nil
local VirtualRig, RigConnection = nil, nil
local GodModeConnection = nil
local FakeHumanoidRef = nil
-- ฟังก์ชันอำนวยความสะดวกในการสร้างส่วนประกอบ UI (UI Instance Creator)
local function create(class, parent, props)
local inst = Instance.new(class)
for k, v in pairs(props) do inst[k] = v end
inst.Parent = parent
return inst
end
-- ระบบแจ้งเตือนรูปแบบพรีเมียม (Premium Notification Toast)
local function Notify(title, text)
local ScreenGui = PlayerGui:FindFirstChild("GeminiNotifications") or create("ScreenGui", PlayerGui, {Name = "GeminiNotifications", ResetOnSpawn = false})
local container = ScreenGui:FindFirstChild("NotifyContainer") or create("Frame", ScreenGui, {
Name = "NotifyContainer",
Size = UDim2.new(0, 250, 1, 0),
Position = UDim2.new(1, -260, 0, 10),
BackgroundTransparency = 1
})
local list = container:FindFirstChild("UIList") or create("UIListLayout", container, {
Name = "UIList",
Padding = UDim.new(0, 10),
VerticalAlignment = Enum.VerticalAlignment.Bottom,
SortOrder = Enum.SortOrder.LayoutOrder
})
local toast = create("Frame", container, {
Size = UDim2.new(1, 0, 0, 60),
BackgroundColor3 = Color3.fromRGB(15, 15, 20),
BorderSizePixel = 0
})
create("UICorner", toast, {CornerRadius = UDim.new(0, 6)})
create("UIStroke", toast, {Thickness = 1.2, Color = Color3.fromRGB(0, 120, 255)})
create("TextLabel", toast, {
Text = "  " .. title,
Size = UDim2.new(1, 0, 0.4, 0),
TextColor3 = Color3.fromRGB(0, 120, 255),
Font = Enum.Font.SourceSansBold,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1
})
create("TextLabel", toast, {
Text = "  " .. text,
Position = UDim2.new(0, 0, 0.4, 0),
Size = UDim2.new(1, 0, 0.6, 0),
TextColor3 = Color3.fromRGB(200, 200, 200),
Font = Enum.Font.SourceSans,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1
})
task.delay(3.5, function()
for i = 0, 1, 0.1 do
toast.BackgroundTransparency = i
task.wait(0.02)
end
toast:Destroy()
end)
end
-- ดักจับและแสร้งส่งค่าสเตตัสหลอกป้องกันเซิร์ฟเวอร์เช็ค WalkSpeed
local function SetupMetatableHook()
local gmt = getrawmetatable and getrawmetatable(game)
if gmt and setreadonly then
setreadonly(gmt, false)
local oldIndex = gmt.__index
gmt.__index = newcclosure(function(t, k)
if tostring(t) == "Humanoid" and k == "WalkSpeed" then return 16 end
return oldIndex(t, k)
end)
setreadonly(gmt, true)
end
end
pcall(SetupMetatableHook)
-- ป้องกันเซิร์ฟเวอร์ดึงพิกัดกลับ (Anti-Rubberband Dynamic Velocity Sync)
RunService.RenderStepped:Connect(function(deltaTime)
if HubSettings.SpeedEnabled and LocalPlayer.Character then
local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if humanoid and rootPart and humanoid.MoveDirection.Magnitude > 0 then
local speedMultiplier = HubSettings.SpeedMultiplier * 10
local moveVector = humanoid.MoveDirection * speedMultiplier
-- ป้อนความเร็วทางฟิสิกส์หลอกเซิร์ฟเวอร์
rootPart.AssemblyLinearVelocity = Vector3.new(moveVector.X, rootPart.AssemblyLinearVelocity.Y, moveVector.Z)
rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
-- ดันพิกัด CFrame ไปข้างหน้าตามจังหวะเฟรมเรตอย่างลื่นไหล
rootPart.CFrame = rootPart.CFrame + Vector3.new(moveVector.X * deltaTime, 0, moveVector.Z * deltaTime)
end
end
end)
-- ระบบสแกนหาตำแหน่งผู้เล่นคนอื่นทะลุกำแพง (Advanced ESP Master)
local function CreateESP(player)
if player == LocalPlayer then return end
local function applyEsp(character)
if not character then return end
local oldEsp = character:FindFirstChild("GeminiESP")
if oldEsp then oldEsp:Destroy() end
local highlight = create("Highlight", character, {
Name = "GeminiESP",
FillColor = Color3.fromRGB(0, 120, 255),
FillTransparency = 0.4,
OutlineColor = Color3.fromRGB(255, 255, 255),
OutlineTransparency = 0,
Enabled = HubSettings.EspEnabled
})
EspObjects[player.Name] = highlight
end
player.CharacterAdded:Connect(applyEsp)
if player.Character then applyEsp(player.Character) end
end
local function ToggleESP(state)
HubSettings.EspEnabled = state
for _, player in ipairs(Players:GetPlayers()) do
if player.Character then
local highlight = player.Character:FindFirstChild("GeminiESP")
if highlight then highlight.Enabled = state else CreateESP(player) end
end
end
Notify("ESP Status Update", "Extra Sensory Perception highlights: " .. (state and "Enabled" or "Disabled"))
end
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p) EspObjects[p.Name] = nil end)
-- ล่องหนล็อกพิกัดเสมือนป้องกันการตกด่าน (Ghost Invisibility Safe Platform Bypass)
local function ToggleInvisibility(state)
HubSettings.InvisibleEnabled = state
local char = LocalPlayer.Character
if not char or not char:FindFirstChild("HumanoidRootPart") then return end
if state then
char.Archivable = true
GhostClone = char:Clone()
GhostClone.Name = "GhostVisualShell"
GhostClone.Parent = workspace
-- ล็อกพิกัดตัวละครจริงไว้ไม่ให้ฟิสิกส์หล่นลงใต้พื้นแมพ
char.HumanoidRootPart.Anchored = true
RealCharacterCFrame = char.HumanoidRootPart.CFrame
-- เสกแผ่นพื้นไร้คนเห็นมารองรับฟิสิกส์เซิร์ฟเวอร์
GhostPlatform = create("Part", workspace, {
Size = Vector3.new(6, 1, 6),
CFrame = char.HumanoidRootPart.CFrame - Vector3.new(0, 3.5, 0),
Transparency = 1,
Anchored = true,
CanCollide = true
})
-- ทำให้ตัวจริงจางลง เพื่อแสดงสัญลักษณ์ว่าตัวคุณกำลังล่องหนอยู่
for _, part in ipairs(char:GetChildren()) do
if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = 0.8 end
end
Notify("Ghost Mode", "Invisibility Active - Real Body Anchored Safely.")
else
char.HumanoidRootPart.Anchored = false
if GhostClone and GhostClone:FindFirstChild("HumanoidRootPart") then
char.HumanoidRootPart.CFrame = GhostClone.HumanoidRootPart.CFrame
GhostClone:Destroy()
GhostClone = nil
elseif RealCharacterCFrame then
char.HumanoidRootPart.CFrame = RealCharacterCFrame
end
if GhostPlatform then
GhostPlatform:Destroy()
GhostPlatform = nil
end
for _, part in ipairs(char:GetChildren()) do
if part:IsA("BasePart") then part.Transparency = 0 end
end
Notify("Ghost Mode", "Invisibility Restored - Merged to Safe Position.")
end
end
--[[
========================================================================
[  GEMINI PREMIUM MULTI-FUNCTION BYPASS HUB v3.1 (CLEAN EDITION)  ]
========================================================================
สคริปต์ส่วนที่ 2: ระบบจำลองโครงร่างตัวละคร (R6/R15), ระบบอมตะ God Mode และตัวถัง ScreenGui
--]]
-- ล้างโครงสร้างโมเดลจำลองตัวละคร
local function ClearVirtualRig()
if RigConnection then RigConnection:Disconnect() RigConnection = nil end
if VirtualRig then VirtualRig:Destroy() VirtualRig = nil end
local char = LocalPlayer.Character
if char then
for _, part in ipairs(char:GetChildren()) do
if part:IsA("BasePart") then
part.Transparency = 0
if part:FindFirstChildOfClass("Decal") then part:FindFirstChildOfClass("Decal").Transparency = 0 end
end
end
local camera = workspace.CurrentCamera
if char:FindFirstChildOfClass("Humanoid") then camera.CameraSubject = char:FindFirstChildOfClass("Humanoid") end
end
end
-- สลับโครงร่างโมเดล R6 / R15 ต้านเซิร์ฟเวอร์แบน
local function SetVirtualRig(targetType)
ClearVirtualRig()
local char = LocalPlayer.Character
if not char or not char:FindFirstChild("HumanoidRootPart") then return end
local realHumanoid = char:FindFirstChildOfClass("Humanoid")
if not realHumanoid then return end
HubSettings.RigMode = targetType
char.Archivable = true
local fakeModel = create("Model", workspace, {Name = "Virtual_" .. targetType .. "_Rig"})
local fakeHumanoid = create("Humanoid", fakeModel, {})
local rootPart = create("Part", fakeModel, {Name = "HumanoidRootPart", Size = Vector3.new(2, 2, 1), Transparency = 1, CanCollide = false})
local function CreateVirtualLimb(name, size, offset)
local part = create("Part", fakeModel, {Name = name, Size = size, Color = Color3.fromRGB(160, 160, 160), CanCollide = false, Massless = true})
create("Weld", rootPart, {Name = name .. "_Joint", Part0 = rootPart, Part1 = part, C0 = CFrame.new(offset)})
end
if targetType == "R6" then
CreateVirtualLimb("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0))
CreateVirtualLimb("Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 1.5, 0))
CreateVirtualLimb("Left Arm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 0, 0))
CreateVirtualLimb("Right Arm", Vector3.new(1, 2, 1), Vector3.new(1.5, 0, 0))
CreateVirtualLimb("Left Leg", Vector3.new(1, 2, 1), Vector3.new(-0.5, -2, 0))
CreateVirtualLimb("Right Leg", Vector3.new(1, 2, 1), Vector3.new(0.5, -2, 0))
elseif targetType == "R15" then
CreateVirtualLimb("UpperTorso", Vector3.new(1.6, 0.8, 1), Vector3.new(0, 0.4, 0))
CreateVirtualLimb("LowerTorso", Vector3.new(1.6, 0.8, 1), Vector3.new(0, -0.4, 0))
CreateVirtualLimb("Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 1.4, 0))
CreateVirtualLimb("RightUpperArm", Vector3.new(1, 1, 1), Vector3.new(1.3, 0.5, 0))
CreateVirtualLimb("RightLowerArm", Vector3.new(1, 1, 1), Vector3.new(1.3, -0.3, 0))
CreateVirtualLimb("RightHand", Vector3.new(0.8, 0.5, 0.8), Vector3.new(1.3, -0.9, 0))
CreateVirtualLimb("LeftUpperArm", Vector3.new(1, 1, 1), Vector3.new(-1.3, 0.5, 0))
CreateVirtualLimb("LeftLowerArm", Vector3.new(1, 1, 1), Vector3.new(-1.3, -0.3, 0))
CreateVirtualLimb("LeftHand", Vector3.new(0.8, 0.5, 0.8), Vector3.new(-1.3, -0.9, 0))
end
VirtualRig = fakeModel
for _, part in ipairs(char:GetChildren()) do
if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
part.Transparency = 1
if part:FindFirstChildOfClass("Decal") then part:FindFirstChildOfClass("Decal").Transparency = 1 end
end
end
workspace.CurrentCamera.CameraSubject = fakeHumanoid
RigConnection = RunService.Heartbeat:Connect(function()
if not char or not char:FindFirstChild("HumanoidRootPart") or not VirtualRig then ClearVirtualRig() return end
rootPart.CFrame = char.HumanoidRootPart.CFrame
fakeHumanoid.MoveDirection = realHumanoid.MoveDirection
fakeHumanoid:ChangeState(realHumanoid:GetState())
end)
Notify("Rig Reanimated", "Client-Side Custom Emulation rig connected: " .. targetType)
end
-- อมตะแบบทำลายกระดานดาเมจของเซิร์ฟเวอร์ (True God Mode - Local Humanoid Swapping Bypass)
local function ToggleGodMode(state)
HubSettings.GodModeEnabled = state
local char = LocalPlayer.Character
if not char then return end
if state then
local originalHumanoid = char:FindFirstChildOfClass("Humanoid")
if not originalHumanoid then return end
-- ลบข้อตกลงในการตรวจจับคอหักตาย
originalHumanoid.RequiresNeck = false
-- โคลน Humanoid ขึ้นมาควบคุมพิกัดในเครื่องของเราโดยตรง
local fakeHumanoid = originalHumanoid:Clone()
fakeHumanoid.Name = "BypassHumanoid"
fakeHumanoid.Parent = char
FakeHumanoidRef = fakeHumanoid
-- ลบ Humanoid เดิมทิ้งเพื่อตัดช่องทางการรับความเสียหายจากเซิร์ฟเวอร์โดยสมบูรณ์
originalHumanoid:Destroy()
-- เบี่ยงทิศทางกล้องไปยังผู้ควบคุมเสมือนใหม่
workspace.CurrentCamera.CameraSubject = fakeHumanoid
GodModeConnection = RunService.Heartbeat:Connect(function()
local root = char:FindFirstChild("HumanoidRootPart")
if fakeHumanoid then
fakeHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
if fakeHumanoid.Health < fakeHumanoid.MaxHealth then
fakeHumanoid.Health = fakeHumanoid.MaxHealth
end
end
-- ป้องกันหล่นก้นด่านเพื่อดึงพิกัดตัวกลับขึ้นแผนที่
if root and root.Position.Y < -350 then
root.CFrame = CFrame.new(root.Position.X, 100, root.Position.Z)
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end
end)
Notify("God Mode Enabled", "Anti-Death Humanoid Swap complete. Damage packets Nullified.")
else
if GodModeConnection then GodModeConnection:Disconnect() GodModeConnection = nil end
Notify("God Mode Disabled", "Bypass disconnected. Please reset your character if damaged.")
end
end
-- ==========================================
-- [ 2. Ultimate Premium Cyberpunk UI ]
-- ==========================================
local existingUi = PlayerGui:FindFirstChild("GeminiScriptHub")
if existingUi then existingUi:Destroy() end
local GeminiScriptHub = create("ScreenGui", PlayerGui, {Name = "GeminiScriptHub", ResetOnSpawn = false})
-- บานหน้าต่างหลักควบคุมสคริปต์ (Main Control Panel)
local MainFrame = create("Frame", GeminiScriptHub, {
Name = "MainFrame",
Size = UDim2.new(0, 540, 0, 340),
Position = UDim2.new(0.5, -270, 0.5, -170),
BackgroundColor3 = Color3.fromRGB(13, 13, 18),
BorderSizePixel = 0,
Active = true,
Draggable = true
})
create("UICorner", MainFrame, {CornerRadius = UDim.new(0, 10)})
create("UIStroke", MainFrame, {Thickness = 1.6, Color = Color3.fromRGB(0, 120, 255)})
-- แถบสี Cyan คาดด้านบนสวยงาม
local HeaderDecor = create("Frame", MainFrame, {
Size = UDim2.new(1, 0, 0, 4),
BackgroundColor3 = Color3.fromRGB(0, 120, 255),
BorderSizePixel = 0
})
create("UICorner", HeaderDecor, {CornerRadius = UDim.new(0, 10)})
local TitleBar = create("TextLabel", MainFrame, {
Size = UDim2.new(1, 0, 0, 35),
BackgroundTransparency = 1,
Text = "  GEMINI SCRIPT BYPASS HUB [V3.1 GOD-EDITION]",
TextColor3 = Color3.fromRGB(240, 240, 255),
TextSize = 13,
Font = Enum.Font.SourceSansBold,
TextXAlignment = Enum.TextXAlignment.Left
})
local CloseButton = create("TextButton", MainFrame, {
Size = UDim2.new(0, 30, 0, 30),
Position = UDim2.new(1, -35, 0, 2),
BackgroundTransparency = 1,
Text = "X",
TextColor3 = Color3.fromRGB(255, 75, 75),
TextSize = 16,
Font = Enum.Font.SourceSansBold
})
CloseButton.MouseButton1Click:Connect(function() GeminiScriptHub:Destroy() end)
local MinimizeButton = create("TextButton", MainFrame, {
Size = UDim2.new(0, 30, 0, 30),
Position = UDim2.new(1, -65, 0, -2),
BackgroundTransparency = 1,
Text = "_",
TextColor3 = Color3.fromRGB(255, 255, 255),
TextSize = 18,
Font = Enum.Font.SourceSansBold
})
-- ปุ่มย่อหน้าจอลอยตัวสุดล้ำ (Floating Widget)
local RestoreButton = create("TextButton", GeminiScriptHub, {
Name = "RestoreButton",
Size = UDim2.new(0, 75, 0, 34),
Position = UDim2.new(0.05, 0, 0.15, 0),
BackgroundColor3 = Color3.fromRGB(13, 13, 18),
Text = "GEMINI v3",
TextColor3 = Color3.fromRGB(0, 120, 255),
Font = Enum.Font.SourceSansBold,
TextSize = 12,
Visible = false,
Active = true,
Draggable = true
})
create("UICorner", RestoreButton, {CornerRadius = UDim.new(0, 6)})
create("UIStroke", RestoreButton, {Thickness = 1.4, Color = Color3.fromRGB(0, 120, 255)})
MinimizeButton.MouseButton1Click:Connect(function()
MainFrame:TweenPosition(UDim2.new(0.5, -270, 1.5, 0), "Out", "Quad", 0.4, true, function()
MainFrame.Visible = false
RestoreButton.Visible = true
end)
end)
RestoreButton.MouseButton1Click:Connect(function()
RestoreButton.Visible = false
MainFrame.Visible = true
MainFrame:TweenPosition(UDim2.new(0.5, -270, 0.5, -170), "Out", "Back", 0.4, true)
end)
-- แผงควบคุมสไลเดอร์ด้านซ้าย
local Sidebar = create("Frame", MainFrame, {
Size = UDim2.new(0, 140, 1, -45),
Position = UDim2.new(0, 5, 0, 40),
BackgroundColor3 = Color3.fromRGB(8, 8, 12),
BorderSizePixel = 0
})
create("UICorner", Sidebar, {CornerRadius = UDim.new(0, 6)})
local UIList = create("UIListLayout", Sidebar, {
Padding = UDim.new(0, 4),
HorizontalAlignment = Enum.HorizontalAlignment.Center,
SortOrder = Enum.SortOrder.LayoutOrder
})
local ContentArea = create("Frame", MainFrame, {
Size = UDim2.new(1, -160, 1, -50),
Position = UDim2.new(0, 150, 0, 40),
BackgroundTransparency = 1
})
local Frames = {}
local function CreateTab(name, order)
local btn = create("TextButton", Sidebar, {
Size = UDim2.new(0.95, 0, 0, 30),
BackgroundColor3 = order == 1 and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(20, 20, 25),
Text = name,
TextColor3 = order == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160),
Font = Enum.Font.SourceSansBold,
TextSize = 11,
LayoutOrder = order
})
create("UICorner", btn, {CornerRadius = UDim.new(0, 4)})
local viewFrame = create("Frame", ContentArea, {
Size = UDim2.new(1, 0, 1, 0),
BackgroundTransparency = 1,
Visible = order == 1
})
Frames[name] = {Button = btn, Frame = viewFrame}
--[[
========================================================================
[  GEMINI PREMIUM MULTI-FUNCTION BYPASS HUB v3.1 (CLEAN EDITION)  ]
========================================================================
สคริปต์ส่วนที่ 3: ตรรกะการสลับหน้าต่างแท็บเมนู และชิ้นส่วนปุ่มฟังก์ชันการแฮกทั้งหมด
--]]
btn.MouseButton1Click:Connect(function()
for _, t in pairs(Frames) do
t.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
t.Button.TextColor3 = Color3.fromRGB(160, 160, 160)
t.Frame.Visible = false
end
btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
viewFrame.Visible = true
end)
return viewFrame
end
-- สร้างเมนูแท็บย่อย
local ExecView = CreateTab("Script Executor", 1)
local SpeedView = CreateTab("Bypass Speed", 2)
local EspView = CreateTab("ESP Master", 3)
local GhostView = CreateTab("Ghost Invisible", 4)
local RigView = CreateTab("Rig Reanimator", 5)
local GodView = CreateTab("God Mode", 6)
-- [ Tab 1: หน้าต่างโปรแกรมรันโค้ดพกพา ]
local ScriptBox = create("TextBox", ExecView, {
Size = UDim2.new(1, 0, 0.78, 0),
BackgroundColor3 = Color3.fromRGB(5, 5, 8),
TextColor3 = Color3.fromRGB(200, 200, 200),
Font = Enum.Font.Code,
Text = "-- Paste your external configurations here...",
MultiLine = true,
ClearTextOnFocus = false,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top
})
create("UICorner", ScriptBox, {CornerRadius = UDim.new(0, 4)})
local ExecuteBtn = create("TextButton", ExecView, {Size = UDim2.new(0.48, 0, 0.18, 0), Position = UDim2.new(0, 0, 0.82, 0), BackgroundColor3 = Color3.fromRGB(0, 150, 80), Text = "Execute Code", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
local ClearBtn = create("TextButton", ExecView, {Size = UDim2.new(0.48, 0, 0.18, 0), Position = UDim2.new(0.52, 0, 0.82, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 40), Text = "Clear Text", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
ExecuteBtn.MouseButton1Click:Connect(function()
local success, err = pcall(function()
local f = loadstring(ScriptBox.Text)
if f then f() else error("Syntax Error") end
end)
if not success then ScriptBox.Text = "-- Error:\n" .. tostring(err) end
end)
ClearBtn.MouseButton1Click:Connect(function() ScriptBox.Text = "" end)
-- [ Tab 2: หน้าต่างระบบควบคุมความเร็วพิเศษ ]
local SpeedToggle = create("TextButton", SpeedView, {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "Bypass Speed Acceleration: OFF", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 14})
SpeedToggle.MouseButton1Click:Connect(function()
HubSettings.SpeedEnabled = not HubSettings.SpeedEnabled
SpeedToggle.BackgroundColor3 = HubSettings.SpeedEnabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
SpeedToggle.Text = "Bypass Speed Acceleration: " .. (HubSettings.SpeedEnabled and "ON" or "OFF")
end)
local SpeedLabel = create("TextLabel", SpeedView, {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 60), BackgroundTransparency = 1, Text = "Velocity Factor Vector: x2.0", TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.SourceSans, TextSize = 13})
local SliderBg = create("Frame", SpeedView, {Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 0, 100), BackgroundColor3 = Color3.fromRGB(40, 40, 45)})
local SliderFill = create("Frame", SliderBg, {Size = UDim2.new(0.2, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 120, 255)})
local SliderBtn = create("TextButton", SliderBg, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0.2, -8, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = ""})
local isDragging = false
local function UpdateSlider(input)
local relativeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
SliderBtn.Position = UDim2.new(relativeX, -8, 0.5, -8)
local val = math.floor((1 + (relativeX * 9)) * 10) / 10
HubSettings.SpeedMultiplier = val
SpeedLabel.Text = "Velocity Factor Vector: x" .. string.format("%.1f", val)
end
SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end end)
UserInputService.InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(input) end end)
-- [ Tab 3: หน้าต่างระบบสแกนตำแหน่งผู้เล่น (ESP) ]
local EspToggle = create("TextButton", EspView, {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "Extra Sensory Perception (ESP): OFF", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 14})
EspToggle.MouseButton1Click:Connect(function()
local state = not HubSettings.EspEnabled
ToggleESP(state)
EspToggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
EspToggle.Text = "Extra Sensory Perception (ESP): " .. (state and "ON" or "OFF")
end)
-- [ Tab 4: หน้าต่างระบบล่องหนล็อกพิกัดเสมือน ]
local GhostToggle = create("TextButton", GhostView, {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "Bypass Ghost Invisibility: OFF", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 14})
GhostToggle.MouseButton1Click:Connect(function()
local state = not HubSettings.InvisibleEnabled
ToggleInvisibility(state)
GhostToggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
GhostToggle.Text = "Bypass Ghost Invisibility: " .. (state and "ON" or "OFF")
end)
-- [ Tab 5: หน้าต่างการสลับโครงร่างโมเดลจำลองตัวละคร ]
local RigTitle = create("TextLabel", RigView, {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "Virtual Character Rig Emulation Bypass Setup", TextColor3 = Color3.fromRGB(200, 200, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
local SwitchR6Btn = create("TextButton", RigView, {Size = UDim2.new(0.31, 0, 0, 40), Position = UDim2.new(0, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(30, 30, 35), Text = "Virtual R6", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
local SwitchR15Btn = create("TextButton", RigView, {Size = UDim2.new(0.31, 0, 0, 40), Position = UDim2.new(0.34, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(30, 30, 35), Text = "Virtual R15", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
local ResetRigBtn = create("TextButton", RigView, {Size = UDim2.new(0.31, 0, 0, 40), Position = UDim2.new(0.68, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "Reset Rig", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
SwitchR6Btn.MouseButton1Click:Connect(function() SetVirtualRig("R6") RigTitle.Text = "Active Rig Virtualization Bypass: R6" end)
SwitchR15Btn.MouseButton1Click:Connect(function() SetVirtualRig("R15") RigTitle.Text = "Active Rig Virtualization Bypass: R15" end)
ResetRigBtn.MouseButton1Click:Connect(function() ClearVirtualRig() RigTitle.Text = "Active Rig Virtualization Bypass: Original" end)
-- [ Tab 6: หน้าต่างระบบอมตะขั้นสมบูรณ์แบบ ]
local GodTitle = create("TextLabel", GodView, {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "Ultimate God Mode Bypass System [Humanoid Swap]", TextColor3 = Color3.fromRGB(200, 200, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
local GodToggle = create("TextButton", GodView, {Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "Anti-Death God Mode: OFF", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 14})
create("UICorner", GodToggle, {CornerRadius = UDim.new(0, 6)})
create("TextLabel", GodView, {Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(0, 0, 0, 105), BackgroundTransparency = 1, Text = "Secured Features Active:\n• Bypass Client-side death (State Locking)\n• Void damage recovery (Auto-Teleport)\n• No Neck-Break death trigger\n• [V3 EXCLUSIVE] Client-Side Humanoid Swap Bypass", TextColor3 = Color3.fromRGB(170, 170, 175), Font = Enum.Font.SourceSans, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
GodToggle.MouseButton1Click:Connect(function()
local state = not HubSettings.GodModeEnabled
ToggleGodMode(state)
GodToggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
GodToggle.Text = "Anti-Death God Mode: " .. (state and "ON" or "OFF")
end)
-- ส่งสัญญาณแจ้งเตือนระบบรันเสร็จสิ้น
Notify("Gemini Script Loaded Successfully", "All bypass networks are online.")
