-- ====================================================
-- FOXNAME HUB v6 (NAVY GLASS) - PART 1: CORE ENGINE (TRUE INF)
-- ====================================================

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
    SpoofStatsActive = false
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net")
local PlayerLostSanity = Net:WaitForChild("RE/PlayerLostSanity")
local StatsEvent = Net:WaitForChild("RE/Stats")

-- 1. บล็อกข้อมูลความเหนื่อยล้าฝั่ง Server
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

-- 2. ลูปตรวจสอบล็อกหลอดในเครื่อง (ปรับเป็น math.huge หรือ Infinity ของจริง)
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().InfiniteStaminaActive then
            pcall(function()
                local Character = LocalPlayer.Character
                -- ใช้ math.huge เพื่อให้ค่ากลายเป็น Infinity จริงๆ ในระบบ
                local InfValue = math.huge 
                
                if Character then
                    if Character:GetAttribute("Stamina") then Character:SetAttribute("Stamina", InfValue) end
                    if Character:GetAttribute("Sanity") then Character:SetAttribute("Sanity", InfValue) end
                    if LocalPlayer:GetAttribute("Stamina") then LocalPlayer:SetAttribute("Stamina", InfValue) end
                    if LocalPlayer:GetAttribute("Sanity") then LocalPlayer:SetAttribute("Sanity", InfValue) end
                end
            end)
        end
    end
end)

-- 3. ระบบ Spoof Stats - ค่าเงิน Cash = 999
local statsConnection
pcall(function()
    statsConnection = StatsEvent.OnClientEvent:Connect(function(actionType, statsTable, updateField, extraData)
        if getgenv().States.SpoofStatsActive and actionType == "Stats" and type(statsTable) == "table" then
            statsTable.Cash = 999
            statsTable.LocalCash = 0
            statsTable.PatientsCheckedIn = 999
            statsTable.PatientsTreated = 999
            statsTable.HighestShift = 99
            statsTable.GamesStarted = 99
            statsTable.Class = "Nurse"
            
            statsTable.ClassXP = { Nurse = 9999, Intern = 9999 }
            statsTable.UnlockedClasses = { Nurse = true, Intern = true, Doctor = true }
            statsTable.Settings = statsTable.Settings or { EpilepsyMode = false }
            statsTable.UnlockedSkins = statsTable.UnlockedSkins or {}
            statsTable.EquippedSkins = statsTable.EquippedSkins or {}
        end
    end)
end)

print("[Part 1]: อัปเดตระบบล็อกหลอดสมอง/พลังงานเป็น Infinity (math.huge) เรียบร้อยแล้ว!")

-- ====================================================
-- FOXNAME HUB v6 (NAVY GLASS) - PART 2: UI & ESP SCANNER
-- ====================================================

