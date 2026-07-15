--[[
    ====================================================================
    [!] FOXNAME HUB v6 - MAIN LOADER
    [!] วิธีใช้งาน: นำโค้ดนี้ไปรันใน Executor 
    [!] หมายเหตุ: อย่าลืมเปลี่ยนลิงก์ URL ด้านล่างให้เป็นลิงก์ RAW GitHub ของคุณเองนะครับ
    ====================================================================
--]]

-- ประกาศสเตตัสเริ่มต้นเพื่อให้สคริปต์ย่อยดึงไปใช้งานร่วมกันได้
getgenv().InfiniteStaminaActive = true

getgenv().States = {
    CurrentTab = "User",
    SpeedValue = 16,
    JumpPowerValue = 50,
    NoclipActive = false,
    UnlockThirdPerson = false,
    AutoTreatActive = false,
    AutoStampActive = false,
    AutoObjectiveActive = false,
    EspActive = false,
    BlockNotifications = false,
    LogNotifications = false,
    SpoofStatsActive = false
}

-- ฟังก์ชันดึงและดาวน์โหลดสคริปต์ย่อยมาทำงาน
local function SafeLoad(url, sectionName)
    local success, scriptContent = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and scriptContent then
        local runFunction, err = loadstring(scriptContent)
        if runFunction then
            task.spawn(runFunction)
            print("[SUCCESS]: โหลดส่วน " .. sectionName .. " สำเร็จแล้ว!")
        else
            warn("[ERROR]: ไม่สามารถประกอบคอมไพล์โค้ดส่วน " .. sectionName .. " ได้: " .. tostring(err))
        end
    else
        warn("[ERROR]: ไม่สามารถเชื่อมต่อเพื่อดึงสคริปต์ส่วน " .. sectionName .. " จากเซิร์ฟเวอร์ได้")
    end
end

-- [[ ส่วนสำหรับเปลี่ยนลิงก์ GitHub RAW ของคุณ ]]
-- สมมติว่าคุณอัปโหลดไฟล์ core.lua และ ui.lua ไว้ใน Repository เดียวกัน
local GITHUB_USERNAME = "ชื่อของคุณ"
local REPO_NAME = "ชื่อโปรเจกต์"
local BRANCH = "main"

local CORE_URL = "https://raw.githubusercontent.com/"..GITHUB_USERNAME.."/"..REPO_NAME.."/"..BRANCH.."/core.lua"
local UI_URL = "https://raw.githubusercontent.com/"..GITHUB_USERNAME.."/"..REPO_NAME.."/"..BRANCH.."/ui.lua"

-- ทำการเรียกใช้งานส่วนประกอบทั้งหมดตามลำดับ
task.spawn(function()
    SafeLoad(CORE_URL, "Core Engine")
    task.wait(0.5) -- หน่วงเวลาเล็กน้อยเพื่อให้ตัวแกนหลักเซตค่าเสร็จก่อนโหลด UI
    SafeLoad(UI_URL, "User Interface & Automation")
end)

