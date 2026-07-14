-- ====================================================
-- FOXNAME HUB v6: PART 1 (CORE ENGINE)
-- ====================================================

-- สร้างตัวแปรส่วนกลางให้ใช้งานข้ามส่วนได้
getgenv().States = {
    SpeedValue = 16,
    JumpPowerValue = 50,
    NoclipActive = false,
    AutoTreatActive = false,
    AutoStampActive = false,
    BlockNotifications = false,
    LogNotifications = false,
    SpoofStatsActive = false
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net")
local PlayerLostSanity = Net:WaitForChild("RE/PlayerLostSanity")
local StatsEvent = Net:WaitForChild("RE/Stats")
local NotifyRemote = Net:WaitForChild("RE/Notify")

-- 1. บายพาสสตามิน่า
local hookSuccess, hookError = pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if self == PlayerLostSanity and (method == "FireServer" or method == "fireServer") then
            return nil
        end
        return oldNamecall(self, ...)
    end)
end)

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local Char = LocalPlayer.Character
            if Char then
                if Char:GetAttribute("Stamina") then Char:SetAttribute("Stamina", 100) end
                if Char:GetAttribute("Sanity") then Char:SetAttribute("Sanity", 100) end
            end
        end)
    end
end)

-- 2. ระบบ Spoof Stats
pcall(function()
    StatsEvent.OnClientEvent:Connect(function(actionType, statsTable)
        if getgenv().States.SpoofStatsActive and actionType == "Stats" and type(statsTable) == "table" then
            statsTable.Cash = 999999
            statsTable.PatientsCheckedIn = 999
            statsTable.PatientsTreated = 999
            statsTable.ClassXP = {Nurse = 9999, Intern = 9999}
            statsTable.UnlockedClasses = {Nurse = true, Intern = true, Doctor = true}
        end
    end)
end)

print("[Part 1]: ระบบ Core รันสำเร็จพร้อมใช้งาน!")

-- ====================================================
-- FOXNAME HUB v6: PART 2 (UI & AUTOMATION - FULL FIXED)
-- ====================================================

local States = getgenv().States or {
    SpeedValue = 16,
    JumpPowerValue = 50,
    NoclipActive = false,
    AutoTreatActive = false,
    AutoStampActive = false,
    BlockNotifications = false,
    LogNotifications = false,
    SpoofStatsActive = false
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Net = game:GetService("ReplicatedStorage").Util.Net
local NotifyRemote = Net:WaitForChild("RE/Notify")
local StatsEvent = Net:WaitForChild("RE/Stats")

-- ฟังก์ชันระบบแจ้งเตือนกวนใจ
local function ToggleNotifications(block)
    States.BlockNotifications = block
    if getconnections then
        for _, connection in ipairs(getconnections(NotifyRemote.OnClientEvent)) do
            if block then connection:Disable() else connection:Enable() end
        end
    end
end

-- ฟังก์ชันช่วยเหลือสัตว์และการปั๊มตราแบบฟอร์ม
local function AutoTasks()
    if States.AutoTreatActive then
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local p = prompt.Parent
                if p and (p.Name:lower():find("patient") or p.Name:lower():find("animal")) then
                    task.spawn(function() fireproximityprompt(prompt) end)
                end
            end
        end
    end
    if States.AutoStampActive then
        local form = workspace:FindFirstChild("Form", true) or workspace:FindFirstChild("CheckIn", true)
        if form then
            local prompt = form:FindFirstChildOfClass("ProximityPrompt")
            if prompt then fireproximityprompt(prompt) end
        end
    end
end

-- 1. สร้างหน้าจอ UI หลัก
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "FoxnameFixedUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 280)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
MainFrame.Active = true
MainFrame.Draggable = true

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

-- แถบสลับเมนูด้านข้าง (Sidebar)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)

local SideCorner = Instance.new("UICorner", Sidebar)
SideCorner.CornerRadius = UDim.new(0, 10)

local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 40)
Logo.Text = "Foxname v6"
Logo.TextColor3 = Color3.fromRGB(240, 240, 250)
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 12

