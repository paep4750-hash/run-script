--[[
    ========================================================================
    [  GEMINI CUSTOM MULTI-SCRIPT EXECUTOR & ADVANCED BYPASS HUB v2.5  ]
    ========================================================================
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
if not PlayerGui then return end

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
local RealCharacterCFrame = nil
local VirtualRig = nil
local RigConnection = nil
local GodModeConnection = nil

-- Metatable WalkSpeed spoofing bypass
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

-- Anti-detection Speed Frame Loop
RunService.RenderStepped:Connect(function(deltaTime)
    if HubSettings.SpeedEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart and humanoid.MoveDirection.Magnitude > 0 then
            local moveDirection = humanoid.MoveDirection
            local calculatedFactor = moveDirection * (HubSettings.SpeedMultiplier * 10) * deltaTime
            rootPart.CFrame = rootPart.CFrame + Vector3.new(calculatedFactor.X, 0, calculatedFactor.Z)
        end
    end
end)
-- Advanced ESP Master
local function CreateESP(player)
    if player == LocalPlayer then return end
    local function applyEsp(character)
        if not character then return end
        local oldEsp = character:FindFirstChild("GeminiESP")
        if oldEsp then oldEsp:Destroy() end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "GeminiESP"
        highlight.FillColor = Color3.fromRGB(0, 120, 255)
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Enabled = HubSettings.EspEnabled
        highlight.Parent = character
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
end

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p) EspObjects[p.Name] = nil end)

-- Ghost Invisibility Setup
local function ToggleInvisibility(state)
    HubSettings.InvisibleEnabled = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    if state then
        char.Archivable = true
        GhostClone = char:Clone()
        GhostClone.Name = "GhostVisualShell"
        GhostClone.Parent = workspace
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = 0.6 end
        end
        RealCharacterCFrame = char.HumanoidRootPart.CFrame
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame - Vector3.new(0, 80, 0)
    else
        if GhostClone and GhostClone:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = GhostClone.HumanoidRootPart.CFrame
            GhostClone:Destroy()
            GhostClone = nil
        elseif RealCharacterCFrame then
            char.HumanoidRootPart.CFrame = RealCharacterCFrame
        end
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then part.Transparency = 0 end
        end
    end
end
-- Clear Virtual Rig Connections
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
        if char:FindFirstChildOfClass("Humanoid") then workspace.CurrentCamera.CameraSubject = char:FindFirstChildOfClass("Humanoid") end
    end
end

-- Virtual Rig Reanimator Setup
local function SetVirtualRig(targetType)
    ClearVirtualRig()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local realHumanoid = char:FindFirstChildOfClass("Humanoid")
    if not realHumanoid then return end
    
    HubSettings.RigMode = targetType
    char.Archivable = true
    
    local fakeModel = Instance.new("Model")
    fakeModel.Name = "Virtual_" .. targetType .. "_Rig"
    fakeModel.Parent = workspace
    local fakeHumanoid = Instance.new("Humanoid")
    fakeHumanoid.Parent = fakeModel
    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(2, 2, 1)
    rootPart.Transparency = 1
    rootPart.CanCollide = false
    rootPart.Parent = fakeModel
    
    local function CreateVirtualLimb(name, size, offset)
        local part = Instance.new("Part")
        part.Name = name
        part.Size = size
        part.Color = Color3.fromRGB(160, 160, 160)
        part.CanCollide = false
        part.Massless = true
        part.Parent = fakeModel
        local weld = Instance.new("Weld")
        weld.Part0 = rootPart
        weld.Part1 = part
        weld.C0 = CFrame.new(offset)
        weld.Parent = rootPart
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
end
-- Toggle God Mode
local function ToggleGodMode(state)
    HubSettings.GodModeEnabled = state
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if state then
        humanoid.RequiresNeck = false
        GodModeConnection = RunService.Heartbeat:Connect(function()
            local currentChar = LocalPlayer.Character
            if not currentChar then return end
            local currentHumanoid = currentChar:FindFirstChildOfClass("Humanoid")
            local root = currentChar:FindFirstChild("HumanoidRootPart")
            if currentHumanoid then
                currentHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                if currentHumanoid:GetState() == Enum.HumanoidStateType.Dead then currentHumanoid:ChangeState(Enum.HumanoidStateType.Running) end
                if currentHumanoid.Health < currentHumanoid.MaxHealth then currentHumanoid.Health = currentHumanoid.MaxHealth end
            end
            if root and root.Position.Y < -350 then
                root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if GodModeConnection then GodModeConnection:Disconnect() GodModeConnection = nil end
        humanoid.RequiresNeck = true
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end
end
-- [ Create Screen GUI Frames ]
local existingUi = PlayerGui:FindFirstChild("GeminiScriptHub")
if existingUi then existingUi:Destroy() end

local GeminiScriptHub = Instance.new("ScreenGui")
GeminiScriptHub.Name = "GeminiScriptHub"
GeminiScriptHub.Parent = PlayerGui
GeminiScriptHub.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 540, 0, 340)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = GeminiScriptHub

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(0, 120, 255)
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "  GEMINI SCRIPT EXECUTOR & MULTI-BYPASS HUB"
TitleBar.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleBar.TextSize = 13
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 2)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = MainFrame
CloseButton.MouseButton1Click:Connect(function() GeminiScriptHub:Destroy() end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -65, 0, -2)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = MainFrame