--[[
    ====================================================================
    [!] FOXNAME HUB v6 (NAVY GLASS) - PART 1: CORE ENGINE (FREE)
    [!] ฟังก์ชัน: บายพาสความเหนื่อยล้า, ปรับค่า Stamina/Sanity, ปลดล็อกสเตตัสจำลอง
    ====================================================================
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ตรวจสอบและดึงค่า States ส่วนกลาง
local States = getgenv().States or {}

-- ค้นหาโฟลเดอร์ระบบเครือข่ายส่งข้อมูลของเกม
local Net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net")
local PlayerLostSanity = Net:WaitForChild("RE/PlayerLostSanity")
local StatsEvent = Net:WaitForChild("RE/Stats")

-- ====================================================
-- [ CORE EXPLOIT BYPASSES (ระบบตัดแต่งการทำงานตัวละคร) ]
-- ====================================================

-- 1. บล็อกข้อมูลความเหนื่อยล้าไม่ให้ส่งกลับไปยังฝั่ง Server (Anti-Stamina Loss)
local hookSuccess, hookError = pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if self == PlayerLostSanity and (method == "FireServer" or method == "fireServer") then
                if getgenv().InfiniteStaminaActive then
                    return nil -- ปล่อยให้แพ็กเก็ตหายไป ไม่ให้เซิร์ฟเวอร์รู้ว่าเราเหนื่อย
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

-- 2. ลูปตรวจสอบล็อกหลอดในเครื่อง (ล็อกค่าเหนื่อยฝั่ง Client เป็นค่าสูงสุดตลอดเวลา)
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().InfiniteStaminaActive then
            pcall(function()
                local Character = LocalPlayer.Character
                local InfValue = math.huge -- กำหนดค่าเป็นอนันต์ (Infinity)
                
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

-- 3. ระบบ Spoof Stats - จำลองเงิน ข้อมูลอาชีพและระดับเลเวลแบบปลอดภัย
local statsConnection
pcall(function()
    statsConnection = StatsEvent.OnClientEvent:Connect(function(actionType, statsTable, updateField, extraData)
        if States.SpoofStatsActive and actionType == "Stats" and type(statsTable) == "table" then
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

print("[Core Engine]: ระบบทำงานหลักและจำลองสเตตัสทำงานเรียบร้อยแล้ว!")

--[[
    ====================================================================
    [!] FOXNAME HUB v6 (NAVY GLASS) - PART 2: UI & AUTOMATION
    [!] ฟังก์ชัน: หน้าต่างเมนู GUI, ระบบสแกนคนไข้ ESP, บอททำภารกิจออโต้ทั้งหมด
    ====================================================================
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ตรวจสอบและดึงค่าสเตตัสเริ่มต้น
local States = getgenv().States or {}

local Net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net")
local StatsEvent = Net:WaitForChild("RE/Stats")
local NotifyRemote = Net:WaitForChild("RE/Notify")
local SetObjectiveEvent = Net:WaitForChild("RE/SetObjective")

-- ====================================================
-- [ UTILITY FUNCTIONS (ระบบซ่อมแซมและช่วยเหลือการส่งสัญญาณ) ]
-- ====================================================

-- ฟังก์ชันจำลองสัญญาณเช็คอินภารกิจ (ปลอดภัยและรันได้จริงทุกรันเนอร์)
local function SafeFireSignal(eventSignal, ...)
    if not eventSignal then return end
    if getconnections then
        for _, connection in ipairs(getconnections(eventSignal)) do
            if firesignal then
                pcall(firesignal, connection, ...)
            elseif connection.Function then
                task.spawn(connection.Function, ...)
            end
        end
    end
end

-- ฟังก์ชันจำลองการกดแบบ Interactive ป้องกันเกมติดขัด
local function SafeInteract(prompt)
    if not prompt then return end
    pcall(function()
        if prompt:IsA("ProximityPrompt") then
            if fireproximityprompt then
                fireproximityprompt(prompt)
            else
                prompt:InputHoldBegin()
                task.wait(prompt.HoldDuration)
                prompt:InputHoldEnd()
            end
        elseif prompt:IsA("ClickDetector") then
            if fireclickdetector then
                fireclickdetector(prompt)
            end
        end
    end)
end

-- ====================================================
-- [ AUTOMATION SCRIPTS (ระบบช่วยฟาร์มออโต้ภายในแผนที่) ]
-- ====================================================

-- 1. บอทรักษาสัตว์อัตโนมัติ
local function AutoInteractWithAnimals()
    if not States.AutoTreatActive then return end
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parent = prompt.Parent
            if parent and (parent.Name:lower():find("patient") or parent.Name:lower():find("animal") or parent.Name:lower():find("treat")) then
                task.spawn(function() SafeInteract(prompt) end)
            end
        end
    end
end

-- 2. บอทปั๊มตราประทับอัตโนมัติ
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
                task.spawn(function() SafeInteract(prompt) end)
            end
        end
    end
end

-- 3. บอททำเควสเช็คอิน รูปถ่าย และวิเคราะห์ผลตรวจอัตโนมัติ
local function AutoCompleteObjectives()
    if not States.AutoObjectiveActive then return end
    pcall(function()
        local Misc = workspace:FindFirstChild("Misc")
        local CheckIn = Misc and Misc:FindFirstChild("CheckIn")
        local NPCs = workspace:FindFirstChild("NPCs")
        local Rooms = workspace:FindFirstChild("Rooms")
        
        local RevealPhotoEvent = ReplicatedStorage.Util.Net:FindFirstChild("RE/RevealPhoto")
        local PlayCutsceneEvent = ReplicatedStorage.Util.Net:FindFirstChild("RE/PlayCutscene")
        
        -- เควสขั้นตอนเช็คอินที่คอมพิวเตอร์และรูปถ่าย
        if CheckIn then
            if CheckIn:FindFirstChild("Computer") then SafeFireSignal(SetObjectiveEvent.OnClientEvent, "Register in PC", nil, CheckIn.Computer) end
            if CheckIn:FindFirstChild("Camera") then SafeFireSignal(SetObjectiveEvent.OnClientEvent, "Take a photo", nil, CheckIn.Camera) end
            if CheckIn:FindFirstChild("Printer") then SafeFireSignal(SetObjectiveEvent.OnClientEvent, "Print Badge", nil, CheckIn.Printer) end
        end
        
        -- เควสพาคนไข้เข้าห้องตรวจและตรวจเช็ก
        if NPCs then
            for _, patient in ipairs(NPCs:GetChildren()) do
                if patient:IsA("Model") or patient:IsA("BasePart") then
                    if PlayCutsceneEvent then
                        SafeFireSignal(PlayCutsceneEvent.OnClientEvent, "VisitorArrived", patient, true, nil)
                    end
                    if RevealPhotoEvent and CheckIn then
                        SafeFireSignal(RevealPhotoEvent.OnClientEvent, CheckIn, patient)
                    end
                    SafeFireSignal(SetObjectiveEvent.OnClientEvent, "Follow the patient to their room", nil, patient)
                    SafeFireSignal(SetObjectiveEvent.OnClientEvent, "Take sample from patient in Room 1", nil, patient)
                    SafeFireSignal(SetObjectiveEvent.OnClientEvent, "Take sample from patient in Room 2", nil, patient)
                    SafeFireSignal(SetObjectiveEvent.OnClientEvent, "Take sample from patient in Room 3", nil, patient)
                end
            end
        end

        -- เควสการสปูฟระบบวิเคราะห์ผลตรวจ
        if Rooms and Rooms:FindFirstChild("Medical") then
            for _, room in ipairs(Rooms.Medical:GetChildren()) do
                local Minigame = room:FindFirstChild("Minigame")
                local Analyzer = Minigame and Minigame:FindFirstChild("Analyzer")
                if Analyzer then
                    SafeFireSignal(SetObjectiveEvent.OnClientEvent, "Analyze the sample", nil, Analyzer)
                end
            end
        end
    end)
end

-- ====================================================
-- [ NOTIFICATION LOGGER & ESP SYSTEMS ]
-- ====================================================

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

local function RunEsp()
    if not States.EspActive then return end
    local NPCs = workspace:FindFirstChild("NPCs")
    if NPCs then
        for _, npc in ipairs(NPCs:GetChildren()) do
            if (npc:IsA("Model") or npc:IsA("BasePart")) and not npc:FindFirstChild("FoxEspHighlight") then
                local h = Instance.new("Highlight")
                h.Name = "FoxEspHighlight"
                h.Adornee = npc
                h.FillColor = Color3.fromRGB(0, 255, 255)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.OutlineTransparency = 0
                h.FillTransparency = 0.5
                h.Parent = npc
            end
        end
    end
end

-- ====================================================
-- [ GUI NAVY GLASS PANEL CREATION ]
-- ====================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FoxnameHospitalUI_v6_Split"
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

-- ====================================================
-- [ UI INTERACTIVE GENERATORS (ระบบเรนเดอร์สไลเดอร์และปุ่ม) ]
-- ====================================================

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

-- === ผูกคอมโพเนนต์เข้ากับหน้า USER CONTROLS ===
AddSlider(PageUser, "Speed (ปรับความเร็วตัวละคร)", 16, 150, 16, function(val) States.SpeedValue = val end)
AddSlider(PageUser, "Jump Power (ความสูงกระโดด)", 50, 200, 50, function(val) States.JumpPowerValue = val end)
AddToggle(PageUser, "Infinity Stamina & Sanity", getgenv().InfiniteStaminaActive, function(state) getgenv().InfiniteStaminaActive = state end)
AddToggle(PageUser, "Noclip (เดินทะลุกำแพง)", false, function(state) States.NoclipActive = state end)
AddToggle(PageUser, "Unlock Third Person (ซูมมุมมองไกล)", false, function(state) States.UnlockThirdPerson = state LocalPlayer.CameraMaxZoomDistance = state and 500 or 30 end)
AddToggle(PageUser, "Spoof Stats (จำลองเงิน & สถิติ)", false, function(state) States.SpoofStatsActive = state if state then pcall(function() SafeFireSignal(StatsEvent.OnClientEvent, "Stats", {}, "PatientsCheckedIn", nil) end) end end)

-- === ผูกคอมโพเนนต์เข้ากับหน้า AUTO CONTROLS ===
AddToggle(PageAuto, "NPC Scanner (ESP สแกนคนไข้)", false, function(state) States.EspActive = state if not state then ClearEsp() end end)
AddToggle(PageAuto, "Auto Complete Objectives (ฟาร์มเควสออโต้)", false, function(state) States.AutoObjectiveActive = state end)
AddToggle(PageAuto, "Auto Treat Animals (รักษาสัตว์ออโต้)", false, function(state) States.AutoTreatActive = state end)
AddToggle(PageAuto, "Auto Stamp Form (ปั๊มตรากระดาษม่วง)", false, function(state) States.AutoStampActive = state end)
AddToggle(PageAuto, "Block Game Popups (บล็อกแจ้งเตือนเกม)", false, function(state) ToggleGameNotifications(state) end)
AddToggle(PageAuto, "Log Notifications to F9 Console", false, function(state) States.LogNotifications = state end)

-- ====================================================
-- [ SYSTEM LOOPS & RUNTIME INITIALIZATION ]
-- ====================================================

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

-- ปุ่มย่อและเปิดหน้าต่างเมนู
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

print("[UI System]: โหลดเมนูหลัก Navy Glass GUI และระบบประมวลผลลูปฟาร์มออโต้สำเร็จ!")
