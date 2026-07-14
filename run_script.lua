-- ====================================================
-- PART 1: FOXNAME INFINITY SANITY & STAMINA BYPASS
-- ====================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ประกาศสร้าง Global State ป้องกันค่าหายจากการรีเซ็ตตัวละคร
getgenv().InfiniteStaminaActive = true

-- 1. บล็อกการยิงรีโมทโดยตรง (บังคับคืนค่าว่างทันที)
local Net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net")
local PlayerLostSanity = Net:WaitForChild("RE/PlayerLostSanity")

local hookSuccess, hookError = pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if self == PlayerLostSanity and (method == "FireServer" or method == "fireServer") then
            if getgenv().InfiniteStaminaActive then
                return nil -- บล็อกแพ็กเก็ตโยนทิ้งทันที สตามิน่าจะไม่ลด
            end
        end
        return oldNamecall(self, ...)
    end)
end)

-- 2. เจาะระบบลดหลอดภายในเครื่อง (สแกนทับค่า Attributes ให้เต็มตลอดเวลา)
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().InfiniteStaminaActive then
            pcall(function()
                local Character = LocalPlayer.Character
                if Character then
                    if Character:GetAttribute("Stamina") then Character:SetAttribute("Stamina", 100) end
                    if Character:GetAttribute("Sanity") then Character:SetAttribute("Sanity", 100) end
                    if LocalPlayer:GetAttribute("Stamina") then LocalPlayer:SetAttribute("Stamina", 100) end
                    if LocalPlayer:GetAttribute("Sanity") then LocalPlayer:SetAttribute("Sanity", 100) end
                end
            end)
        end
    end
end)

print("[Part 1]: ระบบล็อคค่า Stamina & Sanity (Infinity) รันสำเร็จ!")

-- ====================================================
-- PART 2: FOXNAME MAIN UI & ALL CONTROL FEATURES
-- ====================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- [ CONFIGURATION & STATE MANAGEMENT ]
local States = {
    CurrentTab = "User",
    SpeedValue = 16,
    JumpPowerValue = 50,
    NoclipActive = false,
    UnlockThirdPerson = false,
    AutoTreatActive = false,
    AutoStampActive = false,
    BlockNotifications = false,
    LogNotifications = false
}

-- [ NETWORK REMOTES ]
local Net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net")
local NotifyRemote = Net:WaitForChild("RE/Notify")

-- [ ฟังก์ชันจัดการแจ้งเตือนเด้งหน้าจอ (RE/Notify Interceptor) ]
local notifyConnection = nil
pcall(function()
    notifyConnection = NotifyRemote.OnClientEvent:Connect(function(...)
        if States.LogNotifications then
            local args = {...}
            print("[Foxname Logger - Notify]: " .. tostring(args[1] or ""))
        end
    end)
end)

local function ToggleGameNotifications(block)
    States.BlockNotifications = block
    if getconnections then
        for _, connection in ipairs(getconnections(NotifyRemote.OnClientEvent)) do
            if connection.Function ~= notifyConnection then
                if block then connection:Disable() else connection:Enable() end
            end
        end
    end
end

-- [ ฟังก์ชันฟาร์มอัตโนมัติ ]
local function AutoInteractWithAnimals()
    if not States.AutoTreatActive then return end
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parent = prompt.Parent
            if parent and (parent.Name:lower():find("patient") or parent.Name:lower():find("animal") or parent.Name:lower():find("treat")) then
                task.spawn(function() fireproximityprompt(prompt) end)
            end
        end
    end
end

local function AutoStampForm()
    if not States.AutoStampActive then return end
    local FormObj = workspace:FindFirstChild("Misc", true)
    if FormObj then
        local CheckIn = FormObj:FindFirstChild("CheckIn")
        local Form = CheckIn and CheckIn:FindFirstChild("Form")
        local TargetForm = Form or workspace:FindFirstChild("Form", true)
        if TargetForm then
            local prompt = TargetForm:FindFirstChildOfClass("ProximityPrompt") or TargetForm:FindFirstChildOfClass("ClickDetector")
            if prompt then
                if prompt:IsA("ProximityPrompt") then fireproximityprompt(prompt)
                elseif prompt:IsA("ClickDetector") then fireclickdetector(prompt) end
            end
        end
    end
end

-- [ สร้างหน้าจอ UI สไตล์ NAVY GLASS ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FoxnameHospitalUI_v6_Final"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 360)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(45, 52, 75)
MainStroke.Parent = MainFrame

-- แถบ Sidebar ด้านซ้าย
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(1, 0, 0, 45)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "  Foxname Hub v6"
LogoLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.TextSize = 12
LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
LogoLabel.Parent = Sidebar

-- แถบสำหรับใส่เนื้อหาคอนโทรลเลอร์
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -165, 1, -20)
ContentArea.Position = UDim2.new(0, 155, 0, 10)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Pages = {}
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.CanvasSize = UDim2.new(0, 0, 0, 400)
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(45, 52, 75)
    Page.Visible = false
    Page.Parent = ContentArea
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.Parent = Page
    
    Pages[name] = Page
    return Page
end

local PageUser = CreatePage("User")
local PageAuto = CreatePage("Auto")

local function SwitchTab(tabName)
    for name, page in pairs(Pages) do
        page.Visible = (name == tabName)
    end
end

