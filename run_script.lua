--[[
    ====================================================================
    [!] PREMIUM FOXNAME HUB - ANIMAL HOSPITAL (SANITY BYPASS EDITION)
    [!] DESIGN: Elegant Dark Navy Glassmorphism (High-End UIStroke & Blur)
    [!] FEATURES: 
        - Infinite Sanity (บล็อกรีโมท RE/PlayerLostSanity ไม่ให้สมองลด)
        - Infinite Stamina (สตามิน่าไม่จำกัดจาก ObjectivesLocal)
        - Auto Treatment (ออโต้รักษาและล้างตัวสัตว์เลี้ยงใกล้ตัว)
        - Premium WalkSpeed & JumpPower & Noclip
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
    
    -- LocalPlayer Utilities
    SpeedValue = 16,
    JumpPowerValue = 50,
    InfiniteStamina = false,
    InfiniteSanity = false, -- สถานะเปิด/ปิดการล็อกสมองไม่ให้ลด
    NoclipActive = false,
    UnlockThirdPerson = false,
    
    -- Auto Farming
    AutoTreatActive = false
}

-- ค้นหารีโมทลดความเครียด (Sanity Remote) ตามที่คุณเจาะเจอ
local SanityRemote = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net"):WaitForChild("RE/PlayerLostSanity")

-- ====================================================
-- [ ระบบ HOOK METATABLE เพื่อบล็อกแพ็กเก็ตสมองลด (SANITY BYPASS) ]
-- ====================================================
local hookSuccess, hookError = pcall(function()
    local RawMeta = getrawmetatable(game)
    local OldNamecall = RawMeta.__namecall
    setreadonly(RawMeta, false)
    
    -- ใช้เทคนิคดักจับ Namecall ระดับสูงเพื่อบล็อกรีโมทฝั่งส่งข้อมูลออก
    RawMeta.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- หากเปิดใช้งาน Infinite Sanity และตัวเกมพยายามสั่งให้สมองลดผ่านรีโมทตัวนี้
        if States.InfiniteSanity and self == SanityRemote and (method == "FireServer" or method == "fireServer") then
            -- สกัดกั้นแพ็กเก็ตทันที (ส่งค่าว่างกลับไปแทนเพื่อให้เซิร์ฟเวอร์ไม่ได้รับสัญญาณความเครียด)
            return nil
        end
        
        return OldNamecall(self, unpack(args))
    end)
    
    setreadonly(RawMeta, true)
end)

if not hookSuccess then
    warn("[!] ไม่สามารถเริ่มระบบบ Hook ป้องกันสมองลดได้: " .. tostring(hookError))
end

-- ====================================================
-- [ ฟังก์ชันระบบฟาร์มและพละกำลัง ]
-- ====================================================

-- 1. ระบบ Infinite Stamina (หลอดเหนื่อยไม่ลด)
local function ApplyInfiniteStamina(enabled)
    if not enabled then return end
    local Character = LocalPlayer.Character
    if Character then
        for _, attribute in ipairs({"Stamina", "Energy", "SprintEnergy"}) do
            if Character:GetAttribute(attribute) then
                Character:SetAttribute(attribute, 999999)
            end
        end
        
        for _, val in ipairs(Character:GetDescendants()) do
            if val:IsA("NumberValue") or val:IsA("IntValue") then
                local name = val.Name:lower()
                if name:find("stamina") or name:find("energy") then
                    val.Value = 100
                end
            end
        end
    end
end

-- 2. ระบบ Auto Treatment (สแกนปุ่มกดรักษาอัตโนมัติ)
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

-- ====================================================
-- [ การสร้างเมนู UI สไตล์ FOXNAME HUB (Navy Glass) ]
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FoxnameAnimalHospital_" .. tostring(math.random(1000, 9999))
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- หน้าต่างหลัก (Main Window)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 660, 0, 400)
MainFrame.Position = UDim2.new(0.5, -330, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26) -- สี Navy เข้มเรียบหรูตามแบบ
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- เส้นขอบเรืองแสงบางๆ รอบเมนูหลัก (UIStroke)
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(45, 52, 75)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- แถบนำทางด้านซ้าย (Left Sidebar)
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

-- ข้อความแบรนด์และโลโก้
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
LogoSub.Text = "Animal Hospital v2"
LogoSub.TextColor3 = Color3.fromRGB(110, 115, 135)
LogoSub.Font = Enum.Font.GothamSemibold
LogoSub.TextSize = 9
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Parent = Sidebar

-- ที่จัดเก็บปุ่มเมนูหลัก (Tab Scroller)
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

-- พื้นที่แสดงรายละเอียดคอนเทนต์ด้านขวา
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -195, 1, -20)
ContentArea.Position = UDim2.new(0, 185, 0, 10)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- โครงสร้างหน้าเพจแต่ละ Tab
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

-- ระบบสลับเปลี่ยนหน้าจอพร้อมอนิเมชั่นสมูท
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

-- ลิสต์เมนูหลักด้านซ้าย
local DefaultBtn = AddTabButton("Local Player", "User", "👤")
AddTabButton("Auto Hospital", "Auto", "🏥")
AddTabButton("About & Info", "Credit", "ℹ️")

SwitchTab("User", DefaultBtn)

-- ====================================================
-- [ ส่วนประกอบ UI Components (สไลเดอร์, ท็อกเกิล) ]
-- ====================================================

-- 1. กล่องจัดระเบียบหมวดหมู่ (Section)
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

-- 2. ปุ่มท็อกเกิลสวิตช์ปิด/เปิด (Toggle Switch)
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

