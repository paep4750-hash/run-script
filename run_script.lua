--[[
    ====================================================================
    [!] PREMIUM FOXNAME HUB - ANIMAL HOSPITAL EDITION
    [!] DESIGN: Dark Navy Glassmorphism (Glassmorphic Glow, Smooth Tweens)
    [!] FEATURES: Infinite Stamina, Auto Interact/Treat, WalkSpeed & JumpPower
    ====================================================================
--]]

local Players = game:GetService("Players")
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
    InfiniteStamina = false,
    NoclipActive = false,
    UnlockThirdPerson = false,
    
    -- Auto Farming
    AutoTreatActive = false,
    AutoTasksActive = false
}

-- ====================================================
-- [ ฟังก์ชันระบบหลัก (Core Logic) ]
-- ====================================================

-- 1. ระบบ Infinite Stamina / Energy Bypass
local function ApplyInfiniteStamina(enabled)
    if not enabled then return end
    
    local Character = LocalPlayer.Character
    if Character then
        -- สแกนหาค่า Stamina หรือ Energy ในตัวละคร (Attributes)
        for _, attribute in ipairs({"Stamina", "Energy", "SprintEnergy", "Sanity"}) do
            if Character:GetAttribute(attribute) then
                Character:SetAttribute(attribute, 999999)
            end
        end
        
        -- ค้นหาโฟลเดอร์หรือ Value Object ที่อาจจะเก็บค่าความเหนื่อยล้า
        for _, val in ipairs(Character:GetDescendants()) do
            if val:IsA("NumberValue") or val:IsA("IntValue") then
                local name = val.Name:lower()
                if name:find("stamina") or name:find("energy") or name:find("sprint") then
                    val.Value = 100
                end
            end
        end
    end
    
    -- เจาะเข้าไปสแกนหาตัวแปร Stamina ใน ObjectivesLocal Script
    pcall(function()
        local objectivesScript = LocalPlayer.PlayerScripts.UI:FindFirstChild("ObjectivesLocal")
        if objectivesScript and getgc then
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" then
                    if rawget(v, "Stamina") or rawget(v, "stamina") then
                        v.Stamina = 100
                        v.stamina = 100
                    end
                    if rawget(v, "Energy") or rawget(v, "energy") then
                        v.Energy = 100
                        v.energy = 100
                    end
                end
            end
        end
    end)
end

-- 2. ระบบ Auto-Treat (ออโต้รักษาคนไข้สัตว์อัตโนมัติ)
local function AutoInteractWithAnimals()
    if not States.AutoTreatActive then return end
    
    -- สแกนหา ProximityPrompt ทั่วทุก Workspace และทำการรันคำสั่งกดปุ่ม (Interact) ทันที
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parent = prompt.Parent
            if parent and (parent.Name:lower():find("patient") or parent.Name:lower():find("animal") or parent.Name:lower():find("treat") or parent.Name:lower():find("pet")) then
                -- สั่งเปิดใช้งานปุ่มกดอัตโนมัติในทันที
                task.spawn(function()
                    fireproximityprompt(prompt)
                end)
            end
        end
    end
end

-- ====================================================
-- [ การสร้าง UI ระดับพรีเมียม (Glassmorphism Navy) ]
-- ====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FoxnameAnimalHospital_" .. tostring(math.random(1000, 9999))
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- เฟรมหลัก (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 660, 0, 400)
MainFrame.Position = UDim2.new(0.5, -330, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26) -- โทนน้ำเงินเข้มหรูหราตามแบบ
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

-- แถบเมนูด้านซ้าย (Sidebar)
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

-- ปิดมุมโค้งขวาของ Sidebar เพื่อให้เชื่อมต่อกับหน้าต่างหลัก
local CoverFrame = Instance.new("Frame")
CoverFrame.Size = UDim2.new(0, 15, 1, 0)
CoverFrame.Position = UDim2.new(1, -15, 0, 0)
CoverFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
CoverFrame.BackgroundTransparency = 0.2
CoverFrame.BorderSizePixel = 0
CoverFrame.Parent = Sidebar

-- โลโก้แบรนด์ Foxname Hub
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
LogoSub.Text = "Animal Hospital"
LogoSub.TextColor3 = Color3.fromRGB(110, 115, 135)
LogoSub.Font = Enum.Font.GothamSemibold
LogoSub.TextSize = 9
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Parent = Sidebar

