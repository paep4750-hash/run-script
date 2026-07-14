--[[
    ====================================================================
    [!] PREMIUM FOXNAME HUB - ANIMAL HOSPITAL (STAMINA BYPASS UPDATE)
    [!] DESIGN: Dark Navy Glassmorphism (Glassmorphic Glow, UIStroke Borders)
    [!] FE BYPASS: Multi-Method Metatable Hook for "RE/PlayerLostSanity"
    ====================================================================
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- [ CONFIGURATION & STATE MANAGEMENT ]
local States = {
    CurrentTab = "User",
    
    -- LocalPlayer Settings
    SpeedValue = 16,
    JumpPowerValue = 50,
    InfiniteStamina = false, -- บล็อก RE/PlayerLostSanity เพื่อไม่ให้ Stamina & Sanity ลด
    NoclipActive = false,
    UnlockThirdPerson = false,
    
    -- Auto Farming
    AutoTreatActive = false,
    AutoStampActive = false,
    
    -- Notification Controller
    BlockNotifications = false,
    LogNotifications = false
}

-- [ NETWORK REMOTES ]
local Net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net")
local PlayerLostSanity = Net:WaitForChild("RE/PlayerLostSanity")
local NotifyRemote = Net:WaitForChild("RE/Notify")
local SetObjectiveRemote = Net:WaitForChild("RE/SetObjective")

-- ====================================================
-- [ ระบบ MULTI-METHOD HOOK: บล็อกสัญญาณ STAMINA/SANITY ลด ]
-- ====================================================
-- ระบบดักฟังและสกัดกั้นระดับเอนจิ้น เพื่อหยุดการทำงานของ RE/PlayerLostSanity โดยสมบูรณ์
local hookSuccess, hookError = pcall(function()
    -- วิธีที่ 1: hookmetamethod (เสถียรที่สุดใน Executor ปัจจุบัน ป้องกันการหลุดและตรวจสอบยาก)
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            
            if States.InfiniteStamina and self == PlayerLostSanity and (method == "FireServer" or method == "fireServer") then
                return nil -- บล็อกแพ็กเก็ตโยนทิ้งทันที Stamina และ Sanity จะไม่ลดลงเลย
            end
            
            return oldNamecall(self, ...)
        end)
        print("[Foxname Loader]: บล็อกระบบผ่าน hookmetamethod สำเร็จ!")
        
    -- วิธีที่ 2: Standard getrawmetatable hook (ระบบสำรองสำหรับ Executor ทั่วไป)
    elseif getrawmetatable then
        local RawMeta = getrawmetatable(game)
        local OldNamecall = RawMeta.__namecall
        setreadonly(RawMeta, false)
        
        RawMeta.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            
            if States.InfiniteStamina and self == PlayerLostSanity and (method == "FireServer" or method == "fireServer") then
                return nil
            end
            
            return OldNamecall(self, ...)
        end)
        setreadonly(RawMeta, true)
        print("[Foxname Loader]: บล็อกระบบผ่าน getrawmetatable สำเร็จ!")
    else
        warn("[!] Executor ของคุณไม่สนับสนุนการทำ Metatable Hooking")
    end
end)

-- ====================================================
-- [ ฟังก์ชันระบบจัดการแจ้งเตือน (RE/Notify Interceptor) ]
-- ====================================================
local notifyConnection = nil
pcall(function()
    notifyConnection = NotifyRemote.OnClientEvent:Connect(function(...)
        local args = {...}
        if States.LogNotifications then
            local msg = tostring(args[1] or "ไม่มีข้อความ")
            print("[Foxname Logger - Server Notify]: " .. msg)
        end
    end)
end)

local function ToggleGameNotifications(block)
    States.BlockNotifications = block
    if getconnections then
        for _, connection in ipairs(getconnections(NotifyRemote.OnClientEvent)) do
            if connection.Function ~= notifyConnection then
                if block then
                    connection:Disable()
                else
                    connection:Enable()
                end
            end
        end
    end
end