local RestoreButton = Instance.new("TextButton")
RestoreButton.Name = "RestoreButton"
RestoreButton.Size = UDim2.new(0, 80, 0, 32)
RestoreButton.Position = UDim2.new(0.05, 0, 0.15, 0)
RestoreButton.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
RestoreButton.Text = "GEMINI"
RestoreButton.TextColor3 = Color3.fromRGB(0, 120, 255)
RestoreButton.Font = Enum.Font.SourceSansBold
RestoreButton.TextSize = 12
RestoreButton.Visible = false
RestoreButton.Active = true
RestoreButton.Draggable = true
RestoreButton.Parent = GeminiScriptHub

local RestoreCorner = Instance.new("UICorner")
RestoreCorner.CornerRadius = UDim.new(0, 6)
RestoreCorner.Parent = RestoreButton

local RestoreStroke = Instance.new("UIStroke")
RestoreStroke.Thickness = 1.5
RestoreStroke.Color = Color3.fromRGB(0, 120, 255)
RestoreStroke.Parent = RestoreButton

MinimizeButton.MouseButton1Click:Connect(function() MainFrame.Visible = false RestoreButton.Visible = true end)
RestoreButton.MouseButton1Click:Connect(function() RestoreButton.Visible = false MainFrame.Visible = true end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -45)
Sidebar.Position = UDim2.new(0, 5, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 6)
SidebarCorner.Parent = Sidebar

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -160, 1, -50)
ContentArea.Position = UDim2.new(0, 150, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Frames = {}
local function CreateTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = order == 1 and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(20, 20, 25)
    btn.Text = name
    btn.TextColor3 = order == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.LayoutOrder = order
    btn.Parent = Sidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    local viewFrame = Instance.new("Frame")
    viewFrame.Size = UDim2.new(1, 0, 1, 0)
    viewFrame.BackgroundTransparency = 1
    viewFrame.Visible = order == 1
    viewFrame.Parent = ContentArea
    
    Frames[name] = {Button = btn, Frame = viewFrame}

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

local ExecView = CreateTab("Script Executor", 1)
local SpeedView = CreateTab("Bypass Speed", 2)
local EspView = CreateTab("ESP Master", 3)
local GhostView = CreateTab("Ghost Invisible", 4)
local RigView = CreateTab("Rig Reanimator", 5)
local GodView = CreateTab("God Mode", 6)

-- [ Tab 1: Executor View Components ]
local ScriptBox = Instance.new("TextBox")
ScriptBox.Size = UDim2.new(1, 0, 0.78, 0)
ScriptBox.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
ScriptBox.TextColor3 = Color3.fromRGB(200, 200, 200)
ScriptBox.Font = Enum.Font.Code
ScriptBox.Text = "-- Paste your external configurations here..."
ScriptBox.MultiLine = true
ScriptBox.ClearTextOnFocus = false
ScriptBox.TextXAlignment = Enum.TextXAlignment.Left
ScriptBox.TextYAlignment = Enum.TextYAlignment.Top
ScriptBox.Parent = ExecView

local ScriptBoxCorner = Instance.new("UICorner")
ScriptBoxCorner.CornerRadius = UDim.new(0, 4)
ScriptBoxCorner.Parent = ScriptBox

local ExecuteBtn = Instance.new("TextButton")
ExecuteBtn.Size = UDim2.new(0.48, 0, 0.18, 0)
ExecuteBtn.Position = UDim2.new(0, 0, 0.82, 0)
ExecuteBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
ExecuteBtn.Text = "Execute Code"
ExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteBtn.Font = Enum.Font.SourceSansBold
ExecuteBtn.TextSize = 13
ExecuteBtn.Parent = ExecView

ExecuteBtn.MouseButton1Click:Connect(function()
    local src = ScriptBox.Text
    local success, err = pcall(function()
        local f = loadstring(src)
        if f then f() else error("Syntax compilation failed.") end
    end)
    if not success then ScriptBox.Text = "-- Compilation Error:\n" .. tostring(err) end
end)

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.48, 0, 0.18, 0)
ClearBtn.Position = UDim2.new(0.52, 0, 0.82, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
ClearBtn.Text = "Clear Text"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Font = Enum.Font.SourceSansBold
ClearBtn.TextSize = 13
ClearBtn.Parent = ExecView
ClearBtn.MouseButton1Click:Connect(function() ScriptBox.Text = "" end)

-- [ Tab 2: Speed View Components ]
local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.new(1, 0, 0, 45)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
SpeedToggle.Text = "Bypass Speed Acceleration: OFF"
SpeedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedToggle.Font = Enum.Font.SourceSansBold
SpeedToggle.TextSize = 14
SpeedToggle.Parent = SpeedView

SpeedToggle.MouseButton1Click:Connect(function()
    HubSettings.SpeedEnabled = not HubSettings.SpeedEnabled
    SpeedToggle.BackgroundColor3 = HubSettings.SpeedEnabled and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
    SpeedToggle.Text = "Bypass Speed Acceleration: " .. (HubSettings.SpeedEnabled and "ON" or "OFF")
end)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 30)
SpeedLabel.Position = UDim2.new(0, 0, 0, 60)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Velocity Factor Vector: x2.0"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.TextSize = 13
SpeedLabel.Parent = SpeedView

