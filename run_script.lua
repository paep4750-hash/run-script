-- ====================================================
-- FOXNAME HUB v6 (NAVY GLASS) - PART 1: CORE ENGINE
-- ====================================================

-- ประกาศตัวแปรส่วนกลางเพื่อใช้เชื่อมต่อไปยังพาร์ท 2
getgenv().InfiniteStaminaActive = true

getgenv().States = {
    CurrentTab = "User",
    SpeedValue = 16,
    JumpPowerValue = 50,
    NoclipActive = false,
    UnlockThirdPerson = false,
    AutoTreatActive = false,
    AutoStampActive = false,
    BlockNotifications = false,
    LogNotifications = false,
    SpoofStatsActive = false -- ฟังก์ชันใหม่สลับค่าสถานะจำลองฝั่ง Client
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net")
local PlayerLostSanity = Net:WaitForChild("RE/PlayerLostSanity")
local StatsEvent = Net:WaitForChild("RE/Stats")

-- 1. บล็อกข้อมูลฝั่งเซิร์ฟเวอร์เรื่องความเหนื่อยล้า (Bypass)
local hookSuccess, hookError = pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if self == PlayerLostSanity and (method == "FireServer" or method == "fireServer") then
            if getgenv().InfiniteStaminaActive then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
end)

-- 2. ลูปตรวจสอบล็อกหลอดในเครื่อง (Stamina & Sanity) ให้เต็ม 100 ตลอดเวลา
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

-- 3. [ฟังก์ชันใหม่] ระบบ Spoof Stats ดักจับการอัปเดตสถิติเพื่อแปลงค่าปลอม
local statsConnection
pcall(function()
    statsConnection = StatsEvent.OnClientEvent:Connect(function(actionType, statsTable, updateField, extraData)
        if getgenv().States.SpoofStatsActive and actionType == "Stats" and type(statsTable) == "table" then
            statsTable.Cash = 999999
            statsTable.PatientsCheckedIn = 999
            statsTable.PatientsTreated = 999
            statsTable.HighestShift = 99
            statsTable.ClassXP = { Nurse = 9999, Intern = 9999 }
            statsTable.UnlockedClasses = { Nurse = true, Intern = true, Doctor = true }
        end
    end)
end)

print("[Part 1]: ล็อกหลอดสมอง/พลังงาน และระบบดักค่า Spoof ทำงานแล้ว!")

-- ====================================================
-- FOXNAME HUB v6 (NAVY GLASS) - PART 2: UI & AUTOMATION
-- ====================================================

local States = getgenv().States or {
    CurrentTab = "User",
    SpeedValue = 16,
    JumpPowerValue = 50,
    NoclipActive = false,
    UnlockThirdPerson = false,
    AutoTreatActive = false,
    AutoStampActive = false,
    BlockNotifications = false,
    LogNotifications = false,
    SpoofStatsActive = false
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net")
local StatsEvent = Net:WaitForChild("RE/Stats")
local NotifyRemote = Net:WaitForChild("RE/Notify")

-- [ บล็อกการแจ้งเตือนและระบบกรองสกรีนเนอร์ ]
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

-- [ ระบบบอทช่วยเหลือ ]
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

-- [ สร้างหน้าต่างเมนูต้นฉบับ ]
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

-- แถบ Sidebar ข้างซ้าย
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

-- ส่วนพื้นที่วางปุ่มต่างๆ
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

-- [ ฟังก์ชันเครื่องมือสร้าง UI ]
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

-- [ ใส่ฟังก์ชันลงแท็บต่าง ๆ ]

-- === แท็บที่ 1: USER CONTROLS (👤 Player Specs) ===
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

-- ปุ่มฟังก์ชันใหม่: ปุ่มสลับระบบสร้างค่าพลังจำลอง
AddToggle(PageUser, "Spoof Stats (จำลองเงิน & สถิติ)", false, function(state)
    States.SpoofStatsActive = state
    if state then
        pcall(function()
            -- สั่งให้สัญญาณจำลองส่งข้อมูลไปหลอกฝั่ง UI ของเกมทันที
            firesignal(StatsEvent.OnClientEvent, "Stats", {}, "PatientsCheckedIn", nil)
        end)
    end
end)

-- === แท็บที่ 2: AUTO CONTROLS (🏥 Auto Hospital) ===
AddToggle(PageAuto, "Auto Treat Animals (รักษาสัตว์ออ้ต)", false, function(state) States.AutoTreatActive = state end)
AddToggle(PageAuto, "Auto Stamp Form (ปั๊มตรากระดาษม่วง)", false, function(state) States.AutoStampActive = state end)
AddToggle(PageAuto, "Block Game Popups (บล็อกแจ้งเตือนเด้งกวนใจ)", false, function(state) ToggleGameNotifications(state) end)
AddToggle(PageAuto, "Log Notifications to F9 Console", false, function(state) States.LogNotifications = state end)

-- [ ลูปเบื้องหลังความเร็วและปีนป่าย ]
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

-- ลูปรักษาสัตว์และการทำงานออโต้ฟาร์ม
task.spawn(function()
    while true do
        task.wait(0.25)
        if States.AutoTreatActive then AutoInteractWithAnimals() end
        if States.AutoStampActive then AutoStampForm() end
    end
end)

-- [ ปุ่มกลมลอยย่อหน้าต่าง ]
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 40, 0, 40)
MinimizeBtn.Position = UDim2.new(0, 10, 0, 10)
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

print("[Part 2]: โครงสร้างเมนู Navy Glass ต้นฉบับและปุ่มเปิด Spoof Stats โหลดเสร็จเรียบร้อย!")