-- ====================================================
-- [ ฟังก์ชันการทำงานของฟาร์มอัตโนมัติ ]
-- ====================================================

-- 1. ระบบ Auto Treatment (รักษาสัตว์เลี้ยงอัตโนมัติ)
local function AutoInteractWithAnimals()
    if not States.AutoTreatActive then return end
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parent = prompt.Parent
            if parent and (parent.Name:lower():find("patient") or parent.Name:lower():find("animal") or parent.Name:lower():find("treat") or parent.Name:lower():find("pet")) then
                task.spawn(function()
                    fireproximityprompt(prompt)
                end)
            end
        end
    end
end

-- 2. ระบบ Auto Stamp Form (ประทับตราแบบฟอร์มสแตมป์สีม่วง)
local function AutoStampForm()
    if not States.AutoStampActive then return end
    local FormObj = workspace:FindFirstChild("Misc", true)
    if FormObj then
        local CheckIn = FormObj:FindFirstChild("CheckIn")
        local Form = CheckIn and CheckIn:FindFirstChild("Form")
        local TargetForm = Form or workspace:FindFirstChild("Form", true)
        
        if TargetForm then
            local prompt = TargetForm:FindFirstChildOfClass("ProximityPrompt") or TargetForm:FindFirstChildOfClass("ClickDetector") or TargetForm.Parent:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                elseif prompt:IsA("ClickDetector") then
                    fireclickdetector(prompt)
                end
            end
        end
    end
end

-- ====================================================
-- [ การสร้างเมนู UI สไตล์ FOXNAME HUB (Navy Glass) ]
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FoxnameAnimalHospital_v5_" .. tostring(math.random(1000, 9999))
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- หน้าต่างหลัก (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 660, 0, 400)
MainFrame.Position = UDim2.new(0.5, -330, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- เส้นขอบเรืองแสงบางๆ (UIStroke)
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(45, 52, 75)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- แถบ Sidebar ด้านซ้าย
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

local CoverFrame = Instance.new("Frame")
CoverFrame.Size = UDim2.new(0, 15, 1, 0)
CoverFrame.Position = UDim2.new(1, -15, 0, 0)
CoverFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
CoverFrame.BackgroundTransparency = 0.2
CoverFrame.BorderSizePixel = 0
CoverFrame.Parent = Sidebar

-- หัวข้อโลโก้สคริปต์
local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(1, 0, 0, 45)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "  Foxname Hub"
LogoLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.TextSize = 13
LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
LogoLabel.Parent = Sidebar

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(1, 0, 0, 15)
LogoSub.Position = UDim2.new(0, 10, 0, 32)
LogoSub.BackgroundTransparency = 1
LogoSub.Text = "Hospital Simulator"
LogoSub.TextColor3 = Color3.fromRGB(110, 115, 135)
LogoSub.Font = Enum.Font.GothamSemibold
LogoSub.TextSize = 9
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Parent = Sidebar

-- แถบเมนูแท็บสลับหน้าจอ (Tab Scroller)
local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(1, -10, 1, -75)
TabContainer.Position = UDim2.new(0, 5, 0, 65)
TabContainer.BackgroundTransparency = 1
TabContainer.CanvasSize = UDim2.new(0, 0, 0, 300)
TabContainer.ScrollBarThickness = 0
TabContainer.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = TabContainer

-- หน้าแสดงผลลัพธ์ข้อมูลด้านขวา
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -195, 1, -20)
ContentArea.Position = UDim2.new(0, 185, 0, 10)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Pages = {}

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.CanvasSize = UDim2.new(0, 0, 0, 450)
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(45, 52, 75)
    Page.Visible = false
    Page.Parent = ContentArea
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 12)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.Parent = Page
    
    Pages[name] = Page
    return Page
end

local PageAuto = CreatePage("Auto")
local PageUser = CreatePage("User")
local PageCredit = CreatePage("Credit")

-- สลับหน้าต่างแบบสมูท
local CurrentActiveBtn = nil