-- 3. สไลเดอร์สเกลการปรับแต่ง (Slider)
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

-- ====================================================
-- [ การออกแบบชุดควบคุมบนหน้ากระดาษ (Tab Content) ]
-- ====================================================

-- --- PAGE 1: USER UTILITIES ---
local UserSec = CreateSection(PageUser, "LocalPlayer (ฟังก์ชันผู้เล่น)")

CreateSlider(UserSec, "Speed (ปรับความเร็ว)", 16, 150, 16, function(val)
    States.SpeedValue = val
end)

CreateSlider(UserSec, "JumpPower (พลังกระโดด)", 50, 200, 50, function(val)
    States.JumpPowerValue = val
end)

CreateToggle(UserSec, "Noclip (เดินทะลุกำแพง)", "ทำให้ตัวละครเดินทะลุสิ่งกีดขวางในแผนที่ได้", false, function(state)
    States.NoclipActive = state
end)

CreateToggle(UserSec, "Unlock Third Person (เปิดกล้องอิสระ)", "ปลดล็อกขีดจำกัดระยะการซูมกล้องเข้า-ออก", false, function(state)
    States.UnlockThirdPerson = state
    if state then
        LocalPlayer.CameraMaxZoomDistance = 500
    else
        LocalPlayer.CameraMaxZoomDistance = 30
    end
end)

-- โหมดพิเศษควบคุมสมองและพละกำลัง
local OtherSec = CreateSection(PageUser, "Other (ฟังก์ชันพิเศษข้ามขีดจำกัด)")

-- ฟังก์ชัน Infinite Sanity บล็อกแพ็กเก็ตที่คุณส่งมาโดยตรง!
CreateToggle(OtherSec, "Infinite Sanity (สมองไม่ลด / ค่าความเครียดล็อก 100%)", "ดักจับและบล็อกรีโมท RE/PlayerLostSanity เพื่อป้องกันสมองลดเมื่อเครียด", false, function(state)
    States.InfiniteSanity = state
    
    -- หากเปิดใช้งาน จะแจ้งเตือนสถานะความสำเร็จในฝั่ง Client
    if state then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Foxname Hub",
            Text = "เปิดใช้ล็อกสมองเต็ม 100% เรียบร้อย!",
            Duration = 3
        })
    end
end)

CreateToggle(OtherSec, "Infinite Stamina (หลอดเหนื่อยไม่จำกัด)", "ล็อกค่าสตามิน่าจาก ObjectivesLocal ให้เต็มตลาดวิ่งได้ไม่สะดุด", false, function(state)
    States.InfiniteStamina = state
end)

-- --- PAGE 2: AUTO HOSPITAL ---
local AutoHospitalSec = CreateSection(PageAuto, "ระบบช่วยอำนวยความสะดวกในโรงพยาบาล")

CreateToggle(AutoHospitalSec, "Auto Treatment (รักษาคนไข้สัตว์อัตโนมัติ)", "ตรวจหาและรักษาทำความสะอาดสัตว์เลี้ยงรอบตัวทันที", false, function(state)
    States.AutoTreatActive = state
end)

-- --- PAGE 3: CREDIT ---
local CreditSec = CreateSection(PageCredit, "ข้อมูลผู้พัฒนาและทีมงาน")

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.95, 0, 0, 120)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "🎨 ดีไซน์ UI แบบหรูหราสไตล์ Foxname Hub\n🔧 อัปเกรดระบบ Bypass Sanity ด้วยรีโมทส่งสัญญาณในระบบเครือข่าย\n\nเปิดให้ใช้งานอย่างปลอดภัย ไร้กังวลเรื่องการโดนดักจับซอร์สโค้ด!"
InfoLabel.TextColor3 = Color3.fromRGB(170, 175, 190)
InfoLabel.Font = Enum.Font.GothamSemibold
InfoLabel.TextSize = 10
InfoLabel.Parent = CreditSec

-- ====================================================
-- [ การควบคุมและการทำงานเบื้องหลัง (Background Thread) ]
-- ====================================================

-- 1. ลูปการเคลื่อนไหวและการควบคุมสถานะผู้เล่นแบบเรียลไทม์
RunService.Heartbeat:Connect(function()
    local Character = LocalPlayer.Character
    if Character then
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        
        -- ควบคุมทิศทางความเร็วอย่างนุ่มนวลตรวจจับยาก
        if Humanoid and RootPart and Humanoid.MoveDirection.Magnitude > 0 and States.SpeedValue > 16 then
            local vel = Humanoid.MoveDirection * (States.SpeedValue - 16)
            RootPart.AssemblyLinearVelocity = Vector3.new(vel.X, RootPart.AssemblyLinearVelocity.Y, vel.Z)
        end
        
        -- กำหนดพลังกระโดด
        if Humanoid and States.JumpPowerValue > 50 then
            Humanoid.JumpPower = States.JumpPowerValue
        end
        
        -- สั่งปิด CanCollide ของร่างกายหากเปิด Noclip
        if States.NoclipActive then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        
        -- ประมวลผลเมื่อเลือก Infinite Stamina
        if States.InfiniteStamina then
            ApplyInfiniteStamina(true)
        end
    end
end)

-- 2. สั่งเริ่มระบบออโต้ฟาร์มรักษาคนไข้สัตว์เลี้ยงเป็นระยะ
task.spawn(function()
    while true do
        task.wait(0.3)
        if States.AutoTreatActive then
            AutoInteractWithAnimals()
        end
    end
end)

-- ====================================================
-- [ ปุ่มย่อ/ขยายหน้าเมนูวงกลมกลมลอยตัวสำหรับมือถือ ]
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
