-- ====================================================
-- FOXNAME HUB v6: ALL-IN-ONE (MENU + INFINITE SANITY)
-- ====================================================

-- [1] INITIALIZE CORE VARIABLES
getgenv().States = {
    SpeedValue = 16,
    JumpPowerValue = 50,
    NoclipActive = false,
    AutoTreatActive = false,
    AutoStampActive = false,
    SpoofStatsActive = false
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net")
local StatsEvent = Net:WaitForChild("RE/Stats")
local NotifyRemote = Net:WaitForChild("RE/Notify")
local PlayerLostSanity = Net:WaitForChild("RE/PlayerLostSanity")

-- [2] INFINITE SANITY / STRESS BYPASS (ตัวล็อกค่าความเครียด)
task.spawn(function()
    -- บายพาส Remote Event ที่ทำให้เสียสติ
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
    
    -- ลูปบังคับค่า Sanity ให้เต็มตลอด
    while task.wait(0.2) do
        pcall(function()
            local Char = LocalPlayer.Character
            if Char then
                if Char:GetAttribute("Sanity") then Char:SetAttribute("Sanity", 100) end
                if Char:GetAttribute("Stamina") then Char:SetAttribute("Stamina", 100) end
            end
        end)
    end
end)

-- [3] UI & AUTOMATION FUNCTIONS
local function AutoTasks()
    if getgenv().States.AutoTreatActive then
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local p = prompt.Parent
                if p and (p.Name:lower():find("patient") or p.Name:lower():find("animal")) then
                    task.spawn(function() fireproximityprompt(prompt) end)
                end
            end
        end
    end
    if getgenv().States.AutoStampActive then
        local form = workspace:FindFirstChild("Form", true) or workspace:FindFirstChild("CheckIn", true)
        if form then
            local prompt = form:FindFirstChildOfClass("ProximityPrompt")
            if prompt then fireproximityprompt(prompt) end
        end
    end
end

-- [4] CREATE UI (หน้าต่างเมนู)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 300)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -20, 1, -20)
ContentArea.Position = UDim2.new(0, 10, 0, 10)
ContentArea.BackgroundTransparency = 1
Instance.new("UIListLayout", ContentArea).Padding = UDim.new(0, 5)

-- ปุ่มปิด/เปิดเมนู
local MinBtn = Instance.new("TextButton", ScreenGui)
MinBtn.Size = UDim2.new(0, 50, 0, 50)
MinBtn.Position = UDim2.new(0, 10, 0, 10)
MinBtn.Text = "FOX"
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- ฟังก์ชันสร้างปุ่ม Toggle ง่ายๆ
local function AddButton(name, callback)
    local btn = Instance.new("TextButton", ContentArea)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(60, 110, 240) or Color3.fromRGB(40, 45, 60)
        callback(active)
    end)
end

-- [5] ADD OPTIONS
AddButton("Infinite Sanity (ล็อคค่าความเครียด) [ACTIVE]", function() end)
AddButton("Noclip (เดินทะลุกำแพง)", function(s) getgenv().States.NoclipActive = s end)
AddButton("Auto Treat (รักษาออโต้)", function(s) getgenv().States.AutoTreatActive = s end)
AddButton("Auto Stamp (ปั๊มตราฟอร์ม)", function(s) getgenv().States.AutoStampActive = s end)

-- [6] LOOP UPDATES
RunService.Heartbeat:Connect(function()
    local Char = LocalPlayer.Character
    if Char and getgenv().States.NoclipActive then
        for _, p in ipairs(Char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
end)

task.spawn(function()
    while task.wait(0.4) do AutoTasks() end
end)

print("FOXNAME HUB v6 โหลดครบทุกฟังก์ชันแล้ว!")