local function SwitchTab(tabName, button)
    for name, page in pairs(Pages) do
        page.Visible = (name == tabName)
    end
    
    if CurrentActiveBtn then
        TweenService:Create(CurrentActiveBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(15, 17, 26),
            TextColor3 = Color3.fromRGB(130, 135, 150)
        }):Play()
    end
    
    CurrentActiveBtn = button
    TweenService:Create(button, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(28, 32, 48),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    States.CurrentTab = tabName
end

local function AddTabButton(label, tabName, emoji)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.95, 0, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
    Btn.Text = "  " .. emoji .. "   " .. label
    Btn.TextColor3 = Color3.fromRGB(130, 135, 150)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 10
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.AutoButtonColor = false
    Btn.Parent = TabContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        SwitchTab(tabName, Btn)
    end)
    return Btn
end

-- สร้างปุ่มสลับหน้าเมนูหลัก
local DefaultBtn = AddTabButton("Local Player", "User", "👤")
AddTabButton("Auto Hospital", "Auto", "🏥")
AddTabButton("About & Info", "Credit", "ℹ️")

SwitchTab("User", DefaultBtn)

-- ====================================================
-- [ ระบบเครื่องมือ UI Elements (Section, Toggle, Slider) ]
-- ====================================================

local function CreateSection(parent, titleText)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(0.95, 0, 0, 40)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
    SectionFrame.BackgroundTransparency = 0.2
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Parent = parent
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 8)
    SectionCorner.Parent = SectionFrame
    
    local SectionStroke = Instance.new("UIStroke")
    SectionStroke.Thickness = 1
    SectionStroke.Color = Color3.fromRGB(35, 40, 58)
    SectionStroke.Parent = SectionFrame
    
    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Size = UDim2.new(1, -20, 0, 32)
    HeaderLabel.Position = UDim2.new(0, 12, 0, 0)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Text = titleText
    HeaderLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    HeaderLabel.Font = Enum.Font.GothamBold
    HeaderLabel.TextSize = 10
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Parent = SectionFrame
    
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "Holder"
    ContentHolder.Size = UDim2.new(1, 0, 1, -32)
    ContentHolder.Position = UDim2.new(0, 0, 0, 32)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = SectionFrame
    
    local HolderLayout = Instance.new("UIListLayout")
    HolderLayout.Padding = UDim.new(0, 8)
    HolderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    HolderLayout.Parent = ContentHolder
    
    HolderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SectionFrame.Size = UDim2.new(0.95, 0, 0, HolderLayout.AbsoluteContentSize.Y + 42)
    end)
    
    return ContentHolder
end

local function CreateToggle(parent, title, desc, defaultValue, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0.95, 0, 0, 42)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.7, 0, 0, 22)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.TextSize = 10
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = ToggleFrame
    
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(0.7, 0, 0, 15)
    DescLabel.Position = UDim2.new(0, 0, 0, 20)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = desc
    DescLabel.TextColor3 = Color3.fromRGB(120, 125, 140)
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextSize = 8
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Parent = ToggleFrame
    
    local SwitchBtn = Instance.new("TextButton")
    SwitchBtn.Size = UDim2.new(0, 38, 0, 18)
    SwitchBtn.Position = UDim2.new(1, -42, 0.5, -9)
    SwitchBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(80, 110, 250) or Color3.fromRGB(40, 45, 60)
    SwitchBtn.Text = ""
    SwitchBtn.AutoButtonColor = false
    SwitchBtn.Parent = ToggleFrame
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchBtn
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = defaultValue and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = SwitchBtn
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    local state = defaultValue
    SwitchBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local targetColor = state and Color3.fromRGB(80, 110, 250) or Color3.fromRGB(40, 45, 60)
        
        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        TweenService:Create(SwitchBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        callback(state)
    end)
end