-- พื้นที่แสดงปุ่มตั้งค่าต่างๆ
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -140, 1, -20)
ContentArea.Position = UDim2.new(0, 135, 0, 10)
ContentArea.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", ContentArea)
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 2. ฟังก์ชันสร้างปุ่ม Toggle เปิด-ปิดสำหรับแท็บเล็ต
local function CreateToggle(txt, default, callback)
    local Frame = Instance.new("Frame", ContentArea)
    Frame.Size = UDim2.new(0.95, 0, 0, 30)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = txt
    Label.TextColor3 = Color3.fromRGB(220, 225, 240)
    Label.TextSize = 10
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 45, 0, 18)
    Btn.Position = UDim2.new(1, -50, 0.5, -9)
    Btn.BackgroundColor3 = default and Color3.fromRGB(60, 110, 240) or Color3.fromRGB(40, 45, 60)
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 8
    
    local BCorner = Instance.new("UICorner", Btn)
    BCorner.CornerRadius = UDim.new(0, 4)
    
    local active = default
    Btn.MouseButton1Click:Connect(function()
        active = not active
        Btn.Text = active and "ON" or "OFF"
        Btn.BackgroundColor3 = active and Color3.fromRGB(60, 110, 240) or Color3.fromRGB(40, 45, 60)
        callback(active)
    end)
end

-- 3. สร้างปุ่มสไลเดอร์ปรับค่าความเร็ว/ความสูง
local function CreateSlider(title, min, max, default, callback)
    local Frame = Instance.new("Frame", ContentArea)
    Frame.Size = UDim2.new(0.95, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.6, 0, 0, 12)
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(190, 195, 210)
    Label.TextSize = 8
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    
    local ValLabel = Instance.new("TextLabel", Frame)
    ValLabel.Size = UDim2.new(0.4, 0, 0, 12)
    ValLabel.Position = UDim2.new(0.6, 0, 0, 0)
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = Color3.fromRGB(60, 110, 240)
    ValLabel.TextSize = 8
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.BackgroundTransparency = 1
    
    local Bar = Instance.new("Frame", Frame)
    Bar.Size = UDim2.new(1, 0, 0, 4)
    Bar.Position = UDim2.new(0, 0, 0, 18)
    Bar.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(60, 110, 240)
    
    local Drag = Instance.new("TextButton", Bar)
    Drag.Size = UDim2.new(1, 0, 1, 0)
    Drag.BackgroundTransparency = 1
    Drag.Text = ""
    
    local function Update(input)
        local pct = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        local val = math.round(min + (pct * (max - min)))
        ValLabel.Text = tostring(val)
        callback(val)
    end
    
    local drag = false
    Drag.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true Update(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            Update(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

-- 4. ติดตั้งปุ่มควบคุมทั้งหมดลงบนหน้าจอเมนู
CreateSlider("Speed (ความเร็วตัวละคร)", 16, 150, 16, function(v) States.SpeedValue = v end)
CreateSlider("Jump Power (แรงกระโดด)", 50, 180, 50, function(v) States.JumpPowerValue = v end)

CreateToggle("Noclip (เดินทะลุกำแพง)", false, function(s) States.NoclipActive = s end)
CreateToggle("Spoof Stats (เสกเงิน & ค่าจำลอง)", false, function(s)
    States.SpoofStatsActive = s
    if s then
        pcall(function() firesignal(StatsEvent.OnClientEvent, "Stats", {}, "PatientsCheckedIn", nil) end)
    end
end)
CreateToggle("Auto Treat Animals (รักษาออโต้)", false, function(s) States.AutoTreatActive = s end)
CreateToggle("Auto Stamp Form (ปั๊มตรากระดาษ)", false, function(s) States.AutoStampActive = s end)
CreateToggle("Block Popups (บล็อกแจ้งเตือน)", false, function(s) ToggleNotifications(s) end)

-- ปุ่มย่อส่วน (FOX) วงกลมมุมบนซ้ายมือ
local MinBtn = Instance.new("TextButton", ScreenGui)
MinBtn.Size = UDim2.new(0, 44, 0, 44)
MinBtn.Position = UDim2.new(0, 10, 0, 10)
MinBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
MinBtn.Text = "FOX"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 10

local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(1, 0)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 5. ลูปการทำงานหลังบ้านร่วมกับส่วนที่ 1
RunService.Heartbeat:Connect(function()
    local Char = LocalPlayer.Character
    if Char then
        local Root = Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum and Root and Hum.MoveDirection.Magnitude > 0 and States.SpeedValue > 16 then
            local vel = Hum.MoveDirection * (States.SpeedValue - 16)
            Root.AssemblyLinearVelocity = Vector3.new(vel.X, Root.AssemblyLinearVelocity.Y, vel.Z)
        end
        if States.NoclipActive then
            for _, p in ipairs(Char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.4) do
        AutoTasks()
    end
end)

print("[Part 2]: หน้าต่างเมนูปุ่มสมบูรณ์พร้อมใช้งานแล้ว!")

