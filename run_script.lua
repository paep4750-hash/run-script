--[[
========================================================================
[   PREMIUM MULTI-FUNCTION HUB v3.3 (CLEAN EDITION)  ]
========================================================================
สคริปต์ส่วนที่ 1: ระบบเริ่มต้น, บายพาสความเร็ว และระบบระบุตำแหน่งผู้เล่น (ESP)
--]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
-- รอโหลดหน้าจอแสดงผลหลักของผู้เล่น
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
if not PlayerGui then return end
-- ตารางข้อมูลเก็บสถานะการตั้งค่าของตัวโปรแกรมโกง
local HubSettings = {
SpeedEnabled = false,
SpeedMultiplier = 2,
EspEnabled = false,
InvisibleEnabled = false,
RigMode = "Original",
GodModeEnabled = false,
FpsBoostEnabled = false, -- สถานะระบบเพิ่มความลื่น (FPS Boost)
FullBrightEnabled = false, -- สถานะระบบความสว่างหน้าจอ (Full Bright)
}
local EspObjects = {}
local GhostClone = nil
local GhostPlatform = nil
local RealCharacterCFrame = nil
local VirtualRig, RigConnection = nil, nil
local GodModeConnection = nil
local FakeHumanoidRef = nil
-- ฟังก์ชันสำหรับสร้างอ็อบเจกต์หน้าจอเพื่อให้โค้ดกระชับและลื่นไหล
local function create(class, parent, props)
local inst = Instance.new(class)
for k, v in pairs(props) do inst[k] = v end
inst.Parent = parent
return inst
end
-- ระบบแจ้งเตือนขวาขวาล่างแบบลอยขึ้น (Notification Toast)
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
-- การบายพาสแก้ทาง Metatable ป้องกันระบบตรวจสปีด WalkSpeed
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
-- ดักสลับสปีดด้วยค่าแรงส่ง Assembly Linear Velocity ป้องกันอาการเดินแล้วโดนวาร์ปดึงกลับ
RunService.RenderStepped:Connect(function(deltaTime)
if HubSettings.SpeedEnabled and LocalPlayer.Character then
local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if humanoid and rootPart and humanoid.MoveDirection.Magnitude > 0 then
local speedMultiplier = HubSettings.SpeedMultiplier * 10
local moveVector = humanoid.MoveDirection * speedMultiplier
rootPart.AssemblyLinearVelocity = Vector3.new(moveVector.X, rootPart.AssemblyLinearVelocity.Y, moveVector.Z)
rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
rootPart.CFrame = rootPart.CFrame + Vector3.new(moveVector.X * deltaTime, 0, moveVector.Z * deltaTime)
end
end
end)
-- ระบบสแกนพิกัดผู้เล่นอื่นทะลุกำแพง (ESP Highlight)
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
Notify("อัปเดตระบบมองทะลุ", "ระบบสแกนรอบทิศทาง: " .. (state and "เปิดใช้งาน" or "ปิดการใช้งาน"))
end
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p) EspObjects[p.Name] = nil end)
-- บายพาสระบบล่องหนไม่ร่วงหล่นตกแผนที่ ด้วยระบบแผ่นพื้นลอยจำลองแรงรับน้ำหนัก
local function ToggleInvisibility(state)
HubSettings.InvisibleEnabled = state
local char = LocalPlayer.Character
if not char or not char:FindFirstChild("HumanoidRootPart") then return end
if state then
char.Archivable = true
GhostClone = char:Clone()
GhostClone.Name = "GhostVisualShell"
GhostClone.Parent = workspace
char.HumanoidRootPart.Anchored = true
RealCharacterCFrame = char.HumanoidRootPart.CFrame
GhostPlatform = create("Part", workspace, {
Size = Vector3.new(6, 1, 6),
CFrame = char.HumanoidRootPart.CFrame - Vector3.new(0, 3.5, 0),
Transparency = 1,
Anchored = true,
CanCollide = true
})
for _, part in ipairs(char:GetChildren()) do
if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = 0.8 end
end
Notify("ระบบล่องหน", "เปิดใช้งานโหมดล่องหน - ตัวตนจริงถูกแช่แข็งไว้อย่างปลอดภัย")
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
Notify("ระบบล่องหน", "ปิดใช้งานโหมดล่องหน - เชื่อมตำแหน่งคืนสู่ปกติแล้ว")
end
end
--[[
========================================================================
[  GEMINI PREMIUM MULTI-FUNCTION BYPASS HUB v3.3 (CLEAN EDITION)  ]
========================================================================
สคริปต์ส่วนที่ 2: ระบบสลับกระดูกตัวละครจำลอง (R6/R15), ฟังก์ชันอมตะหลอกดาเมจ และเฟรมสร้างเมนูหลัก
--]]
-- ล้างพิกัดโครงสร้างกระดูกจำลองเดิม
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
-- ระบบจำลองโครงข้อต่อ R6 / R15 เพื่อ bypass สแกนความเร็วฟิสิกส์ชิ้นส่วน
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
Notify("เปลี่ยนกระดูกตัวละครสำเร็จ", "ปรับโครงสร้างเป็นแบบ: " .. targetType)
end
-- ระบบโคลนและสลับสิทธิ์รับค่าความเสียหายเพื่อทำเป็นอมตะ (True God Mode Humanoid Swap)
local function ToggleGodMode(state)
HubSettings.GodModeEnabled = state
local char = LocalPlayer.Character
if not char then return end
if state then
local originalHumanoid = char:FindFirstChildOfClass("Humanoid")
if not originalHumanoid then return end
originalHumanoid.RequiresNeck = false
local fakeHumanoid = originalHumanoid:Clone()
fakeHumanoid.Name = "BypassHumanoid"
fakeHumanoid.Parent = char
FakeHumanoidRef = fakeHumanoid
originalHumanoid:Destroy()
workspace.CurrentCamera.CameraSubject = fakeHumanoid
GodModeConnection = RunService.Heartbeat:Connect(function()
local root = char:FindFirstChild("HumanoidRootPart")
if fakeHumanoid then
fakeHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
if fakeHumanoid.Health < fakeHumanoid.MaxHealth then
fakeHumanoid.Health = fakeHumanoid.MaxHealth
end
end
if root and root.Position.Y < -350 then
root.CFrame = CFrame.new(root.Position.X, 100, root.Position.Z)
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end
end)
Notify("โหมดอมตะเปิดทำงาน", "ถอดการส่งสัญญาณความเสียหายเสร็จสิ้น - คุณไร้เทียมทานแล้ว")
else
if GodModeConnection then GodModeConnection:Disconnect() GodModeConnection = nil end
Notify("ปิดโหมดอมตะ", "หากตัวละครเกิดอาการบั๊กจากการได้รับดาเมจ กรุณากดตัวตายเพื่อคืนค่าสู่สภาวะปกติ")
end
end
-- [ สร้างเฟรมเมนูแสดงผลหลักบนหน้าต่างแท็บเล็ต ]
local existingUi = PlayerGui:FindFirstChild("GeminiScriptHub")
if existingUi then existingUi:Destroy() end
local GeminiScriptHub = create("ScreenGui", PlayerGui, {Name = "GeminiScriptHub", ResetOnSpawn = false})
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
local HeaderDecor = create("Frame", MainFrame, {
Size = UDim2.new(1, 0, 0, 4),
BackgroundColor3 = Color3.fromRGB(0, 120, 255),
BorderSizePixel = 0
})
create("UICorner", HeaderDecor, {CornerRadius = UDim.new(0, 10)})
local TitleBar = create("TextLabel", MainFrame, {
Size = UDim2.new(1, 0, 0, 35),
BackgroundTransparency = 1,
Text = "  GEMINI SCRIPT BYPASS HUB [V3.3 รุ่นพิเศษ]",
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
Size = UDim2.new(0.95, 0, 0, 26),
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

-- [[
--    ========================================================================
--    [  GEMINI PREMIUM MULTI-FUNCTION BYPASS HUB v3.3 (CLEAN EDITION)  ]
--    ========================================================================
--    สคริปต์ส่วนที่ 3: ตัวจัดการเปลี่ยนหน้าแท็บเมนูด้านซ้าย และฟังก์ชันปุ่มคำสั่งรวมถึง FPS Boost และ Full Bright
-- ]]
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
-- สร้างเมนูแท็บย่อยทั้งหมด 8 แท็บ
local ExecView = CreateTab("รันสคริปต์", 1)
local SpeedView = CreateTab("สปีดไม่ดึงกลับ", 2)
local EspView = CreateTab("มองทะลุตัวละคร", 3)
local GhostView = CreateTab("โหมดล่องหน", 4)
local RigView = CreateTab("แปลงร่างจำลอง", 5)
local GodView = CreateTab("โหมดอมตะเทพ", 6)
local TeleportView = CreateTab("วาร์ปผู้เล่น", 7)
local VisualView = CreateTab("ภาพลื่น & สว่าง", 8) -- แท็บที่ 8 เพิ่มเข้ามาใหม่สำหรับกราฟิกและแสงไฟ
-- [ ตกแต่งแท็บที่ 1: หน้ารันสคริปต์ ]
local ScriptBox = create("TextBox", ExecView, {
Size = UDim2.new(1, 0, 0.78, 0),
BackgroundColor3 = Color3.fromRGB(5, 5, 8),
TextColor3 = Color3.fromRGB(200, 200, 200),
Font = Enum.Font.Code,
Text = "-- วางสคริปต์ที่ต้องการรันเพิ่มเติมตรงนี้...",
MultiLine = true,
ClearTextOnFocus = false,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top
})
create("UICorner", ScriptBox, {CornerRadius = UDim.new(0, 4)})
local ExecuteBtn = create("TextButton", ExecView, {Size = UDim2.new(0.48, 0, 0.18, 0), Position = UDim2.new(0, 0, 0.82, 0), BackgroundColor3 = Color3.fromRGB(0, 150, 80), Text = "รันสคริปต์", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
local ClearBtn = create("TextButton", ExecView, {Size = UDim2.new(0.48, 0, 0.18, 0), Position = UDim2.new(0.52, 0, 0.82, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 40), Text = "ล้างข้อมูล", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
ExecuteBtn.MouseButton1Click:Connect(function()
local success, err = pcall(function()
local f = loadstring(ScriptBox.Text)
if f then f() else error("ไวยากรณ์สคริปต์ทำงานขัดข้อง") end
end)
if not success then ScriptBox.Text = "-- พบข้อผิดพลาดในสคริปต์:\n" .. tostring(err) end
end)
ClearBtn.MouseButton1Click:Connect(function() ScriptBox.Text = "" end)
-- [ ตกแต่งแท็บที่ 2: หน้าสปีดบายพาส ]
local SpeedToggle = create("TextButton", SpeedView, {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "เปิดระบบควบคุมความเร็วบายพาส: ปิด", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 14})
SpeedToggle.MouseButton1Click:Connect(function()
HubSettings.SpeedEnabled = not HubSettings.SpeedEnabled
SpeedToggle.BackgroundColor3 = HubSettings.SpeedEnabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
SpeedToggle.Text = "เปิดระบบควบคุมความเร็วบายพาส: " .. (HubSettings.SpeedEnabled and "เปิด" or "ปิด")
end)
local SpeedLabel = create("TextLabel", SpeedView, {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 60), BackgroundTransparency = 1, Text = "อัตราตัวคูณสปีดความเร็ว: x2.0", TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.SourceSans, TextSize = 13})
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
SpeedLabel.Text = "อัตราตัวคูณสปีดความเร็ว: x" .. string.format("%.1f", val)
end
SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end end)
UserInputService.InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(input) end end)
-- [ ตกแต่งแท็บที่ 3: ระบบมองทะลุ ]
local EspToggle = create("TextButton", EspView, {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "เปิดระบบแสดงกรอบเรืองแสง (ESP): ปิด", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 14})
EspToggle.MouseButton1Click:Connect(function()
local state = not HubSettings.EspEnabled
ToggleESP(state)
EspToggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
EspToggle.Text = "เปิดระบบแสดงกรอบเรืองแสง (ESP): " .. (state and "เปิด" or "ปิด")
end)
-- [ ตกแต่งแท็บที่ 4: หน้าล่องหนบายพาส ]
local GhostToggle = create("TextButton", GhostView, {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "เปิดโหมดล่องหนปลอดภัย: ปิด", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 14})
GhostToggle.MouseButton1Click:Connect(function()
local state = not HubSettings.InvisibleEnabled
ToggleInvisibility(state)
GhostToggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
GhostToggle.Text = "เปิดโหมดล่องหนปลอดภัย: " .. (state and "เปิด" or "ปิด")
end)
-- [ ตกแต่งแท็บที่ 5: สลับกระดูกจำลองตัวละคร ]
local RigTitle = create("TextLabel", RigView, {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "ควบคุมระบบจำลองกระดูกต้านตรวจแบน", TextColor3 = Color3.fromRGB(200, 200, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
local SwitchR6Btn = create("TextButton", RigView, {Size = UDim2.new(0.31, 0, 0, 40), Position = UDim2.new(0, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(30, 30, 35), Text = "จำลองร่าง R6", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
local SwitchR15Btn = create("TextButton", RigView, {Size = UDim2.new(0.31, 0, 0, 40), Position = UDim2.new(0.34, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(30, 30, 35), Text = "จำลองร่าง R15", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
local ResetRigBtn = create("TextButton", RigView, {Size = UDim2.new(0.31, 0, 0, 40), Position = UDim2.new(0.68, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(15, 15, 40), Text = "คืนร่างจริง", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
SwitchR6Btn.MouseButton1Click:Connect(function() SetVirtualRig("R6") RigTitle.Text = "สถานะโหมดกระดูกจำลอง: R6" end)
SwitchR15Btn.MouseButton1Click:Connect(function() SetVirtualRig("R15") RigTitle.Text = "สถานะโหมดกระดูกจำลอง: R15" end)
ResetRigBtn.MouseButton1Click:Connect(function() ClearVirtualRig() RigTitle.Text = "สถานะโหมดกระดูกจำลอง: ร่างเดิมโรงงาน" end)
-- [ ตกแต่งแท็บที่ 6: ระบบอมตะเทพ ]
local GodTitle = create("TextLabel", GodView, {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "ควบคุมระบบอมตะถอดสิทธิ์รับดาเมจความเสียหาย", TextColor3 = Color3.fromRGB(200, 200, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
local GodToggle = create("TextButton", GodView, {Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "เปิดการต้านทานความตาย (อมตะ): ปิด", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 14})
create("UICorner", GodToggle, {CornerRadius = UDim.new(0, 6)})
create("TextLabel", GodView, {Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(0, 0, 0, 105), BackgroundTransparency = 1, Text = "ฟังก์ชันอมตะ Bypass v3.3:\n• ปิดการตายจากการชนหรือคอหัก\n• ระบบเช็ดเลือดและฟื้นฟูวินาทีต่อวินาที\n• สลับสิทธิ์ Humanoid หลบการถูกทำลายจากเซิร์ฟเวอร์", TextColor3 = Color3.fromRGB(170, 170, 175), Font = Enum.Font.SourceSans, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
GodToggle.MouseButton1Click:Connect(function()
local state = not HubSettings.GodModeEnabled
ToggleGodMode(state)
GodToggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
GodToggle.Text = "เปิดการต้านทานความตาย (อมตะ): " .. (state and "เปิด" or "ปิด")
end)
-- [ ตกแต่งแท็บที่ 7: หน้าวาร์ปหาผู้เล่น ]
local TeleportTitle = create("TextLabel", TeleportView, {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "ป้อนตัวอักษรบางส่วนของชื่อและกดยืนยัน", TextColor3 = Color3.fromRGB(200, 200, 255), Font = Enum.Font.SourceSansBold, TextSize = 13})
local PlayerInput = create("TextBox", TeleportView, {
Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(5, 5, 8), TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, Text = "", PlaceholderText = "พิมพ์ชื่อผู้เล่นที่นี่...", TextSize = 14
})
create("UICorner", PlayerInput, {CornerRadius = UDim.new(0, 6)})
create("UIStroke", PlayerInput, {Thickness = 1, Color = Color3.fromRGB(0, 120, 255)})
local TeleportBtn = create("TextButton", TeleportView, {
Size = UDim2.new(1, 0, 0, 45), Position = UDim2.new(0, 0, 0, 95), BackgroundColor3 = Color3.fromRGB(0, 120, 255), Text = "ยืนยันวาร์ปพิกัดด่วน", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 14
})
create("UICorner", TeleportBtn, {CornerRadius = UDim.new(0, 6)})
TeleportBtn.MouseButton1Click:Connect(function()
local targetText = string.lower(PlayerInput.Text)
if targetText == "" then Notify("ความผิดพลาด", "กรุณาใส่ชื่อเป้าหมายก่อนทำการวาร์ป") return end
local foundPlayer = nil
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and (string.sub(string.lower(player.Name), 1, #targetText) == targetText or string.sub(string.lower(player.DisplayName), 1, #targetText) == targetText) then
foundPlayer = player
break
end
end
if foundPlayer and foundPlayer.Character and foundPlayer.Character:FindFirstChild("HumanoidRootPart") then
local myChar = LocalPlayer.Character
if myChar and myChar:FindFirstChild("HumanoidRootPart") then
myChar.HumanoidRootPart.CFrame = foundPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
Notify("วาร์ปสำเร็จ", "ย้ายพิกัดไปถึงผู้เล่น: " .. foundPlayer.Name)
else
Notify("ล้มเหลว", "กำลังโหลดโมเดลตัวละครของคุณ")
end
else
Notify("ค้นหาล้มเหลว", "ไม่พบชื่อนี้ในเซิร์ฟเวอร์หรือผู้เล่นออฟไลน์")
end
end)
-- [ ตกแต่งแท็บที่ 8: เมนูลดกราฟิกภาพลื่น และเพิ่มความสว่าง (FPS Boost & Full Bright) ]
local FpsToggle = create("TextButton", VisualView, {
Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "เปิดใช้งานระบบเพิ่มเฟรมเรต (FPS Boost): ปิด", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13
})
create("UICorner", FpsToggle, {CornerRadius = UDim.new(0, 6)})
local BrightToggle = create("TextButton", VisualView, {
Size = UDim2.new(1, 0, 0, 45), Position = UDim2.new(0, 0, 0, 55), BackgroundColor3 = Color3.fromRGB(150, 40, 40), Text = "เปิดโหมดความสว่างสูงสุด (Full Bright): ปิด", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 13
})
create("UICorner", BrightToggle, {CornerRadius = UDim.new(0, 6)})
-- อัลกอริทึมลดกราฟิกเพื่อให้เครื่องลื่นขึ้น (FPS Boost)
local function OptimizeGraphics(state)
HubSettings.FpsBoostEnabled = state
if state then
-- ปรับลดความละเอียดระบบฟิสิกส์และคุณภาพเรนเดอร์ในอุปกรณ์แท็บเล็ตลงทันที
settings().Physics.PhysicsEnvironmentalThrottle = 1
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
-- ทำการล้างพาร์ทเอฟเฟกต์ พื้นผิว สติ๊กเกอร์ทั้งหมดในแผนที่ให้เกลี้ยง
for _, v in ipairs(workspace:GetDescendants()) do
if v:IsA("Decal") or v:IsA("Texture") then
v.Transparency = 1
elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
v.Enabled = false
elseif v:IsA("PostEffect") then
v.Enabled = false
elseif v:IsA("BasePart") then
v.Material = Enum.Material.SmoothPlastic
v.Reflectance = 0
end
end
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Notify("ระบบภาพลื่นสำเร็จ", "ทำการล้างภาพสะท้อน พื้นผิว ดีแคล และลดคุณภาพโมเดลเพื่อลดความร้อนแล้ว")
else
Notify("คำเตือนระบบภาพ", "ปิดใช้งานระบบลดกราฟิกแล้ว คุณสามารถรีเซ็ตตัวละครเพื่อคืนค่ากราฟิกปกติได้")
end
end
-- อัลกอริทึมเปิดสว่างตอนกลางคืนทะลุมิติ (Full Bright System)
local function OptimizeBrightness(state)
HubSettings.FullBrightEnabled = state
if state then
-- ทำการเร่งแสง Ambient โดยตรงเพื่อให้แผนที่ไม่มีความสว่างติดมืดอีกต่อไป
Lighting.Ambient = Color3.fromRGB(255, 255, 255)
Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
Lighting.Brightness = 3
Lighting.GlobalShadows = false
Notify("เปิดความสว่างสูงสุด", "เร่งค่าความสว่างสภาพแวดล้อมเสร็จสิ้น")
else
-- คืนค่าสภาพอากาศกลับสู่สถาวะเดิมที่แมพเซ็ตไว้
Lighting.Ambient = Color3.fromRGB(128, 128, 128)
Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
Lighting.Brightness = 1
Lighting.GlobalShadows = true
Notify("ปิดระบบแสงสว่าง", "คืนค่าความสว่างสภาพแวดล้อมปกติ")
end
end
FpsToggle.MouseButton1Click:Connect(function()
local state = not HubSettings.FpsBoostEnabled
OptimizeGraphics(state)
FpsToggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
FpsToggle.Text = "เปิดใช้งานระบบเพิ่มเฟรมเรต (FPS Boost): " .. (state and "เปิด" or "ปิด")
end)
BrightToggle.MouseButton1Click:Connect(function()
local state = not HubSettings.FullBrightEnabled
OptimizeBrightness(state)
BrightToggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
BrightToggle.Text = "เปิดโหมดความสว่างสูงสุด (Full Bright): " .. (state and "เปิด" or "ปิด")
end)
-- แจ้งเตือนสคริปต์โหลดเสร็จสมบูรณ์เรียบร้อย
Notify("Gemini Script โหลดเสร็จสิ้น", "ระบบความคุ้มครองความปลอดภัยเชื่อมโยงสำเร็จแล้ว")