local function AddTabBtn(txt, pageName)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 32)
    Btn.Position = UDim2.new(0.05, 0, 0, #Sidebar:GetChildren() * 34 + 15)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
    Btn.Text = txt
    Btn.TextColor3 = Color3.fromRGB(220, 225, 240)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 10
    Btn.Parent = Sidebar
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function() SwitchTab(pageName) end)
end

AddTabBtn("👤 Player Specs", "User")
AddTabBtn("🏥 Auto Hospital", "Auto")
SwitchTab("User")

-- [ ฟังก์ชันสร้างเครื่องมือ UI: Toggles & Sliders ]
local function AddToggle(parent, txt, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.95, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = txt
    Label.TextColor3 = Color3.fromRGB(220, 225, 240)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 9
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 45, 0, 18)
    Btn.Position = UDim2.new(1, -50, 0.5, -9)
    Btn.BackgroundColor3 = default and Color3.fromRGB(80, 110, 250) or Color3.fromRGB(40, 45, 60)
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 8
    Btn.Parent = Frame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Btn
    
    local active = default
    Btn.MouseButton1Click:Connect(function()
        active = not active
        Btn.Text = active and "ON" or "OFF"
        Btn.BackgroundColor3 = active and Color3.fromRGB(80, 110, 250) or Color3.fromRGB(40, 45, 60)
        callback(active)
    end)
end

local function AddSlider(parent, title, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.95, 0, 0, 40)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.7, 0, 0, 15)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(190, 195, 210)
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.TextSize = 9
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.25, 0, 0, 15)
    ValueLabel.Position = UDim2.new(0.75, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(80, 110, 250)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 9
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 4)
    SliderBar.Position = UDim2.new(0, 0, 0, 22)
    SliderBar.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    SliderBar.Parent = SliderFrame
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(80, 110, 250)
    Fill.Parent = SliderBar
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 8, 0, 8)
    Knob.Position = UDim2.new((default - min) / (max - min), -4, 0.5, -4)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Parent = SliderBar
    
    local Trigger = Instance.new("TextButton")
    Trigger.Size = UDim2.new(1, 0, 1, 0)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""
    Trigger.Parent = SliderBar
    
    local function UpdateSlider(input)
        local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        Knob.Position = UDim2.new(percentage, -4, 0.5, -4)
        local val = math.round(min + (percentage * (max - min)))
        ValueLabel.Text = tostring(val)
        callback(val)
    end
    
    local dragging = false
    Trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true UpdateSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- [ ประกอบอุปกรณ์ลงในหน้าต่างๆ ของเมนู ]

-- หน้าผู้เล่น (User Page)
AddSlider(PageUser, "Speed (ปรับความเร็วตัวละคร)", 16, 150, 16, function(val) States.SpeedValue = val end)
AddSlider(PageUser, "Jump Power (ความสูงกระโดด)", 50, 200, 50, function(val) States.JumpPowerValue = val end)

AddToggle(PageUser, "Infinity Stamina & Sanity", getgenv().InfiniteStaminaActive, function(state)
    getgenv().InfiniteStaminaActive = state
end)

AddToggle(PageUser, "Noclip (เดินทะลุกำแพง)", false, function(state) States.NoclipActive = state end)

AddToggle(PageUser, "Unlock Third Person (ซูมมุมมองไกล)", false, function(state)
    States.UnlockThirdPerson = state
    LocalPlayer.CameraMaxZoomDistance = state and 500 or 30
end)

-- หน้าช่วยฟาร์ม (Auto Page)
AddToggle(PageAuto, "Auto Treat Animals (รักษาสัตว์ออโต้)", false, function(state) States.AutoTreatActive = state end)
AddToggle(PageAuto, "Auto Stamp Form (ปั๊มตรากระดาษม่วง)", false, function(state) States.AutoStampActive = state end)
AddToggle(PageAuto, "Block Game Popups (บล็อกแจ้งเตือนเด้งกวนใจ)", false, function(state) ToggleGameNotifications(state) end)
AddToggle(PageAuto, "Log Notifications to F9 Console", false, function(state) States.LogNotifications = state end)

-- [ ลูปทำงานเบื้องหลังสำหรับความเร็ว/กระโดด/ทะลุกำแพง ]
RunService.Heartbeat:Connect(function()
    local Character = LocalPlayer.Character
    if Character then
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid and RootPart and Humanoid.MoveDirection.Magnitude > 0 and States.SpeedValue > 16 then
            local vel = Humanoid.MoveDirection * (States.SpeedValue - 16)
            RootPart.AssemblyLinearVelocity = Vector3.new(vel.X, RootPart.AssemblyLinearVelocity.Y, vel.Z)
        end
        if Humanoid and States.JumpPowerValue > 50 then Humanoid.JumpPower = States.JumpPowerValue end
        if States.NoclipActive then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- ลูปการทำงานฟาร์มอัตโนมัติ
task.spawn(function()
    while true do
        task.wait(0.25)
        if States.AutoTreatActive then AutoInteractWithAnimals() end
        if States.AutoStampActive then AutoStampForm() end
    end
end)

-- ปุ่มย่อหน้าต่างกลมสีดำลอยได้
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 40, 0, 40)
MinimizeBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
MinimizeBtn.Text = "FOX"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 10
MinimizeBtn.Parent = ScreenGui

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(1, 0)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

print("[Part 2]: หน้าต่างเมนูคุมความเร็ว, ฟาร์ม และแจ้งเตือนรันสำเร็จ!")