-- คอนเทนเนอร์ปุ่มเลือก Tab (เลื่อนได้)
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

-- พื้นที่แสดงเนื้อหาด้านขวา
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -195, 1, -20)
ContentArea.Position = UDim2.new(0, 185, 0, 10)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- ตารางเก็บแต่ละหน้า
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

-- ====================================================
-- [ ระบบสลับ Tab อนิมิชัน ]
-- ====================================================
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

-- สร้างปุ่มเมนูตามแบบในภาพ
local DefaultBtn = AddTabButton("Local Player", "User", "👤")
AddTabButton("Auto Hospital", "Auto", "🏥")
AddTabButton("About & Info", "Credit", "ℹ️")

SwitchTab("User", DefaultBtn)

-- ====================================================
-- [ UI Components Creation (Foxname-Style Elements) ]
-- ====================================================

-- ส่วนที่ 1: กล่อง Section
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
    
    -- ปรับความสูงตามจำนวนลูกของมันแบบไดนามิก
    HolderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SectionFrame.Size = UDim2.new(0.95, 0, 0, HolderLayout.AbsoluteContentSize.Y + 42)
    end)
    
    return ContentHolder
end

-- ส่วนที่ 2: สวิตช์ปิด/เปิด (Toggle Switch)
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

-- ส่วนที่ 3: สไลเดอร์ความละเอียดสูง (Slider)
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
-- [ การออกแบบชุดฟังก์ชันลงบนหน้าเมนูหลัก ]
-- ====================================================

-- --- PAGE 1: LOCAL PLAYER UTILITIES ---
local LocalSec = CreateSection(PageUser, "LocalPlayer (ฟังก์ชันผู้เล่น)")

CreateSlider(LocalSec, "Speed (ปรับความเร็ว)", 16, 150, 16, function(val)
    States.SpeedValue = val
end)

CreateSlider(LocalSec, "JumpPower (พลังกระโดด)", 50, 200, 50, function(val)
    States.JumpPowerValue = val
end)

CreateToggle(LocalSec, "Noclip (เดินทะลุกำแพง)", "ทำให้ตัวละครเดินทะลุสิ่งกีดขวางได้", false, function(state)
    States.NoclipActive = state
end)

CreateToggle(LocalSec, "Unlock Third Person (เปิดกล้องอิสระ)", "ปลดล็อกโหมดมุมมองบุคคลที่สามและซูมกล้องไกลขึ้น", false, function(state)
    States.UnlockThirdPerson = state
    local Camera = workspace.CurrentCamera
    if Camera then
        if state then
            LocalPlayer.CameraMaxZoomDistance = 500
        else
            LocalPlayer.CameraMaxZoomDistance = 30
        end
    end
end)

local OtherSec = CreateSection(PageUser, "Other (ฟังก์ชันพิเศษสำหรับเซิร์ฟเวอร์)")

CreateToggle(OtherSec, "Infinite Stamina (หลอดพละกำลังไม่จำกัด)", "ล็อกค่าสตามิน่าจากตัว ObjectivesLocal ให้เต็มตลอดกาล", false, function(state)
    States.InfiniteStamina = state
end)

-- --- PAGE 2: AUTO HOSPITAL ---
local AutoHospitalSec = CreateSection(PageAuto, "ระบบช่วยอำนวยความสะดวกในโรงพยาบาลสัตว์")

CreateToggle(AutoHospitalSec, "Auto Treatment (รักษาคนไข้สัตว์ออโต้)", "ทำการตรวจรักษาและทำความสะอาดสัตว์เลี้ยงที่อยู่ใกล้เคียงทันที", false, function(state)
    States.AutoTreatActive = state
end)

-- --- PAGE 3: CREDIT ---
local CreditSec = CreateSection(PageCredit, "ข้อมูลผู้พัฒนาและทีมงาน")

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.95, 0, 0, 120)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "🎨 หน้าต่างดีไซน์พรีเมียมแบบ Foxname Hub\n🔧 ออกแบบเฉพาะสำหรับระบบรักษาคนไข้สัตว์ (Animal Hospital)\n\nปลดล็อกสิทธิ์ใช้งานฟรีสำหรับทุกคน!"
InfoLabel.TextColor3 = Color3.fromRGB(170, 175, 190)
InfoLabel.Font = Enum.Font.GothamSemibold
InfoLabel.TextSize = 10
InfoLabel.Parent = CreditSec

-- ====================================================
-