local function CreateSlider(parent, title, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.95, 0, 0, 45)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.7, 0, 0, 18)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(190, 195, 210)
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.TextSize = 10
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.25, 0, 0, 18)
    ValueLabel.Position = UDim2.new(0.75, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(80, 110, 250)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 10
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 4)
    SliderBar.Position = UDim2.new(0, 0, 0, 28)
    SliderBar.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.Parent = SliderBar
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(80, 110, 250)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBar
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.Parent = Fill
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 10, 0, 10)
    Knob.Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = SliderBar
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    local Trigger = Instance.new("TextButton")
    Trigger.Size = UDim2.new(1, 0, 1, 0)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""
    Trigger.Parent = SliderBar
    
    local function UpdateSlider(input)
        local inputX = input.Position.X
        local barX = SliderBar.AbsolutePosition.X
        local barWidth = SliderBar.AbsoluteSize.X
        local percentage = math.clamp((inputX - barX) / barWidth, 0, 1)
        
        Fill.Size = UDim2.new(percentage, 0, 1, 0)
        Knob.Position = UDim2.new(percentage, -5, 0.5, -5)
        
        local val = math.round(min + (percentage * (max - min)))
        ValueLabel.Text = tostring(val)
        callback(val)
    end
    
    local dragging = false
    Trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
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

-- --- PAGE 1: USER CONTROLS ---
local UserSec = CreateSection(PageUser, "LocalPlayer (ฟังก์ชันผู้เล่น)")

CreateSlider(UserSec, "Speed (ปรับความเร็ว)", 16, 150, 16, function(val)
    States.SpeedValue = val
end)

CreateSlider(UserSec, "Speed (ปรับความเร็ว)", 16, 150, 16, function(val)
    States.SpeedValue = val
end)

CreateSlider(UserSec, "JumpPower (พลังกระโดด)", 50, 200, 50, function(val)
    States.JumpPowerValue = val
end)

CreateToggle(UserSec, "Noclip (เดินทะลุกำแพง)", "ทำให้ตัวละครสามารถเดินทะลุกำแพงสิ่งกีดขวางได้", false, function(state)
    States.NoclipActive = state
end)

CreateToggle(UserSec, "Unlock Third Person", "ขยายพิกัดระยะการซูมออกของมุมมองบุคคลที่สาม", false, function(state)
    States.UnlockThirdPerson = state
    if state then
        LocalPlayer.CameraMaxZoomDistance = 500
    else
        LocalPlayer.CameraMaxZoomDistance = 30
    end
end)

-- หมวดหมู่สมองและพลังการทำงาน (Sanity & Stamina Block)
local StaminaSec = CreateSection(PageUser, "Bypass Engine (ระบบสมองและค่าความเหนื่อยล้า)")

-- ฟังก์ชันดักจับและบล็อก RE/PlayerLostSanity โดยตรงเพื่อไม่ให้ Stamina & Sanity ลด!
CreateToggle(StaminaSec, "Infinite Stamina & Sanity (ล็อกค่าสมองและพละกำลัง)", "สั่งบล็อกรีโมท RE/PlayerLostSanity เพื่อป้องกันการลดพละกำลังและสตามิน่าจากเกม", false, function(state)
    States.InfiniteStamina = state
    
    local notifyText = state and "เปิดระบบล็อกพละกำลังและสมอง 100% สำเร็จ!" or "ยกเลิกการบล็อกสัญญาณ"
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Foxname Hub",
        Text = notifyText,
        Duration = 3
    })
end)

-- --- PAGE 2: AUTO HOSPITAL ---
local AutoHospitalSec = CreateSection(PageAuto, "ระบบช่วยฟาร์มและบริการทำเควสต์อัตโนมัติ")

CreateToggle(AutoHospitalSec, "Auto Treatment (รักษาและทำความสะอาดสัตว์ออโต้)", "ตรวจจับสัตว์เลี้ยงเป้าหมายที่อยู่รอบตัวคุณแล้วกดรักษากดชำระล้างอัตโนมัติ", false, function(state)
    States.AutoTreatActive = state
end)

CreateToggle(AutoHospitalSec, "Auto Stamp Form (สแตมป์แบบฟอร์มอัตโนมัติ)", "ตรวจหาแบบฟอร์มกระดาษสีม่วงที่เคาน์เตอร์แล้วสแตมป์ประทับตราอัตโนมัติ", false, function(state)
    States.AutoStampActive = state
end)