local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(1, 0, 0, 8)
SliderBg.Position = UDim2.new(0, 0, 0, 100)
SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
SliderBg.Parent = SpeedView

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.2, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
SliderFill.Parent = SliderBg

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(0, 16, 0, 16)
SliderBtn.Position = UDim2.new(0.2, -8, 0.5, -8)
SliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBg

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

-- [ Tab 3: ESP View Components ]
local EspToggle = Instance.new("TextButton")
EspToggle.Size = UDim2.new(1, 0, 0, 45)
EspToggle.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
EspToggle.Text = "Extra Sensory Perception (ESP): OFF"
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggle.Font = Enum.Font.SourceSansBold
EspToggle.TextSize = 14
EspToggle.Parent = EspView
EspToggle.MouseButton1Click:Connect(function()
    local state = not HubSettings.EspEnabled
    ToggleESP(state)
    EspToggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
    EspToggle.Text = "Extra Sensory Perception (ESP): " .. (state and "ON" or "OFF")
end)

-- [ Tab 4: Ghost Invisible View Components ]
local GhostToggle = Instance.new("TextButton")
GhostToggle.Size = UDim2.new(1, 0, 0, 45)
GhostToggle.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
GhostToggle.Text = "Bypass Ghost Invisibility: OFF"
GhostToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
GhostToggle.Font = Enum.Font.SourceSansBold
GhostToggle.TextSize = 14
GhostToggle.Parent = GhostView
GhostToggle.MouseButton1Click:Connect(function()
    local state = not HubSettings.InvisibleEnabled
    ToggleInvisibility(state)
    GhostToggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
    GhostToggle.Text = "Bypass Ghost Invisibility: " .. (state and "ON" or "OFF")
end)