local States = getgenv().States or {
    CurrentTab = "User",
    SpeedValue = 16,
    JumpPowerValue = 50,
    NoclipActive = false,
    UnlockThirdPerson = false,
    AutoTreatActive = false,
    AutoStampActive = false,
    AutoObjectiveActive = false,
    EspActive = false, -- 🆕 เพิ่มสถานะ ESP
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
local SetObjectiveEvent = Net:WaitForChild("RE/SetObjective")

-- [ ฟังก์ชันทำความสะอาด ESP ]
local function ClearEsp()
    local NPCs = workspace:FindFirstChild("NPCs")
    if NPCs then
        for _, npc in ipairs(NPCs:GetChildren()) do
            if npc:FindFirstChild("FoxEspHighlight") then
                npc.FoxEspHighlight:Destroy()
            end
        end
    end
end

-- [ ระบบ ESP สแกน NPC ]
local function RunEsp()
    if not States.EspActive then return end
    local NPCs = workspace:FindFirstChild("NPCs")
    if NPCs then
        for _, npc in ipairs(NPCs:GetChildren()) do
            if (npc:IsA("Model") or npc:IsA("BasePart")) and not npc:FindFirstChild("FoxEspHighlight") then
                local h = Instance.new("Highlight")
                h.Name = "FoxEspHighlight"
                h.Adornee = npc
                h.FillColor = Color3.fromRGB(0, 255, 255) -- สีฟ้าเรืองแสง
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.OutlineTransparency = 0
                h.FillTransparency = 0.5
                h.Parent = npc
            end
        end
    end
end

-- [ ระบบบอททำงานอัตโนมัติเดิม ]
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

local function AutoCompleteObjectives()
    if not States.AutoObjectiveActive then return end
    pcall(function()
        local Misc = workspace:FindFirstChild("Misc")
        local CheckIn = Misc and Misc:FindFirstChild("CheckIn")
        local NPCs = workspace:FindFirstChild("NPCs")
        if CheckIn then
            if CheckIn:FindFirstChild("Computer") then firesignal(SetObjectiveEvent.OnClientEvent, "Register in PC", nil, CheckIn.Computer) end
            if CheckIn:FindFirstChild("Camera") then firesignal(SetObjectiveEvent.OnClientEvent, "Take a photo", nil, CheckIn.Camera) end
            if CheckIn:FindFirstChild("Printer") then firesignal(SetObjectiveEvent.OnClientEvent, "Print Badge", nil, CheckIn.Printer) end
        end
        if NPCs then
            for _, patient in ipairs(NPCs:GetChildren()) do
                firesignal(SetObjectiveEvent.OnClientEvent, "Follow the patient to their room", nil, patient)
                firesignal(SetObjectiveEvent.OnClientEvent, "Take sample from patient in Room 1", nil, patient)
                firesignal(SetObjectiveEvent.OnClientEvent, "Take sample from patient in Room 2", nil, patient)
            end
        end
    end)
end

-- [ สร้าง UI ] (ตัดโค้ด UI ช่วงสร้างตารางมาใส่เพื่อให้เหมือนเดิม)
-- (ส่วนนี้คือ UI เดิมที่คุณใช้ เพียงแค่เพิ่มปุ่ม ESP เข้าไป)
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

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(1, 0, 0, 45)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "  Foxname Hub v6"
LogoLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.TextSize = 12
LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
LogoLabel.Parent = Sidebar

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

local function SwitchTab(tabName) for name, page in pairs(Pages) do page.Visible = (name == tabName) end end
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
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = Btn
    Btn.MouseButton1Click:Connect(function() SwitchTab(pageName) end)
end

AddTabBtn("👤 Player Specs", "User")
AddTabBtn("🏥 Auto Hospital", "Auto")
SwitchTab("User")

local function AddToggle(parent, txt, default, callback)
    local Frame = Instance.new("Frame") Frame.Size = UDim2.new(0.95, 0, 0, 35) Frame.BackgroundTransparency = 1 Frame.Parent = parent
    local Label = Instance.new("TextLabel") Label.Size = UDim2.new(0.7, 0, 1, 0) Label.BackgroundTransparency = 1 Label.Text = txt Label.TextColor3 = Color3.fromRGB(220, 225, 240) Label.Font = Enum.Font.GothamSemibold Label.TextSize = 9 Label.TextXAlignment = Enum.TextXAlignment.Left Label.Parent = Frame
    local Btn = Instance.new("TextButton") Btn.Size = UDim2.new(0, 45, 0, 18) Btn.Position = UDim2.new(1, -50, 0.5, -9) Btn.BackgroundColor3 = default and Color3.fromRGB(80, 110, 250) or Color3.fromRGB(40, 45, 60) Btn.Text = default and "ON" or "OFF" Btn.TextColor3 = Color3.fromRGB(255, 255, 255) Btn.Font = Enum.Font.GothamBold Btn.TextSize = 8 Btn.Parent = Frame
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 4) Corner.Parent = Btn
    local active = default
    Btn.MouseButton1Click:Connect(function() active = not active Btn.Text = active and "ON" or "OFF" Btn.BackgroundColor3 = active and Color3.fromRGB(80, 110, 250) or Color3.fromRGB(40, 45, 60) callback(active) end)
end

-- [ เพิ่มปุ่ม ESP เข้าไปในหน้า Auto ]
AddToggle(PageAuto, "NPC Scanner (ESP)", false, function(state) 
    States.EspActive = state 
    if not state then ClearEsp() end
end)
AddToggle(PageAuto, "Auto Complete Objectives", false, function(state) States.AutoObjectiveActive = state end)
AddToggle(PageAuto, "Auto Treat Animals", false, function(state) States.AutoTreatActive = state end)
AddToggle(PageAuto, "Auto Stamp Form", false, function(state) States.AutoStampActive = state end)

-- [ ลูปทำงานเบื้องหลัง ]
RunService.Heartbeat:Connect(function()
    if States.EspActive then RunEsp() end
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        if States.AutoObjectiveActive then AutoCompleteObjectives() end
        if States.AutoTreatActive then AutoInteractWithAnimals() end
        if States.AutoStampActive then AutoStampForm() end
    end
end)