-- ระบบตัดการแจ้งเตือนป๊อปอัพหน้าจอดังเดิมจากรีโมท RE/Notify
local NotifySec = CreateSection(PageAuto, "ระบบดักจับแจ้งเตือนป๊อปอัพเกม (RE/Notify)")

CreateToggle(NotifySec, "Block Game Popups (บล็อกแจ้งเตือนเด้งกวนหน้าจอ)", "ปิดป๊อปอัพแจ้งเตือนของตัวเกมทั้งหมด เพื่อไม่ให้สแปมรกหน้าจอขณะฟาร์ม", false, function(state)
    ToggleGameNotifications(state)
end)

CreateToggle(NotifySec, "Log Notifications to F9 Console", "ดักฟังข้อความแล้วนำมาบันทึกเป็นประวัติเก็บไว้ใน Console แทนการเด้งขึ้นจอ", false, function(state)
    States.LogNotifications = state
end)

-- --- PAGE 3: CREDIT ---
local CreditSec = CreateSection(PageCredit, "ข้อมูลผู้พัฒนาและการถอดรหัส")

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.95, 0, 0, 120)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "🎨 หน้าต่างเมนู Foxname Hub สวยงามแบบ Navy Glass\n⚡ ถอดระบบการทำงานของ RE/PlayerLostSanity เพื่อบล็อก Stamina/Sanity ลด\n\nเปิดใช้งานได้อย่างปลอดภัยและรันได้อย่างเสถียร!"
InfoLabel.TextColor3 = Color3.fromRGB(170, 175, 190)
InfoLabel.Font = Enum.Font.GothamSemibold
InfoLabel.TextSize = 10
InfoLabel.Parent = CreditSec

-- ====================================================
-- [ ลูปเบื้องหลัง (Background Runtime Engine) ]
-- ====================================================

-- 1. ลูปตรวจสอบ Attributes และทิศทางความเร็วแบบเรียลไทม์
RunService.Heartbeat:Connect(function()
    local Character = LocalPlayer.Character
    if Character then
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        
        -- บาลานซ์ความเร็วด้วยแรงเฉื่อย (AssemblyLinearVelocity Bypass)
        if Humanoid and RootPart and Humanoid.MoveDirection.Magnitude > 0 and States.SpeedValue > 16 then
            local vel = Humanoid.MoveDirection * (States.SpeedValue - 16)
            RootPart.AssemblyLinearVelocity = Vector3.new(vel.X, RootPart.AssemblyLinearVelocity.Y, vel.Z)
        end
        
        -- ปรับปรุงพละกำลังการกระโดด
        if Humanoid and States.JumpPowerValue > 50 then
            Humanoid.JumpPower = States.JumpPowerValue
        end
        
        -- รันระบบ CanCollide เคลื่อนที่ทะลุกำแพง
        if States.NoclipActive then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- 2. สั่งรันลูปออโต้ฟาร์มภารกิจรอบข้างเป็นระยะ
task.spawn(function()
    while true do
        task.wait(0.2)
        if States.AutoTreatActive then
            AutoInteractWithAnimals()
        end
        if States.AutoStampActive then
            AutoStampForm()
        end
    end
end)

-- ====================================================
-- [ ปุ่มย่อ/ขยายหน้าต่างเมนูกลมสีดำลอยได้ ]
-- ====================================================
local CloseOpenButton = Instance.new("TextButton")
CloseOpenButton.Size = UDim2.new(0, 45, 0, 45)
CloseOpenButton.Position = UDim2.new(0.05, 0, 0.15, 0)
CloseOpenButton.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
CloseOpenButton.Text = "FOX"
CloseOpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseOpenButton.Font = Enum.Font.GothamBold
CloseOpenButton.TextSize = 10
CloseOpenButton.Parent = ScreenGui

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseOpenButton

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Thickness = 1
CloseStroke.Color = Color3.fromRGB(50, 55, 75)
CloseStroke.Parent = CloseOpenButton

CloseOpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