-- [ Tab 5: Rig Reanimator View Components ]
local RigTitle = Instance.new("TextLabel")
RigTitle.Size = UDim2.new(1, 0, 0, 30)
RigTitle.BackgroundTransparency = 1
RigTitle.Text = "Virtual Character Rig Emulation Bypass Setup"
RigTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
RigTitle.Font = Enum.Font.SourceSansBold
RigTitle.TextSize = 13
RigTitle.Parent = RigView

local SwitchR6Btn = Instance.new("TextButton")
SwitchR6Btn.Size = UDim2.new(0.31, 0, 0, 40)
SwitchR6Btn.Position = UDim2.new(0, 0, 0, 45)
SwitchR6Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SwitchR6Btn.Text = "Virtual R6"
SwitchR6Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
SwitchR6Btn.Font = Enum.Font.SourceSansBold
SwitchR6Btn.TextSize = 13
SwitchR6Btn.Parent = RigView
SwitchR6Btn.MouseButton1Click:Connect(function() SetVirtualRig("R6") RigTitle.Text = "Active Rig Virtualization Bypass: R6" end)

local SwitchR15Btn = Instance.new("TextButton")
SwitchR15Btn.Size = UDim2.new(0.31, 0, 0, 40)
SwitchR15Btn.Position = UDim2.new(0.34, 0, 0, 45)
SwitchR15Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SwitchR15Btn.Text = "Virtual R15"
SwitchR15Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
SwitchR15Btn.Font = Enum.Font.SourceSansBold
SwitchR15Btn.TextSize = 13
SwitchR15Btn.Parent = RigView
SwitchR15Btn.MouseButton1Click:Connect(function() SetVirtualRig("R15") RigTitle.Text = "Active Rig Virtualization Bypass: R15" end)

local ResetRigBtn = Instance.new("TextButton")
ResetRigBtn.Size = UDim2.new(0.31, 0, 0, 40)
ResetRigBtn.Position = UDim2.new(0.68, 0, 0, 45)
ResetRigBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
ResetRigBtn.Text = "Reset Rig"
ResetRigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetRigBtn.Font = Enum.Font.SourceSansBold
ResetRigBtn.TextSize = 13
ResetRigBtn.Parent = RigView
ResetRigBtn.MouseButton1Click:Connect(function() ClearVirtualRig() RigTitle.Text = "Active Rig Virtualization Bypass: Original" end)

-- [ Tab 6: God Mode View Components ]
local GodTitle = Instance.new("TextLabel")
GodTitle.Size = UDim2.new(1, 0, 0, 30)
GodTitle.BackgroundTransparency = 1
GodTitle.Text = "Advanced Anti-Death & Damage Interceptor Bypass"
GodTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
GodTitle.Font = Enum.Font.SourceSansBold
GodTitle.TextSize = 13
GodTitle.Parent = GodView

local GodToggle = Instance.new("TextButton")
GodToggle.Size = UDim2.new(1, 0, 0, 50)
GodToggle.Position = UDim2.new(0, 0, 0, 45)
GodToggle.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
GodToggle.Text = "Anti-Death God Mode: OFF"
GodToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
GodToggle.Font = Enum.Font.SourceSansBold
GodToggle.TextSize = 14
GodToggle.Parent = GodView

local GodToggleCorner = Instance.new("UICorner")
GodToggleCorner.CornerRadius = UDim.new(0, 6)
GodToggleCorner.Parent = GodToggle

local GodInfoText = Instance.new("TextLabel")
GodInfoText.Size = UDim2.new(1, 0, 0, 60)
GodInfoText.Position = UDim2.new(0, 0, 0, 105)
GodInfoText.BackgroundTransparency = 1
GodInfoText.Text = "Secured Features Active:\n• Bypass Client-side death (State Locking)\n• Void damage recovery (Auto-Teleport)\n• No Neck-Break death trigger"
GodInfoText.TextColor3 = Color3.fromRGB(170, 170, 175)
GodInfoText.Font = Enum.Font.SourceSans
GodInfoText.TextSize = 12
GodInfoText.TextXAlignment = Enum.TextXAlignment.Left
GodInfoText.Parent = GodView

GodToggle.MouseButton1Click:Connect(function()
    local state = not HubSettings.GodModeEnabled
    ToggleGodMode(state)
    GodToggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 40, 40)
    GodToggle.Text = "Anti-Death God Mode: " .. (state and "ON" or "OFF")
end)
