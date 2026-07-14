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
-- FOXNAME HUB v6: PART 2 (UI & AUTOMATION)
-- ====================================================

local States = getgenv().States
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Net = game:GetService("ReplicatedStorage").Util.Net
local NotifyRemote = Net:WaitForChild("RE/Notify")

-- ฟังก์ชันดัก Notification
local notifyConnection = nil
local function ToggleNotifications(block)
    States.BlockNotifications = block
    if getconnections then
        for _, connection in ipairs(getconnections(NotifyRemote.OnClientEvent)) do
            if block then connection:Disable() else connection:Enable() end
        end
    end
end

-- ฟังก์ชันฟาร์มออโต้
local function AutoTasks()
    if States.AutoTreatActive then
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local p = prompt.Parent
                if p and (p.Name:lower():find("patient") or p.Name:lower():find("animal")) then
                    fireproximityprompt(prompt)
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

-- สร้าง UI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
MainFrame.Active = true
MainFrame.Draggable = true

-- สร้างปุ่มเปิด/ปิด (ย่อส่วน)
local MinBtn = Instance.new("TextButton", ScreenGui)
MinBtn.Size = UDim2.new(0, 50, 0, 50)
MinBtn.Text = "FOX"
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- ลูปการทำงาน (Noclip / Speed / AutoFarm)
RunService.Heartbeat:Connect(function()
    local Char = LocalPlayer.Character
    if Char then
        local Root = Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if Hum then
            if States.JumpPowerValue > 50 then Hum.JumpPower = States.JumpPowerValue end
            if States.NoclipActive then
                for _, p in ipairs(Char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        AutoTasks()
    end
end)

-- (เพิ่มส่วนการสร้างปุ่ม Toggle/Slider ตรงนี้ได้เหมือนเดิมครับ ถ้าต้องการให้เมนูสวยๆ)
print("[Part 2]: หน้าจอเมนูและระบบออโต้รันสำเร็จแล้ว!")
